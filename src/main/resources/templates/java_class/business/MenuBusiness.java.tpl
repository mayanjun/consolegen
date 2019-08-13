package ${packageName}.business;

import ${packageName}.bean.Menu;
import ${packageName}.util.CommonUtils;
import ${packageName}.util.ParametersBuilder;
import org.mayanjun.core.Assert;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 菜单管理
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class MenuBusiness extends BaseBusiness<Menu> {

    @Override
    protected void doCheck(Menu entity, boolean update) {
        Assert.notBlank(entity.getName(), "菜单名称不能为空");
    }

    @Override
    public List<Menu> listAll(ParametersBuilder parametersBuilder) {
        List<Menu> list = super.listAll(parametersBuilder);
        return CommonUtils.hierarchicalMenus(list);
    }


    @Override
    public void delete(Long[] ids) {
        transaction().execute(transactionStatus -> {
            super.delete(ids);
            for (Long id : ids) {
                service.delete(
                        QueryBuilder.custom(Menu.class)
                                .andEquivalent("parentId", id)
                                .build()
                );
            }
            return true;
        });
    }

}
