package ${packageName}.controller.api;

import ${packageName}.bean.Settings;
import ${packageName}.business.AttributeBusiness;
import ${packageName}.config.MetaProperty;
import ${packageName}.config.Privileged;
import ${packageName}.config.PrivilegedMeta;
import ${packageName}.interceptor.Login;
import org.mayanjun.myrest.BaseController;
import org.mayanjun.myrest.RestResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 系统设置接口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Login
@RequestMapping("api/settings")
@RestController
@PrivilegedMeta(@MetaProperty(name = "module", value = "系统设置"))
public class SettingsController extends BaseController {

    @Autowired
    private AttributeBusiness business;

    @GetMapping("{id}")
    @Privileged("获取{module}详细数据")
    public Object get(@PathVariable long id) {
        return RestResponse.ok().add("entity", business.allSettings());
    }

    @Privileged("更新{module}")
    @PostMapping("update")
    public Object update(@RequestBody Settings bean) {
        business.updateSettings(bean);
        return RestResponse.ok();
    }

    @Privileged("恢复出厂设置")
    @PostMapping("factory")
    public Object restoreFactorySettings() {
        business.restoreFactorySettings();
        return RestResponse.ok();
    }
}
