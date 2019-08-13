package ${package_name}.bean;

import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EditableEntity;
import org.mayanjun.myjack.api.enums.DataType;
${imports}

/**
 * ${comment}
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "${table_name}", comment = "${comment}", indexes = {${table_indexes}})
public class ${class_name} extends EditableEntity {

    public ${class_name}() {
    }

    public ${class_name}(Long id) {
        super(id);
    }

${fields}

${getters_and_setters}
}