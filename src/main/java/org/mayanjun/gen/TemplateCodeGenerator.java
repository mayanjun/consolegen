package org.mayanjun.gen;

import org.apache.commons.lang3.StringUtils;
import org.joda.time.DateTime;
import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.HashMap;
import java.util.Map;

/**
 * 基于模板的代码生成器
 * @author mayanjun
 * @date 2019-07-24
 */
public abstract class TemplateCodeGenerator implements CodeGenerator {

    public static final String [] PROJECT_FOLDERS = {
            "src/main/java",
            "src/main/resources/config",
            "src/main/resources/deploy",
            "src/main/resources/logback",
            "src/main/resources/static",
            "src/main/resources/templates",
    };

    private static final Logger LOG = LoggerFactory.getLogger(TemplateCodeGenerator.class);

    private final Status errorStatus = new Status(10000, "Generator code");

    private GeneratorContext context;

    public TemplateCodeGenerator(GeneratorContext context) {
        this.context = context;
    }

    protected GeneratorContext context() {
        return context;
    }

    protected Map<String, Object> rootMap() {
        ProjectConfig config = context.getProjectConfig();
        Map<String, Object> root = new HashMap<>();
        root.put("package_name", config.getPackageName());
        root.put("date", config.getDate());
        root.put("author", config.getAuthor());
        root.put("vendor", config.getVendor());
        root.put("generatorVersion", config.getGeneratorVersion());
        root.put("manufacturer", config.getManufacturer());
        root.put("vue_date_options_present", false);
        root.put("data_export_supported", false);
        root.put("secretKey", config.getSecretKey());
        return root;
    }

    protected String parseFieldType(String javaType, StringBuffer imports) {
        if (StringUtils.isBlank(javaType)) return "String";
        int dotIndex = javaType.lastIndexOf('.');
        if (dotIndex == 0 || dotIndex == javaType.length() - 1) {
            throw new ServiceException("Incorrect java type of field: {}", javaType);
        } else if (dotIndex < 0) {
            return javaType;
        } else { // package name found
            importClass(javaType, imports);
            return javaType.substring(dotIndex + 1);
        }
    }

    protected void importClass(String cls, StringBuffer imports) {
        imports.append("\nimport ").append(cls).append(";");
    }

    @Override
    public void generate() {
        try {
            execute();
        } catch (Exception e) {
            LOG.error("Generate error", e);
            throw new ServiceException(errorStatus, null, null, e);
        }
    }

    public abstract void execute() throws Exception;
}
