package ${packageName}.sql;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.SelectProvider;
import org.apache.ibatis.annotations.UpdateProvider;

import java.util.Date;
import java.util.List;
import java.util.Map;

/**
 *
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Mapper
public interface CustomMapper {

    @UpdateProvider(type = CustomSQLBuilder.class, method = "databaseDDL")
    void generateDatabase();
}
