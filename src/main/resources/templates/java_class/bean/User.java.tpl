package ${packageName}.bean;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myjack.api.annotation.Index;
import org.mayanjun.myjack.api.annotation.IndexColumn;
import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EditableEntity;
import org.mayanjun.myjack.api.enums.DataType;
import org.mayanjun.myjack.api.enums.IndexType;

import java.util.List;
import java.util.Set;

/**
 * 用户
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "t_user",
        indexes = {
                @Index(value = "idx_username", columns = @IndexColumn("username"), type = IndexType.UNIQUE)
        },
        comment = "用户")
public class User extends EditableEntity {

    public User() {
    }

    public User(Long id) {
        super(id);
    }

    public User(User user) {
        this(user.username);
    }

    public User(String username) {
        this.username = username;
        this.loginTime = System.currentTimeMillis();
    }

    public User(String username, long loginTime) {
        this.username = username;
        this.loginTime = loginTime;
    }

    public User(String username, String password) {
        this.username = username;
        this.password = password;
    }

    @Column(comment = "用户名", type = DataType.VARCHAR, length = "32")
    private String username;

    private long loginTime;

    @Column(comment = "密码", type = DataType.VARCHAR, length = "255")
    private String password;

    @Column(comment = "是否管理员", type = DataType.BIT, length = "1")
    private Boolean administrator;

    @Column(comment = "备注", type = DataType.VARCHAR, length = "500")
    private String description;

    private String token;

    private Long roles[];

    private List<Menu> menus;

    private Set<String> privileges;

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public long getLoginTime() {
        return loginTime;
    }

    public void setLoginTime(long loginTime) {
        this.loginTime = loginTime;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public String getToken() {
        return token;
    }

    public void setToken(String token) {
        this.token = token;
    }

    public Boolean getAdministrator() {
        return administrator;
    }

    public void setAdministrator(Boolean administrator) {
        this.administrator = administrator;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Long[] getRoles() {
        return roles;
    }

    public void setRoles(Long[] roles) {
        this.roles = roles;
    }

    public List<Menu> getMenus() {
        return menus;
    }

    public void setMenus(List<Menu> menus) {
        this.menus = menus;
    }

    public Set<String> getPrivileges() {
        return privileges;
    }

    public void setPrivileges(Set<String> privileges) {
        this.privileges = privileges;
    }
}
