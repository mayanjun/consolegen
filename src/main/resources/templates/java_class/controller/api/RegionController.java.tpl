package ${packageName}.controller.api;

import ${packageName}.bean.Region;
import ${packageName}.business.BaseBusiness;
import ${packageName}.business.RegionBusiness;
import ${packageName}.config.MetaProperty;
import ${packageName}.config.Privileged;
import ${packageName}.config.PrivilegedMeta;
import ${packageName}.interceptor.Login;
import ${packageName}.util.ParametersBuilder;
import org.mayanjun.myrest.RestResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * 地区管理接口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Login
@RestController
@RequestMapping("api/region")
@PrivilegedMeta({
        @MetaProperty(name = "module", value = "地区")
})
public class RegionController extends DataController<Region> {

    @Autowired
    private RegionBusiness business;

    @Privileged("{module}列表查询")
    @GetMapping
    public Object list(@RequestParam(required = false, defaultValue = "1") Integer page,
                       @RequestParam(required = false, defaultValue = "10") Integer pageSize,
                       @RequestParam(required = false) Long sid,
                       @RequestParam(required = false) String sname,
                       @RequestParam(required = false) Long sparent,
                       @RequestParam(required = false) Integer slevel) {
        ParametersBuilder pb = ParametersBuilder.custom();
        pb.add("id", sid);
        pb.add("parent", sparent);
        pb.add("__LIKE__name", sname);
        pb.add("level", slevel);
        return RestResponse.ok().add("list", business.listAll(pb));
    }

    @Override
    protected BaseBusiness<Region> business() {
        return business;
    }
}
