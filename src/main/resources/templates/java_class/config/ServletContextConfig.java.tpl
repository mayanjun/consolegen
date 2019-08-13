package ${packageName}.config;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myrest.RestResponse;
import org.mayanjun.myrest.interceptor.ApplicationExceptionHandler;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.web.servlet.ServletContextInitializer;
import org.springframework.stereotype.Component;
import org.springframework.validation.BindException;
import org.springframework.validation.FieldError;

import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import java.lang.reflect.Field;

/**
 * Servlet初始化回调
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class ServletContextConfig implements ServletContextInitializer {

    private static final Logger LOG = LoggerFactory.getLogger(ServletContextConfig.class);

    @Autowired
    private AppConfig config;

    @Override
    public void onStartup(ServletContext servletContext) throws ServletException {
        ApplicationExceptionHandler.installUnknownExceptionHandler(new ApplicationExceptionHandler.UnknownExceptionHandler() {
            @Override
            public RestResponse handleException(Throwable t) {
                RestResponse response = RestResponse.error();
                if (t instanceof BindException) {
                    FieldError error = ((BindException) t).getFieldError();
                    String fieldName = error.getField();
                    Object target = ((BindException) t).getTarget();
                    try {
                        Field field = target.getClass().getDeclaredField(fieldName);
                        if (field != null) {
                            Column column = field.getAnnotation(Column.class);
                            if (column != null) {
                                String comment = column.comment();
                                response.setMessage(comment + " 参数错误").add("description", t.getMessage());
                            }
                        }
                    } catch (NoSuchFieldException e) {
                    }

                }
                return response;
            }
        });
        servletContext.setAttribute("__APPCONF__", config);
    }
}
