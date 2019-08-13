package org.mayanjun.gen;

import org.apache.commons.collections.CollectionUtils;
import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
import org.mayanjun.util.JavaTypeUtils;
import org.mayanjun.util.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;
import java.util.concurrent.atomic.AtomicBoolean;

import static org.mayanjun.util.FileUtils.mkdirs;
import static org.mayanjun.util.JavaTypeUtils.*;
import static org.mayanjun.util.JavaTypeUtils.isFloat;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class ListPageCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(ListPageCodeGenerator.class);

    public ListPageCodeGenerator(GeneratorContext context) {
        super(context);
    }

    @Override
    public void execute() throws Exception {
        ProjectConfig config = context().getProjectConfig();

        List<EntityConfig> configs = config.getEntityConfigs();
        if (CollectionUtils.isNotEmpty(configs)) {
            Map<String, Object> root = rootMap();
            configs.forEach(e -> {
                try {
                    root.put("class_name", e.getClassName());
                    root.put("comment", e.getComment());
                    root.put("data_export_supported", e.isExportSupported());
                    renderListHtmlCode(e, root);
                    renderEntityHtmlCode(e, root);
                } catch (Exception ex) {
                    throw new ServiceException(Status.INTERNAL_ERROR, "Generate entity code error", e.getClassName(), ex);
                }
            });
        }
        LOG.info("Java list page code generate done");
    }


    private void renderEntityHtmlCode(EntityConfig entityConfig, Map<String, Object> root) throws Exception {
        File targetDir = new File(context().getProjectDir(), PROJECT_FOLDERS[5] + "/pages");
        mkdirs(targetDir);
        File targetFile = new File(targetDir, Strings.toRequestMapping(entityConfig.getClassName()) + "-list.ftl");
        context().getTemplateConfiguration().getTemplate("java_entity_templates/entity-list.tpl").process(root, new OutputStreamWriter(new FileOutputStream(targetFile)));
    }

    /**
     * 渲染字段
     * @param entityConfig
     * @param root
     */
    private void renderListHtmlCode(EntityConfig entityConfig, Map<String, Object> root) {
        List<FieldConfig> fieldConfigs = entityConfig.getFieldConfigs();
        if (CollectionUtils.isNotEmpty(fieldConfigs)) {

            StringJoiner htmlSearchParamsJoiner = new StringJoiner("\n");
            StringJoiner vueScriptOptionsJoiner = new StringJoiner("\n");
            StringJoiner htmlTableColumnJoiner = new StringJoiner("\n");
            StringJoiner htmlCodeJoiner = new StringJoiner("\n");

            final AtomicBoolean descDialogRendered = new AtomicBoolean(false);
            final AtomicBoolean imagePreviewRendered = new AtomicBoolean(false);

            fieldConfigs.forEach(f -> {
                String javaType = f.getJavaType();
                String fname = f.getName();

                // render html table column
                if (isDate(javaType)) {
                    htmlTableColumnJoiner.add(String.format("<el-table-column prop=\"%s\" label=\"%s\" width=\"140\" align=\"center\"></el-table-column>",
                            fname, f.getComment()));
                } else if (isBoolean(javaType)) {
                    String html = " <el-table-column prop=\"%s\" label=\"%s\" align=\"center\">\n" +
                            "                <template slot-scope=\"scope\">\n" +
                            "                    <i :class=\"scope.row.%s ? 'el-icon-check' : 'el-icon-close'\"></i>\n" +
                            "                </template>\n" +
                            "            </el-table-column>";
                    htmlTableColumnJoiner.add(String.format(html, fname, f.getComment(), fname));
                } else if (f.getInputType() == InputType.FILE_IMAGE) {
                    String html = "<el-table-column prop=\"%s\" label=\"%s\" width=\"60\" align=\"center\">\n" +
                            "                <template slot-scope=\"scope\">\n" +
                            "                    <el-image v-if=\"!(scope.row.%s == '')\"\n" +
                            "                              @click=\"showImagePreview(scope.row.%s)\"\n" +
                            "                              :src=\"scope.row.%s\"\n" +
                            "                              fit=\"contain\" class=\"list-image\"></el-image>\n" +
                            "                    <el-image v-else\n" +
                            "                              src=\"/images/noimage.png\" fit=\"contain\" class=\"list-image\"></el-image>\n" +
                            "                </template>\n" +
                            "            </el-table-column>";

                    htmlTableColumnJoiner.add(String.format(html, fname, f.getComment(), fname, fname, fname));

                    if (!imagePreviewRendered.get()) {
                        htmlCodeJoiner.add("<el-dialog :visible.sync=\"imagePreviewDialogVisible\" width=\"440px\">\n" +
                                "        <img width=\"400\" :src=\"imagePreviewURL\" alt=\"\" style=\"text-align: center\">\n" +
                                "    </el-dialog>");
                        vueScriptOptionsJoiner.add("vue_options.data.imagePreviewDialogVisible = false;");
                        vueScriptOptionsJoiner.add("vue_options.data.imagePreviewURL = '/images/noimage.png';");
                        vueScriptOptionsJoiner.add(" vue_options.methods['showImagePreview'] = function (url) {\n" +
                                "            this.imagePreviewURL = url;\n" +
                                "            this.imagePreviewDialogVisible = true;\n" +
                                "        }");
                        imagePreviewRendered.set(true);
                    }
                } else if (f.getInputType() == InputType.FILE_ORDINARY) {
                    String html = "<el-table-column prop=\"%s\" label=\"%s\" width=\"150\" align=\"center\">\n" +
                            "                <template slot-scope=\"scope\">\n" +
                            "                    <el-link target=\"_blank\" style=\"font-size: 12px\" icon=\"el-icon-link\" :href=\"scope.row.%s == '' ? 'javascript:;' : scope.row.%s\">下载</el-link>\n" +
                            "                </template>\n" +
                            "            </el-table-column>";
                    htmlTableColumnJoiner.add(String.format(html, fname, f.getComment(), fname, fname));
                } else if (JavaTypeUtils.isEnmuType(f)) {
                    String formatterName = f.getName() + "_formatter";
                    htmlTableColumnJoiner.add(String.format("<el-table-column prop=\"%s\" label=\"%s\" :formatter=\"%s\"></el-table-column>", fname, f.getComment(), formatterName));

                    String values[] = f.getEnumValues();
                    StringJoiner valuesJoiner = new StringJoiner("\n");
                    for (int i = 0; i < values.length; i+=2) {
                        String value = values[i].toUpperCase();
                        String label = values[i + 1];
                        valuesJoiner.add(String.format("case '%s': return '%s';", value, label));
                    }

                    String script = "vue_options.methods['%s'] = function (row, column, cellValue, index) {\n" +
                            "           switch(cellValue) {\n" +
                            "               %s" +
                            "               default: return '未知';\n" +
                            "           }\n" +
                            "        }";
                    vueScriptOptionsJoiner.add(String.format(script, formatterName, valuesJoiner.toString()));
                } else if (isString(javaType) && f.getInputLength() > 64) {
                    String html = "<el-table-column prop=\"%s\" label=\"%s\" width=\"80\" align=\"center\">\n" +
                            "                <template slot-scope=\"scope\">\n" +
                            "                    <el-link style=\"font-size: 12px\"\n" +
                            "                             icon=\"el-icon-link\"\n" +
                            "                             @click=\"openDescDialog(scope.row.%s)\">查看</el-link>\n" +
                            "                </template>\n" +
                            "            </el-table-column>";
                    htmlTableColumnJoiner.add(
                            String.format(html, fname, f.getComment(), fname)
                    );

                    if (!descDialogRendered.get()) {
                        htmlCodeJoiner.add(
                                "<el-dialog :visible.sync=\"descDialogVisible\" width=\"80%\" center fullscreen>\n" +
                                        "        <div v-html=\"descDialogContent\"></div>\n" +
                                        "        <span slot=\"footer\" class=\"dialog-footer\">\n" +
                                        "            <el-button size=\"small\" type=\"primary\" @click=\"descDialogVisible = false\" icon=\"el-icon-circle-close\">关闭</el-button>\n" +
                                        "        </span>\n" +
                                        "    </el-dialog>"
                        );

                        vueScriptOptionsJoiner.add("vue_options.data.descDialogVisible = false;");
                        vueScriptOptionsJoiner.add("vue_options.data.descDialogContent = '';");
                        vueScriptOptionsJoiner.add(String.format("vue_options.methods['openDescDialog'] = function (data) {\n" +
                                "            this.descDialogContent = data;\n" +
                                "            this.descDialogVisible = true;\n" +
                                "        }\n", fname));
                        descDialogRendered.set(true);
                    }
                } else {
                    htmlTableColumnJoiner.add(String.format("<el-table-column prop=\"%s\" label=\"%s\"></el-table-column>", fname, f.getComment()));
                }

                // render html search
                if (f.isIndexed()) {
                    String pattern = f.getPattern();
                    // render html search
                    if (isString(javaType)) {
                        int length = JavaTypeUtils.nonPrimitiveTypeDatabaseLength(f.getJavaType(), f.getDatabaseLength());
                        String html = "<el-form-item><el-input class=\"short-input\" maxlength=\"%s\" placeholder=\"%s\" v-model=\"searchForm.s%s\" clearable @clear=\"searchData\" @keyup.enter.native=\"searchData\"></el-input></el-form-item>";
                        htmlSearchParamsJoiner.add( String.format(html, length, f.getComment(), f.getName()));
                    } else if (isDate(javaType)) {
                        root.put("vue_date_options_present", true);
                        String html = "<el-form-item>\n" +
                                "                <el-date-picker style=\"width: 240px\"\n" +
                                "                        @change=\"handle%sSelected\"\n" +
                                "                        v-model=\"%sDates\"" +
                                "                        type=\"daterange\"\n" +
                                "                        align=\"right\"\n" +
                                "                        unlink-panels\n" +
                                "                        value-format=\"%s\"\n" +
                                "                        range-separator=\"至\"\n" +
                                "                        start-placeholder=\"%s\"\n" +
                                "                        end-placeholder=\"%s\"\n" +
                                "                        :picker-options=\"pickerOptions\">\n" +
                                "                </el-date-picker>\n" +
                                "            </el-form-item>";
                        htmlSearchParamsJoiner.add(String.format(html, f.getName(), f.getName(), pattern, f.getComment(), f.getComment()));
                        String dateScript = "vue_options.data.%sDates = [];\n" +
                                "vue_options.methods['handle%sSelected'] = function (values) {\n" +
                                "                app.searchForm.s%s0 = values[0];\n" +
                                "                app.searchForm.s%s1 = values[1];\n" +
                                "                this.searchData();\n" +
                                "            };";
                        vueScriptOptionsJoiner.add(String.format(dateScript, f.getName(), f.getName(), f.getName(), f.getName()));
                    } else if (isInteger(javaType)) {
                        String html = "<el-form-item><el-input class=\"short-input\" maxlength=\"%s\" placeholder=\"%s\" v-model=\"searchForm.s%s\" clearable @clear=\"searchData\"  @input=\"numberFilter('searchForm.s%s')\" @keyup.enter.native=\"searchData\"></el-input></el-form-item>";
                        htmlSearchParamsJoiner.add( String.format(html, "18", f.getComment(), f.getName(), f.getName()));
                    } else if (isFloat(javaType)) {
                        String html = "<el-form-item><el-input class=\"short-input\" maxlength=\"%s\" placeholder=\"%s\" v-model=\"searchForm.s%s\" clearable @clear=\"searchData\"  @input=\"floatFilter('searchForm.s%s')\" @keyup.enter.native=\"searchData\"></el-input></el-form-item>";
                        htmlSearchParamsJoiner.add( String.format(html, "18", f.getComment(), f.getName(), f.getName()));
                    }
                }
            });

            if (htmlCodeJoiner.length() > 0) {
                root.put("html_code", htmlCodeJoiner.toString());
            }

            if (htmlSearchParamsJoiner.length() > 0) {
                root.put("html_search_params", htmlSearchParamsJoiner.toString());
            }

            if (vueScriptOptionsJoiner.length() > 0) {
                root.put("vue_scripts_options", vueScriptOptionsJoiner.toString());
            }

            if (htmlTableColumnJoiner.length() > 0) {
                root.put("html_table_columns", htmlTableColumnJoiner.toString());
            }
        }
    }

    @Override
    public int getOrder() {
        return GeneratorOrder.PAGES_LIST_CODE_GENERATOR.ordinal();
    }
}
