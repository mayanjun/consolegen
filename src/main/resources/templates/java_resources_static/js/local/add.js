function showMessage(msg, type, callback) {
    if (!type) type = 'warning';
    app.$confirm(msg, '提示', {
        confirmButtonText: '知道了',
        showCancelButton: false,
        type: type,
        center: true,
        showClose: false,
        closeOnClickModal: false
    }).then(function () {
        if (callback && typeof callback === 'function') callback();
    });
}

$(function () {

    var vue_options = {
        el: '#app',
        data: {
            title: (entityId === '') ? ('添加' + moduleTitle) : ('编辑' + moduleTitle),
            loading: false,
            update: !(entityId === ''),
            form: {},
            rules: {}
        },
        methods: {
            goBack: function () {
                window.history.back();
            },
            submitForm: function () {
                if (window.before_submit && (typeof window.before_submit === 'function')) window.before_submit(app);
                app.$refs['form'].validate(function (valid) {
                    if (valid) {
                        app.loading = true;
                        var url = '/api/' + module;
                        if (app.update) url += '/update'
                        axios.post(url + '?rand=' + Math.random(), app.form)
                            .then(function (value) {
                                if (value.data.code == 0) {
                                    showMessage('数据提交成功', 'success', function () {
                                        window.location.href = '/pages/' + module + '/list';
                                    });
                                } else if(value.data.code == 2001 ) {
                                    showMessage(value.data.msg, 'warn',function () {
                                        window.top.location.href = '/';
                                    });
                                } else {
                                    showMessage('数据提交错误：' + value.data.msg);
                                }
                            })
                            .catch(function (reason) {
                                showMessage('数据提交错误：' + reason);
                            })
                            .finally(function () {
                                app.loading = false;
                            });
                    } else {
                        showMessage('请按要求填写表单');
                    }
                });
            },
            resetForm: function () {
                this.$refs['form'].resetFields();
            },
            numberFilter: function (vars) {
                var script = "app."+ vars + " = app." + vars + ".replace(/[^\\d]/g,\'\')";
                eval(script);
            },

            floatFilter: function (vars) {
                var script = "app."+ vars + " = app." + vars + ".replace(/[^\\d\\.]/g,\'\')";
                eval(script);
            }
        },
        computed: {}
    };

    if (window.pre_vue_init && (typeof window.pre_vue_init === 'function')) window.pre_vue_init(vue_options);
    app = new Vue(vue_options); // end vue

    if (app.update) { // if update
        axios.get('/api/' + module + '/' + entityId + '?rand=' + Math.random())
            .then(function (value) {
                if (value.data.code == 0) {
                    if (window.dataload_success && (typeof window.dataload_success === 'function')) window.dataload_success(app, value.data);
                    app.form = value.data.entity;
                } else if(value.data.code == 2001 ) {
                    showMessage(value.data.msg, 'warn',function () {
                        window.top.location.href = '/';
                    });
                } else {
                    showMessage('无法加载数据：' + value.data.msg + '(' + value.data.code + ')');
                }
            })
            .catch(function (reason) {
                showMessage('无法加载数据：' + reason);
            }).finally(function () {
            if (window.dataloaded_vue_init && (typeof window.dataloaded_vue_init === 'function')) window.dataloaded_vue_init(app);
        });
    }
    if (window.post_vue_init && (typeof window.post_vue_init === 'function')) window.post_vue_init(app);
});