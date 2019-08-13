package ${packageName}.bean;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myjack.api.annotation.Index;
import org.mayanjun.myjack.api.annotation.IndexColumn;
import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EditableEntity;
import org.mayanjun.myjack.api.enums.DataType;

/**
 * 角色菜单
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "t_role_menu",
        indexes = {
                @Index(value = "idx_role", columns = @IndexColumn("role")),
                @Index(value = "idx_menu", columns = @IndexColumn("menu"))
        },
        comment = "角色权限表")
public class RoleMenu extends EditableEntity {

    @Column(type = DataType.BIGINT, referenceField = "id")
    private Role role;

    @Column(type = DataType.BIGINT, referenceField = "id")
    private Menu menu;

    public RoleMenu() {
    }

    public RoleMenu(Long id) {
        super(id);
    }

    public RoleMenu(Role role, Menu menu) {
        this.role = role;
        this.menu = menu;
    }

    public RoleMenu(Long roleId, Long menuId) {
        this.role = new Role(roleId);
        this.menu = new Menu(menuId);
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public Menu getMenu() {
        return menu;
    }

    public void setMenu(Menu menu) {
        this.menu = menu;
    }
}
