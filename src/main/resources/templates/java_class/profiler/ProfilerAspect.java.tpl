package ${packageName}.profiler;

import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.aspectj.lang.annotation.Pointcut;
import org.aspectj.lang.reflect.MethodSignature;
import org.mayanjun.myjack.dao.BasicDAO;
import org.mayanjun.myrest.RestResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.RequestAttributes;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;

import javax.servlet.http.HttpServletRequest;
import java.lang.reflect.Method;
import java.util.IdentityHashMap;
import java.util.Map;

/**
 *
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Aspect
@Component
public class ProfilerAspect {

    private static final Logger LOG = LoggerFactory.getLogger(ProfilerAspect.class);

    private Map<Method, ProfilerConf> cache = new IdentityHashMap<>();

    @Autowired
    protected BasicDAO service;

    @Pointcut("@annotation(${packageName}.profiler.Profiler)")
    public void profiler(){
    }

    /**
     * 记录访问日志
     * @param jp
     * @return
     * @throws Throwable
     */
    @Around("profiler()")
    public Object log(ProceedingJoinPoint jp) throws Throwable {
        long now = System.currentTimeMillis();
        Object ret = null;
        ProfilerConf conf = getConf(jp);
        boolean success = true;
        try {
            ret = jp.proceed();
            return ret;
        } catch (Throwable throwable) {
            success = false;
            throw throwable;
        } finally {
            try {
                long elapsed = System.currentTimeMillis() - now;
                if (ret instanceof RestResponse) ((RestResponse) ret).add("elapsed", elapsed);
                if (conf.profiler.printAccessLog()) printAccessLog(success, elapsed);
            } catch (Throwable e) {
                LOG.error("Print access log error", e);
            }
        }
    }

    private void printAccessLog(boolean success, long elapsed) {
        RequestAttributes attributes = RequestContextHolder.getRequestAttributes();
        ServletRequestAttributes sra = (ServletRequestAttributes) attributes;
        String proxyIp = "";
        String clientIp = "";
        String uri = "";
        String method = "";
        if (sra != null) {
            HttpServletRequest request = sra.getRequest();
            proxyIp = request.getRemoteAddr();
            clientIp = request.getHeader("X-Forwarded-For");
            uri = request.getRequestURI();
            method = request.getMethod();
        }
        LOG.info("<< ACCESS {} {} [{}] {} [{}] [{}] >>", (success ? "SUCCESS" : "FAIL"), method, uri, elapsed, proxyIp, clientIp);
    }

    /**
     * 获取Profiler配置
     * @param jp
     * @return
     */
    private ProfilerConf getConf(ProceedingJoinPoint jp) {
        MethodSignature msig = (MethodSignature) jp.getSignature();
        Method method = msig.getMethod();
        ProfilerConf conf = cache.get(method);
        if (conf != null) return conf;

        Profiler profiler = method.getAnnotation(Profiler.class);
        conf = new ProfilerConf(profiler);
        cache.put(method, conf);
        return conf;
    }

    /**
     * 被拦截方法的日志配置
     */
    public static class ProfilerConf {
        private Profiler profiler;

        public ProfilerConf(Profiler profiler) {
            this.profiler = profiler;
        }

        public Profiler getProfiler() {
            return profiler;
        }

        public void setProfiler(Profiler profiler) {
            this.profiler = profiler;
        }
    }
}
