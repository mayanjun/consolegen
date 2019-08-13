package org.mayanjun.gen;

import org.apache.commons.collections.CollectionUtils;
import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
import org.mayanjun.util.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;

import static org.mayanjun.util.FileUtils.mkdirs;
import static org.mayanjun.util.JavaTypeUtils.isDate;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class JavaControllerCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(JavaControllerCodeGenerator.class);

    public JavaControllerCodeGenerator(GeneratorContext context) {
        super(context);
    }

    @Override
    public void execute() throws Exception {
        ProjectConfig config = context().getProjectConfig();

        List<EntityConfig> configs = config.getEntityConfigs();
        if (CollectionUtils.isNotEmpty(configs)) {
            Map<String, Object> root = rootMap();
            configs.forEach(e -> {
                try {
                    root.put("class_name", e.getClassName());
                    root.put("comment", e.getComment());
                    root.put("data_export_supported", e.isExportSupported());
                    renderController(e, root);
                    renderEntityControllerCode(e, root);
                } catch (Exception ex) {
                    throw new ServiceException(Status.INTERNAL_ERROR, "Generate entity code error", e.getClassName(), ex);
                }
            });
        }

        LOG.info("Java controller code generate done");
    }

    private void renderEntityControllerCode(EntityConfig entityConfig, Map<String, Object> root) throws Exception {
        File targetDir = new File(context().getProjectDir(), PROJECT_FOLDERS[0] + "/" + context().getProjectConfig().getPackageName().replace('.', '/') + "/controller/api");
        mkdirs(targetDir);
        File targetFile = new File(targetDir, entityConfig.getClassName() + "Controller.java");
        root.put("request_mapping", Strings.toRequestMapping(entityConfig.getClassName()));
        context().getTemplateConfiguration().getTemplate("java_entity_templates/controller.tpl").process(root, new OutputStreamWriter(new FileOutputStream(targetFile)));
    }

    private void renderController(EntityConfig entityConfig, Map<String, Object> root) {
        List<FieldConfig> fieldConfigs = entityConfig.getFieldConfigs();
        if (CollectionUtils.isNotEmpty(fieldConfigs)) {

            StringJoiner controllerSearchParamsJoiner = new StringJoiner(",\n");
            StringBuffer controllerImports = new StringBuffer();
            StringJoiner controllerParamsBuilderJoiner = new StringJoiner("\n");

            fieldConfigs.forEach(f -> {
                String fname = f.getName();
                String finalJavaType = f.getFinalJavaType();

                // render html search
                if (f.isIndexed()) {
                    String pattern = f.getPattern();
                    // render params
                    parseFieldType(f.getJavaType(), controllerImports);

                    if (isDate(f.getJavaType())) {
                        importClass("org.springframework.format.annotation.DateTimeFormat", controllerImports);
                        String params0 = String.format("@RequestParam(required = false) @DateTimeFormat(pattern = \"%s\") %s s%s", pattern, finalJavaType, fname + "0");
                        String params1 = String.format("@RequestParam(required = false) @DateTimeFormat(pattern = \"%s\") %s s%s", pattern, finalJavaType, fname + "1");
                        root.put("vue_date_options_present", true);
                        controllerSearchParamsJoiner.add(params0);
                        controllerSearchParamsJoiner.add(params1);
                        String code = " if (s%s0 != null && s%s1 != null) {\n" +
                                "            pb.add(\"__>=__day\", s%s0);\n" +
                                "            pb.add(\"__<=__day\", s%s1);\n" +
                                "        }";
                        String scode = String.format(code, fname, fname, fname, fname);
                        controllerParamsBuilderJoiner.add(scode);
                    } else {
                        String params = String.format("@RequestParam(required = false) %s s%s", finalJavaType, f.getName());
                        controllerSearchParamsJoiner.add(params);
                        controllerParamsBuilderJoiner.add(String.format("pb.add(\"%s\", s%s);", f.getName(), f.getName()));
                    }
                }
            });


            if (controllerSearchParamsJoiner.length() > 0) {
                root.put("controller_imports", controllerImports);
                root.put("controller_search_params", ", " + controllerSearchParamsJoiner.toString());
            }

            if (controllerParamsBuilderJoiner.length() > 0) {
                root.put("controller_params_builder", controllerParamsBuilderJoiner.toString());
            }
        }
    }


    @Override
    public int getOrder() {
        return GeneratorOrder.JAVA_CONTROLLER_CODE_GENERATOR.ordinal();
    }
}
