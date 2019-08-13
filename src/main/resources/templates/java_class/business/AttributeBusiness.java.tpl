package ${packageName}.business;

import ${packageName}.bean.Attribute;
import ${packageName}.bean.Settings;
import org.apache.commons.beanutils.BeanUtilsBean2;
import org.apache.commons.beanutils.PropertyUtilsBean;
import org.mayanjun.myjack.api.query.Query;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.beans.PropertyDescriptor;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * 属性业务
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class AttributeBusiness extends BaseBusiness<Attribute> {

    private static final Logger LOG = LoggerFactory.getLogger(AttributeBusiness.class);



    private final Map<String, String> SETTINGS_CACHE = new ConcurrentHashMap<>();

    public static final String GROUP_SETTINGS = "settings";

    public Attribute getAttribute(String group, String name) {
        Query<Attribute> query = QueryBuilder.custom(Attribute.class)
                .andEquivalent("group", group)
                .andEquivalent("name", name)
                .forUpdate()
                .build();
        return service.queryOne(query);
    }

    public Map<String, String> allSettings() {
        Query<Attribute> query = QueryBuilder.custom(Attribute.class)
                .andEquivalent("group", GROUP_SETTINGS)
                .build();
        List<Attribute> list = service.query(query);
        Map<String, String> data = new HashMap<>();
        list.forEach(e -> data.put(e.getName(), e.getValue()));

        return data;
    }

    public void updateSettings(Settings settings) {
        try {
            saveOrUpdateSettings(settings, true);
        } finally {
            SETTINGS_CACHE.clear();
        }
    }

    public void restoreFactorySettings() {
        try {
            initSystemSettings(true);
        } finally {
            SETTINGS_CACHE.clear();
        }
    }

    public void initSystemSettings(boolean update) {
        Settings settings = new Settings();
        saveOrUpdateSettings(settings, update);
    }

    private void saveOrUpdateSettings(Settings settings, boolean update) {
        PropertyUtilsBean utilsBean = BeanUtilsBean2.getInstance().getPropertyUtils();
        final PropertyDescriptor[] origDescriptors = utilsBean.getPropertyDescriptors(settings);
        for (PropertyDescriptor descriptor : origDescriptors) {
            final String name = descriptor.getName();
            if ("class".equals(name)) {
                continue; // No point in trying to set an object's class
            }
            try {
                Object value = utilsBean.getSimpleProperty(settings, name);
                if (value == null) value = "";
                saveOrUpdate(GROUP_SETTINGS, name, String.valueOf(value), "System init", update);
            } catch (final Exception e) {
                LOG.warn("Can not copy settings value from property:'" + name + "'", e);
            }
        }
    }

    private void saveOrUpdate(String group, String name, String value, String desc, boolean update) {
        Attribute attribute = new Attribute();
        attribute.setGroup(group);
        attribute.setName(name);
        attribute.setValue(value);
        attribute.setDescription(desc);
        saveOrUpdate(attribute, update);
    }

    private void saveOrUpdate(Attribute attribute, boolean update) {
        transaction().execute(transactionStatus -> {
            Attribute a = getAttribute(attribute.getGroup(), attribute.getName());
            if (a == null) {
                service.save(attribute);
            } else {
                if (update) {
                    attribute.setId(a.getId());
                    service.update(attribute);
                }
            }
            return 1;
        });
    }

    /**
     * 获取系统设置
     * @param name
     * @return
     */
    public String getSettings(String name) {
        String val = SETTINGS_CACHE.get(name);
        if (val != null) return val;

        Query<Attribute> query = QueryBuilder.custom(Attribute.class)
                .andEquivalent("group", GROUP_SETTINGS)
                .andEquivalent("name", name)
                .forUpdate()
                .build();
        Attribute attribute = service.queryOne(query);
        if (attribute == null) return null;

        String value = attribute.getValue();
        SETTINGS_CACHE.put(name, value);
        return value;
    }

    public boolean getBooleanSettings(String name) {
        String value = getSettings(name);
        return "true".equalsIgnoreCase(value);
    }
}
