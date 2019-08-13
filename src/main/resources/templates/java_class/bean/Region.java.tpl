package ${packageName}.bean;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myjack.api.annotation.Index;
import org.mayanjun.myjack.api.annotation.IndexColumn;
import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EditableEntity;
import org.mayanjun.myjack.api.enums.DataType;

/**
 * 地区
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "t_region",
        indexes = {
                @Index(value = "idx_name", columns = @IndexColumn("name")),
                @Index(value = "idx_pinyin", columns = @IndexColumn("pinyin"))
        },
        comment = "地区")
public class Region extends EditableEntity {

    @Column(length = "32")
    private String name;

    @Column(type = DataType.BIGINT, referenceField = "id")
    private Region parent;

    @Column(length = "32")
    private String shortName;

    @Column(type = DataType.INT)
    private Integer level;

    @Column(length = "10")
    private String number;

    @Column(length = "10")
    private String postcode;

    @Column(length = "255")
    private String longName;

    @Column(length = "10,7", type = DataType.DOUBLE)
    private Double longitude;

    @Column(length = "10,7", type = DataType.DOUBLE)
    private Double latitude;

    @Column(length = "500")
    private String pinyin;

    public Region() {
    }

    public Region(Long id) {
        super(id);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Region getParent() {
        return parent;
    }

    public void setParent(Region parent) {
        this.parent = parent;
    }

    public String getShortName() {
        return shortName;
    }

    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    public Integer getLevel() {
        return level;
    }

    public void setLevel(Integer level) {
        this.level = level;
    }

    public String getNumber() {
        return number;
    }

    public void setNumber(String number) {
        this.number = number;
    }

    public String getPostcode() {
        return postcode;
    }

    public void setPostcode(String postcode) {
        this.postcode = postcode;
    }

    public String getLongName() {
        return longName;
    }

    public void setLongName(String longName) {
        this.longName = longName;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public String getPinyin() {
        return pinyin;
    }

    public void setPinyin(String pinyin) {
        this.pinyin = pinyin;
    }
}
