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

                <el-form-item label="菜单类型">
                    <el-radio-group v-model="form.type" @change="handleMenuTypeChange">
                        <el-radio-button label="LINK">链接</el-radio-button>
                        <el-radio-button label="SEPARATOR">分割线</el-radio-button>
                    </el-radio-group>
                </el-form-item>

                <el-form-item label="菜单名称" prop="name">
                    <el-input v-model="form.name" maxlength="32" show-word-limit clearable></el-input>
                </el-form-item>

                <el-form-item label="请选择图标" prop="icon">
                    <el-autocomplete style="width: 100%"
                                     v-model="form.icon"
                                     clearable
                                     :fetch-suggestions="querySearchIcons"
                                     placeholder="请选择菜单图标"
                                     @select="handleSelectIcon">
                        <template slot-scope="{ item }">
                            <i style="float: left; font-size: 18px; margin-top: 8px" :class="item.value"></i>
                            <span style="float: right; color: #8492a6; font-size: 13px">{{item.value}}</span>
                        </template>
                        <i class="el-icon-search el-input__icon" slot="suffix"></i>
                    </el-autocomplete>
                </el-form-item>

                <el-form-item label="选择父菜单" prop="parent">
                    <el-autocomplete style="width: 100%"
                                     v-model="form.parentName"
                                     popper-class="my-autocomplete"
                                     clearable
                                     :fetch-suggestions="querySearch"
                                     placeholder="请选择父菜单"
                                     @select="handleSelectRootMenu">

                        <template slot-scope="{ item }">
                            <div class="name">{{ item.value }}</div>
                            <span class="addr">{{ item.description }}</span>
                        </template>
                        <i class="el-icon-search el-input__icon" slot="suffix"></i>
                    </el-autocomplete>
                </el-form-item>

                <el-form-item label="链接地址" prop="href">
                    <el-input v-model="form.href" maxlength="200" show-word-limit clearable placeholder="绝对地址或相对地址"
                              :readonly="is_separator"></el-input>
                </el-form-item>

                <el-form-item label="菜单目标" prop="target">
                    <el-input v-model="form.target" maxlength="32" show-word-limit clearable
                              placeholder="HTML A标签的target"
                              :readonly="is_separator"></el-input>
                </el-form-item>

                <el-form-item label="显示顺序" prop="order">
                    <el-input placeholder="数字越小越靠前" v-model="form.order" maxlength="10" show-word-limit clearable type="number"></el-input>
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
    var moduleTitle = '菜单';
    var entityId = '${entityId!""}';
    var formCopy = {};
    // ***************************************
    var el_icons = [
        {value:'el-icon-delete-solid'},
        {value:'el-icon-delete'},
        {value:'el-icon-s-tools'},
        {value:'el-icon-setting'},
        {value:'el-icon-user-solid'},
        {value:'el-icon-user'},
        {value:'el-icon-phone'},
        {value:'el-icon-phone-outline'},
        {value:'el-icon-more'},
        {value:'el-icon-more-outline'},
        {value:'el-icon-star-on'},
        {value:'el-icon-star-off'},
        {value:'el-icon-s-goods'},
        {value:'el-icon-goods'},
        {value:'el-icon-warning'},
        {value:'el-icon-warning-outline'},
        {value:'el-icon-question'},
        {value:'el-icon-info'},
        {value:'el-icon-remove'},
        {value:'el-icon-circle-plus'},
        {value:'el-icon-success'},
        {value:'el-icon-error'},
        {value:'el-icon-zoom-in'},
        {value:'el-icon-zoom-out'},
        {value:'el-icon-remove-outline'},
        {value:'el-icon-circle-plus-outline'},
        {value:'el-icon-circle-check'},
        {value:'el-icon-circle-close'},
        {value:'el-icon-s-help'},
        {value:'el-icon-help'},
        {value:'el-icon-minus'},
        {value:'el-icon-plus'},
        {value:'el-icon-check'},
        {value:'el-icon-close'},
        {value:'el-icon-picture'},
        {value:'el-icon-picture-outline'},
        {value:'el-icon-picture-outline-round'},
        {value:'el-icon-upload'},
        {value:'el-icon-upload2'},
        {value:'el-icon-download'},
        {value:'el-icon-camera-solid'},
        {value:'el-icon-camera'},
        {value:'el-icon-video-camera-solid'},
        {value:'el-icon-video-camera'},
        {value:'el-icon-message-solid'},
        {value:'el-icon-bell'},
        {value:'el-icon-s-cooperation'},
        {value:'el-icon-s-order'},
        {value:'el-icon-s-platform'},
        {value:'el-icon-s-fold'},
        {value:'el-icon-s-unfold'},
        {value:'el-icon-s-operation'},
        {value:'el-icon-s-promotion'},
        {value:'el-icon-s-home'},
        {value:'el-icon-s-release'},
        {value:'el-icon-s-ticket'},
        {value:'el-icon-s-management'},
        {value:'el-icon-s-open'},
        {value:'el-icon-s-shop'},
        {value:'el-icon-s-marketing'},
        {value:'el-icon-s-flag'},
        {value:'el-icon-s-comment'},
        {value:'el-icon-s-finance'},
        {value:'el-icon-s-claim'},
        {value:'el-icon-s-custom'},
        {value:'el-icon-s-opportunity'},
        {value:'el-icon-s-data'},
        {value:'el-icon-s-check'},
        {value:'el-icon-s-grid'},
        {value:'el-icon-menu'},
        {value:'el-icon-share'},
        {value:'el-icon-d-caret'},
        {value:'el-icon-caret-left'},
        {value:'el-icon-caret-right'},
        {value:'el-icon-caret-bottom'},
        {value:'el-icon-caret-top'},
        {value:'el-icon-bottom-left'},
        {value:'el-icon-bottom-right'},
        {value:'el-icon-back'},
        {value:'el-icon-right'},
        {value:'el-icon-bottom'},
        {value:'el-icon-top'},
        {value:'el-icon-top-left'},
        {value:'el-icon-top-right'},
        {value:'el-icon-arrow-left'},
        {value:'el-icon-arrow-right'},
        {value:'el-icon-arrow-down'},
        {value:'el-icon-arrow-up'},
        {value:'el-icon-d-arrow-left'},
        {value:'el-icon-d-arrow-right'},
        {value:'el-icon-video-pause'},
        {value:'el-icon-video-play'},
        {value:'el-icon-refresh'},
        {value:'el-icon-refresh-right'},
        {value:'el-icon-refresh-left'},
        {value:'el-icon-finished'},
        {value:'el-icon-sort'},
        {value:'el-icon-sort-up'},
        {value:'el-icon-sort-down'},
        {value:'el-icon-rank'},
        {value:'el-icon-loading'},
        {value:'el-icon-view'},
        {value:'el-icon-c-scale-to-original'},
        {value:'el-icon-date'},
        {value:'el-icon-edit'},
        {value:'el-icon-edit-outline'},
        {value:'el-icon-folder'},
        {value:'el-icon-folder-opened'},
        {value:'el-icon-folder-add'},
        {value:'el-icon-folder-remove'},
        {value:'el-icon-folder-delete'},
        {value:'el-icon-folder-checked'},
        {value:'el-icon-tickets'},
        {value:'el-icon-document-remove'},
        {value:'el-icon-document-delete'},
        {value:'el-icon-document-copy'},
        {value:'el-icon-document-checked'},
        {value:'el-icon-document'},
        {value:'el-icon-document-add'},
        {value:'el-icon-printer'},
        {value:'el-icon-paperclip'},
        {value:'el-icon-takeaway-box'},
        {value:'el-icon-search'},
        {value:'el-icon-monitor'},
        {value:'el-icon-attract'},
        {value:'el-icon-mobile'},
        {value:'el-icon-scissors'},
        {value:'el-icon-umbrella'},
        {value:'el-icon-headset'},
        {value:'el-icon-brush'},
        {value:'el-icon-mouse'},
        {value:'el-icon-coordinate'},
        {value:'el-icon-magic-stick'},
        {value:'el-icon-reading'},
        {value:'el-icon-data-line'},
        {value:'el-icon-data-board'},
        {value:'el-icon-pie-chart'},
        {value:'el-icon-data-analysis'},
        {value:'el-icon-collection-tag'},
        {value:'el-icon-film'},
        {value:'el-icon-suitcase'},
        {value:'el-icon-suitcase-1'},
        {value:'el-icon-receiving'},
        {value:'el-icon-collection'},
        {value:'el-icon-files'},
        {value:'el-icon-notebook-1'},
        {value:'el-icon-notebook-2'},
        {value:'el-icon-toilet-paper'},
        {value:'el-icon-office-building'},
        {value:'el-icon-school'},
        {value:'el-icon-table-lamp'},
        {value:'el-icon-house'},
        {value:'el-icon-no-smoking'},
        {value:'el-icon-smoking'},
        {value:'el-icon-shopping-cart-full'},
        {value:'el-icon-shopping-cart-1'},
        {value:'el-icon-shopping-cart-2'},
        {value:'el-icon-shopping-bag-1'},
        {value:'el-icon-shopping-bag-2'},
        {value:'el-icon-sold-out'},
        {value:'el-icon-sell'},
        {value:'el-icon-present'},
        {value:'el-icon-box'},
        {value:'el-icon-bank-card'},
        {value:'el-icon-money'},
        {value:'el-icon-coin'},
        {value:'el-icon-wallet'},
        {value:'el-icon-discount'},
        {value:'el-icon-price-tag'},
        {value:'el-icon-news'},
        {value:'el-icon-guide'},
        {value:'el-icon-male'},
        {value:'el-icon-female'},
        {value:'el-icon-thumb'},
        {value:'el-icon-cpu'},
        {value:'el-icon-link'},
        {value:'el-icon-connection'},
        {value:'el-icon-open'},
        {value:'el-icon-turn-off'},
        {value:'el-icon-set-up'},
        {value:'el-icon-chat-round'},
        {value:'el-icon-chat-line-round'},
        {value:'el-icon-chat-square'},
        {value:'el-icon-chat-dot-round'},
        {value:'el-icon-chat-dot-square'},
        {value:'el-icon-chat-line-square'},
        {value:'el-icon-message'},
        {value:'el-icon-postcard'},
        {value:'el-icon-position'},
        {value:'el-icon-turn-off-microphone'},
        {value:'el-icon-microphone'},
        {value:'el-icon-close-notification'},
        {value:'el-icon-bangzhu'},
        {value:'el-icon-time'},
        {value:'el-icon-odometer'},
        {value:'el-icon-crop'},
        {value:'el-icon-aim'},
        {value:'el-icon-switch-button'},
        {value:'el-icon-full-screen'},
        {value:'el-icon-copy-document'},
        {value:'el-icon-mic'},
        {value:'el-icon-stopwatch'},
        {value:'el-icon-medal-1'},
        {value:'el-icon-medal'},
        {value:'el-icon-trophy'},
        {value:'el-icon-trophy-1'},
        {value:'el-icon-first-aid-kit'},
        {value:'el-icon-discover'},
        {value:'el-icon-place'},
        {value:'el-icon-location'},
        {value:'el-icon-location-outline'},
        {value:'el-icon-location-information'},
        {value:'el-icon-add-location'},
        {value:'el-icon-delete-location'},
        {value:'el-icon-map-location'},
        {value:'el-icon-alarm-clock'},
        {value:'el-icon-timer'},
        {value:'el-icon-watch-1'},
        {value:'el-icon-watch'},
        {value:'el-icon-lock'},
        {value:'el-icon-unlock'},
        {value:'el-icon-key'},
        {value:'el-icon-service'},
        {value:'el-icon-mobile-phone'},
        {value:'el-icon-bicycle'},
        {value:'el-icon-truck'},
        {value:'el-icon-ship'},
        {value:'el-icon-basketball'},
        {value:'el-icon-football'},
        {value:'el-icon-soccer'},
        {value:'el-icon-baseball'},
        {value:'el-icon-wind-power'},
        {value:'el-icon-light-rain'},
        {value:'el-icon-lightning'},
        {value:'el-icon-heavy-rain'},
        {value:'el-icon-sunrise'},
        {value:'el-icon-sunrise-1'},
        {value:'el-icon-sunset'},
        {value:'el-icon-sunny'},
        {value:'el-icon-cloudy'},
        {value:'el-icon-partly-cloudy'},
        {value:'el-icon-cloudy-and-sunny'},
        {value:'el-icon-moon'},
        {value:'el-icon-moon-night'},
        {value:'el-icon-dish'},
        {value:'el-icon-dish-1'},
        {value:'el-icon-food'},
        {value:'el-icon-chicken'},
        {value:'el-icon-fork-spoon'},
        {value:'el-icon-knife-fork'},
        {value:'el-icon-burger'},
        {value:'el-icon-tableware'},
        {value:'el-icon-sugar'},
        {value:'el-icon-dessert'},
        {value:'el-icon-ice-cream'},
        {value:'el-icon-hot-water'},
        {value:'el-icon-water-cup'},
        {value:'el-icon-coffee-cup'},
        {value:'el-icon-cold-drink'},
        {value:'el-icon-goblet'},
        {value:'el-icon-goblet-full'},
        {value:'el-icon-goblet-square'},
        {value:'el-icon-goblet-square-full'},
        {value:'el-icon-refrigerator'},
        {value:'el-icon-grape'},
        {value:'el-icon-watermelon'},
        {value:'el-icon-cherry'},
        {value:'el-icon-apple'},
        {value:'el-icon-pear'},
        {value:'el-icon-orange'},
        {value:'el-icon-coffee'},
        {value:'el-icon-ice-tea'},
        {value:'el-icon-ice-drink'},
        {value:'el-icon-milk-tea'},
        {value:'el-icon-potato-strips'},
        {value:'el-icon-lollipop'},
        {value:'el-icon-ice-cream-square'},
        {value:'el-icon-ice-cream-round'}
    ];

    // Vue 初始化之前的回调
    function pre_vue_init(vue_options) {
        vue_options.data.form = {
            type: 'LINK'
        };

        vue_options.data.elicons = el_icons;

        vue_options.data.rules = {
            name: [
                {required: true, message: '请输入菜单名称', trigger: 'blur'}
            ],
            icon: [
                {required: true, message: '请选择图标', trigger: 'submit'}
            ]
        };

        vue_options.methods['createFilter'] = function (qs) {
            return function (data_item) {
                return (data_item.value.toLowerCase().indexOf(qs.toLowerCase()) >= 0);
            }
        };

        vue_options.methods['querySearchIcons'] = function (qs, cb) {
            var icons = this.elicons;
            var results = qs ? icons.filter(this.createFilter(qs)) : icons;
            cb(results);
        };

        vue_options.methods['handleSelectIcon'] = function (item) {
            app.form.icon = item.value;
        };

        vue_options.methods['querySearch'] = function (qs, cb) {
            var root_menus = this.root_menus;
            var results = qs ? root_menus.filter(this.createFilter(qs)) : root_menus;
            cb(results);
        };

        vue_options.methods['handleSelectRootMenu'] = function (item) {
            app.form.parentId = item.id;
        };

        vue_options.methods['handleMenuTypeChange'] = function(val) {
            if (val == 'SEPARATOR') {
                this.form = {
                    name: '--------',
                    target: '',
                    href: '',
                    icon: '',
                    type: val
                };
            } else {
                this.form.name = formCopy.name;
                this.form.target = formCopy.target;
                this.form.href = formCopy.href;
                this.form.icon = formCopy.icon;
                this.form.type = val;
            }
        };

        vue_options.computed['is_separator'] = function () {
            return this.form.type == 'SEPARATOR';
        };
    };

    function post_data_loaded(app, update) {
        if (update) {
            formCopy = JSON.parse(JSON.stringify(app.form)); // 如果选择了SERARATOR后数据会被改变，这里用来恢复现场
        }

        var selectedEntity;
        axios.get('/api/' + module + '/all-root-menus', {
            params: {
                excludeId: app.form.id
            }
        }).then(function (value) {
            if (value.data.code == 0) {
                var list = [{id: 0, value: '根节点', description: '作为根节点菜单'}];
                var dblist = value.data.list;
                if (dblist && dblist.length > 0) {
                    for (var i in dblist) {
                        var entity = dblist[i];
                        entity.value = entity.name;
                        list.push(entity);
                        if (entity.id == app.form.parentId) {
                            selectedEntity = entity;
                        }
                    }
                }
                app.root_menus = list;
            } else {
                showMessage('数据加载错误：' + value.data.msg);
            }
        }).catch(function (reason) {
                showMessage('数据加载错误：' + reason);
            }).finally(function () {
            if (selectedEntity) {
                app.form.parentName = selectedEntity.name;
                app.form.parentId = selectedEntity.id;
                var copy = JSON.parse(JSON.stringify(app.form));
                app.form = copy;
            }
        });
    }

    function dataloaded_vue_init(app) {
        post_data_loaded(app, true);
    }

    function post_vue_init(app) {
        post_data_loaded(app, false);
    }
</script>
<script type="text/javascript" src="/js/local/add.js"></script>
</html>