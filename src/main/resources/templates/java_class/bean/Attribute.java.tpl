package ${packageName}.bean;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myjack.api.annotation.Index;
import org.mayanjun.myjack.api.annotation.IndexColumn;
import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EditableEntity;
import org.mayanjun.myjack.api.enums.IndexType;

/**
 * 属性
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "t_attribute",
        indexes = {
                @Index(value = "idx_name", columns = {
                        @IndexColumn("group"),
                        @IndexColumn("name")
                }, type = IndexType.UNIQUE)
        },
        comment = "属性")
public class Attribute extends EditableEntity {

    @Column(length = "32")
    private String name;

    @Column(length = "32")
    private String group;

    @Column(length = "5000")
    private String value;

    @Column(length = "255")
    private String description;

    public Attribute() {
    }

    public Attribute(Long id) {
        super(id);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getGroup() {
        return group;
    }

    public void setGroup(String group) {
        this.group = group;
    }
}
