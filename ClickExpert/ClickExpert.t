var debug = false
var isRan = false
var isDriveKM = false // 是否开启超级键鼠
var expertModeChecked = false

var threadId
var cmdArr = array()

function main()
    if(expertModeChecked)
        expertMode()
    else
        easyMode()
    end
end

//======================================== 简单模式 ========================================

function easyMode()
    debug("EasyMode is running...", "easyMode")
    
    debug("get params", "easyMode")
    var param = combogetcursel("MouseSelectType")
    var delay = editgettext("MouseClickDelay")
    debug("params ---> MouseSelectType: " & param & ", MouseClickDelay: " & delay, "easyMode")
    
    debug("start loop", "easyMode")
    while(true)
        select(param)
            // 左键
            case 0
            mouseLeftClick()
            
            // 右键
            case 1
            mouseRightClick()
            
            // 中间
            case 2
            mouseMiddleClick()
            
            // 左右交替
            case 3
            mouseLeftClick()
            sleep(delay)
            mouseRightClick()
            
            default
            debug("mouse click command has error, execute default command: mouseLeftClick()", "easyMode.select.default")
            mouseLeftClick()
        end
        sleep(delay)
    end
end

//======================================== 高级模式 ========================================

function expertMode()
    debug("ExpertMode is running...", "expertMode")
    
    debug("get params", "expertMode")
    var loop = checkgetstate("Expert_LoopCheckBox")
    debug("params ---> Expert_LoopCheckBox: " & loop, "expertMode")
    
    debug("start loop", "expertMode")
    while(true)
        
        for(var i = 0; i < arraysize(cmdArr); i++)
            var res = transformCommand(cmdArr[i])
            distributeCommand(res["type"], res["params"])
        end
        
        if(!loop)
            debug("exit loop", "expertMode")
            break
        end
    end
    
    debug("ExpertMode stopped...", "expertMode")
    stop()
end

// 将命令列表控件中的内容, 保存至数组中
function saveCommand()
    debug("Parsing command...", "saveCommand")
    arrayclear(cmdArr)
    var count = listgetcount("Expert_CommandList")
    
    for(var i = 0; i < count; i++)
        cmdArr[i] = listgettext("Expert_CommandList", i)
    end
    
    debug(arraytostring(cmdArr), "saveCommand")
end

// 转换命令
// array(0 = "MOVE|1234|1234") => array(0 = "MOVE", 1 = array(0 = "1234", 1 = "1234"))
function transformCommand(commandStr)
    debug("Transforming command...", "transformCommand")
    var res = array(), params = array(), retArr
    
    // 如果是发送字符串命令时, 不进行分割操作, 避免将 value 分割的错误.
    var leftStr = strleft(commandStr, 3)
    if(leftStr == "STR")
        res["type"] = leftStr
        params[0] = strcut(commandStr, 4, true)
        res["params"] = params
        return res
    end
    
    strsplit(commandStr, "|", retArr)
    
    for(var i = 0; i < arraysize(retArr); i++)
        if(i > 0)
            params[i - 1] = retArr[i]
        end
    end
    
    res["type"] = retArr[0]
    res["params"] = params
    
    debug("result ---> " & arraytostring(res), "transformCommand")
    return res
end

// 分发命令
function distributeCommand(commandType, paramArr)
    debug("Distributing command...", "distributeCommand")
    
    select(commandType)
        case "KEY"
        executeKeyCommand(paramArr[0], paramArr[1])
        
        case "MOVE"
        executeMoveCommand(paramArr[0], paramArr[1])
        
        case "MOUSE"
        executeMouseCommand(paramArr[0], paramArr[1])
        
        case "STR"
        executeStrCommand(paramArr[0])
        
        case "DELAY"
        executeDelayCommand(paramArr[0])
        
        default
        debug("distributed command has error, exit script...", "distributeCommand.select.default")
        stop()
    end
end

function executeKeyCommand(type, code)
    debug("Executing key command...", "executeKeyCommand")
    debug("params ---> " & type & ", " & code, "executeKeyCommand")
    
    select(type)
        case 0
        keyPress(code)
        
        case 1
        keyDown(code)
        
        case 2
        keyUp(code)
        
        default
        debug("executed key command has error, exit script...", "executeKeyCommand.select.default")
        stop()
    end
end

function executeMoveCommand(x, y)
    debug("Executing mouse move command...", "executeMoveCommand")
    debug("params ---> " & x & ", " & y, "executeMoveCommand")
    
    mouseMove(x, y)
end

