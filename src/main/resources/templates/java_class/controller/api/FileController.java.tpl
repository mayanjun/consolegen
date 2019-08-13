package ${packageName}.controller.api;

import ${packageName}.business.FileBusiness;
import ${packageName}.config.MetaProperty;
import ${packageName}.config.Privileged;
import ${packageName}.config.PrivilegedMeta;
import ${packageName}.interceptor.Login;
import ${packageName}.interceptor.Verify;
import org.mayanjun.myrest.BaseController;
import org.mayanjun.myrest.RestResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.servlet.mvc.method.annotation.StreamingResponseBody;

import javax.servlet.http.HttpServletResponse;

/**
 * 文件管理接口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@RestController
@RequestMapping("api/file")
@PrivilegedMeta({
        @MetaProperty(name = "module", value = "文件")
})
public class FileController extends BaseController {

    private static final Logger LOG = LoggerFactory.getLogger(FileController.class);

    @Autowired
    private FileBusiness business;

    @Login
    @Privileged("文件上传")
    @PostMapping(headers = "!" + Verify.HEADER_SIGN)
    public Object upload(MultipartFile file, String tag) throws Exception {
        return RestResponse.ok().add("url", business.upload(file, tag));
    }


    @Verify
    @PostMapping(headers = Verify.HEADER_SIGN)
    public Object uploadForClient(MultipartFile file, String tag) throws Exception {
        business.uploadForClient(file, tag);
        return RestResponse.ok();
    }

    /**
     * 客户端访问文件资源
     * @param name
     * @param response
     * @return
     */
    @Verify
    @GetMapping(value = "{name}", headers = Verify.HEADER_SIGN)
    public StreamingResponseBody downloadForClient(@PathVariable String name, HttpServletResponse response) {
        return doDownload(name, response);
    }

    /**
     * 后台访问文件资源
     * @param name
     * @param response
     * @return
     */
    @Login
    @GetMapping(value = "{name}", headers = "!" + Verify.HEADER_SIGN)
    public StreamingResponseBody downloadForConsole(@PathVariable String name, HttpServletResponse response) {
        return doDownload(name, response);
    }

    private StreamingResponseBody doDownload(String name, HttpServletResponse response) {
        business.assertFileExists(name);
        return outputStream -> {
            try {
                business.download(name, outputStream, response);
            } catch (Exception e) {
                LOG.error("Download file fail: filename=" + name, e);
            }
        };
    }
}
