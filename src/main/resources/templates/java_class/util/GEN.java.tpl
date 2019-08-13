package ${packageName}.util;

import ${packageName}.bean.User;
import org.mayanjun.myjack.generator.DDL;
import org.mayanjun.util.Encryptions;

import java.io.File;

/**
 *
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public class GEN {

    public static void main(String[] args) throws Exception {
        Encryptions.generateKeys();
        //ddl();
    }

    private static void ddl() throws Exception {
        DDL.ddl(new File("/Users/mayanjun/Desktop/court.ddl"), false,false, User.class.getPackage().getName());
    }
}
