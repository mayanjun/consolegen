package ${packageName}.bean;

/**
 * 系统设置
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
public class Settings {

    private Boolean verboseLogEnabled = false;

    public Boolean getVerboseLogEnabled() {
        return verboseLogEnabled;
    }

    public void setVerboseLogEnabled(Boolean verboseLogEnabled) {
        this.verboseLogEnabled = verboseLogEnabled;
    }
}