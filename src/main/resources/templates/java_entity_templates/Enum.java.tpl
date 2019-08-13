package ${package_name}.bean;

/**
 * ${class_name}
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public enum ${class_name} {

    UNKNOWN("其他"),
${enum_values}
    ;

    private String displayName;

    ${class_name}(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
