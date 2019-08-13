Date.prototype.format = function(format) {
    var o = {
        "M+" : this.getMonth() + 1, // month
        "d+" : this.getDate(), // day
        "H+" : this.getHours(), // hour
        "m+" : this.getMinutes(), // minute
        "s+" : this.getSeconds(), // second
        "q+" : Math.floor((this.getMonth() + 3) / 3), // quarter
        "S" : this.getMilliseconds()
        // millisecond
    }

    if (/(y+)/.test(format)) {
        format = format.replace(RegExp.$1, (this.getFullYear() + "")
            .substr(4 - RegExp.$1.length));
    }

    for ( var k in o) {
        if (new RegExp("(" + k + ")").test(format)) {
            format = format.replace(RegExp.$1, RegExp.$1.length == 1 ? o[k]
                : ("00" + o[k]).substr(("" + o[k]).length));
        }
    }
    return format;
}

var ONE_MILLI_SECOND = 1;
var ONE_SECOND = ONE_MILLI_SECOND * 1000;
var ONE_MINUTE = ONE_SECOND * 60;
var ONE_HOUR = ONE_MINUTE * 60;
var ONE_DAY = ONE_HOUR * 24;
var ONE_MONTH = ONE_DAY * 30;
var ONE_YEAR = ONE_MONTH * 12;

var TIME_UNITS = [ONE_YEAR, ONE_MONTH, ONE_DAY, ONE_HOUR, ONE_MINUTE, ONE_SECOND, ONE_MILLI_SECOND];
var TIME_UNIT_NAME = ['年','个月','天','小时','分钟','秒','毫秒'];

function humanTime(millis) {
    var timeString = '';
    var remain = millis;
    for (var index in TIME_UNITS) {
        if (remain >= TIME_UNITS[index]) {
            var mod = remain % TIME_UNITS[index];
            var len = (remain - mod) / TIME_UNITS[index];
            //times.push(len);
            timeString += (len + TIME_UNIT_NAME[index]);
            remain = mod;
        } else {
            //times.push(0);
        }
    }
    return timeString;
}

function humanTimeFast(millis) {
    var remain = millis;
    for (var index in TIME_UNITS) {
        if (remain >= TIME_UNITS[index]) {
            var mod = remain % TIME_UNITS[index];
            var len = (remain - mod) / TIME_UNITS[index];
            return len + TIME_UNIT_NAME[index];
        }
    }
}