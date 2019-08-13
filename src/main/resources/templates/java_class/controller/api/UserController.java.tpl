package ${packageName}.controller.api;

import ${packageName}.bean.User;
import ${packageName}.business.BaseBusiness;
import ${packageName}.business.UserBusiness;
import ${packageName}.config.MetaProperty;
import ${packageName}.config.Privileged;
import ${packageName}.config.PrivilegedMeta;
import ${packageName}.interceptor.Login;
import ${packageName}.util.ParametersBuilder;
import org.mayanjun.myrest.RestResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

/**
 * 用户管理接口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Login
@RestController
@RequestMapping("api/user")
@PrivilegedMeta(@MetaProperty(name = "module", value = "用户"))
public class UserController extends DataController<User> {

    @Autowired
    private UserBusiness business;

    @Privileged("{module}列表查询")
    @GetMapping
    public Object list(@RequestParam(required = false, defaultValue = "0") Integer page,
                       @RequestParam(required = false, defaultValue = "10") Integer pageSize,
                       @RequestParam(required = false) Long sid,
                       @RequestParam(required = false) String susername) {
        ParametersBuilder pb = ParametersBuilder.custom();
        if (sid != null) pb.add("id", sid);
        pb.add("__LIKE__username", susername);
        return RestResponse.ok()
                .add("list", business.list(page, pageSize, pb))
                .add("total", business.count(pb));
    }

    @PostMapping
    @Privileged(value = "创建{module}",
            dependencies = "${packageName}.controller.api.RoleController::listAllRoles")
    @Override
    public Object save(@RequestBody User bean) {
        return super.save(bean);
    }

    @PostMapping("update")
    @Privileged(value = "更新{module}",
            dependencies = "${packageName}.controller.api.RoleController::listAllRoles")
    @Override
    public Object update(@RequestBody User bean) {
        return super.update(bean);
    }

    @Override
    protected BaseBusiness<User> business() {
        return business;
    }
}
