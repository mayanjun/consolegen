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
        .logo-div {
            display: flex;
            flex-direction: row;
        }

        .logo-svg {
            height: 40px;
            width: 40px;
            color: #5daad2;
            stroke: currentColor;
            fill: currentColor;
            margin: 10px 6px 0 16px;
        }

        .sys-title {
            font-size: 18px;
            color: #5c98c0;
            line-height: 60px;
        }

        .el-header {
            -webkit-box-shadow: 0px 3px 10px rgba(137, 137, 144, .3);
            -moz-box-shadow: 0px 3px 10px rgba(137, 137, 144, .3);
            box-shadow: 0px 3px 10px rgba(137, 137, 144, .3);
            z-index: 800
        }

        .el-footer {
            border-top: solid 1px #e6e6e6;
        }

        .el-menu-vertical-index:not(.el-menu--collapse) {
            width: 200px;
            min-height: 400px;
        }

        .el-menu--collapse {
            min-height: 400px;
        }

        .el-menu {
            border-right: none;
        }

        .el-aside {
            border-right: solid 1px #e6e6e6;
        }

        .main-frame {
            min-height: 400px;
            width: 100%;
        }
        .el-tooltip__popper.is-dark {
            background: rgba(0,0,0,.7);
        }

        .my-collapse {
            width: 24px; height: 60px; cursor: pointer; line-height: 60px;font-size: 18px; color: #909399; text-align: center;
            padding-right: 20px;
            border-right: #FFFFFF solid 1px;
        }

        .my-menus-collapsed {
            border-right: #e6e6e6 solid 1px;
        }

        .my-collapse:HOVER {
            color: #3a8ee6;
        }
    </style>

    <link type="text/css" href="/css/iconfont/iconfont.css" rel="stylesheet">
</head>
<body>
<svg style="position: absolute; width: 0; height: 0;" width="0" height="0" version="1.1"
     xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <defs>
        <symbol id="icon-logo" viewBox="0 0 1024 1024">
            <path d="M716.2 619.3c17.5-32.1 27.4-69 27.4-108.1 0-125.1-101.4-226.5-226.5-226.5-28.6 0-55.9 5.3-81 15l58.4 58.4c35.9 35.9 35.9 94.6 0 130.4-35.9 35.9-94.6 35.9-130.4 0l-58.4-58.4c-9.6 25.2-15 52.5-15 81 0 125.1 101.4 226.5 226.5 226.5 39.2 0 76-9.9 108.1-27.4L791 875.8c25 25 65.9 25 90.9 0s25-65.9 0-90.9L716.2 619.3z m119.1 244.5c-16.9 0-30.6-13.7-30.6-30.6 0-16.9 13.7-30.6 30.6-30.6s30.6 13.7 30.6 30.6c0 17-13.7 30.6-30.6 30.6z"></path><path d="M890 451.8c-4.1-26.2-11-51.5-20.3-75.7l69.4-40.1-59.3-102.7-69.5 40.1c-16.5-20.3-35.1-38.9-55.4-55.4l40.1-69.5-102.7-59.2-40.1 69.4c-24.1-9.3-49.5-16.1-75.7-20.3V58.3H457.9v80.2c-26.2 4.1-51.5 11-75.7 20.3l-40.1-69.4-102.7 59.3 40.1 69.5c-20.3 16.5-38.9 35.1-55.4 55.4l-69.5-40.1-59.3 102.6 69.4 40.1c-9.3 24.1-16.1 49.5-20.3 75.7H64.3v118.6h80.2c4.1 26.2 11 51.5 20.3 75.7l-69.4 40.1L154.6 789l69.5-40.1c16.5 20.3 35.1 38.9 55.4 55.4l-40.1 69.5L342.1 933l40.1-69.4c24.1 9.3 49.5 16.1 75.7 20.3v80.2h118.6v-80.2c12.2-1.9 24.1-4.5 35.9-7.6l-23.7-77.4c-22.9 5.7-46.9 8.7-71.5 8.7-163.8 0-296.5-132.8-296.5-296.5s132.8-296.5 296.5-296.5 296.5 132.8 296.5 296.5c0 28.7-4.2 56.5-11.8 82.8l76.5 26.1c4.9-16.1 8.8-32.6 11.5-49.5h69.4V451.8H890z"></path>
        </symbol>
    </defs>
