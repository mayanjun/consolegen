<!DOCTYPE html>
<html lang="en">
<head>
    <title></title>
    <#include "../inc/common-head.ftl">
    <link rel="stylesheet" href="/css/add.css" type="text/css">
    <style rel="stylesheet" type="text/css">
        .settings-sep {
            margin: 50px auto 30px;
        }
    </style>
</head>
<body>
<div id="app">
    <#-- 头部 -->
    <div class="data-header">
        <div class="title">
            <div class="title-content0" v-text="title"></div>
        </div>
    </div>

    <#-- 表单 -->
    <el-row>
        <el-col :span="5">&nbsp;</el-col>
        <el-col :span="13">
            <el-form :model="form"
                     size="small"
                     :rules="rules"
                     ref="form"
                     status-icon
                     label-width="140px"
                     v-loading="loading"
                     label-position="left"
                     style="margin-top: 20px">

                <div class="settings-sep" style="margin-top: 0"><el-divider content-position="left"><i class="el-icon-s-operation"></i> 系统</el-divider></div>

                <el-form-item label="是否打开详细日志">
                    <el-switch v-model="form.verboseLogEnabled"></el-switch>
                </el-form-item>

                <#-- sbumit button -->
                <el-form-item>
                    <el-button size="small" type="primary" @click="submitForm">提交设置</el-button>
                    <el-button size="small" type="primary" @click="restoreFactorySettings">恢复出厂设置</el-button>
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
    var moduleTitle = '系统配置';
    var entityId = '1';
    // ***************************************

    function pre_vue_init(vue_options) {
        vue_options.methods['restoreFactorySettings'] = function () {
            axios.post('/api/' + module + '/factory')
                .then(function (value) {
                    if (value.data.code == 0) {
                        showMessage('恢复出厂设置成功', 'success', function () {
                            window.location.href = '/pages/' + module + '/list';
                        });
                    } else if(value.data.code == 2001 ) {
                        showMessage(value.data.msg, 'warn',function () {
                            window.top.location.href = '/';
                        });
                    } else {
                        showMessage('恢复出厂设置错误：' + value.data.msg);
                    }
                })
                .catch(function (reason) {
                    showMessage('恢复出厂设置错误错误：' + reason);
                });
        }
    }

    function dataload_success(app, data) {
        var entity = data.entity;
        for (var name in entity) {
            if (entity[name] === 'true') {
                entity[name] = true;
            } else if (entity[name] === 'false') {
                entity[name] = false;
            }
        }
    }

</script>
<script type="text/javascript" src="/js/local/add.js"></script>
</html>