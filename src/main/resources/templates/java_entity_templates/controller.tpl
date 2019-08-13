package ${package_name}.controller.api;

import ${package_name}.bean.${class_name};
import ${package_name}.business.BaseBusiness;
import ${package_name}.business.${class_name}Business;
import ${package_name}.config.MetaProperty;
import ${package_name}.config.Privileged;
import ${package_name}.config.PrivilegedMeta;
import ${package_name}.interceptor.Login;
import ${package_name}.util.ParametersBuilder;
import org.mayanjun.myrest.RestResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

${controller_imports!""}

/**
 * ${comment}
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Login
@RestController
@RequestMapping("api/${request_mapping}")
@PrivilegedMeta({
        @MetaProperty(name = "module", value = "${comment}")
})
public class ${class_name}Controller extends DataController<${class_name}> {

    @Autowired
    private ${class_name}Business business;

    @Privileged("{module}列表查询")
    @GetMapping
    public Object list(@RequestParam(required = false, defaultValue = "0") Integer page,
                       @RequestParam(required = false, defaultValue = "10") Integer pageSize,
                       <#if data_export_supported>@RequestParam(required = false, defaultValue = "false") Boolean export, // 添加 export参数即可支持数据导出</#if>
                       @RequestParam(required = false) Long sid${controller_search_params!""}) {

        ParametersBuilder pb = ParametersBuilder.custom();
        if (sid != null) pb.add("id", sid);

        ${controller_params_builder!""}

        <#if data_export_supported>
        if (Boolean.TRUE.equals(export)) return exportData(pb);
        </#if>
        return RestResponse.ok()
                .add("list", business.list(page, pageSize, pb))
                .add("total", business.count(pb));
    }

    @Override
    protected BaseBusiness<${class_name}> business() {
        return business;
    }
}
