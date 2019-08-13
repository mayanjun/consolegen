package org.mayanjun.gen;

import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;
import java.util.function.Consumer;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class JavaSystemManageCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(JavaSystemManageCodeGenerator.class);

    public JavaSystemManageCodeGenerator(GeneratorContext context) {
        super(context);
    }

    @Override
    public void execute() throws Exception {
        GeneratorContext ctx = context();
        ProjectConfig config = ctx.getProjectConfig();

        File javaClassTemplateDir = new File(ctx.getTemplatePath() + "/java_class");
        File targetDir = new File(ctx.getProjectDir(),  "src/main/java/" + config.getPackageName().replace('.', '/'));

        travelAndRenderDir(javaClassTemplateDir, file -> {
            String absolutePath = file.getAbsolutePath();
            String classPath = absolutePath.substring(javaClassTemplateDir.getAbsolutePath().length() + 1);
            String tplPath = "java_class/" + classPath;
            File targetFile = new File(targetDir, classPath.substring(0, classPath.length() - 4));

            if (!targetFile.getParentFile().exists()) targetFile.getParentFile().mkdirs();

            try (Writer out = new OutputStreamWriter(new FileOutputStream(targetFile))) {
                ctx.getTemplateConfiguration().getTemplate(tplPath).process(config, out);
            } catch (Exception e) {
                throw new ServiceException(Status.INTERNAL_ERROR, "Merge java code tpl file error", tplPath, e);
            }
        });
        LOG.info("Java system manage code generate done");
    }

    private void travelAndRenderDir(File file, Consumer<File> consumer) {
        if (file.isFile()) {
            consumer.accept(file);
            return;
        } else {
            File []list = file.listFiles();
            for (File f : list) travelAndRenderDir(f, consumer);
        }
    }


    @Override
    public int getOrder() {
        return GeneratorOrder.JAVA_SYSTEM_MANAGE_CODE_GENERATOR.ordinal();
    }
}
