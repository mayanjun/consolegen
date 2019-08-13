package ${packageName}.bean;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myjack.api.annotation.Index;
import org.mayanjun.myjack.api.annotation.IndexColumn;
import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EditableEntity;
import org.mayanjun.myjack.api.enums.DataType;

/**
 * 角色权限
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "t_role_privilege",
        indexes = {
                @Index(value = "idx_role", columns = @IndexColumn("role")),
                @Index(value = "idx_privilege", columns = @IndexColumn("privilege"))
        },
        comment = "角色权限表")
public class RolePrivilege extends EditableEntity {

    @Column(type = DataType.BIGINT, referenceField = "id")
    private Role role;

    @Column(type = DataType.BIGINT, referenceField = "id")
    private Privilege privilege;

    public RolePrivilege() {
    }

    public RolePrivilege(Long id) {
        super(id);
    }

    public RolePrivilege(Role role, Privilege privilege) {
        this.role = role;
        this.privilege = privilege;
    }

    public RolePrivilege(Long roleId, Long privilegeId) {
        this.role = new Role(roleId);
        this.privilege = new Privilege(privilegeId);
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public Privilege getPrivilege() {
        return privilege;
    }

    public void setPrivilege(Privilege privilege) {
        this.privilege = privilege;
    }
}
