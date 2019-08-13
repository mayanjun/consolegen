package ${packageName}.bean;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myjack.api.annotation.Index;
import org.mayanjun.myjack.api.annotation.IndexColumn;
import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EditableEntity;
import org.mayanjun.myjack.api.enums.DataType;

import java.util.Set;

/**
 * 菜单
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "t_menu",
        indexes = {
                @Index(value = "idx_name", columns = @IndexColumn("name"))
        },
        comment = "菜单")
public class Menu extends EditableEntity implements Comparable {

    @Column(length = "32")
    private String name;

    @Column(length = "32")
    private MenuType type;

    @Column(length = "32")
    private String target;

    @Column(length = "200")
    private String href;

    @Column(length = "32")
    private String icon;

    @Column(type = DataType.BIGINT)
    private Long parentId;

    @Column(comment = "菜单顺序", type = DataType.DOUBLE, length = "10,5")
    private Double order;

    @Column(comment = "备注", type = DataType.VARCHAR, length = "500")
    private String description;

    private Set<Menu> children;

    public Menu() {
    }

    public Menu(Long id) {
        super(id);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public MenuType getType() {
        return type;
    }

    public void setType(MenuType type) {
        this.type = type;
    }

    public String getTarget() {
        return target;
    }

    public void setTarget(String target) {
        this.target = target;
    }

    public String getHref() {
        return href;
    }

    public void setHref(String href) {
        this.href = href;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    @Override
    public int compareTo(Object o) {
        Menu menu = (Menu) o;
        double thisOrder = this.order == null ? 0 : this.order;
        double thatOrder = menu.getOrder() == null ? 0 : menu.getOrder();
        return thisOrder < thatOrder ? -1 : 1;
    }

    public Set<Menu> getChildren() {
        return children;
    }

    public void setChildren(Set<Menu> children) {
        this.children = children;
    }

    public static enum MenuType {
        LINK,
        SEPARATOR,
    }

    public Double getOrder() {
        return order;
    }

    public void setOrder(Double order) {
        this.order = order;
    }
}