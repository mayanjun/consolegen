package ${packageName}.interceptor;

import ${packageName}.bean.User;
import ${packageName}.config.AppConfig;
import org.mayanjun.core.ServiceException;
import org.mayanjun.myrest.interceptor.AnnotationBasedHandlerInterceptor;
import org.mayanjun.myrest.session.SessionUser;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLEncoder;

/**
 * 登录检查拦截器
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class LoginInterceptor extends AnnotationBasedHandlerInterceptor {

    private static final Logger LOG = LoggerFactory.getLogger(LoginInterceptor.class);

    @Autowired
    private SessionManager session;

    @Autowired
    private AppConfig config;

    @Override
    public int getOrder() {
        return 0;
    }

    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception {
        Login login = findAnnotation(Login.class, handler);

        if(login.checkUser()) {
            try {
                SessionUser<User> user = session.getUser(request);
                request.setAttribute("__current_user", user.getUsername());
            } catch (ServiceException e) {
                String uri = request.getRequestURI();
                if (uri.startsWith("/api")) throw e;

                String newURL = request.getScheme() + "://" + config.getDomain();
                String redirect = "/login?redirect=" + URLEncoder.encode(newURL, "utf-8");
                response.sendRedirect(redirect);
                LOG.error("===========LOGIN FAIL==========");
                return false;
            }
        }
        return true;
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception {
        session.clear();
    }
}