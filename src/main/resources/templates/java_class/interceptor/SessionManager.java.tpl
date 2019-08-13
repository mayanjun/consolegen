package ${packageName}.interceptor;

import ${packageName}.bean.*;
import ${packageName}.business.MenuBusiness;
import ${packageName}.config.AppConfig;
import ${packageName}.util.CommonUtils;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.myjack.api.query.Query;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.mayanjun.myjack.dao.BasicDAO;
import org.mayanjun.myrest.session.Session;
import org.mayanjun.myrest.session.SessionUser;
import org.mayanjun.myrest.session.UserLoader;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.InitializingBean;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * 会话管理器
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class SessionManager extends Session<User> implements InitializingBean {

    private static final Logger LOG = LoggerFactory.getLogger(SessionManager.class);

    @Autowired
    private AppConfig config;

    @Autowired
    private BasicDAO dao;

    @Autowired
    private MenuBusiness menuBusiness;

    private Map<String, SessionUser<User>> userCache = new HashMap<>();

    @Scheduled(cron = "0 */5 * * * ?")
    public void clearInactiveUser() {
        LOG.info(">>>>>>>>>>>>>>>>> AUTOMATIC SIGN OUT >>>>>>>>>>>>>>>>>");
        Set<String> usernames = new HashSet<>(userCache.keySet());
        if (CollectionUtils.isNotEmpty(usernames)) {
            usernames.stream().forEach(e -> {
                SessionUser<User> user = userCache.get(e);
                if (System.currentTimeMillis() - user.getLastLoginTime() > 600000) {
                    userCache.remove(e);
                    LOG.info("User no activity for long time and logout automatically: username={}", e);
                }
            });
        }
    }

    @Override
    public void afterPropertiesSet() throws Exception {
        setDomain(config.getDomain());
        setTokenName(config.getTokenCookieName());
        setKeyPairStore(config.keyPairStore());
        setTokenName(config.getTokenCookieName());
        setUserLoader(new UserLoader<User>() {
            @Override
            public SessionUser<User> loadUser(String username) {
                Assert.notBlank(username, "用户名不能为空");
                User user = queryUser(username);
                SessionUser<User> sessionUser = new SessionUser<>(user.getUsername());
                sessionUser.setId(user.getId());
                sessionUser.setPassword(user.getPassword());
                sessionUser.setOriginUser(user);
                return sessionUser;
            }

            @Override
            public void setUserCache(SessionUser<User> user) {
                userCache.put(user.getUsername(), user);
            }

            @Override
            public void removeUserCache(SessionUser<User> user) {
                userCache.remove(user.getUsername());
            }

            @Override
            public SessionUser<User> getUserFromCache(String username) {
                return userCache.get(username);
            }
        });
    }

    public User getUser() {
        String username = getCurrentUser().getUsername();
        User user = getUserLoader().getUserFromCache(username).getOriginUser();
        Assert.notNull(user, SessionManager.NO_SIGN_IN);
        return user;
    }

    public List<Menu> userMenus() {
        return getUser().getMenus();
    }

    /**
     * 查询用户角色并渲染菜单和权限列表
     * @param username
     * @return
     */
    private User queryUser(String username) {
        Query<User> query = QueryBuilder.custom(User.class)
                .andEquivalent("username", username)
                .build();
        User user = dao.queryOne(query);
        Assert.notNull(user, Session.USER_NOT_EXISTS);

        // 查询角色列表
        if (Boolean.TRUE.equals(user.getAdministrator())) { // is admin
            user.setMenus(menuBusiness.listAll(null));
        } else {
            List<UserRole> userRoles = dao.query(QueryBuilder.custom(UserRole.class).andEquivalent("user", user.getId()).build());
            Set<String> privileges = new HashSet<>();

            Map<Long, Menu> menuMap = new HashMap<>();
            userRoles.stream().forEach(userRole -> {
                Long roleId = userRole.getRole().getId();

                // load menus
                List<RoleMenu> roleMenus = dao.query(
                        QueryBuilder.custom(RoleMenu.class).andEquivalent("role", roleId).build()
                );
                roleMenus.stream().forEach(rm -> {
                    Menu menu = dao.getInclude(rm.getMenu());
                    menuMap.put(menu.getId(), menu);

                    Long pid = menu.getParentId();
                    if (pid != null && pid > 0) {
                        Menu pmenu = menuMap.get(pid);
                        if (pmenu == null) menuMap.put(pid, dao.getInclude(new Menu(pid)));
                    }
                });

                // load privileges
                List<RolePrivilege> rolePrivileges = dao.query(
                        QueryBuilder.custom(RolePrivilege.class).andEquivalent("role", roleId).build()
                );
                rolePrivileges.stream().forEach(rolePrivilege -> {
                    Long pid = rolePrivilege.getPrivilege().getId();
                    Privilege p = dao.getInclude(new Privilege(pid), "method", "dependencies");
                    if (p != null) {
                        privileges.add(p.getMethod());
                        String de = p.getDependencies();
                        if (StringUtils.isNotBlank(de)) {
                            String des[] = de.split(",");
                            for (String s : des) privileges.add(s);
                        }
                    }
                });
            });
            user.setPrivileges(privileges);
            user.setMenus(CommonUtils.hierarchicalMenus(menuMap.values()));
        }
        return user;
    }
}