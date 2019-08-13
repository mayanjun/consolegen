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

                <el-form-item label="角色名称" prop="name">
                    <el-input v-model="form.name" maxlength="32" show-word-limit clearable></el-input>
                </el-form-item>

                <el-form-item label="选择菜单">
                    <template>
                        <el-transfer
                                v-model="form.menus"
                                :titles="['菜单列表', '已选菜单']"
                                :data="menus"
                                filterable>
                        </el-transfer>
                    </template>
                </el-form-item>

                <el-form-item label="选择权限">
                    <template>
                        <el-transfer
                                v-model="form.privileges"
                                :titles="['可用权限', '已选择权限']"
                                :data="privileges"
                                filterable>
                        </el-transfer>
                    </template>
                </el-form-item>

                <el-form-item label="备注">
                    <el-input type="textarea" maxlength="500" show-word-limit v-model="form.description" clearable
                              autosize></el-input>
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
    var moduleTitle = '角色';
    var entityId = '${entityId!""}';
    // ***************************************

    function pre_vue_init(vue_options) {
        vue_options.data.rules = {
            name: [
                {required: true, message: '请输入角色名称', trigger: 'blur'}
            ]
        };
        vue_options.data.privileges = [];
        vue_options.data.menus = [];
    }

    function dataloaded_vue_init(app) {
        console.log(app.form.menus);
    }

    function post_vue_init(app) {
        axios.get('/api/privilege/all-privileges')
            .then(function (value) {
                if (value.data.code == 0) {
                    var list = value.data.list;
                    for (var index in list) {
                        list[index].key = list[index].id;
                        list[index].label = list[index].name;
                    }
                    app.privileges = list;
                } else {
                    showMessage('数据加载错误：' + value.data.msg);
                }
            })
            .catch(function (reason) {
                showMessage('数据加载错误：' + reason);
            });

        axios.get('/api/menu/all-menus')
            .then(function (value) {
                if (value.data.code == 0) {
                    var list = value.data.list;

                    var menuList = new Array();
                    for (var index in list) {
                        var parent = list[index];
                        parent.key = list[index].id;
                        parent.label = list[index].name;

                        menuList.push(parent);

                        if (parent.children && parent.children.length > 0) {
                            parent.disabled = true;
                            for (var ix in parent.children) {
                                var child = parent.children[ix];
                                child.key = child.id;
                                child.label = '　⊢' + child.name;
                                menuList.push(child);
                            }
                        }
                    }
                    app.menus = menuList;
                } else {
                    showMessage('数据加载错误：' + value.data.msg);
                }
            })
            .catch(function (reason) {
                showMessage('数据加载错误：' + reason);
            });
    }
</script>
<script type="text/javascript" src="/js/local/add.js"></script>
</html>