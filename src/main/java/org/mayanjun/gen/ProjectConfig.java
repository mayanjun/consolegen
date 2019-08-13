package org.mayanjun.gen;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.joda.time.DateTime;
import org.mayanjun.core.ServiceException;
import org.mayanjun.util.ConfigVerifier;
import org.mayanjun.util.FileUtils;
import org.mayanjun.util.Strings;

import java.io.File;
import java.security.KeyPair;
import java.security.KeyPairGenerator;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.security.interfaces.RSAPrivateKey;
import java.security.interfaces.RSAPublicKey;
import java.util.List;

/**
 * @author mayanjun
 * @date 2019-07-17
 */
public class ProjectConfig implements ValidateConfig {

    private File outDirFile;

    @Configurable(comment = "项目的输出目录，如果不配置则会在配置文件所在的文件夹生成项目")
    private String outDir;

    @Configurable(comment = "英文项目名称", defaultValue = "new-project")
    private String projectName = "new-project";

    @Configurable(comment = "后台要显示的系统名称", defaultValue = "后台管理系统")
    private String systemName = "后台管理系统";

    @Configurable(comment = "用于在页脚生成公司名字")
    private String companyName = "";

    @Configurable(comment = "用于在页脚生成的一句话标语", defaultValue = "打造智能系统")
    private String slogan = "打造智能系统";

    private String configFileLocation;

    private volatile boolean validated = false;

    @Configurable(comment = "实体列表配置：参见【EntityConfig 配置】")
    private List<EntityConfig> entityConfigs;

    @Configurable(comment = "项目包名，用于生成POM文件", defaultValue = "org.mayanjun.project")
    private String packageName = "org.mayanjun.project";

    @Configurable(comment = "项目组名，用于生成POM文件", defaultValue = "org.mayanjun")
    private String groupId = "org.mayanjun";

    @Configurable(comment = "项目版本，用于生成POM文件", defaultValue = "0.0.1-SNAPSHOT")
    private String version = "0.0.1-SNAPSHOT";

    @Configurable(comment = "项目域名，用于访问后台的域名", defaultValue = "m.com")
    private String domain = "m.com";

    private String privateKey;

    private String publicKey;

    @Configurable(comment = "登录验证系统的Cookie名称", defaultValue = "token")
    private String sessionCookieName = "token";

    @Configurable(comment = "上传的文件保存文件夹", defaultValue = "/export/data/upload")
    private String fileUploadDir = "/export/data/upload";

    @Configurable(comment = "JDBC主机IP和端口号", defaultValue = "127.0.0.1:3306")
    private String jdbcHost = "127.0.0.1:3306";

    @Configurable(comment = "数据库用户名", defaultValue = "root")
    private String jdbcUsername = "root";

    @Configurable(comment = "数据库密码", defaultValue = "123456")
    private String jdbcPassword = "123456";

    @Configurable(comment = "数据库名称", defaultValue = "mydb")
    private String jdbcDatabase = "mydb";

    @Configurable(comment = "服务器端口", defaultValue = "8080")
    private int serverPort = 8080;

    @Configurable(comment = "代码作者信息", defaultValue = "mayanjun")
    private String author = "mayanjun";

    @Configurable(comment = "系统提供商", defaultValue = "mayanjun.org")
    private String vendor = "mayanjun.org";

    private String generatorVersion = "consolegen 1.0";

    private String manufacturer = "https://mayanjun.org";

    private String secretKey = Strings.generateSecretKey(32);

    private String date = DateTime.now().toString("yyyy-MM-dd");

    public synchronized void validate(String configFileLocation) {
        this.configFileLocation = configFileLocation;
        if (!validated) validate();
    }

    public boolean validate() {
        if (StringUtils.isBlank(groupId)) groupId = packageName;

        ConfigVerifier.verify(this);

        File parent;
        if (StringUtils.isNotBlank(outDir)) {
            parent = new File(outDir);
            FileUtils.mkdirs(parent);
        } else {
            parent = new File(configFileLocation).getParentFile();
        }

        outDirFile = new File(parent,"dist");
        if (CollectionUtils.isNotEmpty(entityConfigs)) {
            entityConfigs.forEach(e -> e.validate());
        }

        // 生成密钥
        generateKeys();

        validated = true;
        return validated;
    }


