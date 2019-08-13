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
                <el-form-item label="是否管理员" prop="administrator">
                    <el-switch v-model="form.administrator"></el-switch>
                </el-form-item>

                <el-form-item label="用户名" prop="username">
                    <el-input v-model="form.username" maxlength="32" show-word-limit clearable :readonly="update"></el-input>
                </el-form-item>

                <el-form-item label="密码" prop="password">
                    <el-input type="password" v-model="form.password" maxlength="64" show-password show-word-limit autocomplete="off" clearable></el-input>
                </el-form-item>

                <el-form-item label="确认密码" prop="repeatPassword">
                    <el-input type="password" v-model="form.repeatPassword" maxlength="64" show-password show-word-limit autocomplete="off" clearable></el-input>
                </el-form-item>

                <el-form-item label="选择角色">
                    <template>
                        <el-transfer
                                v-model="form.roles"
                                :titles="['可用角色', '已选择角色']"
                                :data="roles"
                                filterable>
                        </el-transfer>
                    </template>
                </el-form-item>

                <el-form-item label="备注">
                    <el-input type="textarea" maxlength="500" show-word-limit v-model="form.description" clearable autosize></el-input>
                </el-form-item>

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
    var moduleTitle = '用户';
    var entityId = '${entityId!""}';
    // ***************************************

    var regex = new RegExp('(?=.*[0-9])(?=.*[a-zA-Z]).{6,32}');

    function validatePassword(rule, value, callback) {
        if (value == undefined) return callback();

        if (value.length > 0) {
            if (regex.test(value)) {
                callback();
            } else {
                callback(new Error('密码必须同时包含字母和数字，长度在6-32个字符之间'));
            }
        } else {
            callback();
        }
    }

    function pre_vue_init(vue_options) {
        vue_options.data.rules = {
            username: [
                {required: true, message: '请输入用户名', trigger: 'blur'},
                {min: 3, max: 32, message: '长度在 3 到 32 个字符', trigger: 'blur'}
            ],
            password: [
                {validator: validatePassword, trigger: 'change'}
            ],
            repeatPassword: [
                { validator: checkPassword, trigger: 'blur' }
            ]
        };
        vue_options.data.roles = [];
    }

    var checkPassword = function(rule, value, callback) {
        if (value == undefined) value = '';
        if (app.form.password != value) {
            callback(new Error('两次密码不一致'));
        } else {
            return callback();
        }
    };

    function post_vue_init(app) {
        axios.get('/api/role/all-roles')
            .then(function (value) {
                if (value.data.code == 0) {
                    var list = value.data.list;
                    for (var index in list) {
                        list[index].key = list[index].id;
                        list[index].label = list[index].name;
                    }
                    app.roles = list;
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