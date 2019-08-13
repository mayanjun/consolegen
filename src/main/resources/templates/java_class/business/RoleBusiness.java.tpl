package ${packageName}.business;

import ${packageName}.bean.Privilege;
import ${packageName}.bean.Role;
import ${packageName}.bean.RoleMenu;
import ${packageName}.bean.RolePrivilege;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.myjack.api.query.Query;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * 角色管理
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class RoleBusiness extends BaseBusiness<Role> {

    @Override
    protected void doCheck(Role entity, boolean update) {
        Assert.notBlank(entity.getName(), "角色名称不能为空");
    }

    @Override
    protected long doSave(Role bean) {
        return transaction().execute(status -> {
            Long rid = super.doSave(bean);
            saveRolePrivileges(bean);
            saveMenus(bean);
            return rid;
        });
    }

    private void saveMenus(Role role) {
        Long [] mids = role.getMenus();

        // 这里不保存菜单的父菜单，用户加载菜单的时候自动加载
        if (mids != null && mids.length > 0) {
            for (Long mid : mids) {
                RoleMenu rm = new RoleMenu(role.getId(), mid);
                rm.setCreator(role.getEditor());
                rm.setEditor(role.getEditor());
                service.save(rm);
            }
        }

        //Set<Long> menus = new HashSet<>();
        /*if (mids != null && mids.length > 0) {
            List<Menu> menuList = service.query(
                    QueryBuilder.custom(Menu.class)
                            .andIn("id", mids)
                            .includeFields("id", "parentId")
                            .build()
            );
            if (CollectionUtils.isNotEmpty(menuList)) {
                menuList.stream().forEach(e -> {
                    menus.add(e.getId());
                    Long pid = e.getParentId();
                    if (pid != null && pid > 0) {
                        menus.add(pid);
                    }
                });
            }
        }*/

    }

    private void saveRolePrivileges(Role role) {
        Long pids[] = role.getPrivileges();
        if (pids != null && pids.length > 0) {
            Set<Long> dependencies = new HashSet<>();
            for (Long pid : pids) {
                dependencies.add(pid);

                // 权限所依赖的权限也应该被分配
                Privilege privilege = service.getInclude(new Privilege(pid), "dependencies");
                String csps = privilege.getDependencies();
                if (StringUtils.isNotBlank(csps)) {
                    String cs[] = csps.split(",");
                    List<Privilege> plist = service.query(QueryBuilder.custom(Privilege.class)
                            .andIn("method", cs)
                            .includeFields("id")
                            .build());
                    plist.stream().forEach(e -> dependencies.add(e.getId()));
                }
            }

            for (Long pid : dependencies) {
                RolePrivilege rp = new RolePrivilege(role.getId(), pid);
                rp.setCreator(role.getEditor());
                rp.setEditor(role.getEditor());
                service.save(rp);
            }
        }
    }

    @Override
    protected int doUpdate(Role bean) {
        return transaction().execute(status -> {
            Query<RolePrivilege> query = QueryBuilder.custom(RolePrivilege.class)
                    .andEquivalent("role", bean.getId())
                    .build();
            service.delete(query);
            saveRolePrivileges(bean);

            Query<RoleMenu> query2 = QueryBuilder.custom(RoleMenu.class)
                    .andEquivalent("role", bean.getId())
                    .build();
            service.delete(query2);
            saveMenus(bean);
            return super.doUpdate(bean);
        });
    }

    @Override
    protected Role doGet(Role bean) {
        Role role = super.doGet(bean);

        // 加载权限列表
        Query<RolePrivilege> query = QueryBuilder.custom(RolePrivilege.class)
                .andEquivalent("role", bean.getId())
                .build();
        List<RolePrivilege> rolePrivileges = service.query(query);
        if (CollectionUtils.isNotEmpty(rolePrivileges)) {
            Long ids [] = new Long[rolePrivileges.size()];
            for (int i = 0; i < ids.length; i++) {
                ids[i] = rolePrivileges.get(i).getPrivilege().getId();
            }
            role.setPrivileges(ids);
        }

        // 加载菜单列表
        Query<RoleMenu> query2 = QueryBuilder.custom(RoleMenu.class)
                .andEquivalent("role", bean.getId())
                .build();
        List<RoleMenu> roleMenus = service.query(query2);
        if (CollectionUtils.isNotEmpty(roleMenus)) {
            Long ids [] = new Long[roleMenus.size()];
            for (int i = 0; i < ids.length; i++) {
                ids[i] = roleMenus.get(i).getMenu().getId();
            }
            role.setMenus(ids);
        }

        return role;
    }
}
