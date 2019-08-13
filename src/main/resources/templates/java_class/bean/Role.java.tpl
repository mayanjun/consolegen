package ${packageName}.bean;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myjack.api.annotation.Index;
import org.mayanjun.myjack.api.annotation.IndexColumn;
import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EditableEntity;

/**
 * 角色
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "t_role",
        indexes = {
                @Index(value = "idx_name", columns = @IndexColumn("name"))
        },
        comment = "角色")
public class Role extends EditableEntity {

    @Column(length = "32")
    private String name;

    @Column(length = "500")
    private String description;

    // 接收权限参数
    private Long privileges[];

    private Long menus[];

    public Long[] getPrivileges() {
        return privileges;
    }

    public void setPrivileges(Long[] privileges) {
        this.privileges = privileges;
    }

    public Role() {
    }

    public Role(Long id) {
        super(id);
    }

    public Long[] getMenus() {
        return menus;
    }

    public void setMenus(Long[] menus) {
        this.menus = menus;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
