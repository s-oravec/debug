var watchedDebugGroupId = args[1]

var groupSql =
' select debug_adm.group_exists(:idDebugGroup) as group_exists from dual\n'
;

var logSql =
' select id_debug_log,\n' +
'        text\n' +
'   from table(debug_format.get_debug_lines(:idDebugLogLast, :idDebugGroup, :fetchRowCount))\n'
;

var debugLogBinds = {
    idDebugGroup: watchedDebugGroupId,
    idDebugLogLast: -1,
    fetchRowCount: 10
};

var main = function () {
    var Thread = Java.type("java.lang.Thread");
    var System = Java.type("java.lang.System");

    while (true) {
        // fetch log messages
        var result = util.executeReturnListofList(logSql, debugLogBinds);
        for (var i = 1; i < result.size(); i++) {
            debugLogBinds.idDebugLogLast = result[i][0];
            System.out.println(result[i][1]);
        }
        // sleep if fetched all
        if (result.size() < debugLogBinds.fetchRowCount) {
            Thread.sleep(1000);
            // exit when group has been dropped
            var result = util.executeReturnListofList(groupSql, {idDebugGroup: watchedDebugGroupId});
            if (result[1][0] == 'N') {
                return;
            }
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
