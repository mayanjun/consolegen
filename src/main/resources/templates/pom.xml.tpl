<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
    <modelVersion>4.0.0</modelVersion>

    <groupId>${groupId}</groupId>
    <artifactId>${projectName}</artifactId>
    <version>${version}</version>

    <parent>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-parent</artifactId>
        <version>2.1.5.RELEASE</version>
    </parent>

    <packaging>jar</packaging>

    <developers>
        <developer>
            <id>mayanjun3</id>
            <email>mayanjun@jd.com</email>
        </developer>
    </developers>

    <properties>
        <java.version>1.8</java.version>
    </properties>

    <dependencies>

        <dependency>
            <groupId>org.apache.poi</groupId>
            <artifactId>poi-ooxml</artifactId>
            <version>3.17</version>
        </dependency>

        <dependency>
            <groupId>com.fasterxml.jackson.core</groupId>
            <artifactId>jackson-databind</artifactId>
            <version>2.9.9</version>
        </dependency>

        <dependency>
            <groupId>com.squareup.okhttp3</groupId>
            <artifactId>okhttp</artifactId>
            <version>3.11.0</version>
        </dependency>

        <dependency>
            <groupId>org.mayanjun</groupId>
            <artifactId>myjack-starter</artifactId>
            <version>0.0.2.RELEASE</version>
            <exclusions>
                <exclusion>
                    <groupId>com.fasterxml.jackson.core</groupId>
                    <artifactId>jackson-databind</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

        <dependency>
            <groupId>org.mayanjun</groupId>
            <artifactId>myrest</artifactId>
            <version>0.0.1.RELEASE</version>
            <exclusions>
                <exclusion>
                    <groupId>com.fasterxml.jackson.core</groupId>
                    <artifactId>jackson-databind</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

        <!--Spring-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-web</artifactId>
            <exclusions>
                <exclusion>
                    <groupId>org.springframework.boot</groupId>
                    <artifactId>spring-boot-starter-tomcat</artifactId>
                </exclusion>
                <exclusion>
                    <groupId>com.fasterxml.jackson.core</groupId>
                    <artifactId>jackson-databind</artifactId>
                </exclusion>
            </exclusions>
        </dependency>

        <!--Uses undertow server instead of Tomcat-->
        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-undertow</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-configuration-processor</artifactId>
            <optional>true</optional>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-test</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-freemarker</artifactId>
        </dependency>

        <dependency>
            <groupId>org.springframework.boot</groupId>
            <artifactId>spring-boot-starter-aop</artifactId>
        </dependency>

        <dependency>
            <groupId>joda-time</groupId>
            <artifactId>joda-time</artifactId>
            <version>2.9.9</version>
        </dependency>

        <!--Apache Commons-->
        <dependency>
            <groupId>commons-codec</groupId>
            <artifactId>commons-codec</artifactId>
            <version>1.10</version>
        </dependency>

        <dependency>
            <groupId>commons-beanutils</groupId>
            <artifactId>commons-beanutils</artifactId>
            <version>1.9.3</version>
        </dependency>

        <dependency>
            <groupId>commons-collections</groupId>
            <artifactId>commons-collections</artifactId>
            <version>3.2.2</version>
        </dependency>

        <dependency>
            <groupId>com.belerweb</groupId>
            <artifactId>pinyin4j</artifactId>
            <version>2.5.0</version>
        </dependency>

    </dependencies>

    <build>
        <plugins>
            <plugin>
                <groupId>org.springframework.boot</groupId>
                <artifactId>spring-boot-maven-plugin</artifactId>
            </plugin>
            <plugin>
                <artifactId>maven-resources-plugin</artifactId>
                <version>3.0.2</version>
                <executions>
                    <execution>
                        <id>copy-deploy</id>
                        <phase>validate</phase>
                        <goals>
                            <goal>copy-resources</goal>
                        </goals>
                        <configuration>
                            <outputDirectory>${r'${basedir}'}/target/bin</outputDirectory>
                            <resources>
                                <resource>
                                    <directory>src/main/resources/deploy</directory>
                                    <filtering>true</filtering>
                                </resource>
                            </resources>
                        </configuration>
                    </execution>
                </executions>
            </plugin>
        </plugins>
    </build>

    <profiles>
        <profile>
            <id>development</id>
            <properties>
                <maven.profile.name>development</maven.profile.name>
                <maven.profile.shortname>DEV</maven.profile.shortname>

                <maven.project.name>${r'${project.artifactId}'}</maven.project.name>
                <maven.project.version>${r'${project.version}'}</maven.project.version>
                <maven.profile.javabin>/usr/bin/java</maven.profile.javabin>
                <maven.profile.logpath>/export/Logs/${r'${project.artifactId}'}</maven.profile.logpath>

                <maven.profile.javaopts>-server -Dfile.encoding=utf-8 -Xms1024m -Xmx1024m -XX:MaxMetaspaceSize=256m -XX:+UnlockExperimentalVMOptions -Djava.awt.headless=true -Dsun.net.client.defaultConnectTimeout=60000 -Dsun.net.client.defaultReadTimeout=60000 -Djmagick.systemclassloader=no -Dnetworkaddress.cache.ttl=300 -Dsun.net.inetaddr.ttl=300 -XX:+HeapDumpOnOutOfMemoryError</maven.profile.javaopts>
            </properties>
            <activation>
                <activeByDefault>true</activeByDefault>
            </activation>
        </profile>
        <profile>
            <id>test</id>
            <properties>
                <maven.profile.name>test</maven.profile.name>
                <maven.profile.shortname>TEST</maven.profile.shortname>

                <maven.project.name>${r'${project.artifactId}'}</maven.project.name>
                <maven.project.version>${r'${project.version}'}</maven.project.version>
                <maven.profile.javabin>/usr/bin/java</maven.profile.javabin>
                <maven.profile.logpath>/export/Logs/${r'${project.artifactId}'}</maven.profile.logpath>

                <maven.profile.javaopts>-server -Dfile.encoding=utf-8 -Xms1024m -Xmx1024m -XX:MaxMetaspaceSize=256m -XX:+UnlockExperimentalVMOptions -Djava.awt.headless=true -Dsun.net.client.defaultConnectTimeout=60000 -Dsun.net.client.defaultReadTimeout=60000 -Djmagick.systemclassloader=no -Dnetworkaddress.cache.ttl=300 -Dsun.net.inetaddr.ttl=300 -XX:+HeapDumpOnOutOfMemoryError</maven.profile.javaopts>
            </properties>
        </profile>
        <profile>
            <id>production</id>
            <properties>
                <maven.profile.name>production</maven.profile.name>
                <maven.profile.shortname>PRO</maven.profile.shortname>

                <maven.project.name>${r'${project.artifactId}'}</maven.project.name>
                <maven.project.version>${r'${project.version}'}</maven.project.version>
                <maven.profile.javabin>/usr/bin/java</maven.profile.javabin>
                <maven.profile.logpath>/export/Logs/${r'${project.artifactId}'}</maven.profile.logpath>

                <maven.profile.javaopts>-server -Dmy.config=$APP_DIR/app.properties -Dfile.encoding=utf-8 -Xms4096m -Xmx4096m -XX:MaxMetaspaceSize=512m -XX:+UnlockExperimentalVMOptions -Djava.awt.headless=true -Dsun.net.client.defaultConnectTimeout=60000 -Dsun.net.client.defaultReadTimeout=60000 -Djmagick.systemclassloader=no -Dnetworkaddress.cache.ttl=300 -Dsun.net.inetaddr.ttl=300 -XX:+HeapDumpOnOutOfMemoryError</maven.profile.javaopts>
            </properties>
        </profile>

        <profile>
            <id>prerelease</id>
            <properties>
                <maven.profile.name>prerelease</maven.profile.name>
                <maven.profile.shortname>PRE</maven.profile.shortname>

                <maven.project.name>${r'${project.artifactId}'}</maven.project.name>
                <maven.project.version>${r'${project.version}'}</maven.project.version>
                <maven.profile.javabin>/usr/bin/java</maven.profile.javabin>
                <maven.profile.logpath>/export/Logs/${r'${project.artifactId}'}</maven.profile.logpath>

                <maven.profile.javaopts>-server -Dmy.config=$APP_DIR/app.properties -Dfile.encoding=utf-8 -Xms4096m -Xmx4096m -XX:MaxMetaspaceSize=512m -XX:+UnlockExperimentalVMOptions -Djava.awt.headless=true -Dsun.net.client.defaultConnectTimeout=60000 -Dsun.net.client.defaultReadTimeout=60000 -Djmagick.systemclassloader=no -Dnetworkaddress.cache.ttl=300 -Dsun.net.inetaddr.ttl=300 -XX:+HeapDumpOnOutOfMemoryError</maven.profile.javaopts>
            </properties>
        </profile>
    </profiles>
</project>
