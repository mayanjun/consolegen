<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <#include "inc/common-head.ftl">
    <script type="text/javascript">
        if (window != window.top) {
            window.top.location.href = window.location.href;
        }
    </script>
    <style rel="stylesheet" type="text/css">
        body {
            background: linear-gradient(180deg, #FFFFFF,#FFFFFF, #cef1fb);
        }
        .main-content {
            background: #FFFFFF;
            width: 340px;
            height: 140px;
            -webkit-box-shadow: 0px 3px 16px rgba(137,137,144,.5);
            -moz-box-shadow: 0px 3px 16px rgba(137,137,144,.5);
            box-shadow: 0px 3px 16px rgba(137,137,144,.5);
            border-radius: 10px;
            padding: 30px;
            display: flex;
            flex-direction: column;
            align-items: center;
            margin-top: 10%;
            margin-bottom: 10%;
        }
    </style>
</head>
<body>
<div id="app">
    <el-row style="margin-top: 100px">
        <el-col :span="8">&nbsp;</el-col>
        <el-col :span="8" align="center">
            <span style="font-size: 30px; color: #5e676e">后台管理系统</span>
        </el-col>
        <el-col :span="8">&nbsp;</el-col>
    </el-row>


    <el-row>
        <el-col :span="8">&nbsp;</el-col>
        <el-col :span="8" align="center">
            <el-form :model="form" class="main-content" label-position="left" label-width="60px" size="mini" :rules="rules" ref="loginForm">
                <el-form-item label="用户名" prop="username" style="margin-top: 10px">
                    <el-input @keyup.enter.native="onSubmit('loginForm')" placeholder="请输入用户名" v-model="form.username" clearable prefix-icon="el-icon-user"></el-input>
                </el-form-item>

                <el-form-item label="密　码" prop="password">
                    <el-input @keyup.enter.native="onSubmit('loginForm')" placeholder="请输入密码" v-model="form.password" show-password prefix-icon="el-icon-unlock"></el-input>
                </el-form-item>

                <el-form-item>
                    <el-button style="width: 120px; margin-left: -60px" type="primary" @click="onSubmit('loginForm')" :loading="form.loading" round icon="el-icon-circle-check">登录</el-button>
                </el-form-item>
            </el-form>
        </el-col>
        <el-col :span="8">&nbsp;</el-col>
    </el-row>

    <#include "inc/footer.ftl">
</div>
</body>
<script>

    var domainURL = '${__APPCONF__.domain!""}';

    var checkUserName = function (rules, value, callback) {
        if (value === '') {
            return callback(new Error('用户名不能为空'));
        }
        callback();
    }

    function error(msg) {
        app.$alert(msg, '登录提示', {
            center: true,
            closeOnClickModal: true,
            type: 'warning',
            callback: function () {
                
            }
        });
    }

    var app = new Vue({
        el: '#app',
        data: {
            form: {
                username: '',
                password:'',
                loading: false
            },
            rules: {
                username: [
                    { validator: this.checkUserName, trigger: 'blur' },
                    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
                ],
                password: [
                    { min: 3, max: 20, message: '长度在 3 到 20 个字符', trigger: 'blur' }
                ]
            }
        },
        methods: {
            onSubmit:function (formRef) {
                this.form.loading = true;
                this.$refs[formRef].validate(function (valid) {
                   if (valid) {
                       axios.post('/api/session', {
                           username: app.form.username,
                           password: app.form.password
                       }).then(function (response) {
                           app.form.loading = false;
                           if (response.data.code == 0) { // sign in ok
                               window.location.href = window.location.protocol + '//' + domainURL;
                           } else {
                               error('登录失败:' + response.data.msg);
                           }
                       }).catch(function (reason) {
                           app.form.loading = false;
                           error('请求错误：' + reason.response.statusText);
                       });
                   } else {
                       app.form.loading = false;
                       error('请按照要求填写用户名和密码');
                       return false;
                   }
                });
            }
        }
    });
</script>
</html>