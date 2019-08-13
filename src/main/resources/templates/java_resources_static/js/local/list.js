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

function loadData(callback) {
    app.loading = true;
    var params = {
        page: app.paging.currentPage,
        pageSize: app.paging.defaultPageSize,
        rand: Math.random()
    };
    for (var elt in app.searchForm) {
        var value = app.searchForm[elt];
        if (value != undefined) {
            params[elt] = value;
        }
    }
    axios.get('/api/' + module, {
        params: params
    }).then(function (value) {
        if (value.data.code == 0) {
            if (window.list_data_loaded && (typeof window.list_data_loaded === 'function')) window.list_data_loaded(value);
            app.paging.total = value.data.total;
            app.tableData = value.data.list;
        } else if(value.data.code == 2001 ) {
            showMessage(value.data.msg,'warn', function () {
                window.top.location.href = '/';
            });
        } else {
            showMessage('数据加载错误：' + value.data.msg);
        }
    }).catch(function (reason) {
        showMessage('数据加载错误：' + reason);
    }).finally(function () {
        if (callback && typeof callback === 'function') callback();
        app.loading = false;
    });
}

function exportData(callback) {
    app.loading = true;
    var params = {
        page: app.paging.currentPage,
        pageSize: app.paging.defaultPageSize,
        export: true,
        rand: Math.random()
    };
    for (var elt in app.searchForm) {
        var value = app.searchForm[elt];
        if (value != undefined) {
            params[elt] = value;
        }
    }
    axios.get('/api/' + module, {
        params: params
    }).then(function (value) {
        if (value.data.code == 0) {
            window.top.open('/api/file/' + value.data.url);
        } else if(value.data.code == 2001 ) {
            showMessage(value.data.msg,'warn', function () {
                window.top.location.href = '/';
            });
        } else {
            showMessage('导出失败：' + value.data.msg);
        }
    }).catch(function (reason) {
        showMessage('导出错误：' + reason);
    }).finally(function () {
        if (callback && typeof callback === 'function') callback();
        app.loading = false;
    });
}


$(function () {

    var vue_options = {
        el: '#app',
        data: {
            autoLoadData: true,
            title: moduleTitle + '管理',
            loading: false,
            paging: {
                currentPage: 1,
                pageSizes: [10, 15, 20, 30, 50],
                defaultPageSize: 10,
                total: 0
            },
            screenHeight: $(window).height(),
            searchForm: {},
            tableData: [],
            multipleSelection: []
        },
        methods: {
            __load__data: loadData,
            __export__data: exportData,
            handleSizeChange: function(val) {
                app.paging.currentPage = 1;
                app.paging.defaultPageSize = val;
                app.__load__data();
            },
            handleCurrentChange: function(val) {
                app.paging.currentPage = val;
                app.__load__data();
            },
            handleSelectionChange: function(val) {
                app.multipleSelection = val;
            },
            searchData: function () {
                app.paging.currentPage = 1;
                app.__load__data();
            },
            exportSearchData: function () {
                app.paging.currentPage = 1;
                app.__export__data();
            },
            dateTimeFormatter: function (row, column, cellValue, index) {
                if (cellValue && cellValue.length > 0) {
                    return cellValue.replace('T', ' ').substring(0, cellValue.length - 4);
                }
                return cellValue;
            },
            dateFormatter: function (row, column, cellValue, index) {
                if (cellValue && cellValue.length > 0) {
                    return cellValue.replace('T', ' ').substring(0, 10);
                }
                return cellValue;
            },
            timeFormatter: function (row, column, cellValue, index) {
                if (cellValue && cellValue.length > 0) {
                    return cellValue.replace('T', ' ').substring(11, cellValue.length - 4);
                }
                return cellValue;
            },
            addData: function () {
                window.location.href = '/pages/' + module + '/add';
            },
            deleteData: function() {

                this.$confirm('此操作将永久删除已选数据, 是否继续?', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(function (value) {
                    // begin delete
                    var ids = new Array();
                    for (var index in app.multipleSelection) {
                        ids.push(app.multipleSelection[index].id);
                    }
                    axios.post('/api/' + module + '/delete', ids)
                        .then(function (value) {
                            if (value.data.code == 0) {
                                showMessage('数据删除成功', 'success', function () {
                                    app.__load__data();
                                });
                            } else if(value.data.code == 2001 ) {
                                showMessage(value.data.msg,'warn', function () {
                                    window.top.location.href = '/';
                                });
                            } else {
                                showMessage(value.data.msg, 'error');
                            }
                        })
                        .catch(function (reason) {
                            showMessage(reason, 'error');
                        });
                    // end delete
                }).catch(function (reason) {
                });
            },
            handleEdit: function (index, row) {
                window.location.href = '/pages/' + module + '/add?id=' + row.id;
            },
            numberFilter: function (vars) {
                var script = "app."+ vars + " = app." + vars + ".replace(/[^\\d]/g,\'\')";
                eval(script);
            },
            floatFilter: function (vars) {
                var script = "app."+ vars + " = app." + vars + ".replace(/[^\\d\\.]/g,\'\')";
                eval(script);
            },
            resetSearchForm: function() {
                this.searchForm = {};
                this.searchData();
            }
        },
        computed: {
            deleteButtonDisabled: function () {
                return !(this.multipleSelection && this.multipleSelection.length > 0);
            }
        },
        watch: {}
    };
    if (window.pre_vue_init && (typeof window.pre_vue_init === 'function')) window.pre_vue_init(vue_options);
    app = new Vue(vue_options);

    $(window).resize(function () {
        app.screenHeight = $(window).height();
    });

    // load data
    if (app.autoLoadData) app.__load__data();
});