function executeMouseCommand(type, code)
    debug("Executing mouse click command...", "executeMouseCommand")
    debug("params ---> " & type & ", " & code, "executeMouseCommand")
    
    if(type == 0 && code == 0) // 点击左键
        mouseLeftClick()
    elseif(type == 0 && code == 1) // 点击右键
        mouseRightClick()
    elseif(type == 0 && code == 2) // 点击中建
        mouseMiddleClick()
    elseif(type == 1 && code == 0) // 按下左键
        mouseLeftDown()
    elseif(type == 1 && code == 1) // 按下右键
        mouseRightDown()
    elseif(type == 1 && code == 2) // 按下中键
        mouseMiddleDown()
    elseif(type == 2 && code == 0) // 弹起左键
        mouseLeftUp()
    elseif(type == 2 && code == 1) // 弹起右键
        mouseRightUp()
    elseif(type == 2 && code == 2) // 弹起中键
        mouseMiddleUp()
    else
        mouseLeftClick()
    end
end

function executeStrCommand(str)
    debug("Executing send string command...", "executeStrCommand")
    debug("params ---> " & str, "executeStrCommand")
    
    keySendStr(str)
end

function executeDelayCommand(ms)
    debug("Executing delay command...", "executeDelayCommand")
    debug("params ---> " & ms, "executeDelayCommand")
    
    sleep(ms)
end

//======================================== UI 更新 ========================================

// 简单模式
function EasyModeComponentStatusRefesh()
    controlenable("MouseSelectType", !expertModeChecked)
    controlenable("MouseClickDelay", !expertModeChecked)
end

// 高级模式
function ExpertModeComponentStatusRefesh()
    
    // 命令区控件
    controlenable("Expert_LoopCheckBox", expertModeChecked)
    controlenable("Expert_KeyAction", expertModeChecked)
    controlenable("Expert_KeyCode", expertModeChecked)
    controlenable("Expert_MouseAction", expertModeChecked)
    controlenable("Expert_MouseCode", expertModeChecked)
    controlenable("Expert_MoveX", expertModeChecked)
    controlenable("Expert_MoveY", expertModeChecked)
    controlenable("Expert_Str", expertModeChecked)
    controlenable("Expert_Delay", expertModeChecked)
    
    // 添加按钮控件
    controlenable("Expert_AddKeyCommandButton", expertModeChecked)
    controlenable("Expert_AddMouseCommandButton", expertModeChecked)
    controlenable("Expert_AddMoveCommandButton", expertModeChecked) // 变量名过长执行时会报错, 找不到控件
    controlenable("Expert_AddSendStrCommandButton", expertModeChecked)
    controlenable("Expert_AddDelayCommandButton", expertModeChecked)
    
    // 命令列表控件
    controlenable("Expert_ImportCommandListButton", expertModeChecked)
    controlenable("Expert_ExportCommandListButton", expertModeChecked)
    controlenable("Expert_ClearCommandListButton", expertModeChecked)
    controlenable("Expert_CommandList", expertModeChecked)
end

//======================================== 控件事件 ========================================

// 开启/关闭高级模式
function ExpertModeCheckBox_点击()
    expertModeChecked = checkgetstate("ExpertModeCheckBox")
    EasyModeComponentStatusRefesh()
    ExpertModeComponentStatusRefesh()
end

function Expert_AddKeyCommandButton_点击()
    var keyAction = combogetcursel("Expert_KeyAction")
    var keyCode = editgettext("Expert_KeyCode")
    
    listaddtext("Expert_CommandList", "KEY|" & keyAction & "|" & keyCode)
end

function Expert_AddMoveCommandButton_点击()
    var x = editgettext("Expert_MoveX")
    var y = editgettext("Expert_MoveY")
    
    listaddtext("Expert_CommandList", "MOVE|" & x & "|" & y)
end

function Expert_AddMouseCommandButton_点击()
    var mouseAction = combogetcursel("Expert_MouseAction")
    var mouseCode = combogetcursel("Expert_MouseCode")
    listaddtext("Expert_CommandList", "MOUSE|" & mouseAction & "|" & mouseCode)
end

function Expert_AddSendStrCommandButton_点击()
    var str = editgettext("Expert_Str")
    listaddtext("Expert_CommandList", "STR|" & str)
end

function Expert_AddDelayCommandButton_点击()
    var str = editgettext("Expert_Delay")
    listaddtext("Expert_CommandList", "DELAY|" & str)
end

