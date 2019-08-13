package ${packageName}.controller.api;

import ${packageName}.bean.Menu;
import ${packageName}.business.BaseBusiness;
import ${packageName}.business.MenuBusiness;
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
 * 菜单管理接口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Login
@RestController
@RequestMapping("api/menu")
@PrivilegedMeta({
        @MetaProperty(name = "module", value = "菜单")
})
public class MenuController extends DataController<Menu> {

    @Autowired
    private MenuBusiness business;

    @Privileged("{module}列表查询")
    @GetMapping
    public Object list(@RequestParam(required = false, defaultValue = "0") Integer page,
                       @RequestParam(required = false, defaultValue = "10") Integer pageSize,
                       @RequestParam(required = false) Long sid,
                       @RequestParam(required = false) String sname) {
        ParametersBuilder pb = ParametersBuilder.custom();
        if (sid != null) pb.add("id", sid);
        pb.add("__LIKE__name", sname);
        return RestResponse.ok()
                .add("list", business.listAll(pb));
    }

    @Privileged("查询所有根{module}")
    @GetMapping("all-root-menus")
    public Object listAllRootMenus(@RequestParam(required = false) Long excludeId) {
        ParametersBuilder pb = ParametersBuilder.custom();
        pb.add("parentId", 0);
        pb.add("type", Menu.MenuType.LINK);
        pb.add("__!=__id", excludeId);

        List<Menu> all = business.listAll(pb);
        return RestResponse.ok().add("list", all);
    }

    @Privileged("查询所有{module}")
    @GetMapping("all-menus")
    public Object listAllMenus() {
        List<Menu> all = business.listAll(null);
        return RestResponse.ok().add("list", all);
    }

    @PostMapping
    @Privileged(value = "创建{module}", dependencies = "{thisClass}::listAllRootMenus")
    @Override
    public Object save(@RequestBody  Menu bean) {
        return super.save(bean);
    }

    @PostMapping("update")
    @Privileged(value = "更新{module}", dependencies = "{thisClass}::listAllRootMenus")
    @Override
    public Object update(@RequestBody Menu bean) {
        return super.update(bean);
    }

    @Override
    protected BaseBusiness<Menu> business() {
        return business;
    }
}
