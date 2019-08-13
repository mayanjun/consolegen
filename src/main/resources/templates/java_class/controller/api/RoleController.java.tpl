package ${packageName}.controller.api;

import ${packageName}.bean.Role;
import ${packageName}.business.BaseBusiness;
import ${packageName}.business.RoleBusiness;
import ${packageName}.config.MetaProperty;
import ${packageName}.config.Privileged;
import ${packageName}.config.PrivilegedMeta;
import ${packageName}.interceptor.Login;
import ${packageName}.util.ParametersBuilder;
import org.mayanjun.myrest.RestResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

/**
 * 角色管理接口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Login
@RestController
@RequestMapping("api/role")
@PrivilegedMeta(@MetaProperty(name = "module", value = "角色"))
public class RoleController extends DataController<Role> {

    @Autowired
    private RoleBusiness business;

    @Privileged("{module}列表查询")
    @GetMapping
    public Object list(@RequestParam(required = false, defaultValue = "0") Integer page,
                       @RequestParam(required = false, defaultValue = "10") Integer pageSize,
                       @RequestParam(required = false) Long sid,
                       @RequestParam(required = false) String sname) {
        ParametersBuilder pb = ParametersBuilder.custom();
        if (sid != null) pb.add("id", sid);
        pb.add("name", sname);
        return RestResponse.ok()
                .add("list", business.list(page, pageSize, pb))
                .add("total", business.count(pb));
    }

    @Privileged("查询所有{module}")
    @GetMapping("all-roles")
    public Object listAllRoles() {
        List<Role> all = business.listAll(null);
        return RestResponse.ok().add("list", all);
    }

    @PostMapping
    @Privileged(value = "创建{module}",
            dependencies = {
                    "${packageName}.controller.api.PrivilegeController::listAllPrivileges",
                    "${packageName}.controller.api.MenuController::listAllMenus"
            }
    )
    @Override
    public Object save(@RequestBody Role bean) {
        return super.save(bean);
    }

    @PostMapping("update")
    @Privileged(value = "更新{module}",
            dependencies = {
                    "${packageName}.controller.api.PrivilegeController::listAllPrivileges",
                    "${packageName}.controller.api.MenuController::listAllMenus"
            }
    )
    @Override
    public Object update(@RequestBody Role bean) {
        return super.update(bean);
    }

    @Override
    protected BaseBusiness<Role> business() {
        return business;
    }
}
