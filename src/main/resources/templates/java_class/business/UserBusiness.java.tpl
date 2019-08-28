package ${packageName}.business;

import ${packageName}.bean.User;
import ${packageName}.bean.UserRole;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.core.ServiceException;
import org.mayanjun.myjack.api.query.Query;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.mayanjun.util.Encryptions;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * 用户管理
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class UserBusiness extends BaseBusiness<User> {

    private void saveUserRoles(Long uid, Long rids[], User user) {
        if (rids != null && rids.length > 0) {
            for (Long rid : rids) {
                UserRole join = new UserRole(uid, rid);
                join.setCreator(user.getCreator());
                join.setEditor(user.getEditor());
                service.save(join);
            }
        }
    }

    @Override
    protected List<User> doQuery(QueryBuilder<User> builder) {
        builder.excludeFields("password");
        return super.doQuery(builder);
    }

    @Override
    protected void doCheck(User entity, boolean update) {
        Assert.notBlank(entity.getUsername(), "用户名不能为空");

        if (StringUtils.isNotBlank(entity.getPassword())) {
            String enc = Encryptions.encrypt(entity.getPassword(), config.keyPairStore());
            entity.setPassword(enc);
        }
    }

    @Override
    protected long doSave(User bean) {
        return transaction().execute(status -> {
            try {
                Long id = super.doSave(bean);
                saveUserRoles(id, bean.getRoles(), bean);
                return id;
            } catch (DuplicateKeyException e) {
                throw new ServiceException("该用户名已经存在");
            }
        });
    }

    @Override
    protected int doUpdate(User bean) {
        return transaction().execute(status -> {
            Query<UserRole> query = QueryBuilder.custom(UserRole.class)
                    .andEquivalent("user", bean.getId())
                    .build();
            service.delete(query);
            saveUserRoles(bean.getId(), bean.getRoles(), bean);
            return super.doUpdate(bean);
        });
    }

    @Override
    protected User doGet(User bean) {
        User user = service.getExclude(bean, "password");
        Query<UserRole> query = QueryBuilder.custom(UserRole.class)
                .andEquivalent("user", bean.getId())
                .build();
        List<UserRole> userRoles = service.query(query);
        if (CollectionUtils.isNotEmpty(userRoles)) {
            Long ids [] = new Long[userRoles.size()];
            for (int i = 0; i < ids.length; i++) {
                ids[i] = userRoles.get(i).getRole().getId();
            }
            user.setRoles(ids);
        }
        return user;
    }

    @Override
    public void delete(Long[] ids) {
        // 删除用户的时候应该删除给用户已经分配的权限
        transaction().execute(transactionStatus -> {
            Query<User> deleteQuery = QueryBuilder.custom(getBeanType()).andIn("id", ids).build();
            service.delete(deleteQuery);

            // 删除角色
            Query<UserRole> query = QueryBuilder.custom(UserRole.class).andIn("user", ids).build();
            service.delete(query);

            return true;
        });
    }
}