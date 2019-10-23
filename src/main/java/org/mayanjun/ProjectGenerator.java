package org.mayanjun;

import org.mayanjun.gen.CodeGenerator;
import org.mayanjun.gen.GeneratorContext;
import org.mayanjun.util.FileUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * @author mayanjun
 * @date 2019-07-17
 */
public class ProjectGenerator implements CodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(ProjectGenerator.class);

    public static void main(String[] args) {
        String demoFile = "/Users/mayanjun/Desktop/demo.json";
        ProjectGenerator gen = new ProjectGenerator(demoFile);
        gen.generate();
    }

    private GeneratorContext context;

    public ProjectGenerator(String configLocation) {
        context = new GeneratorContext(configLocation);
    }

    /**
     * 生成项目
     */
    @Override
    public void generate() {
        long now = System.currentTimeMillis();
        context.generate();
        LOG.info("Generate project finished in {} milliseconds", System.currentTimeMillis() - now);
    }

    @Override
    public int getOrder() {
        return 0;
    }
}
