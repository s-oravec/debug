var debugSession = {
    colors: util.executeReturnOneCol('select colors from debug_session where id_debug_session = :idDebugSession', {idDebugSession: args[1]})
}

var formatLine = function (namespace, value, color, ts_created, diff) {
    // no coloring, yet
    // no diff formatting
    if (debugSession.colors === 'NO_COLOR') {
        return ts_created + ' ' + namespace + ' ' + value;
    } else {
        var colorCode = '\u001b[3' + (color < 8 ? color : '8;5;' + color) + 'm';
        return '  ' + colorCode +  namespace + ' ' + '\u001b[0m' + value + ' ' + colorCode + diff + '\u001b[0m';
    }
}

var logSql =
' select id_debug_log,\n' +
'        namespace,\n' +
'        value,\n' +
'        color,\n' +
'        replace(to_char(ts_created, \'YYYY-MM-DD HH24:MI:SS.FF3\'), \' \', \'T\') as ts_created,\n' +
'        case\n' +
'            when diff < numtodsinterval(1, \'second\') / 1000\n' +
'                then \'+0ms\'\n' +
'            when diff < numtodsinterval(1, \'second\')\n' +
'                then \'+\' || (1000 * to_number(\'0.\' || substr(regexp_substr(to_char(diff), \'[^\\.]+\', 1, 2), 1, 12))) || \'ms\'\n' +
'            when diff < numtodsinterval(1, \'minute\')\n' +
'                then \'+\' || ltrim(substr(regexp_substr(to_char(diff), \'[^:]+\', 1, 3), 1, 6), \'0\') || \'s\'\n' +
'            when diff < numtodsinterval(1, \'hour\')\n' +
'                then \'+\' || ltrim(substr(regexp_substr(to_char(diff), \'[^ ]+\', 1, 2), 4, 7), \'0\') || \'min\'\n' +
'            else\n' +
'                \'+\' || ltrim(substr(regexp_substr(to_char(diff), \'[^ ]+\', 1, 2), 1, 8), \'0\') || \'h\'\n' +
'        end as diff\n' +
'   from debug_log\n' +
'  where id_debug_session = :idDebugSession\n' +
'    and id_debug_log > :idDebugLogLast\n' +
'  order by id_debug_log\n' +
'  fetch first :fetchRowCount rows only'
;

var debugLogBinds = {
    idDebugSession: args[1],
    idDebugLogLast: -1,
    fetchRowCount: 10
};

var main = function () {
    var Thread = Java.type("java.lang.Thread");
    var System  = Java.type("java.lang.System");

    while (true) {
        var result = util.executeReturnListofList(logSql, debugLogBinds);
        for (var i = 1; i < result.size(); i++) {
            debugLogBinds.idDebugLogLast = result[i][0];
            System.out.println(formatLine(result[i][1], result[i][2], result[i][3], result[i][4], result[i][5]));
        }
        // sleep if fetched all
        if (result.size < debugLogBinds.fetchRowCount) {
            Thread.sleep(1000);
        }
    }
};

(function (){
	// import and alias Java Thread and Runnable classes
	var Thread = Java.type("java.lang.Thread");
	var Runnable = Java.type("java.lang.Runnable");
	// declare thread
	var thread = new Thread(new Runnable(){
         run: main()
	});
	// start thread
	thread.start();
	return;
})();
