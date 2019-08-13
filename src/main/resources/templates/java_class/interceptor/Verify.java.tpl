package ${packageName}.interceptor;

import org.mayanjun.myrest.interceptor.Interceptor;

import java.lang.annotation.*;

/**
 * 接口调用验证
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Inherited
@Target({ElementType.METHOD, ElementType.TYPE})
@Retention(RetentionPolicy.RUNTIME)
@Interceptor(loadFromContainer = true, value = VerifyInterceptor.class)
public @interface Verify {

    String HEADER_SIGN = "JD-SIGN";

    String [] VERIFY_HEADERS = {
            "JD-TIMESTAMP",
            "JD-RANDOM",
            "JD-DEVICE-ID"
    };
}