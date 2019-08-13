package ${packageName}.config;

/**
 * 元属性，可配合注解进行属性配置
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public @interface MetaProperty {

    String name();

    String value();
}
