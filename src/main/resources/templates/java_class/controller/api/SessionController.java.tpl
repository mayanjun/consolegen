package ${packageName}.controller.api;

import ${packageName}.bean.User;
import ${packageName}.config.AppConfig;
import ${packageName}.interceptor.Login;
import ${packageName}.interceptor.SessionManager;
import org.mayanjun.myrest.BaseController;
import org.mayanjun.myrest.RestResponse;
import org.mayanjun.myrest.session.SessionUser;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 会话管理接口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@RestController
@RequestMapping("api/session")
public class SessionController extends BaseController {

    @Autowired
    private AppConfig config;

    @Autowired
    private SessionManager sessionManager;

    @RequestMapping(method = RequestMethod.POST)
    public Object signin(@RequestBody User user, HttpServletResponse response) {
        SessionUser<User> suser = sessionManager.signIn(user.getUsername(), user.getPassword(), response);
        return RestResponse.ok(suser.getOriginUser());
    }

    @Login
    @RequestMapping(method = RequestMethod.GET, value = "signout")
    public Object signout(HttpServletRequest request, HttpServletResponse response) {
        sessionManager.signOut(request, response);
        return RestResponse.ok().add("domain", config.getDomain());
    }

}
