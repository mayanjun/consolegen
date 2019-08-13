<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <#include "../inc/common-head.ftl">
    <style type="text/css" rel="stylesheet">
        .is-selected {
            color: #1989FA;
        }

        .is-today {
            color: #dc14b0 !important;
        }

        .el-calendar-day {
            font-size: 16px;
        }

        .is-today .el-calendar-day {
            font-size: 30px!important;
        }

        .el-calendar__title {
            font-size: 20px;
        }
    </style>
</head>
<body>
<div id="app">
    <el-calendar v-model="selectedDate"></el-calendar>
</div>
</body>
<script>
    var app_welcome = new Vue({
        el: '#app',
        data: {
            selectedDate: ''
        }
    });
</script>
</html>