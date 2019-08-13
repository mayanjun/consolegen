package ${packageName};

import org.mayanjun.core.Status;

/**
 *
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public class StatusCode {

    public static final Status DAO_SAVE_FAIL                        = new Status(3001, "保存失败");
    public static final Status DAO_UPDATE_FAIL                      = new Status(3002, "更新失败");
    public static final Status API_NOT_SUPPORTED                    = new Status(3003, "不支持的API");
    public static final Status PERMISSION_DENIED                    = new Status(3004, "无权限");
    public static final Status OPENAPI_PERMISSION_DENIED            = new Status(3005, "非法访问");
    public static final Status OPENAPI_PERMISSION_DENIED_TIME       = new Status(3006, "非法访问");
    public static final Status FILE_ALREADY_EXISTS                  = new Status(4000, "文件已经存在");

}
