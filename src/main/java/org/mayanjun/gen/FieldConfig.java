package org.mayanjun.gen;

import org.mayanjun.core.Assert;
import org.mayanjun.myjack.api.enums.DataType;
import org.mayanjun.util.ConfigVerifier;
import org.mayanjun.util.JavaTypeUtils;

/**
 * @author mayanjun
 * @date 2019-07-17
 */
public class FieldConfig implements ValidateConfig {

    @Configurable(comment = "英文字段名", required = true)
    private String name;

    @Configurable(comment = "字段的Java类型", defaultValue = "String")
    private String javaType = "String";

    private String finalJavaType;

    @Configurable(comment = "数据库的长度描述", defaultValue = "64")
    private String databaseLength = "64";

    private int inputLength;

    @Configurable(comment = "字段简短描述，该值还用来生成数据表头，因此不要太长", required = true)
    private String comment = "";

    /**
     * @see {@link org.mayanjun.myjack.api.enums.DataType}
     */
    @Configurable(comment = "数据库的字段类型，取值请参见【org.mayanjun.myjack.api.enums.DataType】的枚举值", defaultValue = "VARCHAR")
    private DataType databaseType = DataType.VARCHAR;

    @Configurable(comment = "是否设置索引，如果支持索引的话会生成数据库索引，同时还会生成后台的搜索条件")
    private boolean indexed = false;

    @Configurable(comment = "输入框的类型，可选的值为FILE_IMAGE：上传图片文件， FILE_ORDINARY：上传任意普通文件")
    private InputType inputType;

    @Configurable(comment = "如果这里定义值的话，这个字段会被定义为枚举： 数组内容为 [\"枚举值\",\"枚举值说明\"]，枚举字段在后台会被生成Radio选择框")
    private String enumValues[];

    @Configurable(comment = "如果字段的类型是日期类型，则指定格式化模式。日期类型在后台会生成日期或者时间选择框", defaultValue = "yyyy-MM-dd HH:mm:ss")
    private String pattern = "yyyy-MM-dd HH:mm:ss";

    private String formatter;

    @Configurable(comment = "当InputType为SEARCH时，指定远程搜索的实体名称")
    private String remoteSearchEntityName;

    @Configurable(comment = "当InputType为SEARCH时，指定远程搜索对象的要显示的字段名，并且远程搜索字段的字段类型必须为long类型")
    private String remoteSearchLabelField;

    @Configurable(comment = "当InputType为SEARCH时，指定远程搜索对象的要显示的描述信息的字段名")
    private String remoteSearchDescField;

    public String getFormatter() {
        return formatter;
    }

    public void setFormatter(String formatter) {
        this.formatter = formatter;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getJavaType() {
        return javaType;
    }

    public void setJavaType(String javaType) {
        this.javaType = javaType;
    }

    public String getDatabaseLength() {
        return databaseLength;
    }

    public void setDatabaseLength(String databaseLength) {
        this.databaseLength = databaseLength;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public DataType getDatabaseType() {
        return databaseType;
    }

    public void setDatabaseType(DataType databaseType) {
        this.databaseType = databaseType;
    }

    public boolean isIndexed() {
        return indexed;
    }

    public void setIndexed(boolean indexed) {
        this.indexed = indexed;
    }

    public InputType getInputType() {
        return inputType;
    }

    public void setInputType(InputType inputType) {
        this.inputType = inputType;
    }

    public String[] getEnumValues() {
        return enumValues;
    }

    public void setEnumValues(String[] enumValues) {
        this.enumValues = enumValues;
    }

    public boolean validate() {
        ConfigVerifier.verify(this);
        if (enumValues != null && enumValues.length > 0) {
            Assert.isTrue(enumValues.length % 2 == 0, "The length of enumValues should be an even number");
        }

        if (inputType == InputType.SEARCH) {
            Assert.notBlank(remoteSearchEntityName, "当前字段为远程搜索字段，必须指定一个搜索实体名称（remoteSearchEntityName）");
            Assert.notBlank(remoteSearchLabelField, "当前字段为远程搜索字段，必须指定一个显示的字段名（remoteSearchLabelField）");
            Assert.isTrue(JavaTypeUtils.isLong(javaType), "远程搜搜字段的数据类型必须为Long类型：当前类型为:" + javaType);
        }

        if (JavaTypeUtils.isDate(javaType)) javaType = "java.util.Date";
        return true;
    }

    public String getPattern() {
        return pattern;
    }

    public void setPattern(String pattern) {
        this.pattern = pattern;
    }

    public String getFinalJavaType() {
        return finalJavaType;
    }

    public void setFinalJavaType(String finalJavaType) {
        this.finalJavaType = finalJavaType;
    }

    public int getInputLength() {
        return inputLength;
    }

    public void setInputLength(int inputLength) {
        this.inputLength = inputLength;
    }

    public String getRemoteSearchLabelField() {
        return remoteSearchLabelField;
    }

    public void setRemoteSearchLabelField(String remoteSearchLabelField) {
        this.remoteSearchLabelField = remoteSearchLabelField;
    }

    public String getRemoteSearchDescField() {
        return remoteSearchDescField;
    }

    public void setRemoteSearchDescField(String remoteSearchDescField) {
        this.remoteSearchDescField = remoteSearchDescField;
    }

    public String getRemoteSearchEntityName() {
        return remoteSearchEntityName;
    }

    public void setRemoteSearchEntityName(String remoteSearchEntityName) {
        this.remoteSearchEntityName = remoteSearchEntityName;
    }
}
