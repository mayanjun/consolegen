package ${packageName}.controller;

import ${packageName}.Application;
import ${packageName}.bean.Menu;
import ${packageName}.interceptor.Login;
import ${packageName}.interceptor.SessionManager;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.myrest.BaseController;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.ModelAndView;

import java.util.List;

/**
 * 页面服务入口
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Controller
@RequestMapping("/")
public class IndexController extends BaseController {

    @Autowired
    private SessionManager sessionManager;

    @Login
    @RequestMapping
    public Object index() {
        List<Menu> menus = sessionManager.userMenus();
        return new ModelAndView("index")
                .addObject("menus", menus)
                .addObject("APP_BUILD_VERSION", Application.APP_BUILD_VERSION);
    }

    @RequestMapping("login")
    public Object login() {
        return new ModelAndView("login").addObject("APP_BUILD_VERSION", Application.APP_BUILD_VERSION);
    }

    @Login
    @GetMapping("pages/{module}/{action}")
    public Object pages(@PathVariable String module, @PathVariable String action, @RequestParam(required = false) String id) {
        ModelAndView modelAndView = new ModelAndView("pages/" + module + "-" + action)
                .addObject("module", module)
                .addObject("action", action);

        if (StringUtils.isNotBlank(id)) {
            try {
                Long.parseLong(id);
                modelAndView.addObject("entityId", id);
            } catch (NumberFormatException e) {
            }
        }
        return modelAndView;
    }

    @GetMapping("docs/{name}")
    public Object docs(@PathVariable String name) {
        return "docs/" + name;
    }

}