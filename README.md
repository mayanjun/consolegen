## consolegen 后台管理系统生成器

### 运行步骤：

- 创建 org.mayanjun.gen.ProjectGenerator 实例
- 执行 generate() 方法
- 在配置文件旁边会生成 dist文件夹，里面包含完整的项目文件

### 配置指南

- 配置文件结构

```javascript
{
    "projectName":"gentest11",
    "packageName": "com.jd.gentest",
    "groupId":"com.jd.zteam",
    "systemName":"北京法院",
    "domain":"m.com",
    "companyName":"京东数字科技",
    ...
    
    "entityConfigs": [
        {
            "className": "AppDevice",
            "comment": "设备",
            "exportSupported": true,
            ...
            
            "fieldConfigs": [
                {
                    "name": "name",
                    "databaseLength": "64",
                    "indexed": true,
                    "comment": "设备名称"
                },
                ...
            ]
        },
        ...
    ]
}
```

- ProjectConfig 配置

配置项 | 数据类型 | 是否必须 | 默认值 | 说明
- | :-: | :-: |-| -
author|String|N|mayanjun|代码作者信息
companyName|String|N||用于在页脚生成公司名字
domain|String|N|m.com|项目域名，用于访问后台的域名
entityConfigs|List|N||实体列表配置：参见【EntityConfig 配置】
fileUploadDir|String|N|/export/data/upload|上传的文件保存文件夹
groupId|String|N|org.mayanjun|项目组名，用于生成POM文件
jdbcDatabase|String|N|mydb|数据库名称
jdbcHost|String|N|127.0.0.1:3306|JDBC主机IP和端口号
jdbcPassword|String|N|123456|数据库密码
jdbcUsername|String|N|root|数据库用户名
outDir|String|N||项目的输出目录，如果不配置则会在配置文件所在的文件夹生成项目
packageName|String|N|org.mayanjun.project|项目包名，用于生成POM文件
projectName|String|N|new-project|英文项目名称
serverPort|int|N|8080|服务器端口
sessionCookieName|String|N|token|登录验证系统的Cookie名称
slogan|String|N|打造智能系统|用于在页脚生成的一句话标语
systemName|String|N|后台管理系统|后台要显示的系统名称
vendor|String|N|mayanjun.org|系统提供商
version|String|N|0.0.1-SNAPSHOT|项目版本，用于生成POM文件

- EntityConfig 配置

配置项 | 数据类型 | 是否必须 | 默认值 | 说明
- | :-: | :-: |-| -
className|String|Y||实体类名
comment|String|Y||简短的实体描述，这个也会用来生成对应的管理菜单的名称，因此不要太长
exportSupported|boolean|N||是否支持后台数据导出功能
fieldConfigs|List|N||实体的字段配置，参见【FieldConfig 配置】
icon|String|N|el-icon-monitor|后台管理对应的菜单图标,选值请参见【https://element.ele.me/#/zh-CN/component/icon】

- FieldConfig 配置

配置项 | 数据类型 | 是否必须 | 默认值 | 说明
- | :-: | :-: |-| -
comment|String|Y||字段简短描述，该值还用来生成数据表头，因此不要太长
databaseLength|String|N|64|数据库的长度描述
databaseType|DataType|N|VARCHAR|数据库的字段类型，取值请参见【org.mayanjun.myjack.api.enums.DataType】的枚举值
enumValues|String[]|N||如果这里定义值的话，这个字段会被定义为枚举： 数组内容为 ["枚举值","枚举值说明"]，枚举字段在后台会被生成Radio选择框
indexed|boolean|N||是否设置索引，如果支持索引的话会生成数据库索引，同时还会生成后台的搜索条件
inputType|InputType|N||输入框的类型，可选的值为FILE_IMAGE：上传图片文件， FILE_ORDINARY：上传任意普通文件
javaType|String|N|String|字段的Java类型
name|String|Y||英文字段名
pattern|String|N|yyyy-MM-dd HH:mm:ss|如果字段的类型是日期类型，则指定格式化模式。日期类型在后台会生成日期或者时间选择框


### 开发

- add.js 回调方法

```javascript
// ************** REQUIRED ***************
var app;
var module = '${module!""}';
var moduleTitle = '菜单';
var entityId = '${RequestParameters["id"]!""}';
// ***************************************

/**
* VUE初始化之前的回调
* @param vue_options 原生的vue options对象
*/
function pre_vue_init(vue_options) {}

/**
* VUE初始化之后的回调
* @param app vue对象
*/
function post_vue_init(app) {}

/**
* 实体数据加载后在VUE表单绑定的对象被替换之前的回调
* @param app VUE对象
* @param data axios响应的数据对象
*/
function dataload_success(app, data) {}

/**
* 数据加载后并且替换了标点绑定的数据之后的回调
* @param app VUE对象
*/
function dataloaded_vue_init(app) {}

/**
* 表单提交之前的回调
* @param app VUE对象
*/
function before_submit(app) {}
```

- list.js 回调方法

```javascript
/**
* VUE初始化之前的回调
* @param vue_options 原生的vue options对象
*/
function pre_vue_init(vue_options) {}

/**
* 列表数据加载后且在VUE绑定的数据对象赋值之前的回调
* @param value axios返回的响应对象
*/
function list_data_loaded(value) {}

```

### 部署

- 数据库时区设置必须设置为正确时区，最好在数据库配置文件中配置时区

```sql
show variables like "%time_zone%";
set global time_zone = '+8:00';
set time_zone = '+8:00';
flush privileges;
```

- NGINX 配置

```nginx
upstream console_servers {
        server 127.0.0.1:8181 weight=1;
}

server {
        listen      80;
	    client_max_body_size 100M;
        access_log  /data/log/nginx/console.log main;
        server_name m.com;
        charset utf-8;
        index index.html login.jsp;
	    proxy_buffering off;
        location  / {
                proxy_set_header        Host $host;
                proxy_set_header        X-Forwarded-For $remote_addr;
                proxy_pass      http://console_servers/;
        }
}

```

- 自动生成数据库

    - 系统启动后会自动检测所有系统中定义的表是否已经创建，如果未创建则会自动创建表。
    - 注意如果表结构发生了变化，系统不会自动检测，只是简单的检测表是否存在。
    - 系统默认会生成一个超级用户，密码会随机生成，请在首次启动的时候观察日志：init password=xxxxxx