</svg>
<div id="app">
    <el-container direction="vertical">
        <el-header>
            <el-row>
                <el-col :span="12">
                    <div style="display: flex; flex-direction: row">
                        <div @click="setCollapse" v-bind:class="{'my-menus-collapsed':isCollapse}" class="my-collapse">
                            <i v-bind:class="getCollapseIcon"></i>
                        </div>

                        <div class="logo-div">
                            <svg class="logo-svg">
                                <use xlink:href="#icon-logo"></use>
                            </svg>
                            <div>
                                <span class="sys-title">${__APPCONF__.systemName!""}</span>
                            </div>
                        </div>
                    </div>
                </el-col>
                <el-col :span="12">
                    <div>
                        <el-link @click="onMenuSelect('/man/manual.pdf')" :underline="false" style="float: right; line-height: 60px; height: 60px; margin-left: 10px">
                            <i class="el-icon-notebook-1"></i>
                        </el-link>

                        <el-dropdown @command="handleCommand" style="z-index: 4000; height: 20px; line-height: 20px; margin-top: 20px; float: right; cursor: pointer">
                            <span class="el-dropdown-link">
                                <i style="color: #70839e" class="el-icon-user-solid"></i>
                                ${__current_user!""}
                                <i class="el-icon-arrow-down el-icon--right"></i>
                            </span>
                            <el-dropdown-menu slot="dropdown" style="z-index: 4000">
                                <el-dropdown-item command="exit">安全退出</el-dropdown-item>
                            </el-dropdown-menu>
                        </el-dropdown>
                    </div>
                </el-col>
            </el-row>
        </el-header>
        <el-container>
            <el-aside width="200">
                <el-menu :default-active="mainFrameSrc"
                         class="el-menu-vertical-index"
                         :collapse="isCollapse"
                         unique-opened
                         @select="onMenuSelect">

                    <#if menus ??>
                        <#list menus>
                            <#items as menu>
                                <#if menu.children ??>
                                    <el-submenu index="${menu.id}">
                                        <template slot="title">
                                            <i class="${menu.icon} menu-icon"></i>
                                            <span slot="title">${menu.name}</span>
                                        </template>
                                        <#list menu.children>
                                            <#items as child>
                                                <el-menu-item index="${child.href}">
                                                    <i class="${child.icon} menu-icon"></i>
                                                    <span slot="title">${child.name}</span>
                                                </el-menu-item>
                                            </#items>
                                        </#list>
                                    </el-submenu>
                                    <#else>
                                        <el-menu-item index="${menu.href}">
                                            <i class="${menu.icon} menu-icon"></i>
                                            <span slot="title">${menu.name}</span>
                                        </el-menu-item>
                                </#if>
                            </#items>
                        </#list>
                    </#if>
                </el-menu>
            </el-aside>

            <el-main>
                <iframe :src="mainFrameSrc"
                        frameborder="0"
                        class="main-frame"
                        :style="{height: (screenHeight - 150) + 'px'}"></iframe>
            </el-main>
        </el-container>

        <el-footer style="height: 20px">
            <#include "inc/footer.ftl">
        </el-footer>
    </el-container>
</div>
</body>
<script>
    var app_index;
    var page_index = '${RequestParameters["page"]!"/docs/welcome"}';

    $(function () {
        app_index = new Vue({
            el: '#app',
            data: {
                isCollapse: true,
                mainFrameSrc: page_index,
                screenHeight: $(window).height()
            },
            methods: {
                setCollapse: function () {
                    this.isCollapse = !this.isCollapse;
                },
                onMenuSelect: function (index) {
                    if (index == 'collapse') return false;
                    if (index == '') return false;
                    app_index.mainFrameSrc = index;
                    console.log(index);
                },
                handleCommand: function(command) {
                    if (command == 'exit') {
                        axios.get('/api/session/signout?rand=' + Math.random())
                            .then(function (value) {
                            var code = value.data.code;
                            if (code == 0 || code == 2001) {
                                window.top.location.href = '/';
                            } else {
                                app_index.$message.error('请求错误：' + value.data.msg);
                            }
                        }).catch(function (reason) {
                            app_index.$message.error('请求错误：' + reason.response.statusText);
                        });
                    }
                }
            },
            computed: {
                getCollapseIcon: function () {
                    return this.isCollapse ? 'el-icon-s-unfold' : 'el-icon-s-fold';
                }
            }
        });

        $(window).resize(function () {
            app_index.screenHeight = $(window).height();
        });
    });
</script>
</html>