package ${packageName}.interceptor;

import org.apache.commons.codec.digest.DigestUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.myrest.interceptor.AnnotationBasedHandlerInterceptor;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.util.StringJoiner;

import static ${packageName}.StatusCode.OPENAPI_PERMISSION_DENIED;
import static ${packageName}.StatusCode.OPENAPI_PERMISSION_DENIED_TIME;
import static ${packageName}.interceptor.Verify.VERIFY_HEADERS;

/**
 * 接口调用验证拦截器
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class VerifyInterceptor extends AnnotationBasedHandlerInterceptor {

    private static final String SECRET_KEY = "${verifySecretKey}";

    @Override
    public int getOrder() {
        return 0;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {

        String timestamp = request.getHeader(VERIFY_HEADERS[0]);
        long time = 0;
        try {
            time = Long.parseLong(timestamp);
        } catch (NumberFormatException e) {
        }

        boolean timeOK = Math.abs(System.currentTimeMillis() - time) < 10000;
        Assert.isTrue(timeOK, OPENAPI_PERMISSION_DENIED_TIME);

        StringJoiner joiner = new StringJoiner("&");
        for (String h : VERIFY_HEADERS) joiner.add(h + "=" + request.getHeader(h));
        joiner.add("SECRET_KEY=" + SECRET_KEY);
        String sign = DigestUtils.sha256Hex(joiner.toString());
        String sign0 = request.getHeader(Verify.HEADER_SIGN);
        Assert.isTrue(sign.equalsIgnoreCase(sign0), OPENAPI_PERMISSION_DENIED);
        return true;
    }
}