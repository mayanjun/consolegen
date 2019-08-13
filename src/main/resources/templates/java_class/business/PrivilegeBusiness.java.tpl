package ${packageName}.business;

import ${packageName}.bean.Privilege;
import org.mayanjun.core.Assert;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.springframework.stereotype.Component;

/**
 * 权限管理
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class PrivilegeBusiness extends BaseBusiness<Privilege> {

    @Override
    protected void doCheck(Privilege entity, boolean update) {
        Assert.notBlank(entity.getName(), "角色名称不能为空");
    }

    @Override
    protected void renderListAllBuilder(QueryBuilder<Privilege> builder) {
        builder.excludeFields("method", "dependencies");
    }
}
