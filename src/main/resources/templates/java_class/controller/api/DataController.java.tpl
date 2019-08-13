package ${packageName}.controller.api;

import ${packageName}.business.BaseBusiness;
import ${packageName}.config.Privileged;
import ${packageName}.util.ParametersBuilder;
import org.mayanjun.core.Assert;
import org.mayanjun.myjack.api.entity.EntityBean;
import org.mayanjun.myrest.BaseController;
import org.mayanjun.myrest.RestResponse;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

/**
 * 提供通用的数据管理功能
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public abstract class DataController<T extends EntityBean> extends BaseController {

    @GetMapping("{id}")
    @Privileged("获取{module}详细数据")
    public Object get(@PathVariable long id) {
        return RestResponse.ok().add("entity", business().get(id));
    }

    @Privileged("删除{module}")
    @PostMapping("delete")
    public Object delete(@RequestBody Long [] ids) {
        Assert.isTrue(ids != null && ids.length > 0, "数据ID错误");
        business().delete(ids);
        return RestResponse.ok();
    }

    @Privileged("创建{module}")
    @PostMapping
    public Object save(@RequestBody T bean) {
        business().save(bean);
        return RestResponse.ok();
    }

    @Privileged("更新{module}")
    @PostMapping("update")
    public Object update(@RequestBody T bean) {
        business().update(bean);
        return RestResponse.ok();
    }

    /**
     * 导出数据
     * @param pb
     * @return
     */
    protected Object exportData(ParametersBuilder pb) {
        return RestResponse.ok().add("url", business().exportData(pb));
    }

    protected abstract BaseBusiness<T> business();
}
