package org.mayanjun.gen;

import freemarker.template.Configuration;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
import org.mayanjun.myjack.api.enums.DataType;
import org.mayanjun.util.JavaTypeUtils;
import org.mayanjun.util.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;

import static org.mayanjun.util.FileUtils.mkdirs;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class JavaBeanCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(JavaBeanCodeGenerator.class);

    public static final String DEFAULT_DATE_FORMAT_PATTERN = "yyyy-MM-dd HH:mm:ss";

    public JavaBeanCodeGenerator(GeneratorContext context) {
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
                    renderEntityBeanCode(e, root);
                } catch (Exception ex) {
                    throw new ServiceException(Status.INTERNAL_ERROR, "Generate entity code error", e.getClassName(), ex);
                }
            });
        }
        LOG.info("Java bean code generate done");
    }

    private void renderEntityBeanCode(EntityConfig entityConfig, Map<String, Object> root) throws Exception {
        // generate bean
        String entityName = entityConfig.getClassName();
        root.put("table_name", Strings.hump2Underline(entityName, "t"));
        root.put("fields", "");
        root.put("getters_and_setters", "");
        root.put("table_indexes", "");

        StringBuffer imports = new StringBuffer();

        // render fields
        renderFields(entityConfig, root, imports);

        root.put("imports", imports.toString());

        File targetDir = new File(context().getProjectDir(), PROJECT_FOLDERS[0] + "/" + context().getProjectConfig().getPackageName().replace('.', '/') + "/bean");
        mkdirs(targetDir);
        File targetFile = new File(targetDir, entityName + ".java");

        context().getTemplateConfiguration().getTemplate("java_entity_templates/bean.tpl").process(root, new OutputStreamWriter(new FileOutputStream(targetFile)));
    }

    /**
     * 渲染字段
     * @param entityConfig
     * @param root
     * @param imports
     */
    private void renderFields(EntityConfig entityConfig, Map<String, Object> root, final StringBuffer imports) {
        List<FieldConfig> fieldConfigs = entityConfig.getFieldConfigs();
        if (CollectionUtils.isNotEmpty(fieldConfigs)) {
            importClass("org.mayanjun.myjack.api.annotation.Column", imports);

            StringBuffer fieldCode = new StringBuffer();
            StringBuffer getterAndSetterCode = new StringBuffer();
            StringJoiner indexJoiner = new StringJoiner(",\n");

            fieldConfigs.forEach(f -> {
                renderFieldsCode(f, fieldCode, getterAndSetterCode, imports);
                String javaType = f.getJavaType();
                String fname = f.getName();

                // render html search
                if (f.isIndexed()) {
                    String index = String.format("@Index(value = \"%s\", columns = @IndexColumn(\"%s\"))", Strings.hump2Underline(fname, "idx"), fname);
                    indexJoiner.add(index);
                }
            });

            if (indexJoiner.length() > 0) {
                importClass("org.mayanjun.myjack.api.annotation.Index", imports);
                importClass("org.mayanjun.myjack.api.annotation.IndexColumn", imports);
                root.put("table_indexes", indexJoiner.toString());
            }

            root.put("fields", fieldCode);
            root.put("getters_and_setters", getterAndSetterCode);
        }
    }

    /**
     * 填充字段相关的代码块
     * @param f
     * @param fieldCode
     * @param getterAndSetterCode
     * @param imports
     * @return Wrapped type
     */
    private void renderFieldsCode(FieldConfig f, StringBuffer fieldCode, StringBuffer getterAndSetterCode, StringBuffer imports) {
        String javaType = f.getJavaType();
        String finalJavaType;

        if(JavaTypeUtils.isPrimitiveType(javaType)) {
            String length =  JavaTypeUtils.primitiveTypeDatabaseLength(javaType, f.getDatabaseLength());
            fieldCode.append(
                    String.format("\t@Column(comment = \"%s\", type = DataType.%s%s)\n",
                            f.getComment() == null ? "" : f.getComment(),
                            JavaTypeUtils.toDatabaseType(javaType),
                            StringUtils.isBlank(length) ? "" : ", length = \"" + length + "\""
                    )
            );
            finalJavaType = parseFieldType(JavaTypeUtils.toPrimitiveWrapper(javaType), imports);
        } else if (JavaTypeUtils.isDate(javaType)) {
            finalJavaType = parseFieldType(javaType, imports);

            String date_pattern = f.getPattern();
            if ("yyyy-MM-dd".equalsIgnoreCase(date_pattern)) {
                f.setDatabaseType(DataType.DATE);
                f.setFormatter("dateFormatter");
            } else if ("HH:mm:ss".equalsIgnoreCase(date_pattern)) {
                f.setDatabaseType(DataType.TIME);
                f.setFormatter("timeFormatter");
            } else {
                f.setPattern(DEFAULT_DATE_FORMAT_PATTERN);
                f.setDatabaseType(DataType.DATETIME);
                f.setFormatter("dateTimeFormatter");
            }

            importClass("com.fasterxml.jackson.annotation.JsonFormat", imports);
            fieldCode.append(
                    String.format("\t@JsonFormat(pattern = \"%s\")\n" +
                                    "\t@Column(comment = \"%s\", type = DataType.%s)\n",
                            f.getPattern(), f.getComment() == null ? "" : f.getComment(), f.getDatabaseType().name()
                    )
            );
        } else {
            finalJavaType = parseFieldType(javaType, imports);
            if (JavaTypeUtils.isEnmuType(f)) { // 如果给定了Enumeration值列表，则认为就是枚举类型
                finalJavaType = Strings.toClassName(javaType);
                f.setJavaType(finalJavaType);
                f.setDatabaseType(DataType.VARCHAR);
                generateEnumCode(f);
            }

            DataType type = f.getDatabaseType();
            if (type == null) type = DataType.VARCHAR;
            int length = JavaTypeUtils.nonPrimitiveTypeDatabaseLength(javaType, f.getDatabaseLength());

            if (f.getInputType() == InputType.FILE_ORDINARY || f.getInputType() == InputType.FILE_IMAGE) {
                if (length < 500) length = 500;
            }

            // render references type

            fieldCode.append(
                    String.format("\t@Column(comment = \"%s\", type = DataType.%s%s)\n",
                            f.getComment() == null ? "" : f.getComment(),
                            type.name(),
                            (", length = \"" + length + "\"")
                    )
            );
            f.setInputLength(length);
        }

        fieldCode.append(String.format("\tprivate %s %s;\n\n", finalJavaType, f.getName()));
        // generate getter and setters
        getterAndSetterCode.append(
                String.format("\n\tpublic %s %s() {\n" +
                        "\t\treturn this.%s;\n" +
                        "\t}\n", finalJavaType, Strings.toHump(f.getName(), "get"), f.getName())
        );

        getterAndSetterCode.append(
                String.format("\n\tpublic void %s(%s %s) {\n" +
                                "\t\tthis.%s = %s;\n" +
                                "\t}\n",
                        Strings.toHump(f.getName(), "set"),
                        finalJavaType,
                        f.getName(), f.getName(), f.getName())
        );

        f.setFinalJavaType(finalJavaType);
    }

    /**
     * 生成枚举代码
     * @param fieldConfig
     * @throws Exception
     */
    private void generateEnumCode(FieldConfig fieldConfig) {
        String values[] = fieldConfig.getEnumValues();
        StringJoiner valuesJoiner = new StringJoiner(",\n");
        int maxLength = 0;
        for (int i = 0; i < values.length; i+=2) {
            String value = values[i].toUpperCase();
            values[i] = value;
            if (value.length() > maxLength) maxLength = value.length();
            String val = "\t%s(\"%s\")";
            valuesJoiner.add(String.format(val, value, values[i + 1]));
        }
        if (maxLength < 32) {
            maxLength = 32;
        } else if (maxLength < 64) {
            maxLength = 64;
        }
        fieldConfig.setDatabaseLength(String.valueOf(maxLength));

        try {
            ProjectConfig config = context().getProjectConfig();
            // generate enum code
            Configuration cfg = context().getTemplateConfiguration();

            File targetDir = new File(context().getProjectDir(), PROJECT_FOLDERS[0] + "/" + config.getPackageName().replace('.', '/') + "/bean");
            mkdirs(targetDir);
            File targetFile = new File(targetDir, fieldConfig.getJavaType() + ".java");

            Map<String, Object> root = rootMap();
            root.put("class_name", fieldConfig.getJavaType());
            root.put("enum_values", valuesJoiner.toString());
            cfg.getTemplate("java_entity_templates/Enum.java.tpl").process(root, new OutputStreamWriter(new FileOutputStream(targetFile)));
        } catch (Exception e) {
            LOG.info("Generate enum error", e);
            throw  new ServiceException("Generate enum code error");
        }
    }

    @Override
    public int getOrder() {
        return GeneratorOrder.JAVA_BEAN_CODE_GENERATOR.ordinal();
    }
}
