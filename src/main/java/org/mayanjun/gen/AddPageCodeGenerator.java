package org.mayanjun.gen;

import org.apache.commons.collections.CollectionUtils;
import org.apache.commons.lang3.StringUtils;
import org.mayanjun.core.ServiceException;
import org.mayanjun.core.Status;
import org.mayanjun.myjack.api.enums.DataType;
import org.mayanjun.util.Strings;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.FileOutputStream;
import java.io.OutputStreamWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.StringJoiner;

import static org.mayanjun.util.FileUtils.mkdirs;
import static org.mayanjun.util.JavaTypeUtils.*;

/**
 * @author mayanjun
 * @date 2019-07-24
 */
public class AddPageCodeGenerator extends TemplateCodeGenerator {

    private static final Logger LOG = LoggerFactory.getLogger(AddPageCodeGenerator.class);

    public AddPageCodeGenerator(GeneratorContext context) {
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
                    renderAddHtmlCode(e, root);
                    renderEntityHtmlCode(e, root);
                } catch (Exception ex) {
                    throw new ServiceException(Status.INTERNAL_ERROR, "Generate entity code error", e.getClassName(), ex);
                }
            });
        }
        LOG.info("Java add page code generate done");
    }

    private void renderEntityHtmlCode(EntityConfig entityConfig, Map<String, Object> root) throws Exception {
        File targetDir = new File(context().getProjectDir(), PROJECT_FOLDERS[5] + "/pages");
        mkdirs(targetDir);
        File targetFile = new File(targetDir, Strings.toRequestMapping(entityConfig.getClassName()) + "-add.ftl");
        context().getTemplateConfiguration().getTemplate("java_entity_templates/entity-add.tpl").process(root, new OutputStreamWriter(new FileOutputStream(targetFile)));
    }

    /**
     * 渲染字段
     * @param entityConfig
     * @param root
     */
    private void renderAddHtmlCode(EntityConfig entityConfig, Map<String, Object> root) {
        List<FieldConfig> fieldConfigs = entityConfig.getFieldConfigs();
        if (CollectionUtils.isNotEmpty(fieldConfigs)) {

            StringJoiner htmlFieldsJoiner = new StringJoiner("\n");
            StringJoiner vueScriptsJoiner = new StringJoiner("\n");
            StringJoiner dataloadedScriptsJoiner = new StringJoiner("\n");
            StringJoiner functionScriptsJoiner = new StringJoiner("\n");

            fieldConfigs.forEach(f -> {
                String javaType = f.getJavaType();
                String fname = f.getName();

                if (isBoolean(javaType)) { // boolean类型强制渲染成开关形式
                    String html = "<el-form-item label=\"%s\" prop=\"%s\">\n" +
                            "                    <el-switch v-model=\"form.%s\"></el-switch>\n" +
                            "                </el-form-item>";
                    htmlFieldsJoiner.add(
                            String.format(html, f.getComment(), fname, fname)
                    );
                } else if (isInteger(javaType)) {
                    if (f.getInputType() == InputType.SEARCH) {
                        renderRemoteSearchField(f, htmlFieldsJoiner, vueScriptsJoiner, functionScriptsJoiner);
                        return;
                    }
                    String html = " <el-form-item label=\"%s\" prop=\"%s\">\n" +
                            "                    <el-input v-model=\"form.%s\" maxlength=\"15\" @input=\"numberFilter('form.%s')\"  show-word-limit clearable placeholder=\"%s\"></el-input>\n" +
                            "                </el-form-item>";
                    htmlFieldsJoiner.add(
                            String.format(html, f.getComment(), fname, fname, fname, f.getComment())
                    );
                } else if (isFloat(javaType)) {
                    String html = " <el-form-item label=\"%s\" prop=\"%s\">\n" +
                            "                    <el-input v-model=\"form.%s\" maxlength=\"15\" @input=\"floatFilter('form.%s')\"  show-word-limit clearable placeholder=\"%s\"></el-input>\n" +
                            "                </el-form-item>";
                    htmlFieldsJoiner.add(
                            String.format(html, f.getComment(), fname, fname, fname, f.getComment())
                    );
                } else if (isDate(javaType)) {
                    String html;
                    if (f.getDatabaseType() == DataType.TIME) {
                        html = " <el-form-item label=\"%s\">\n" +
                                "                    <el-time-picker value-format=\"%s\"\n" +
                                "                                    v-model=\"form.%s\"\n" +
                                "                                    placeholder=\"%s\">\n" +
                                "                    </el-time-picker>\n" +
                                "                </el-form-item>";
                    } else {
                        html = "<el-form-item label=\"%s\" required>\n" +
                                "                    <el-date-picker\n" +
                                "                                    value-format=\"%s\"\n" +
                                "                                    v-model=\"form.%s\"\n" +
                                "                                    placeholder=\"%s\">\n" +
                                "                    </el-date-picker>\n" +
                                "                </el-form-item>";
                    }

                    htmlFieldsJoiner.add(
                            String.format(html, f.getComment(), f.getPattern(), fname, f.getComment())
                    );
                } else if (isEnmuType(f)) { // 枚举的生成 Ratio
                    String html = " <el-form-item label=\"%s\">\n" +
                            "                    <el-radio-group v-model=\"form.%s\">\n" +
                            "%s" +
                            "                    </el-radio-group>\n" +
                            "                </el-form-item>";

                    String values[] = f.getEnumValues();
                    StringJoiner valuesJoiner = new StringJoiner("\n");
                    for (int i = 0; i < values.length; i+=2) {
                        String value = values[i].toUpperCase();
                        String label = values[i + 1];
                        valuesJoiner.add(String.format("<el-radio-button label=\"%s\">\n" +
                                "                            <span>%s</span>\n" +
                                "                        </el-radio-button>", value, label));
                    }
                    htmlFieldsJoiner.add(
                            String.format(html, f.getComment(), fname, valuesJoiner.toString())
                    );
                } else if (f.getInputType() == InputType.FILE_IMAGE) { // 文件选择
                    String uploadOptionsName = f.getName() + "_uploadOptions";
                    String handleSuccessName = f.getName() + "_UploadSuccess";
                    String handleErrorName = f.getName() + "_UploadError";
                    String handleBeforeName = f.getName() + "_BeforeUpload";
                    String tagName = entityConfig.getClassName() + "_" + f.getName();
                    String vmodelName = f.getName() + "_image";

                    String html = "<el-form-item label=\"%s\" style=\"margin-bottom: 0\" required>\n" +
                            "                    <el-upload :data=\"%s\"\n" +
                            "                            class=\"avatar-uploader\"\n" +
                            "                            action=\"/api/file/\"\n" +
                            "                            :show-file-list=\"false\"\n" +
                            "                            :on-success=\"%s\"\n" +
                            "                            :on-error=\"%s\"\n" +
                            "                            :before-upload=\"%s\">\n" +
                            "                        <el-image v-if=\"%s\" :src=\"%s\" fit=\"contain\" class=\"avatar list-image\"></el-image>\n" +
                            "                        <i v-else class=\"el-icon-plus avatar-uploader-icon\"></i>\n" +
                            "                        <span slot=\"tip\" class=\"filetips\">请按要求上传照片。<br>支持JPG,PNG,BMP格式，大小不超过10M</span>\n" +
                            "                    </el-upload>\n" +
                            "                </el-form-item>";

                    htmlFieldsJoiner.add(
                            String.format(html, f.getComment(), uploadOptionsName, handleSuccessName, handleErrorName, handleBeforeName, vmodelName, vmodelName)
                    );

                    String uploadJSHtml = "vue_options.data.%s = {tag: '%s'};\n" +
                            "        vue_options.data.%s = null;\n" +
                            "        vue_options.methods['%s'] = function (file) {\n" +
                            "            var isJPG = (file.type === 'image/jpeg') || (file.type === 'image/png') || (file.type === 'image/bmp');\n" +
                            "            var isLt2M = file.size / 1024 / 1024 < 10;\n" +
                            "\n" +
                            "            if (!isJPG) {\n" +
                            "                showMessage('上传头像图片只能是 JPG|PNG|BMP 格式!');\n" +
                            "            }\n" +
                            "            if (!isLt2M) {\n" +
                            "                showMessage('上传头像图片大小不能超过 10MB!');\n" +
                            "            }\n" +
                            "            return isJPG && isLt2M;\n" +
                            "        };\n" +
                            "\n" +
                            "        vue_options.methods['%s'] = function (response, file) {\n" +
                            "            if (response.code == 0) {\n" +
                            "                this.form.%s = response.url;\n" +
                            "                this.%s = response.url;\n" +
                            "            } else {\n" +
                            "                showMessage(response.msg, 'error');\n" +
                            "            }\n" +
                            "        };\n" +
                            "\n" +
                            "        vue_options.methods['%s'] = function (err, file, fileList) {\n" +
                            "            showMessage(err, 'error');\n" +
                            "        };";
                    vueScriptsJoiner.add(
                            String.format(uploadJSHtml, uploadOptionsName, tagName, vmodelName, handleBeforeName, handleSuccessName, fname, vmodelName, handleErrorName)
                    );
                    dataloadedScriptsJoiner.add(String.format("if (app.form.%s) app.%s = app.form.%s;", fname, vmodelName, fname));

                } else if (f.getInputType() == InputType.FILE_ORDINARY) {
                    String uploadOptionsName = f.getName() + "_uploadOptions";
                    String handleSuccessName = f.getName() + "_UploadSuccess";
                    String handleErrorName = f.getName() + "_UploadError";
                    String handleBeforeName = f.getName() + "_BeforeUpload";
                    String tagName = entityConfig.getClassName() + "_" + f.getName();
                    String fileListName = f.getName() + "FileList";

                    String html = "<el-form-item label=\"%s\" required>\n" +
                            "                    <el-upload :data=\"%s\"\n" +
                            "                            action=\"/api/file/\"\n" +
                            "                            :file-list=\"%s\"\n" +
                            "                            :on-success=\"%s\"\n" +
                            "                            :on-error=\"%s\"\n" +
                            "                            :before-upload=\"%s\" :limit=\"1\">\n" +
                            "                        <el-button size=\"small\" type=\"primary\">点击上传文件</el-button>\n" +
                            "                        <span slot=\"tip\" style=\"font-size: 10px; color: #888888; padding-left: 20px\">请按要求上传文件，文件不超过80Mb</span>\n" +
                            "                    </el-upload>\n" +
                            "                </el-form-item>";

                    htmlFieldsJoiner.add(
                            String.format(html, f.getComment(), uploadOptionsName, handleSuccessName, handleErrorName, handleBeforeName)
                    );

                    String uploadJSHtml = "vue_options.data.%s = {tag: '%s'};\n" +
                            "        vue_options.data.%s = [];\n" +
                            "        vue_options.methods['%s'] = function (file) {\n" +
                            "            //var isZIP = (file.type === 'application/vnd.android.package-archive');\n" +
                            "            var sizeOK = file.size / 1024 / 1024 < 80;\n" +
                            "            //if (!isZIP) {\n" +
                            "            //    showMessage('上传文件只能是 APK 格式!');\n" +
                            "            //}\n" +
                            "            if (!sizeOK) {\n" +
                            "                showMessage('上传文件大小不能超过 80MB!');\n" +
                            "            }\n" +
                            "            //return isZIP && sizeOK;\n" +
                            "            return sizeOK;\n" +
                            "        };\n" +
                            "\n" +
                            "        vue_options.methods['%s'] = function (response, file) {\n" +
                            "            if (response.code == 0) {\n" +
                            "                this.form.%s = response.url;\n" +
                            "            } else {\n" +
                            "                showMessage(response.msg, 'error');\n" +
                            "            }\n" +
                            "        }\n" +
                            "\n" +
                            "        vue_options.methods['%s'] = function (err, file, fileList) {\n" +
                            "            showMessage(err, 'error');\n" +
                            "        }";
                    vueScriptsJoiner.add(
                            String.format(uploadJSHtml, uploadOptionsName, tagName, fileListName, handleBeforeName, handleSuccessName, fname, handleErrorName)
                    );

                    dataloadedScriptsJoiner.add(String.format("app.%s = [\n" +
                            "            {\n" +
                            "                name: '文件:' + app.form.%s,\n" +
                            "                url: app.form.%s\n" +
                            "            }\n" +
                            "        ]", fileListName, fname, fname));

                } else { // INPUT
                    int len = f.getInputLength();
                    if (len <= 100) {
                        String html = "<el-form-item label=\"%s\" prop=\"%s\">\n" +
                                "                    <el-input v-model=\"form.%s\" maxlength=\"%d\" show-word-limit clearable></el-input>\n" +
                                "                </el-form-item>";
                        htmlFieldsJoiner.add(String.format(html, f.getComment(), fname, fname, f.getInputLength()));
                    } else {
                        String html = "<el-form-item label=\"%s\">\n" +
                                "                    <el-input type=\"textarea\" maxlength=\"%d\" show-word-limit v-model=\"form.%s\" autosize></el-input>\n" +
                                "                </el-form-item>";
                        htmlFieldsJoiner.add(String.format(html, f.getComment(), len, fname));
                    }
                }
            });

            root.put("fields_html", htmlFieldsJoiner.toString());
            root.put("fields_vue_scripts", vueScriptsJoiner.toString());
            root.put("fields_vue_dataloaded_scripts", dataloadedScriptsJoiner.toString());
            root.put("function_scripts", functionScriptsJoiner.toString());
        }
    }

    /**
     * 渲染远程搜索字段
     * @param f
     * @param htmlFieldsJoiner
     * @param vueScriptsJoiner
     * @param functionScriptsJoiner
     */
    private void renderRemoteSearchField(FieldConfig f, StringJoiner htmlFieldsJoiner, StringJoiner vueScriptsJoiner, StringJoiner functionScriptsJoiner) {
        String fname = f.getName();
        String modelName = "remoteSearch_" + fname;
        String queryFunName = "queryRemote" + fname + "Data";
        String selectFunName = "handleRemote_" + fname + "Select";

        String html = "<el-form-item label=\"选择%s\" prop=\"%s\">\n" +
                "                    <el-autocomplete v-model=\"%s\" style=\"width: 100%%\"\n" +
                "                                     popper-class=\"my-autocomplete\"\n" +
                "                                     :fetch-suggestions=\"%s\"\n" +
                "                                     placeholder=\"请输入内容\" clearable\n" +
                "                                     @select=\"%s\">\n" +
                "                        <template slot-scope=\"{ item }\">\n" +
                "                            <div class=\"name\">{{ item.%s }}</div>\n" +
                "                            %s\n" +
                "                        </template>\n" +
                "                    </el-autocomplete>\n" +
                "                </el-form-item>";

        String desc = "";
        if (StringUtils.isNotBlank(f.getRemoteSearchDescField())) {
            desc = "<span class=\"addr\">{{ item." + f.getRemoteSearchDescField() + " }}</span>";
        }
        htmlFieldsJoiner.add(
                String.format(html, f.getComment(), modelName, modelName, queryFunName, selectFunName, f.getRemoteSearchLabelField(), desc)
        );


        String vueScripts = "vue_options.data.%s = '';" +
                "vue_options.methods['%s'] = function (key, callback) {\n" +
                "            __%s(key, callback);\n" +
                "        };";
        vueScriptsJoiner.add(
                String.format(vueScripts, modelName, queryFunName, queryFunName)
        );
        String haneleScripts = "vue_options.methods['%s'] = function (item) {\n" +
                "            app.form.%s = item.id;\n" +
                "        };";
        vueScriptsJoiner.add(
                String.format(haneleScripts, selectFunName, fname)
        );

        String functionScripts = "function __%s(key, callback) {\n" +
                "        if (key === '') return callback([]);\n" +
                "        var params = {\n" +
                "            page: 1,\n" +
                "            pageSize: 50,\n" +
                "            s%s: key\n" +
                "        };\n" +
                "        axios.get('/api/%s', {\n" +
                "            params: params\n" +
                "        }).then(function (value) {\n" +
                "            if (value.data.code == 0) {\n" +
                "                var list = value.data.list;\n" +
                "                if (list && list.length > 0) {\n" +
                "                    for (var index in list) {\n" +
                "                        list[index].value = list[index].%s;\n" +
                "                    }\n" +
                "                    callback(list);\n" +
                "                } else {\n" +
                "                    callback([]);\n" +
                "                }\n" +
                "            } else {\n" +
                "                showMessage('数据加载错误：' + value.data.msg);\n" +
                "                callback([]);\n" +
                "            }\n" +
                "        }).catch(function (reason) {\n" +
                "            showMessage('数据加载错误：' + reason);\n" +
                "            callback([]);\n" +
                "        });\n" +
                "    }";

        functionScriptsJoiner.add(
                String.format(functionScripts,
                        queryFunName,
                        f.getRemoteSearchLabelField(),
                        Strings.toRequestMapping(f.getRemoteSearchEntityName()),
                        f.getRemoteSearchLabelField())
        );
    }

    @Override
    public int getOrder() {
        return GeneratorOrder.PAGES_ADD_CODE_GENERATOR.ordinal();
    }
}
