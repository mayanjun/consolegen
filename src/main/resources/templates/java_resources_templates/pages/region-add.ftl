<!DOCTYPE html>
<html lang="en">
<head>
    <title></title>
    <#include "../inc/common-head.ftl">
    <link rel="stylesheet" href="/css/add.css" type="text/css">
</head>
<body>
<div id="app">
    <#-- 头部 -->
    <el-row>
        <el-page-header @back="goBack" :content="title"></el-page-header>
    </el-row>

    <#-- 表单 -->
    <el-row>
        <el-col :span="5">&nbsp;</el-col>
        <el-col :span="13">
            <el-form :model="form"
                     size="small"
                     :rules="rules"
                     ref="form"
                     status-icon
                     label-width="100px"
                     v-loading="loading"
                     style="margin-top: 20px">

                <el-form-item label="地区名称" prop="name">
                    <el-input v-model="form.name" maxlength="32" show-word-limit clearable></el-input>
                </el-form-item>

                <el-form-item label="选择父地区" prop="parentId">
                    <el-autocomplete v-model="parentId" style="width: 100%"
                                     popper-class="my-autocomplete"
                                     :fetch-suggestions="queryParentData"
                                     placeholder="请输入内容" clearable
                                     @select="handleParentSelect">
                        <template slot-scope="{ item }">
                            <div class="name">{{ item.name }}</div>
                            <span class="addr">{{ item.longName }}</span>
                        </template>
                    </el-autocomplete>
                </el-form-item>

                <el-form-item label="简短名称" prop="shortName">
                    <el-input placeholder="一般是去掉后面的市、镇、县等修饰的名字" v-model="form.shortName" maxlength="32" show-word-limit clearable></el-input>
                </el-form-item>

                <el-form-item label="长名称">
                    <el-input placeholder="自动生成，不可更改" readonly v-model="form.longName" maxlength="255" show-word-limit clearable></el-input>
                </el-form-item>

                <el-form-item label="区域级别">
                    <el-input type="number" placeholder="自动生成，不可更改" readonly v-model="form.level" show-word-limit clearable></el-input>
                </el-form-item>

                <el-form-item label="电话区号">
                    <el-input v-model="form.number" maxlength="10" show-word-limit clearable></el-input>
                </el-form-item>

                <el-form-item label="邮政编码">
                    <el-input v-model="form.postcode" maxlength="10" show-word-limit clearable></el-input>
                </el-form-item>

                <el-form-item label="经纬度">
                    <el-col :span="11">
                        <el-input placeholder="经度" v-model="form.longitude" type="number" show-word-limit clearable>
                            <template slot="prepend">经度</template>
                        </el-input>
                    </el-col>
                    <el-col :span="2">&nbsp;</el-col>
                    <el-col :span="11">
                        <el-input placeholder="纬度" v-model="form.latitude" type="number" show-word-limit clearable>
                            <template slot="prepend">纬度</template>
                        </el-input>
                    </el-col>
                </el-form-item>

                <#-- sbumit button -->
                <el-form-item>
                    <el-button size="small" type="primary" @click="submitForm">{{update ? '提交修改' : '立即创建'}}</el-button>
                </el-form-item>
            </el-form>
        </el-col>
        <el-col :span="6">&nbsp;</el-col>
    </el-row>
</div>
</body>
<script type="text/javascript">
    // ************** REQUIRED ***************
    var app;
    var module = '${module!""}';
    var moduleTitle = '地区';
    var entityId = '${entityId!""}';
    // ***************************************

    function loadParentData(key, callback) {
        if (key === '') return callback([]);
        var params = {
            page: 1,
            pageSize: 50,
            sname: key
        };
        axios.get('/api/region', {
            params: params
        }).then(function (value) {
            if (value.data.code == 0) {
                var list = value.data.list;
                if (list && list.length > 0) {
                    for (var index in list) {
                        list[index].value = list[index].name;
                    }
                    callback(list);
                } else {
                    callback([]);
                }
            } else {
                showMessage('数据加载错误：' + value.data.msg);
                callback([]);
            }
        }).catch(function (reason) {
            showMessage('数据加载错误：' + reason);
            callback([]);
        });
    }

    function checkParent(rule, value, callback) {
        if (app.form.parent.id) {
            return callback();
        } else {
            callback(new Error('请选择父地区'));
        }
    }

    // Vue 初始化之前的回调
    function pre_vue_init(vue_options) {
        vue_options.data.parentId = '';
        vue_options.data.form.parent = {};

        vue_options.methods['queryParentData'] = function (key, callback) {
            loadParentData(key, callback);
        };

        vue_options.methods['handleParentSelect'] = function (item) {
            app.form.parent.id = item.id;
            app.form.longName = item.longName + ',' + (app.form.name && app.form.name != '' ? app.form.name : '[请输入地区名称]');
            app.form.level = item.level + 1;
        };

        vue_options.data.rules = {
            name: [
                {required: true, message: '请输入地区名称', trigger: 'blur'}
            ],
            shortName: [
                {required: true, message: '请输入短地区名称', trigger: 'blur'}
            ],
            parentId: [
                { validator: checkParent, trigger: 'blur', required: true}
            ]
        };
    };

    // 更新数据时数据加载完成后的回调
    function dataloaded_vue_init(app) {
        if (app.form.parent.id) {
            axios.get('/api/region/' + app.form.parent.id)
                .then(function (value) {
                if (value.data.code == 0) {
                    var parent = value.data.entity;
                    if (parent) {
                        app.parentId = parent.name;
                    }
                } else {
                    showMessage('数据加载错误：' + value.data.msg);
                }
            }).catch(function (reason) {
                showMessage('数据加载错误：' + reason);
            });
        }
    }

    // Vue 初始化完成后的回调
    function post_vue_init(app) {

    }

    // 数据提交之前的回调
    function before_submit(app) {

    }
</script>
<script type="text/javascript" src="/js/local/add.js"></script>
</html>