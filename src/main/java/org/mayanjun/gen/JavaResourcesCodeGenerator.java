package org.mayanjun.gen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.FileCopyUtils;
import org.springframework.util.FileSystemUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class JavaResourcesCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(JavaResourcesCodeGenerator.class);

    public JavaResourcesCodeGenerator(GeneratorContext context) {
        super(context);
    }

    @Override
    public void execute() throws Exception {
        GeneratorContext ctx = context();
        ProjectConfig config = ctx.getProjectConfig();

        // generate config files
        File javaConfigDir = new File(ctx.getProjectDir(), PROJECT_FOLDERS[1]);
        File javaTempConfigDir = new File(ctx.getTemplatePath() + "/java_resources_config");
        String list[] = javaTempConfigDir.list();
        for (String fn : list) {
            try (Writer out = new OutputStreamWriter(new FileOutputStream(new File(javaConfigDir, fn.substring(0, fn.length() - 4))))) {
                ctx.getTemplateConfiguration().getTemplate("java_resources_config/" + fn).process(config, out);
            }
        }

        // generate deploy files
        copyJavaResources(2, 5);

        // generate inc files
        File javaTemplateDir = new File(ctx.getProjectDir(), PROJECT_FOLDERS[5] + "/inc");
        File javaTemplateIncDir = new File(ctx.getTemplatePath() + "/java_resources_inc");
        for (String fn : javaTemplateIncDir.list()) {
            try (Writer out = new OutputStreamWriter(new FileOutputStream(new File(javaTemplateDir, fn.substring(0, fn.length() - 4))))) {
                ctx.getTemplateConfiguration().getTemplate("java_resources_inc/" + fn).process(config, out);
            }
        }
        LOG.info("Generate web resources done");
    }

    /**
     * 资源拷贝
     * @param start
     * @param end
     * @throws Exception
     */
    private void copyJavaResources(int start, int end) throws Exception {
        for (int i = start; i <= end; i++) {
            File javaDeployDir = new File(context().getProjectDir(), PROJECT_FOLDERS[i]);
            File javaTempDeployDir = new File(context().getTemplatePath() + "/java_resources_" + PROJECT_FOLDERS[i].substring(PROJECT_FOLDERS[i].lastIndexOf("/") + 1));
            for (String fn : javaTempDeployDir.list()) {
                File from = new File(javaTempDeployDir, fn);
                File to = new File(javaDeployDir, fn);
                if (from.isFile()) {
                    FileCopyUtils.copy(from, to);
                } else {
                    FileSystemUtils.copyRecursively(from, to);
                }
            }
        }
    }

    @Override
    public int getOrder() {
        return GeneratorOrder.JAVA_RESOURCES_CODE_GENERATOR.ordinal();
    }
}
