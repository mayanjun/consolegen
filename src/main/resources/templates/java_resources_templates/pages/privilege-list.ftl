<!DOCTYPE html>
<html lang="en">
<head>
    <title></title>
    <#include "../inc/common-head.ftl">
    <link rel="stylesheet" href="/css/list.css" type="text/css">
</head>
<body>
<div id="app">
    <#-- 头部 -->
    <div class="data-header">
        <div class="title">
            <div class="title-content0" v-text="title"></div>
        </div>
    </div>

    <#-- 搜索 -->
    <div class="search-div">
        <el-form :model="searchForm" label-width="60px" label-position="left" size="small" :inline="true">
            <el-form-item>
                <el-input maxlength="18" placeholder="ID" v-model="searchForm.sid" clearable @clear="searchData" @input="numberFilter('searchForm.sid')" @keyup.enter.native="searchData"></el-input>
            </el-form-item>

            <el-form-item>
                <el-input maxlength="32" placeholder="名称" v-model="searchForm.sname" clearable @clear="searchData"></el-input>
            </el-form-item>

            <el-form-item>
                <el-button type="primary" :loading="loading" icon="el-icon-search" round @click="searchData">搜索</el-button>
                <el-button type="primary" :loading="loading" icon="el-icon-refresh" round @click="resetSearchForm">重置</el-button>
            </el-form-item>
        </el-form>
    </div>

    <#-- 数据表 -->
    <template>
        <el-table :data="tableData"
                  style="width: 100%"
                  :height="screenHeight - 150"
                  v-loading="loading"
                  @selection-change="handleSelectionChange"
                  size="small"
                  :tree-props="{children: 'children', hasChildren: 'hasChildren'}"
                  default-expand-all
                  row-key="id">
            <el-table-column type="index" fixed></el-table-column>
            <el-table-column prop="id" width="140" label="ID"></el-table-column>
            <el-table-column prop="name" label="名称" width="150"></el-table-column>
            <el-table-column prop="method" label="方法" show-overflow-tooltip></el-table-column>
            <el-table-column prop="dependencies" label="依赖" show-overflow-tooltip></el-table-column>

            <el-table-column prop="description" label="备注" show-overflow-tooltip></el-table-column>
            <el-table-column prop="createdTime" label="创建时间" width="150" align="center" :formatter="dateTimeFormatter"></el-table-column>
            <el-table-column prop="modifiedTime" label="修改时间" width="150" align="center" :formatter="dateTimeFormatter"></el-table-column>
        </el-table>
    </template>

    <#-- 页码 -->
    <el-pagination style="text-align: center; margin-top: 10px;"
                   @size-change="handleSizeChange"
                   @current-change="handleCurrentChange"
                   :current-page="paging.currentPage"
                   :page-sizes="paging.pageSizes"
                   :page-size="paging.defaultPageSize"
                   layout="total, prev, pager, next, jumper, sizes"
                   :total="paging.total"></el-pagination>
</div>
</body>
<script type="text/javascript">
    // ************** REQUIRED ***************
    var app;
    var module = '${module!""}';
    var moduleTitle = '权限';
    // ***************************************
</script>
<script type="text/javascript" src="/js/local/list.js"></script>
</html>