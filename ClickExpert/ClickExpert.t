var threadId
var isRan = false
var expertModeChecked = false

var cmdArr

function main()
    if(expertModeChecked)
        expertMode()
    else
        easyMode()
    end
end

//======================================== 简单模式 ========================================

function easyMode()
    traceprint("EasyMode is running...")
    
    var param = combogetcursel("MouseSelectType")
    var delay = editgettext("MouseClickDelay")
    
    while(true)
        select(param)
            // 左键连点
            case 0
            mouseleftclick()
            
            // 右键连点
            case 1
            mouserightclick()
            
            // 中间连点
            case 2
            mousemiddleclick()
            
            // 左右交替连点
            case 3
            mouseleftclick()
            sleep(delay)
            mouserightclick()
            
            default
            mouseleftclick()
        end
        sleep(delay)
    end
end

//======================================== 高级模式 ========================================

function expertMode()
    traceprint("ExpertMode is running...")
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
    controlenable("Expert_ClearCommandListButton", expertModeChecked)
    controlenable("Expert_CommandList", expertModeChecked)
end

//======================================== 控件事件 ========================================

// 高级模式
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
end

function Expert_ClearCommandListButton_点击()
    listdeleteall("Expert_CommandList")
end

function Expert_CommandList_左键双击()
    var index = listgetcursel("Expert_CommandList")
    listdeletetext("Expert_CommandList", index)
end

// 保存设置
function SaveSettings_点击()
    hotkeydestroy("StartHotKey")
    hotkeyregister("StartHotKey")
    
    hotkeydestroy("StopHotKey")
    hotkeyregister("StopHotKey")
end

// 还原设置
function RevertSettings_点击()
end

//======================================== 热键事件 ========================================

function StartHotKey_热键()
    if(!isRan)
        isRan = !isRan
        threadId = threadbegin("main", "")
    end
end

function StopHotKey_热键()
    isRan = !isRan
    threadclose(threadId)
end


function WebSite_点击()
    cmd("https://tools.bcl.dev/", false)
end
