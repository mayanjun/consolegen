package ${package_name}.business;

import ${package_name}.bean.${class_name};
import org.springframework.stereotype.Component;

<#if data_export_supported>
import ${package_name}.util.ParametersBuilder;
import java.text.SimpleDateFormat;
</#if>

/**
 * ${comment}
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class ${class_name}Business extends BaseBusiness<${class_name}> {

    @Override
    protected void doCheck(${class_name} entity, boolean update) {
        // TODO 请手动添加验证业务逻辑
    }

    <#if data_export_supported>
    @Override
    protected String exportFileName(ParametersBuilder parametersBuilder) {
        return "${comment}-" + super.exportFileName(parametersBuilder);
    }

    @Override
    protected String[] formatExportEntityHeaders() {
        return new String[] {
                "ID","创建时间","修改时间"
        };
    }

    @Override
    protected String [] formatExportEntity(${class_name} entity) {
        return new String[] {
                "" + entity.getId(),
                new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(entity.getCreatedTime()),
                new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(entity.getModifiedTime()),
        };
    }
    </#if>
}
