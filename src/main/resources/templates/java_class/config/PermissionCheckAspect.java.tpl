package ${packageName}.config;

import ${packageName}.StatusCode;
import ${packageName}.bean.Privilege;
import ${packageName}.bean.User;
import ${packageName}.interceptor.SessionManager;
import ${packageName}.util.CommonUtils;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.mayanjun.core.Assert;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.lang.reflect.Method;

/**
 * 权限检查拦截器
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Aspect
@Component
public class PermissionCheckAspect {

    private static final Logger LOG = LoggerFactory.getLogger(PermissionCheckAspect.class);

    @Autowired
    private SessionManager sessionManager;

    @Pointcut("@annotation(${packageName}.config.Privileged)")
    public void checkPermissionPointCut(){
    }

    @Around("checkPermissionPointCut()")
    public Object checkPermission(ProceedingJoinPoint jp) throws Throwable {
        // check permission
        User user = sessionManager.getUser();
        if (Boolean.FALSE.equals(user.getAdministrator())) { // check permission
            MethodSignature msig = (MethodSignature) jp.getSignature();

            Class<?> cls = jp.getTarget().getClass();
            Method method = msig.getMethod();

            String methodName = CommonUtils.getReferenceMethodName(cls, method);
            boolean ok = user.getPrivileges().contains(methodName);
            Assert.isTrue(ok, StatusCode.PERMISSION_DENIED);
        }
        return jp.proceed();
    }

}
