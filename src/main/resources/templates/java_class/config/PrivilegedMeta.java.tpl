package ${packageName}.config;

import java.lang.annotation.*;

/**
 * 如果一个类中有 @Privileged 方法，则该方法所在的类必须使用这个注解来描述模块的信息。
 * 这个机制主要是为了描述继承下来的 @Privileged 方法。在 @Privileged 注解中可以使用 {propertyName} 来引用这里的属性
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Retention(RetentionPolicy.RUNTIME)
@Target(ElementType.TYPE)
@Inherited
public @interface PrivilegedMeta {

    MetaProperty [] value() default {};
}