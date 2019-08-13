package ${packageName}.bean;

import org.mayanjun.myjack.api.annotation.Column;
import org.mayanjun.myjack.api.annotation.Index;
import org.mayanjun.myjack.api.annotation.IndexColumn;
import org.mayanjun.myjack.api.annotation.Table;
import org.mayanjun.myjack.api.entity.EntityBean;
import org.mayanjun.myjack.api.enums.DataType;

/**
 * 文件元数据
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Table(value = "t_file_meta",
        indexes = {
                @Index(value = "idx_name", columns = @IndexColumn("name")),
                @Index(value = "idx_dir", columns = @IndexColumn("dir")),
                @Index(value = "idx_tag", columns = @IndexColumn("tag")),
        },
        comment = "访客记录")
public class FileMeta extends EntityBean {

    @Column(length = "64")
    private String name;

    @Column(length = "32")
    private String dir;

    @Column(type = DataType.BIGINT)
    private Long size;

    @Column(length = "64")
    private String mime;

    @Column(length = "32")
    private String tag;

    public FileMeta() {
    }

    public FileMeta(Long id) {
        super(id);
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getDir() {
        return dir;
    }

    public void setDir(String dir) {
        this.dir = dir;
    }

    public Long getSize() {
        return size;
    }

    public void setSize(Long size) {
        this.size = size;
    }

    public String getMime() {
        return mime;
    }

    public void setMime(String mime) {
        this.mime = mime;
    }

    public String getTag() {
        return tag;
    }

    public void setTag(String tag) {
        this.tag = tag;
    }
}
