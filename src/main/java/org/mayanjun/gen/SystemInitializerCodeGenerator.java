package org.mayanjun.gen;

import org.apache.commons.collections.CollectionUtils;
import org.joda.time.DateTime;
import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
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

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class SystemInitializerCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(SystemInitializerCodeGenerator.class);

    public SystemInitializerCodeGenerator(GeneratorContext context) {
        super(context);
    }

    @Override
    public void execute() throws Exception {
        ProjectConfig config = context().getProjectConfig();

        List<EntityConfig> configs = config.getEntityConfigs();
        if (CollectionUtils.isNotEmpty(configs)) {

            StringJoiner initMenuItemsJoiner = new StringJoiner(",\n", "\t\t\t", ",");
            configs.forEach(e -> {
                try {
                    initMenuItemsJoiner.add(
                            String.format("new String[]{\"0\", \"%s管理\", \"%s\", \"/pages/%s/list\"}",
                                    e.getComment(), e.getIcon(), Strings.toRequestMapping(e.getClassName()))
                    );
                } catch (Exception ex) {
                    throw new ServiceException(Status.INTERNAL_ERROR, "Generate entity code error", e.getClassName(), ex);
                }
            });
            renderDataInitializerCode(initMenuItemsJoiner);
        }
        LOG.info("System initializer code generate done");
    }

    /**
     * 生成系统初始化代码
     * @param initMenuItemsJoiner
     * @throws Exception
     */
    private void renderDataInitializerCode(StringJoiner initMenuItemsJoiner) throws Exception {
        ProjectConfig config = context().getProjectConfig();

        File targetDir = new File(context().getProjectDir(), PROJECT_FOLDERS[0] + "/" + config.getPackageName().replace('.', '/') + "/config");
        if (!targetDir.exists()) targetDir.mkdirs();
        File targetFile = new File(targetDir, "ApplicationDataInitializer.java");

        Map<String, Object> root = rootMap();
        root.put("packageName", config.getPackageName());
        root.put("entity_menu_items", initMenuItemsJoiner.toString());

        //cfg.getTemplate("business.tpl").process(root, new OutputStreamWriter(System.out));
        context().getTemplateConfiguration().getTemplate("java_entity_templates/ApplicationDataInitializer.java.tpl").process(root, new OutputStreamWriter(new FileOutputStream(targetFile)));
    }


    @Override
    public int getOrder() {
        return GeneratorOrder.JAVA_SYSTEM_INITIALIZER_CODE_GENERATOR.ordinal();
    }
}
