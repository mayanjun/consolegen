package ${packageName}.business;

import ${packageName}.bean.Region;
import net.sourceforge.pinyin4j.PinyinHelper;
import net.sourceforge.pinyin4j.format.HanyuPinyinOutputFormat;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.Assert;
import org.mayanjun.myjack.api.query.Query;
import org.mayanjun.myjack.api.query.QueryBuilder;
import org.mayanjun.myjack.api.query.SortDirection;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

import static net.sourceforge.pinyin4j.format.HanyuPinyinToneType.WITHOUT_TONE;
import static net.sourceforge.pinyin4j.format.HanyuPinyinVCharType.WITH_V;

/**
 * 地区管理
 * @since ${date}
 * @author ${author}
 * @vendor ${vendor}
 * @generator ${generatorVersion}
 * @manufacturer ${manufacturer}
 */
@Component
public class RegionBusiness extends BaseBusiness<Region> {

    private static final Logger LOG = LoggerFactory.getLogger(RegionBusiness.class);
    private static final HanyuPinyinOutputFormat HANYUPINYINFORMAT = new HanyuPinyinOutputFormat();

    static {
        HANYUPINYINFORMAT.setVCharType(WITH_V);
        HANYUPINYINFORMAT.setToneType(WITHOUT_TONE);
    }

    @Override
    protected void doCheck(Region entity, boolean update) {
        Assert.notBlank(entity.getName(), "名称不能为空");
        Assert.notBlank(entity.getShortName(), "短名称不能为空");
        Assert.notNull(entity.getParent(), "父级不能为空");

        if (StringUtils.isNotBlank(entity.getShortName())) {
            StringBuffer sb = new StringBuffer();
            char cs[] = entity.getShortName().toCharArray();
            for (char c : cs) {
                try {
                    String pinyin[] = PinyinHelper.toHanyuPinyinStringArray(c, HANYUPINYINFORMAT);
                    if (pinyin != null && pinyin.length > 0) sb.append(pinyin[0]);
                } catch (Exception e) {
                    LOG.info("Convert pinyin error: " + c, e);
                }
            }
            if (sb.length() > 0) {
                sb.setCharAt(0, Character.toUpperCase(sb.charAt(0)));
            }
            entity.setPinyin(sb.toString());
        }
    }

    @Override
    protected void renderListAllBuilder(QueryBuilder<Region> builder) {
        builder.orderBy("pinyin", SortDirection.ASC);
    }

    @Override
    public void delete(Long[] ids) {
        transaction().execute(transactionStatus -> {
            Set<Long> idset = new HashSet<>();
            for (Long id : ids) {
                loadTree(idset, id);
            }
            idset.stream().forEach(e -> {
                Region region = new Region(e);
                service.delete(region);
            });
            LOG.info("Region delete done: size={}", idset.size());
            return 0;
        });
    }

    private void loadTree(Set<Long> set, Long id) {
        if (set.contains(id)) return;
        set.add(id);
        Query<Region> query = QueryBuilder.custom(Region.class)
                .andEquivalent("parent", id)
                .includeFields("id")
                .build();
        List<Region> regions = service.query(query);
        regions.stream().forEach(e -> loadTree(set, e.getId()));
    }
}
