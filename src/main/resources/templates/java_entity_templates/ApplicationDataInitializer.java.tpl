package ${packageName}.config;

import ${packageName}.bean.Menu;
import ${packageName}.bean.Privilege;
import ${packageName}.bean.User;
import ${packageName}.business.AttributeBusiness;
import ${packageName}.sql.CustomMapper;
import ${packageName}.util.CommonUtils;
import org.mayanjun.myjack.api.query.Query;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.mayanjun.myjack.dao.BasicDAO;
import org.mayanjun.util.Encryptions;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.aop.support.AopUtils;
import org.springframework.beans.BeansException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;
import java.util.*;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


/**
 * 系统初始化。初始化用户、菜单、权限等信息
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class ApplicationDataInitializer implements ApplicationRunner, ApplicationContextAware {
    
    private static final Logger LOG = LoggerFactory.getLogger(ApplicationDataInitializer.class);

    public static final String INITIALIZER_USERNAME = "SYSTEM";

    @Autowired
    private BasicDAO dao;

    @Autowired
    private AppConfig config;

    private ApplicationContext applicationContext;

    @Autowired
    private AttributeBusiness ab;

    @Override
    public void run(ApplicationArguments args) throws Exception {
        synchronized (this) {
            initDatabase();
            initSystemUser();
            initMenus();
            initPrivileges();
            ab.initSystemSettings(false);
            LOG.info("SYSTEM initialized!");
        }
    }

    private void initDatabase() throws Exception {
        CustomMapper mapper = dao.getDataBaseRouter().getDatabaseSession().getMapper(CustomMapper.class);
        mapper.generateDatabase();
    }



    private void addMethodsToSet(Method [] methods, Set<Method> methodSet) {
        if (methods != null && methods.length > 0) {
            for (Method m : methods) methodSet.add(m);
        }
    }

    /**
     * 初始化权限数据
     */
    private void initPrivileges() {
        Map<String, Object> beans = applicationContext.getBeansWithAnnotation(PrivilegedMeta.class);

        Map<String, PrivilegeMetaData> privilegeMetaDataMap = new HashMap<>();

        if (beans != null && !beans.isEmpty()) {
            beans.values().stream().forEach(e -> {
                Class<?> cls = e.getClass();

                if (AopUtils.isAopProxy(e)) {
                     cls = AopUtils.getTargetClass(e);
                }

                Set<Method> methodSet = new HashSet<>();
                Method ms[] = cls.getMethods();
                Method dms[] = cls.getDeclaredMethods();
                addMethodsToSet(ms, methodSet);
                addMethodsToSet(dms, methodSet);
                for (Method m : methodSet) {
                    PrivilegeMetaData pmd = createPrivilegeMetaData(cls, m);
                    if (pmd != null) {
                        privilegeMetaDataMap.put(pmd.methodName, pmd);
                    }
                }
            });

            // check the integrality of dependencies
            if (!privilegeMetaDataMap.isEmpty()) {

                privilegeMetaDataMap.entrySet().stream().forEach(e -> {
                    String ds[] = e.getValue().dependencies;
                    if (ds != null && ds.length > 0) {
                        for (String mn : ds) {
                            PrivilegeMetaData pmd = privilegeMetaDataMap.get(mn);
                            if (pmd == null) {
                                throw new NullPointerException(
                                        String.format("The dependency not found: defined in [%s], value=%s", e.getValue().method, mn)
                                );
                            }
                        }
                    }
                });

                // save privileges, 这里还必须处理间接依赖和循环依赖的问题
                privilegeMetaDataMap.entrySet().stream().forEach(e -> {
                    PrivilegeMetaData data = e.getValue();
                    if (data.dependencies.length > 0) {
                        Set<String> des = new HashSet<>();
                        determineDependencies(des, data.methodName, privilegeMetaDataMap);
                        des.remove(data.methodName);

                        String dependenciesString = commaSeparated(des);
                        savePrivilege(data, dependenciesString);

                    } else { // 没有依赖直接保存
                        savePrivilege(data, null);
                    }
                });
            }
        } else {
            LOG.warn("No privileged bean found!");
        }
    }

    private void savePrivilege(PrivilegeMetaData data, String des) {
        Privilege privilege = new Privilege();
        privilege.setDependencies(des == null ? "" : des);
        privilege.setDescription(data.description);
        privilege.setMethod(data.methodName);
        privilege.setName(data.name);

        Query<Privilege> query = QueryBuilder.custom(Privilege.class)
                .andEquivalent("method", data.methodName)
                .includeFields("id")
                .build();
        Privilege dbp = dao.queryOne(query);
        if (dbp == null) {
            long id = dao.save(privilege);
            LOG.info("Privilege saved: {} <===> {}", id, data.methodName);
        } else {
            privilege.setId(dbp.getId());
            dao.update(privilege);
            LOG.info("Privilege updated: {} <===> {}", dbp.getId(), data.methodName);
        }
    }

    private String commaSeparated(Set<String> set) {
        int size = set.size();
        int count = 1;
        StringBuffer sb = new StringBuffer();
        for (String s : set) {
            sb.append(s);
            if (count++ < size) {
                sb.append(",");
            }
        }
        return sb.toString();
    }

    /**
     * 检测依赖与循环依赖
     * @param des
     * @param mn
     * @param map
     */
    private void determineDependencies(Set<String> des,
                                              String mn,
                                              Map<String, PrivilegeMetaData> map) {
        des.add(mn);
        PrivilegeMetaData data = map.get(mn);
        if (data.dependencies.length == 0) return;

        for (String de : data.dependencies) {
            if (des.contains(de)) continue;
            determineDependencies(des, de, map);
        }
    }


    private PrivilegeMetaData createPrivilegeMetaData(Class<?> cls, Method m) {
        Privileged privileged = m.getAnnotation(Privileged.class);
        if (privileged != null) {
            PrivilegedMeta meta = cls.getAnnotation(PrivilegedMeta.class);
            MetaProperty []metaProperties = meta.value();

            PrivilegeMetaData pmd = new PrivilegeMetaData(cls, m,
                    CommonUtils.getReferenceMethodName(cls, m),
                    privileged.value(),
                    "System created",
                    privileged.dependencies()
            );
            replacePlaceholder(pmd, metaProperties);
            return pmd;
        }
        return null;
    }

    private void replacePlaceholder(PrivilegeMetaData pmd, MetaProperty [] metaProperties) {
        Map<String, String> map = new HashMap<>();
        for (MetaProperty mp : metaProperties) {
            map.put(mp.name(), mp.value());
        }
        pmd.name = doReplacePlaceholder(pmd.name, map, pmd);
        String [] ds = pmd.dependencies;
        if (ds != null && ds.length > 0) {
            for (int i = 0; i < ds.length; i++) {
                ds[i] = doReplacePlaceholder(ds[i], map, pmd);
            }
        }
    }

    private String doReplacePlaceholder(String src, Map<String, String> dict, PrivilegeMetaData data) {
        Pattern pattern = Pattern.compile("\\{([0-9,a-z,A-Z]+)\\}");
        Matcher matcher = pattern.matcher(src);
        StringBuffer sb = new StringBuffer();
        while (matcher.find()) {
            String groupName = matcher.group(1);
            String value = dict.get(groupName);
            if (value != null) {
                matcher.appendReplacement(sb, value);
            } else {
                if ("thisClass".equals(groupName)) {
                    matcher.appendReplacement(sb, data.cls.getName());
                }
            }
        }
        matcher.appendTail(sb);
        return sb.toString();
    }

    private static class PrivilegeMetaData {
        private String methodName;
        private String name;
        private String description;
        private String [] dependencies;
        private Class<?> cls;
        private Method method;
        private Long id;

        public PrivilegeMetaData(Class<?> cls, Method method,
                String methodName, String name, String description, String[] dependencies) {
            this.cls = cls;
            this.method = method;
            this.methodName = methodName;
            this.name = name;
            this.description = description;
            this.dependencies = dependencies;
        }

        public PrivilegeMetaData(String methodName, String[] dependencies) {
            this.methodName = methodName;
            this.dependencies = dependencies;
        }
    }

    private void initSystemUser() {
        // create default user
        User user = dao.queryOne(QueryBuilder.custom(User.class)
                .andEquivalent("username", "admin")
                .build());

        if (user == null) {
            user = new User();
            user.setAdministrator(true);
            user.setUsername("admin");
            user.setDescription("System init user");
            String password = generatePassword();
            String enc = Encryptions.encrypt(password, config.keyPairStore());
            user.setPassword(enc);
            user.setCreator(INITIALIZER_USERNAME);
            user.setEditor(INITIALIZER_USERNAME);
            Long id = dao.save(user);
            LOG.info("System init user created({}), init password={}", id, password);
        }
    }

    private String generatePassword() {
        String uuid = UUID.randomUUID().toString().replace("-","");
        int start = new Double(Math.random() * (uuid.length() - 6)).intValue();
        return uuid.substring(start, start + 6);
    }

    private static final String MENUS[][] = new String[][] {
            // children-count, pid, name, icon, url
            new String[]{"4", "系统管理", "el-icon-s-operation", ""},
            new String[]{"0", "菜单管理", "el-icon-menu", "/pages/menu/list"},
            new String[]{"0", "用户管理", "el-icon-user", "/pages/user/list"},
            new String[]{"0", "角色管理", "el-icon-present", "/pages/role/list"},
            new String[]{"0", "权限管理", "el-icon-c-scale-to-original", "/pages/privilege/list"},

${entity_menu_items!""}

            new String[]{"0", "地区管理", "el-icon-map-location", "/pages/region/list"},
            new String[]{"0", "系统设置", "el-icon-setting", "/pages/settings/add"},
    };

    /**
     * 初始化菜单
     */
    private void initMenus() {
        long count = 0;

        int children = 0;
        long pid = 0;

        for (String menuitem[] : MENUS) {
            Long id = ++count;
            long parentId = 0;

            if (--children >= 0) { // 子节点
                parentId = pid;
            } else {  // 处理完了子节点
                children = Integer.parseInt(menuitem[0]);
                if (children > 0) {
                    pid = id;
                }
            }
            Menu menu = dao.getInclude(new Menu(id), "id");
            if (menu == null) createMenu(id, parentId, menuitem[1], menuitem[2], menuitem[3]);
        }
    }

    private AtomicInteger order = new AtomicInteger(10000);

    /**
     *
     * @param id 菜单ID
     * @param pid 父ID
     * @param name 菜单名称
     * @param icon 菜单图标 参见 https://element.eleme.cn/#/zh-CN/component/icon
     * @param url 菜单URL
     */
    private void createMenu(long id, long pid, String name, String icon, String url) {
        Menu m = new Menu();
        m.setId(id);
        m.setParentId(pid);
        m.setName(name);
        m.setIcon(icon);
        m.setDescription("Generated Menu");
        m.setHref(url);
        m.setOrder(new Double(order.incrementAndGet()));
        m.setType(Menu.MenuType.LINK);
        m.setCreator(INITIALIZER_USERNAME);
        m.setEditor(INITIALIZER_USERNAME);
        long sid = dao.save(m);
        LOG.info("Menu created: id={}, name={}", sid, name);
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        this.applicationContext = applicationContext;
    }
}
