# By default, this configuration can be used directly in production environment
# Global Application Config
application:
  name: "@maven.project.name@"
  version: "@maven.project.version@"
  mavenProfile: "@maven.profile.name@"
  mavenProfileShortname: "@maven.profile.shortname@"

# Logging Config
logging:
  path: "@maven.profile.logpath@"
  file: "info"
  config: ${r'classpath:logback/logback-${spring.profiles.active:development}.xml'}

app-config:
  env: ${r'${spring.profiles.active::DEFAULT}'}
  domain: "${domain}"
  privateKey: "${privateKey}"
  publicKey: "${publicKey}"
  tokenCookieName: "${sessionCookieName}"
  systemName: "${systemName}"
  uploadDir: "${fileUploadDir}"
  midnight-task-cron: "0 30 0 * * ?"
  aesSecretKey: "${aesSecretKey}"
  aesIv: "${aesIv}"

spring:
  jackson:
    default-property-inclusion: non_null
    locale: zh_CN
    time-zone: GMT+8
    date-format: "yyyy-MM-dd'T'HH:mm:ss.SSS"
  servlet:
    multipart:
      max-file-size: "100MB"
      max-request-size: "100MB"
  mvc:
    locale: zh_CN

server:
  port: ${serverPort}


myjack:
  datasourceConfigs:
    - {
        jdbcUrl: "jdbc:mysql://${jdbcHost}/${jdbcDatabase}",
        mybatisConfigLocation: "classpath:/config/mybatis-config.xml",
        isolationLevelName: "ISOLATION_REPEATABLE_READ",
        username: "${jdbcUsername}",
        password: "${jdbcPassword}"
    }