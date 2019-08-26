<!DOCTYPE html>
<html lang="en">
<head>
    <title></title>
    <#include "../inc/common-head.ftl">
    <link href="/css/iconfont/iconfont.css" type="text/css" rel="stylesheet">
</head>
<body style="width: 800px; margin: 50px auto 10px">
<div style="text-align: center">
    <span class="iconfont icon-dingwei" style="font-size: 200px; color: #399bff; line-height: 120px"></span>
    <div style="margin: 0px auto 100px; text-align: center; color: #00345f">
        <p>${.now?string("yyyy-MM-dd HH:mm:ss.SSS")}</p>
        <p>
            ${exception.message!""}
        </p>
        <p>
            服务器发除了一点问题，请稍后重试或回到 <a class="normal-link" href="/">主页</a>
        </p>
        <p>
            Sorry, unless you really were hoping to find our 404 message, the page you were looking
            for has been moved or deleted
        </p>
    </div>
</div>
</body>
</html>