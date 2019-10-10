package ${packageName}.sql;

import ${packageName}.bean.User;
import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.myjack.generator.DDL;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;

/**
 * 自定义SQL提供者
 *
 * @author mayanjun
 * @vendor JDD (https://www.jddglobal.com)
 * @since 2019-07-06
 */
public class CustomSQLBuilder {

    private static final Logger LOG = LoggerFactory.getLogger(CustomSQLBuilder.class);

    /**
     * @return
     * @throws Exception
     */
    public synchronized String databaseDDL() throws Exception {
        StringBuffer sb = new StringBuffer();
        try {
            List<String> ss = DDL.ddl(true, false, User.class.getPackage().getName());
            if (CollectionUtils.isNotEmpty(ss)) {
                ss.forEach(e -> sb.append(e).append("\n"));
            }
        } catch (Exception e) {
            LOG.error("Generate DDL error", e);
        } finally {

        }
        String sql = sb.toString();
        if (StringUtils.isBlank(sql)) {
            return "CREATE TABLE IF NOT EXISTS `t_test` (\n" +
                    "  `id` int(11) unsigned NOT NULL AUTO_INCREMENT,\n" +
                    "  PRIMARY KEY (`id`)\n" +
                    ") ENGINE=InnoDB DEFAULT CHARSET=utf8;";
        }

        return sb.toString();
    }
}