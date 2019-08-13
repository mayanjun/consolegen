package ${packageName}.util;

import ${packageName}.bean.Menu;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;

import java.lang.reflect.Method;
import java.util.*;
import java.util.stream.Collectors;

/**
 *
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public class CommonUtils {

    private CommonUtils() {
    }

    /**
     * 获取权限系统中对访问方法的别名
     * @param instanceClass 调用方法所在的类
     * @param method 方法
     * @return
     */
    public static String getReferenceMethodName(Class<?> instanceClass, Method method) {
        return instanceClass.getName() + "::" + method.getName();
    }

    /**
     * 将一维菜单列表结构化处理
     * @param list 菜单列表
     * @return 结构化的菜单列表
     */
    public static List<Menu> hierarchicalMenus(Collection<Menu> list) {
        Map<Long, Menu> menuMap = new HashMap<>();
        if (CollectionUtils.isNotEmpty(list)) {
            Iterator<Menu> it = list.iterator();
            while (it.hasNext()) {
                Menu e = it.next();
                if (StringUtils.isBlank(e.getIcon())) e.setIcon("el-icon-menu");
                Long pid = e.getParentId();
                if (pid == null || pid == 0) {
                    menuMap.put(e.getId(), e);
                    it.remove();
                } else {
                    Menu p = menuMap.get(pid);
                    if (p != null) {
                        Set<Menu> children = p.getChildren();
                        if (children == null) {
                            children = new TreeSet<>();
                            p.setChildren(children);
                        }
                        children.add(e);
                        it.remove();
                    }
                }
            }

            // 一轮循环结束后可能有的子菜单还没有被处理
            if (!list.isEmpty()) {
                for (Menu e : list) {
                    Long pid = e.getParentId();
                    Menu p = menuMap.get(pid);
                    if (p == null) {
                        menuMap.put(e.getId(), e);
                    } else {
                        Set<Menu> children = p.getChildren();
                        if (children == null) {
                            children = new TreeSet<>();
                            p.setChildren(children);
                        }
                        children.add(e);
                    }
                }
            }
        }

        if (menuMap.isEmpty()) {
            return new ArrayList<>();
        } else {
            return menuMap.values().stream()
                    .sorted()
                    .collect(Collectors.toList());
        }
    }

    /**
     * 字符串脱敏
     * @param src 源字符串
     * @param percent 隐藏百分比
     * @return 脱敏字符串
     */
    public static String insensitiveString(String src, float percent) {
        if (src == null) return "";
        percent = Math.abs(percent);
        if (percent >= 1) return src;
        char cs[] = src.toCharArray();
        int cslen = cs.length;
        int range = (int) (cslen * percent);
        if (range == 0) range = 1;
        int start = (cslen - range) / 2;
        int end = start + range - 1;
        if (end >= cslen) end = cslen - 1;
        StringBuffer sb = new StringBuffer();
        for (int i = 0; i < cslen; i++) {
            if (i >= start && i <= end) {
                sb.append('*');
            } else {
                sb.append(cs[i]);
            }
        }
        return sb.toString();
    }
}