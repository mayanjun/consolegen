package ${packageName}.util;


import org.apache.commons.collections.map.HashedMap;
import org.apache.commons.collections.map.LinkedMap;

import java.util.Map;

/**
 *
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public class ParametersBuilder {

    private Map<String, Object> parameters;
    private Map<String, Object> extra;

    /**
 * 是否开启链式依赖：如果开启链式依赖的话，查询条件遵守最左依赖原则，目的是为了优化联合索引的性能
     */
    private boolean chainedDepend;

    private ParametersBuilder() {
        this.parameters = new LinkedMap();
        this.extra = new HashedMap();
        this.chainedDepend = false;
    }

    public static ParametersBuilder custom() {
        return new ParametersBuilder();
    }

    public ParametersBuilder add(String name, Object value) {
        this.parameters.put(name, value);
        return this;
    }

    public ParametersBuilder remove(String name) {
        this.parameters.remove(name);
        return this;
    }

    public ParametersBuilder enabledChainedDepend() {
        this.chainedDepend = true;
        return this;
    }

    public ParametersBuilder disabledChainedDepend() {
        this.chainedDepend = false;
        return this;
    }

    public ParametersBuilder extra(String name, Object data) {
        this.extra.put(name, data);
        return this;
    }

    public Map<String, Object> extras() {
        return this.extra;
    }

    public Object extra(String name) {
        return this.extra.get(name);
    }

    public boolean isChainedDepend() {
        return chainedDepend;
    }

    public Map<String, Object> build() {
        return parameters;
    }

}
