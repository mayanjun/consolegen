package ${packageName}.controller.api;

import ${packageName}.StatusCode;
import ${packageName}.bean.Privilege;
import ${packageName}.business.BaseBusiness;
import ${packageName}.business.PrivilegeBusiness;
import ${packageName}.config.MetaProperty;
import ${packageName}.config.Privileged;
import ${packageName}.config.PrivilegedMeta;
import ${packageName}.interceptor.Login;
import ${packageName}.util.ParametersBuilder;
import org.mayanjun.core.ServiceException;
import org.mayanjun.myrest.RestResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

/**
 * 权限管理接口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Login
@RestController
@RequestMapping("api/privilege")
@PrivilegedMeta(@MetaProperty(name = "module", value = "权限"))
public class PrivilegeController extends DataController<Privilege> {

    @Autowired
    private PrivilegeBusiness business;

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
                .add("list", business.list(page, pageSize, pb))
                .add("total", business.count(pb));
    }

    @Privileged("查询所有{module}")
    @GetMapping("all-privileges")
    public Object listAllPrivileges() {
        List<Privilege> all = business.listAll(null);
        return RestResponse.ok().add("list", all);
    }

    @Override
    protected BaseBusiness<Privilege> business() {
        return business;
    }

    @Override
    public Object get(long id) {
        throw new ServiceException(StatusCode.API_NOT_SUPPORTED);
    }

    @Override
    public Object delete(Long[] ids) {
        throw new ServiceException(StatusCode.API_NOT_SUPPORTED);
    }

    @Override
    public Object save(Privilege bean) {
        throw new ServiceException(StatusCode.API_NOT_SUPPORTED);
    }

    @Override
    public Object update(Privilege bean) {
        throw new ServiceException(StatusCode.API_NOT_SUPPORTED);
    }
}
