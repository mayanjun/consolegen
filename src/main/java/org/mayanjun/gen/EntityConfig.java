package org.mayanjun.gen;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.util.ConfigVerifier;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author mayanjun
 * @date 2019-07-17
 */
public class EntityConfig implements ValidateConfig {

    @Configurable(comment = "实体类名", required = true)
    private String className;

    @Configurable(comment = "简短的实体描述，这个也会用来生成对应的管理菜单的名称，因此不要太长", required = true)
    private String comment;

    @Configurable(comment = "后台管理对应的菜单图标,选值请参见【https://element.ele.me/#/zh-CN/component/icon】", defaultValue = "el-icon-monitor")
    private String icon = "el-icon-monitor";

    @Configurable(comment = "实体的字段配置，参见【FieldConfig 配置】")
    private List<FieldConfig> fieldConfigs;

    @Configurable(comment = "是否支持后台数据导出功能")
    private boolean exportSupported;

    public boolean validate() {
        if (StringUtils.isBlank(icon)) icon = "el-icon-monitor";

        Map<String, FieldConfig> fieldConfigMap = new HashMap<>();
        if (CollectionUtils.isNotEmpty(fieldConfigs)) {
           for (FieldConfig config : fieldConfigs) {
               String name = config.getName();
               Assert.isFalse(fieldConfigMap.containsKey(name), String.format("重复的字段名：%s.%s", className, name));
               fieldConfigMap.put(name, config);
           }
        }


        ConfigVerifier.verify(this);

        if (CollectionUtils.isNotEmpty(fieldConfigs)) {
            fieldConfigs.forEach(e -> e.validate());
        }

        return true;
    }

    public String getClassName() {
        return className;
    }

    public void setClassName(String className) {
        this.className = className;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public List<FieldConfig> getFieldConfigs() {
        return fieldConfigs;
    }

    public void setFieldConfigs(List<FieldConfig> fieldConfigs) {
        this.fieldConfigs = fieldConfigs;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public boolean isExportSupported() {
        return exportSupported;
    }

    public void setExportSupported(boolean exportSupported) {
        this.exportSupported = exportSupported;
    }
}
