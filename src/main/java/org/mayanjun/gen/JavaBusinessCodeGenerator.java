package org.mayanjun.gen;

import org.apache.commons.collections.CollectionUtils;
import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.List;
import java.util.Map;

import static org.mayanjun.util.FileUtils.mkdirs;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class JavaBusinessCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(JavaBusinessCodeGenerator.class);

    public JavaBusinessCodeGenerator(GeneratorContext context) {
        super(context);
    }

    @Override
    public void execute() throws Exception {
        File targetDir = new File(context().getProjectDir(), PROJECT_FOLDERS[0] + "/" + context().getProjectConfig().getPackageName().replace('.', '/') + "/business");
        mkdirs(targetDir);

        List<EntityConfig> configs = context().getProjectConfig().getEntityConfigs();
        if (CollectionUtils.isNotEmpty(configs)) {
            Map<String, Object> root = rootMap();
            configs.forEach(e -> {
                try {
                    root.put("comment", e.getComment());
                    root.put("class_name", e.getClassName());
                    root.put("data_export_supported", e.isExportSupported());
                    File targetFile = new File(targetDir, e.getClassName() + "Business.java");
                    context().getTemplateConfiguration().getTemplate("java_entity_templates/business.tpl").process(root, new OutputStreamWriter(new FileOutputStream(targetFile)));
                } catch (Exception ex) {
                    throw new ServiceException(Status.INTERNAL_ERROR, "Generate entity code error", e.getClassName(), ex);
                }
            });
        }

        LOG.info("Java business code generate done");
    }

    @Override
    public int getOrder() {
        return GeneratorOrder.JAVA_BUSINESS_CODE_GENERATOR.ordinal();
    }
}
