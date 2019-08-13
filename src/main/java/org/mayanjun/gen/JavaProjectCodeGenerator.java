package org.mayanjun.gen;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.FileSystemUtils;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.io.Writer;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class JavaProjectCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(JavaProjectCodeGenerator.class);

    public JavaProjectCodeGenerator(GeneratorContext context) {
        super(context);
    }

    @Override
    public void execute() throws Exception {
        ProjectConfig config = context().getProjectConfig();

        File distFile = config.getOutDirFile();
        if (distFile.exists()) {
            FileSystemUtils.deleteRecursively(distFile);
        }

        // generate project folder
        for (String dir : PROJECT_FOLDERS) {
            mkdirs(dir);
        }

        // mk java packages
        mkdirs(PROJECT_FOLDERS[0] + "/" + config.getPackageName().replace('.', '/'));

        // generate java pom file
        try (Writer out = new OutputStreamWriter(new FileOutputStream(new File(context().getProjectDir(), "pom.xml")))) {
            context().getTemplateConfiguration().getTemplate("pom.xml.tpl").process(config, out);
        }
        LOG.info("Generate java project done");
    }

    private void mkdirs(String dir) {
        File dirFile = new File(context().getProjectDir(), dir);
        if (! dirFile.exists()) dirFile.mkdirs();
    }

    @Override
    public int getOrder() {
        return GeneratorOrder.JAVA_PROJECT_CODE_GENERATOR.ordinal();
    }
}
