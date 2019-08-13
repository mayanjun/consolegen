package org.mayanjun.gen;

import com.fasterxml.jackson.databind.ObjectMapper;
import freemarker.template.Configuration;
import freemarker.template.TemplateExceptionHandler;
import org.apache.commons.collections.CollectionUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.core.ServiceException;
import org.mayanjun.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.OrderComparator;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class GeneratorContext implements CodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(GeneratorContext.class);

    private ProjectConfig projectConfig;

    private String configPath;

    private File projectDir;

    private Configuration templateConfiguration;

    private String templatePath;

    private List<CodeGenerator> generators;

    public void addGenerator(CodeGenerator generator) {
        if (generator == null) throw new NullPointerException("Generator can not be null");
        generators.add(generator);
    }

    public GeneratorContext(String configLocation) {
        this.configPath = configLocation;
        this.generators = new ArrayList<>();
        parseConfig();
        validateConfig();
        try {
            init();
        } catch (Exception e) {
            LOG.error("Init error", e);
            throw new ServiceException("Init error");
        }

        // 前三个会生成基本系统
        addGenerator(new JavaProjectCodeGenerator(this));
        addGenerator(new JavaResourcesCodeGenerator(this));
        addGenerator(new JavaSystemManageCodeGenerator(this));

        // 生成用户配置的实体管理功能
        addGenerator(new JavaBeanCodeGenerator(this));
        addGenerator(new SystemInitializerCodeGenerator(this));
        addGenerator(new JavaBusinessCodeGenerator(this));
        addGenerator(new JavaControllerCodeGenerator(this));
        addGenerator(new ListPageCodeGenerator(this));
        addGenerator(new AddPageCodeGenerator(this));
    }

    /**
     * 校验Config
     */
    private synchronized void validateConfig() {
        Assert.notNull(projectConfig, "Config not found");
        projectConfig.validate(configPath);
    }

    private void init() throws Exception {
        templatePath = FileUtils.getRootPath() + "/templates";
        templateConfiguration = createTemplateConfiguration(templatePath);
        LOG.info("Create template root done");

        projectDir = new File(projectConfig.getOutDirFile(), projectConfig.getProjectName());
        if (! projectDir.exists()) projectDir.mkdirs();
    }

    private Configuration createTemplateConfiguration(String templatePath) throws Exception {
        Configuration cfg = new Configuration(Configuration.VERSION_2_3_28);
        cfg.setDirectoryForTemplateLoading(new File(templatePath));
        cfg.setDefaultEncoding("UTF-8");
        cfg.setTemplateExceptionHandler(TemplateExceptionHandler.RETHROW_HANDLER);
        cfg.setLogTemplateExceptions(false);
        cfg.setWrapUncheckedExceptions(true);
        cfg.setAutoFlush(true);
        cfg.setNumberFormat("#");
        return cfg;
    }


    private void parseConfig() {
        try {
            ObjectMapper mapper = new ObjectMapper();
            projectConfig = mapper.readValue(new File(configPath), ProjectConfig.class);
        } catch (IOException e) {
            LOG.error("Deserialize config error", e);
            throw new ServiceException("Deserialize config error");
        }
    }


    public ProjectConfig getProjectConfig() {
        return projectConfig;
    }

    public String getConfigPath() {
        return configPath;
    }

    public File getProjectDir() {
        return projectDir;
    }

    public Configuration getTemplateConfiguration() {
        return templateConfiguration;
    }

    public String getTemplatePath() {
        return templatePath;
    }

    @Override
    public void generate() {
        Assert.isTrue(projectConfig.isValidated(), "Config is not valid");
        // 准备代码生成系统所需的环境数据和矫正用户的配置信息

        if (CollectionUtils.isNotEmpty(generators)) {
            generators.sort(OrderComparator.INSTANCE);
            generators.forEach(e -> e.generate());
        }
    }

    @Override
    public int getOrder() {
        return 0;
    }
}
