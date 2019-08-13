package ${packageName};

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.EnableAspectJAutoProxy;
import org.springframework.context.annotation.ImportResource;
import org.springframework.scheduling.annotation.EnableAsync;
import org.springframework.scheduling.annotation.EnableScheduling;
import sun.misc.Signal;

import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.concurrent.CountDownLatch;

/**
 *
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@EnableAsync
@EnableScheduling
@SpringBootApplication(exclude = {DataSourceAutoConfiguration.class})
@EnableAspectJAutoProxy(proxyTargetClass = true)
@ImportResource({"classpath:config/spring.xml"})
public class Application implements InitializingBean {

    public static final String APP_BUILD_VERSION = "2019.1036";

    private static final Logger LOG = LoggerFactory.getLogger(Application.class);
    private static final CountDownLatch LATCH = new CountDownLatch(1);
    private static final String SHUTDOWN_SIGNAL = "USR2";

    public static void main(String[] args) throws Exception {
        List<String> argsList = new ArrayList<>(Arrays.asList(args));
        String joneConfig = System.getProperty("my.config");

        List<String> myConfigStrings = new ArrayList<>();
        if(StringUtils.isNotBlank(joneConfig)) {
            File configFile = new File(joneConfig);

            if (configFile.exists()) {
                Properties properties = new Properties();
                properties.load(new FileReader(configFile));
                properties.stringPropertyNames().stream().forEach(
                        e -> {
                            String conf = "--" + e + "=" + properties.getProperty(e);
                            myConfigStrings.add(conf);
                            argsList.add(conf);
                        }
                );
            }
        } else {
            LOG.info("No JONE config specified");
        }

        String[] realArgs = new String[argsList.size()];
        argsList.toArray(realArgs);

        registerShutdownHook();
        ConfigurableApplicationContext context = new SpringApplicationBuilder()
                .sources(Application.class)
                .run(realArgs);
        printConfigLog(myConfigStrings);
        LOG.info("APPLICATION STARTED!!");
        LATCH.await();
        LOG.info("Shutting down application...");
        context.close();
        LOG.info("Application is closed successfully");
    }

    private static void printConfigLog(List<String> joneConfigStrings) {
        if(CollectionUtils.isEmpty(joneConfigStrings)) {
            LOG.info("No CUSTOM config found");
        } else {
            LOG.info("----------- USING CUSTOM CONFIG -----------");
            joneConfigStrings.stream().forEach(e -> LOG.info(e));
        }
    }

    private static void registerShutdownHook() {
        String osname = System.getProperty("os.name");
        LOG.info("Operation System Name:: {}", osname);
        if (osname != null) {
            if (osname.toLowerCase().indexOf("windows") >= 0) {
                System.setProperty("USER", System.getenv("USERNAME"));
                LOG.info("Windows system can not register signal");
            } else {
                Signal.handle(new Signal(SHUTDOWN_SIGNAL), (Signal s) -> {
                    LOG.info("Signal {} received, system will shutdown", s.getName());
                    LATCH.countDown();
                });
            }
        }
    }

    ${r'@Value("${application.name}")'}
    private String name;

    ${r'@Value("${application.version}")'}
    private String version;

    ${r'@Value("${application.mavenProfile}")'}
    private String mavenProfile;

    ${r'@Value("${spring.profiles.active:development}")'}
    private String springProfile;

    @Override
    public void afterPropertiesSet() throws Exception {
        LOG.info("\n" +
                        "=========================================================================\n" +
                        ":: Application Name: {}\n" +
                        ":: Application Version: {}\n" +
                        ":: Maven Profile/SpringBoot Profile: {}/{}\n" +
                        "=========================================================================\n",
                name, version, mavenProfile, springProfile);
    }
}
