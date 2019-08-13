<!DOCTYPE html>
<html lang="en">
<head>
    <title></title>
    ${r'<#include "../inc/common-head.ftl">'}
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

                     ${fields_html!""}

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
    var module = '${r'${module!""}'}';
    var moduleTitle = '${comment}';
    var entityId = '${r'${entityId!""}'}';
    // ***************************************

    ${function_scripts!""}

    function pre_vue_init(vue_options) {
        // validate
        vue_options.data.rules = {};
        ${fields_vue_scripts!""}
    }

    function dataloaded_vue_init(app) {
        ${fields_vue_dataloaded_scripts!""}
    }

</script>
<script type="text/javascript" src="/js/local/add.js"></script>
</html>