function Expert_ImportCommandListButton_点击()
    var path = filedialog(1, "ClickExpert(*.ce)")
    if(path == "")
        return
    end
    
    var fd = fileopen(path)
    if(fd == -1)
        messagebox("读取文件失败", "error")
        return
    end
    
    listdeleteall("Expert_CommandList")
    while(true)
        var content = strtrim(filereadline(fd))
        listaddtext("Expert_CommandList", content)
        if(fileisend(fd))
            break
        end
    end
    
    fileclose(fd)
    saveCommand()
    messagebox("导入成功", "Success")
end

function Expert_ExportCommandListButton_点击()
    var  count = listgetcount("Expert_CommandList")
    if(count < 1)
        messagebox("命令列表为空", "Error")
        return
    end
    
    var path = filedialog(0, "ClickExpert(*.ce)")
    path = strtrim(path, ".ce") & ".ce"
    
    if(fileexist(path) == 1)
        filewriteex(path, "")
    end
    
    filecreate(path, "CREATE_NEW")
    
    for(var i = 0; i < count; i++)
        fileaddtext(path, listgettext("Expert_CommandList", i))
        if(i < count - 1)
            fileaddtext(path, "\n")
        end
    end
    
    messagebox("导出成功", "Success")
end

function Expert_ClearCommandListButton_点击()
    listdeleteall("Expert_CommandList")
end

function Expert_CommandList_左键双击()
    var index = listgetcursel("Expert_CommandList")
    listdeletetext("Expert_CommandList", index)
end

function DebugCheckBox_点击()
    debug = !debug
end

// 保存设置
function SaveSettings_点击()
    hotkeydestroy("StartHotKey")
    hotkeyregister("StartHotKey")
    
    hotkeydestroy("StopHotKey")
    hotkeyregister("StopHotKey")
    
    if(expertModeChecked)
        saveCommand()
    end
    
    messagebox("应用成功", "Info")
end

//======================================== 热键事件 ========================================

function StartHotKey_热键()
    start()
end

function StopHotKey_热键()
    stop()
end

function WebSite_点击()
    cmd("https://github.com/goclon/ClickExpert", false)
end

//======================================== 键盘代理 ========================================
function keyPress(code, num = 1)
    if(isDriveKM)
        drivekeypress(code, num)
    else
        keypress(code, num)
    end
end

function keyDown(code)
    if(isDriveKM)
        drivekeydown(code)
    else
        keydown(code)
    end
end

function keyUp(code)
    if(isDriveKM)
        drivekeyup(code)
    else
        keyup(code)
    end
end

function keySendStr(str, delay = 50)
    if(isDriveKM)
        drivekeystring(str, delay)
    else
        keysendstring(str, delay)
    end
end

//======================================== 鼠标代理 ========================================

// 移动
function mouseMove(x, y)
    if(isDriveKM)
        drivemousemove(x, y)
    else
        mousemove(x, y)
    end
end

// 左键
function mouseLeftClick(num = 1)
    if(isDriveKM)
        drivemouseleftclick(num)
    else
        mouseleftclick(num)
    end
end

function mouseLeftDown()
    if(isDriveKM)
        drivemouseleftdown()
    else
        mouseleftdown()
    end
end

function mouseLeftUp()
    if(isDriveKM)
        drivemouseleftup()
    else
        mouseleftup()
    end
end

// 右键
function mouseRightClick(num = 1)
    if(isDriveKM)
        drivemouserightclick(num)
    else
        mouserightclick(num)
    end
end

function mouseRightDown()
    if(isDriveKM)
        drivemouserightdown()
    else
        mouserightdown()
    end
end

function mouseRightUp()
    if(isDriveKM)
        drivemouserightup()
    else
        mouserightup()
    end
end

// 中键
function mouseMiddleClick(num = 1)
    if(isDriveKM)
        drivemousemiddleclick(num)
    else
        mousemiddleclick(num)
    end
end

function mouseMiddleDown()
    if(isDriveKM)
        drivemousemiddledown()
    else
        mousemiddledown()
    end
end

function mouseMiddleUp()
    if(isDriveKM)
        drivemousemiddleup()
    else
        mousemiddleup()
    end
end

//======================================== 其他函数 ========================================

function start()
    if(!isRan)
        isRan = !isRan
        threadId = threadbegin("main", "")
        
        debug("Start script. " & timenow(), "main")
    end
end

function stop()
    isRan = !isRan
    threadclose(threadId)
    
    debug("Stop script. " & timenow(), "stop")
end

function debug(obj, fn)
    if(debug)
        traceprint("fn: " & fn & " => " & obj)
        filelog("fn: " & fn & " => " & obj, "./debug.log")
    end
end