    public void generateKeys() {
        KeyPairGenerator keygen = null;
        try {
            keygen = KeyPairGenerator.getInstance("RSA");
        } catch (NoSuchAlgorithmException var7) {
            throw new ServiceException("");
        }
        SecureRandom random = new SecureRandom();
        keygen.initialize(1024, random);
        KeyPair kp = keygen.generateKeyPair();
        RSAPrivateKey privateKey = (RSAPrivateKey)kp.getPrivate();
        String privateKeyString = Base64.encodeBase64String(privateKey.getEncoded());
        RSAPublicKey publicKey = (RSAPublicKey)kp.getPublic();
        String publicKeyString = Base64.encodeBase64String(publicKey.getEncoded());
        this.privateKey = privateKeyString;
        this.publicKey = publicKeyString;
    }


    public boolean isValidated() {
        return validated;
    }

    public File getOutDirFile() {
        return outDirFile;
    }

    public String getConfigFileLocation() {
        return configFileLocation;
    }

    public String getProjectName() {
        return projectName;
    }

    public void setProjectName(String projectName) {
        this.projectName = projectName;
    }

    public String getSystemName() {
        return systemName;
    }

    public void setSystemName(String systemName) {
        this.systemName = systemName;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getSlogan() {
        return slogan;
    }

    public void setSlogan(String slogan) {
        this.slogan = slogan;
    }

    public List<EntityConfig> getEntityConfigs() {
        return entityConfigs;
    }

    public void setEntityConfigs(List<EntityConfig> entityConfigs) {
        this.entityConfigs = entityConfigs;
    }

    public String getPackageName() {
        return packageName;
    }

    public void setPackageName(String packageName) {
        this.packageName = packageName;
    }

    public String getDomain() {
        return domain;
    }

    public void setDomain(String domain) {
        this.domain = domain;
    }

    public String getGroupId() {
        return groupId;
    }

    public void setGroupId(String groupId) {
        this.groupId = groupId;
    }

    public String getVersion() {
        return version;
    }

    public void setVersion(String version) {
        this.version = version;
    }

    public String getPrivateKey() {
        return privateKey;
    }

    public String getPublicKey() {
        return publicKey;
    }

    public String getSessionCookieName() {
        return sessionCookieName;
    }

    public void setSessionCookieName(String sessionCookieName) {
        this.sessionCookieName = sessionCookieName;
    }

    public String getFileUploadDir() {
        return fileUploadDir;
    }

    public void setFileUploadDir(String fileUploadDir) {
        this.fileUploadDir = fileUploadDir;
    }

    public String getJdbcHost() {
        return jdbcHost;
    }

    public void setJdbcHost(String jdbcHost) {
        this.jdbcHost = jdbcHost;
    }

    public String getJdbcUsername() {
        return jdbcUsername;
    }

    public void setJdbcUsername(String jdbcUsername) {
        this.jdbcUsername = jdbcUsername;
    }

    public String getJdbcPassword() {
        return jdbcPassword;
    }

    public void setJdbcPassword(String jdbcPassword) {
        this.jdbcPassword = jdbcPassword;
    }

    public String getJdbcDatabase() {
        return jdbcDatabase;
    }

    public void setJdbcDatabase(String jdbcDatabase) {
        this.jdbcDatabase = jdbcDatabase;
    }

    public int getServerPort() {
        return serverPort;
    }

    public void setServerPort(int serverPort) {
        this.serverPort = serverPort;
    }

    public String getAuthor() {
        return author;
    }

    public String getVendor() {
        return vendor;
    }

    public String getGeneratorVersion() {
        return generatorVersion;
    }

    public void setAuthor(String author) {
        this.author = author;
    }

    public String getManufacturer() {
        return manufacturer;
    }

    public void setVendor(String vendor) {
        this.vendor = vendor;
    }

    public String getDate() {
        return date;
    }

    public String getSecretKey() {
        return secretKey;
    }

    public String getOutDir() {
        return outDir;
    }

    public void setOutDir(String outDir) {
        this.outDir = outDir;
    }
}
