<!DOCTYPE html>
<html lang="en">
<head>
    <title></title>
    <#include "../inc/common-head.ftl">
    <link rel="stylesheet" href="/css/list.css" type="text/css">

    <style>
        .custom-tree-node {
            flex: 1;
            display: flex;
            align-items: center;
            justify-content: space-between;
            font-size: 14px;
            padding-right: 8px;
        }
    </style>
</head>
<body>
<div id="app">
    <#-- 头部 -->
    <div class="data-header">
        <div class="title">
            <div class="title-content">地区管理</div>
        </div>
        <div>
            <el-button-group>
                <el-button size="mini" type="primary" icon="el-icon-plus" @click="addData"></el-button>
                <el-button size="mini" type="primary" icon="el-icon-delete" @click="deleteData" :disabled="deleteButtonDisabled"></el-button>
            </el-button-group>
        </div>
    </div>

    <#-- 搜索 -->
    <div class="search-div">
        <el-input size="small" placeholder="输入关键字进行过滤(注意只能过滤已经加载的数据)" v-model="queryName"></el-input>
    </div>

    <#-- 数据表 -->
    <template>
        <el-tree style="width: 100%"
                 lazy
                 :load="loadRegions"
                 :data="regions"
                 :props="defaultProps"
                 :filter-node-method="filterNode"
                 @check="getCheckedRegion"
                 show-checkbox
                 ref="region_tree">
            <template slot-scope="{node,data}">
                <div class="custom-tree-node">
                    <div>
                        <span v-text="data.name"></span>
                        <span v-text="data.pinyin"></span>
                        (
                        <span v-text="data.longName"></span>
                        <span v-if="data.number != ''">
                        &VerticalSeparator; {{data.number}}
                        </span>
                        <span v-if="data.postcode != ''">
                        &VerticalSeparator; {{data.postcode}}
                        </span>
                        )
                    </div>
                    <el-button  @click.stop type="text" size="mini" icon="el-icon-edit" @click="handleEdit(0, data)">{{data.name}}</el-button>
                </div>
            </template>
        </el-tree>
    </template>
</div>
</body>
<script type="text/javascript">
    // ************** REQUIRED ***************
    var app;
    var module = '${module!""}';
    var moduleTitle = '地区';
    // ***************************************
    function pre_vue_init(vue_options) {
        vue_options.data.autoLoadData = false;
        vue_options.data.queryName = '';
        vue_options.data.defaultProps = {
            children: 'children',
                label: 'name'
        };
        vue_options.data.regions = [];

        vue_options.watch['queryName'] = function (val) {
            this.$refs.region_tree.filter(val);
        };

        vue_options.methods['getCheckedRegion'] = function() {
            this.multipleSelection = this.$refs.region_tree.getCheckedNodes();
        };

        vue_options.methods['filterNode'] = function (value, data) {
            if (!value) return true;
            return data.name.indexOf(value) !== -1;
        };

        vue_options.methods['loadRegions'] = function (node, resolve) {
            var parentId = 100000;
            if (node && node.data && node.data.id) {
                parentId = node.data.id;
                //if (node.data.level == 3) return resolve([]);
            }
            var data = [];
            axios.get('/api/' + module, {
                params: {
                    sparent: parentId
                }
            }).then(function (value) {
                if (value.data.code == 0) {
                    data = value.data.list;
                    if (parentId == 100000) {
                        app.regions = data;
                    }
                } else if(value.data.code == 2001 ) {
                    showMessage(value.data.msg, 'warn', function () {
                        window.top.location.href = '/';
                    });
                } else {
                    showMessage('数据加载错误：' + value.data.msg);
                }
            }).catch(function (reason) {
                showMessage('数据加载错误：' + reason);
            }).finally(function () {
                if (parentId != 100000) {
                    if (resolve && typeof resolve === 'function') resolve(data);
                    app.getCheckedRegion();
                }
            });
        };

        vue_options.methods['__load__data'] = vue_options.methods['loadRegions'];

    }
</script>
<script type="text/javascript" src="/js/local/list.js"></script>
</html>