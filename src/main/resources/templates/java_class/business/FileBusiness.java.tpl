package ${packageName}.business;

import ${packageName}.bean.FileMeta;
import ${packageName}.config.AppConfig;
import ${packageName}.util.MimeUtils;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.myjack.IdWorker;
import org.mayanjun.myjack.dao.BasicDAO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.FileCopyUtils;
import org.springframework.web.multipart.MultipartFile;

import javax.servlet.http.HttpServletResponse;
import java.io.*;

import static ${packageName}.StatusCode.FILE_ALREADY_EXISTS;

/**
 * 文件管理
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class FileBusiness implements InitializingBean {

    private static final Logger LOG = LoggerFactory.getLogger(FileBusiness.class);

    public static final String BUCKET_NAME = "bucket";

    @Autowired
    private AppConfig config;

    @Autowired
    private IdWorker idWorker;

    private File dirFile;

    private File clientDirFile;

    @Autowired
    private BasicDAO dao;


    private File dir(String fileName) {
        int code = Math.abs(fileName.toLowerCase().hashCode());
        int mod = code % 1000;
        File dir = new File(dirFile, BUCKET_NAME + "_" + mod);
        if (!dir.exists()) dir.mkdirs();
        return dir;
    }

    /**
     * 上传文件
     * @param fileName 标准的文件名
     * @param inputStream 文件输入流
     * @return
     * @throws Exception
     */
    public String upload(String fileName, InputStream inputStream, String tag) throws Exception {
        File outFile = new File(dir(fileName), fileName);
        int size = FileCopyUtils.copy(inputStream, new FileOutputStream(outFile));
        LOG.info("File upload done: size={}, copied={}", fileName, size);
        saveFileMeta(outFile, tag);
        return toURL(fileName);
    }

    /**
     * 上传来自网页多媒体的文件
     * @param file 多媒体文件
     * @return 文件下载地址
     * @throws Exception
     */
    public String upload(MultipartFile file, String tag) throws Exception {
        Assert.isTrue(file != null && !file.isEmpty(), "文件为空");
        String newFileName = createNewFileName(file.getOriginalFilename());

        File outFile = localFile(newFileName);
        int size = FileCopyUtils.copy(file.getInputStream(), new FileOutputStream(outFile));
        LOG.info("File upload done: file={}, size={}, copied={}", newFileName, file.getSize(), size);
        saveFileMeta(outFile, tag);
        return toURL(newFileName);
    }

    public void uploadForClient(MultipartFile file, String tag) throws Exception {
        Assert.isTrue(file != null && !file.isEmpty(), "文件为空");
        File outFile = new File(clientDirFile, file.getOriginalFilename());

        Assert.isFalse(outFile.exists(), FILE_ALREADY_EXISTS);

        int size = FileCopyUtils.copy(file.getInputStream(), new FileOutputStream(outFile));
        LOG.info("Client file upload done: file={}, size={}, copied={}", outFile.getAbsolutePath(), file.getSize(), size);
        saveFileMeta(outFile, tag);
    }

    private void saveFileMeta(File file, String tag) {
        FileMeta meta = new FileMeta();
        meta.setName(file.getName());
        meta.setDir(file.getParentFile().getName());
        meta.setSize(file.length());
        meta.setMime(MimeUtils.guessMimeFromExtension(extension(file.getName())));
        meta.setTag(tag);
        dao.save(meta);
    }

    public File localFile(String filename) {
        return new File(dir(filename), filename);
    }

    /**
     * 下载文件
     * @param filename
     * @param outputStream
     * @param response
     * @return 返回文件的MIME
     * @throws Exception
     */
    public String download(String filename, OutputStream outputStream, HttpServletResponse response) throws Exception {
        String extension = extension(filename);
        String mime = MimeUtils.guessMimeFromExtension(extension);
        if (mime == null) mime = "application/octet-stream";
        if (response != null) {
            response.setContentType(mime);
        }
        FileCopyUtils.copy(new FileInputStream(localFile(filename)), outputStream);
        return mime;
    }

    /**
     * 下载文件
     * @param filename
     * @param outputStream
     * @return 返回文件的MIME
     * @throws Exception
     */
    public String download(String filename, OutputStream outputStream) throws Exception {
       return download(filename, outputStream, null);
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        dirFile = new File(config.getUploadDir());
        if (!dirFile.exists()) {
            boolean ok = dirFile.mkdirs();
            LOG.info("Upload dir created: ret={}, path={}", ok, dirFile.getAbsolutePath());
        }

        clientDirFile = new File(dirFile, "client_upload");
        if (!clientDirFile.exists()) clientDirFile.mkdirs();
    }

    private String toURL(String fileName) {
        return String.format("http://%s/api/file/%s", config.getDomain(), fileName);
    }

    private String createNewFileName(String originalName) {
        String extension = extension(originalName);
        if (extension != null) {
            return idWorker.next() + "." + extension;
        } else {
            return String.valueOf(idWorker);
        }
    }

    private String extension(String originalName) {
        int index = -1;
        if (StringUtils.isNotBlank(originalName) && (index = originalName.lastIndexOf(".")) >= 0) {
            if (index == originalName.length() - 1) return null;
            return originalName.substring(index + 1);
        }
        return null;
    }

    public boolean fileExists(String name) {
        File file = new File(dir(name), name);
        return file.exists();
    }
    public void assertFileExists(String name) {
        Assert.isTrue(fileExists(name), "文件不存在");
    }

}
