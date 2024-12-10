/*
ASRS 先进shp渲染脚本
作者：红枫
特别感谢：戴子铃

2023/07/03 立项 UI制作
2023/07/19 改变风格，开始尝试更多卷帘
2023/08/08 加入粒子流源阴影对策，优化对灯光名称和数量的鲁棒性
2023/08/09 一键改变渲染尺寸

2024/02/26 基本完工

制作计划：
1、完全覆盖旧版脚本
2、支持自定义渲染输出
3、支持快速导入动作
4、支持快速导入一整套byd素材库（包括但不限于步兵装具模型，一些常用特效之类的
5、



*/


-- 基本函数体
-- 基本通用渲染函数
fn Ra2_Basic_Render_Function \
    Camera_name CenterDummy_name ShadowCaster_name \ 
                                                    --指定操作对象名：摄像机、中心块、投影灯
    Task_name Faces_Number Spring_Direction Pitch_Condition  SlientRender Pre_Spring Render_Range Shdaow_Force Shadow_Scale Shadow_Independence\
                                                    --指定渲染参数：任务名称、面数、旋转方向、是否带有倾斜、是否静默渲染、预旋转角度(顺时针)、渲染范围、影子强制、影子大小、影子独立
    Save_Path Save_prefix
                                                    --指定储存参数：储存路径、储存前缀

    =(
        ExecuteOrNo = 0
        --startTime = (dotNetClass "System.DateTime").Now
        if ((SlientRender as integer )==0) then 
        ( if queryBox ("即将进行渲染工作，渲染参数如下：\n\n"+"摄像机：" + (Camera_name as string) +\
        "]\n渲染任务：[" + (Task_name as string) + "] \n渲染面数：[" + (Faces_Number as string) + "] \n旋转方向：[" + (Spring_Direction as string) +  \
        "]\n倾斜参数：[" + (Pitch_Condition as string)+"] \n储存路径：[" + (Save_Path as string) + "] \n储存前缀：[" + (Save_prefix as string) + "] \n倾斜情况：[" + (Pitch_Condition as string) + \
        "]\n步进旋转角度："+((360.00 / (Faces_Number as integer)) as string) +"\n预旋转角度："+ (Pre_Spring as string)+"\n渲染范围："+ (Render_Range as string)+"\n影子方向强制："+ (Shdaow_Force as string)+"\n影子尺寸："+ (Shadow_Scale as string)+"\n渲染进行过程中可长按ESC跳出渲染\n\n" )  beep:false title:"确认是否渲染" then (ExecuteOrNo=1) else (ExecuteOrNo =0)
        --messagebox ("即将进行渲染工作，渲染参数如下：\n\n"+"摄像机：" + (Camera_name as string) +\
        --"]\n渲染任务：[" + (Task_name as string) + "] \n渲染面数：[" + (Faces_Number as string) + "] \n旋转方向：[" + (Spring_Direction as string) +  \
        --"]\n倾斜参数：[" + (Pitch_Condition as string)+"] \n储存路径：[" + (Save_Path as string) + "] \n储存前缀：[" + (Save_prefix as string) + \
        --"]\n步进旋转角度："+((360.00 / (Faces_Number as integer)) as string) +"\n渲染进行过程中可长按ESC跳出渲染\n\n" ) 


        )
        startTime = (dotNetClass "System.DateTime").Now
        if ((SlientRender as integer) == 1) then (ExecuteOrNo =1)
        if ((ExecuteOrNo as integer) ==1) then 
        (
                SetSelectFilter 1
                rotate $centerdummy (angleaxis (Pre_Spring as integer) [0,0,1])
                select $ShadowPlane
                $.receiveshadows = off
            select $centerdummy

            if (Spring_Direction as string) == "顺时针" do (Spring_Direction_Fix = 1)
            if (Spring_Direction as string) == "逆时针" do (Spring_Direction_Fix = -1)

            if Render_Range == "活动" do
            (
            for i = 1 to (Faces_Number as integer) do
                (
                    if i < 10 do
                    (
                        render RA2目标摄像机 framerange:#active outputFile:("D:\RA2Scripts\\"+ (Save_Path as string) +"//"+(Save_prefix as string)+"00"+(i as string)+".png") vfb:off
                        --rotate $ (angleaxis (360.00 / (Faces_Number as integer)) [0,0,1])
                    )
                    if (10<=i) and (i<=99) do
                    (
                        render RA2目标摄像机 framerange:#active outputFile:("D:\RA2Scripts\\"+ (Save_Path as string) +"//"+(Save_prefix as string)+"0"+(i as string)+".png") vfb:off
                        --rotate $ (angleaxis (360.00 / (Faces_Number as integer)) [0,0,1])
                    )
                    if (100<=i) and (i<=999) do
                    (
                        render RA2目标摄像机 framerange:#active outputFile:("D:\RA2Scripts\\"+ (Save_Path as string) +"//"+(Save_prefix as string)+(i as string)+".png") vfb:off
                        --rotate $ (angleaxis (360.00 / (Faces_Number as integer)) [0,0,1])
                    )
                    rotate $ (angleaxis ((360.00 / (Faces_Number as integer)) * Spring_Direction_Fix ) [0,0,1])
                )
          ) 
          if Render_Range == "当前" do
          (
          for i = 1 to (Faces_Number as integer) do
              (

                render RA2目标摄像机 frame:#current outputFile:("D:\RA2Scripts\\"+ (Save_Path as string) +"//"+(Save_prefix as string)+"00"+(i as string)+".png") vfb:off
                rotate $ (angleaxis ((360.00 / (Faces_Number as integer)) * Spring_Direction_Fix ) [0,0,1])
              )
          ) 



                clearSelection()
                select $ShadowPlane
                $.receiveshadows = on
                clearSelection()
                select $ShadowPlane
                actionMan.executeAction 0 "40044" 
                meditMaterials[16] = MatteShadow ()
                $.material = meditMaterials[16]
                $.receiveshadows = off
                clearSelection()


                --select #($摄像机角度补光1, $摄像机角度打黑, $投影方向低角度补光, $投影方向负数方向阴影, $右侧垂直补光, $右侧打暗)
                --$.renderable = off

                select lights
                $.renderable = off
                clearSelection()
                --for obj in objects where matchPattern obj.name pattern:"投影灯" do obj.renderable = on
                $投影灯.renderable = on

                clearSelection()
                select $ShadowPlane
                $.receiveshadows = on
                -- 尝试删除所有粒子流源

                   try(
                     for obj in objects where isKindOf obj (PF_Source) do delete obj
                   ) catch ()
                clearSelection()
                --尝试将投影灯拉到正上方
                if Shdaow_Force == "正下方" do 
                (
                    select $投影灯
                    $.pos = [0,0,500]
                )
                clearSelection()

                --尝试将影子帧渲染尺寸缩减到百分之五十

                if Shadow_Scale == "50%" do 
                (
                    select $RA2目标摄像机
                    $.fov = $.fov * 1.5
                )

                --尝试将所有几何体不再遮挡影子

                if Shadow_Independence == "不遮挡" do 
                (
                    SetSelectFilter 2
                    actionMan.executeAction 0 "40021"
                    

                    $.primaryVisibility = off
                    $.receiveshadows = off
                    SetSelectFilter 1
                )
                clearSelection()



                
                select $centerdummy
                if Render_Range == "活动" do
                (
                    for i = 1 to (Faces_Number as integer) do
                    (
                        if i < 10 do
                        (
                            render RA2目标摄像机 framerange:#active outputFile:("D:\RA2Scripts\\"+ (Save_Path as string) +"//"+"S"+(Save_prefix as string)+"00"+(i as string)+".png") vfb:off
                            --rotate $ (angleaxis (360.00 / (Faces_Number as integer)) [0,0,1])
                        )
                        if (10<=i) and (i<=99) do
                        (
                            render RA2目标摄像机 framerange:#active outputFile:("D:\RA2Scripts\\"+ (Save_Path as string) +"//"+"S"+(Save_prefix as string)+"0"+(i as string)+".png") vfb:off
                            --rotate $ (angleaxis (360.00 / (Faces_Number as integer)) [0,0,1])
                        )
                        if (100<=i) and (i<=999) do
                        (
                            render RA2目标摄像机 framerange:#active outputFile:("D:\RA2Scripts\\"+ (Save_Path as string) +"//"+"S"+(Save_prefix as string)+(i as string)+".png") vfb:off
                            --rotate $ (angleaxis (360.00 / (Faces_Number as integer)) [0,0,1])
                        )
                        rotate $ (angleaxis ((360.00 / (Faces_Number as integer)) * Spring_Direction_Fix ) [0,0,1])
                    )
                )
                if Render_Range == "当前" do
                (
                for i = 1 to (Faces_Number as integer) do
                    (
                      render RA2目标摄像机 frame:#current outputFile:("D:\RA2Scripts\\"+ (Save_Path as string) +"//"+"S"+(Save_prefix as string)+"00"+(i as string)+".png") vfb:off
                      rotate $ (angleaxis ((360.00 / (Faces_Number as integer)) * Spring_Direction_Fix ) [0,0,1])
                    )
                ) 
                
                endTime = (dotNetClass "System.DateTime").Now
                ts = endTime.Subtract startTime
                useSeconds = ts.TotalSeconds as float
                --format "用时%秒\r\n" useSeconds
            if ((SlientRender as integer )==0) then (messagebox ("==========================================\n"+"渲染完毕!\n本次渲染共计用时:"+(useSeconds as string)+"秒                         ") title:"渲染成功执行")
    ) 
    if ((ExecuteOrNo as integer) ==0) then  ( (messageBox "==============================\n渲染进程被手动停止，未渲染任何帧") title:"手动停止")
    )












rolWidth = 400
button_width = 90
button_width2 = 115
button_width_INF = 70
-- 定义几个常数用一用
Global_CenterDummy="centerdummy"
Global_ShadowCaster="投影灯"
Global_Camera="RA2目标摄像机"
Global_ShadowPlane="ShadowPlane"







-- 定义子卷展栏
rollout SceneControl "场景控制" width:rolWidth 
    (
         group "快速控制按钮    提示：按完按钮之后点一下视口来刷新视口" (
            
            button 'Import_3Light' "基本3光场景" height:24 width:button_width align:#center across:4
            button 'Import_8Light' "扩展8光场景" height:24 width:button_width align:#center
            button 'Import_SkyLight' "Nord天光场景" height:24 width:button_width align:#center
            button 'Clear_lights' "清除所有场景" height:24 width:button_width align:#center

           -- button 'Import_Wall' "围墙场景" height:24 width:button_width align:#center across:4
          --  button 'Import_XLB' "XLB标准场景" height:24 width:button_width align:#center
          --  button 'Import_XTS' "甜薯标准场景" height:24 width:button_width align:#center
           -- button 'Import_Costom' "自定义场景" height:24 width:button_width align:#center


            button 'BG_Blue' "蓝色背景" height:24 width:button_width align:#center across:4
            button 'BG_White' "白色背景" height:24 width:button_width align:#center
            button 'BG_Green' "绿色背景" height:24 width:button_width align:#center
            button 'BG_Black' "黑色背景" height:24 width:button_width align:#center

            --button 'Shadow_Below' "顶部投影" height:24 width:button_width align:#center across:2
            --button 'Shadow_Normal' "建筑投影" height:24 width:button_width align:#center
            --button 'OpenCS' "打开自定义选项" height:24 width:300 align:#center
    )
        on Import_3Light pressed do --3光场景
        (
        
        clearSelection()
        mergeMAXFile "D:\RA2Scripts\Building scene.max" #mergeDups
        max vpt camera
        max tool maximize
        messagebox" 场景已导入！"
        )
        on Import_8Light pressed do --8光场景
        (
        
        clearSelection()
        mergeMAXFile "D:\RA2Scripts\Building scene 8lights.max" #mergeDups
        max vpt camera
        max tool maximize
        messagebox" 场景已导入！"
        )
        on Import_SkyLight pressed do --天光场景
        (
        
        clearSelection()
        mergeMAXFile "D:\RA2Scripts\Nord场景.max" #mergeDups
        max vpt camera
        max tool maximize
        messagebox" 场景已导入！"
        )
        on Clear_lights pressed do --删除所有场景
        (
        --select #($centerdummy, $RA2目标摄像机, $ShadowPlane, $基本光照, $'基本光照.Target', $基本光照001, $'基本光照001.Target', $基本光照002, $'基本光照002.Target', $目标001, $投影灯, $'投影灯.Target')
           -- max delete
            try (
            delete $centerdummy
            ) catch ()
            try (
            delete $RA2目标摄像机
            ) catch ()
            try (
            delete $ShadowPlane
            ) catch ()
            try (
            delete lights
            ) catch () 
        )

        on BG_Blue pressed do --导入蓝色背景
        (
        
        clearSelection()
        useEnvironmentMap = on
        environmentMap = Bitmaptexture fileName:"D:\RA2Scripts\Background\blue.png"
        clearSelection()
        messagebox" 蓝色背景已导入！"
        )
        on BG_White pressed do --导入白色背景
        (
        
        clearSelection()
        useEnvironmentMap = on
        environmentMap = Bitmaptexture fileName:"D:\RA2Scripts\Background\white.png"
        clearSelection()
        messagebox" 白色背景已导入！"
        )
        on BG_Green pressed do --导入绿色背景
        (
        
        clearSelection()
        useEnvironmentMap = on
        environmentMap = Bitmaptexture fileName:"D:\RA2Scripts\Background\green.png"
        clearSelection()
        messagebox" 绿色背景已导入！"
        )
        on BG_Black pressed do --导入黑色背景
        (
        
        clearSelection()
        useEnvironmentMap = on
        environmentMap = Bitmaptexture fileName:"D:\RA2Scripts\Background\black.png"
        clearSelection()
        messagebox" 黑色背景已导入！"
        )



        on OpenCS pressed do --打开自定义选项面板
        (
            createDialog CustomSetting
        )
    )
rollout CameraContorl "摄像机与渲染尺寸控制" width:rolWidth 
    (
         group "快速控制按钮    提示：按完按钮之后点一下视口来刷新视口" (
            
            button 'L45' "←摄像机左转45度" height:48 width:150 align:#center across:2
            button 'R45' "摄像机右转45度→" height:48 width:150 align:#center across:2

            button 'Zoom_SmallBuildings' "调整为小建筑渲染尺寸" height:24 width:150 align:#center across:2
            button 'Zoom_LargeBuildings' "调整为大建筑渲染尺寸" height:24 width:150 align:#center
    )
        on L45 pressed do --摄像机左转45
        (
            clearSelection()
            --select $centerdummy
            try (rotate $centerdummy (angleaxis -45 [0,0,1])) catch (messagebox "==============================\n执行错误，检查是否正确配置中心块" title:"执行错误")
            clearSelection()
        )
         on R45 pressed do --摄像机右转45
        (
            clearSelection()
            --select $centerdummy
            --rotate $centerdummy (angleaxis 45 [0,0,1])
            try (rotate $centerdummy (angleaxis 45 [0,0,1])) catch (messagebox "==============================\n执行错误，检查是否正确配置中心块" title:"执行错误")
            clearSelection()
        )
        on Zoom_SmallBuildings pressed do --小建筑渲染尺寸
        (
            $RA2目标摄像机.fov = 50.8846
            messageBox("请将渲染尺寸设定为640*480                    ")
            actionMan.executeAction 0 "60010"  -- Render: 渲染设置
        )
        on Zoom_LargeBuildings pressed do --小建筑渲染尺寸
        (
            $RA2目标摄像机.fov = 98.171
            messageBox("请将渲染尺寸设定为1500*1500                    ")
            actionMan.executeAction 0 "60010"  -- Render: 渲染设置
        )   





    )


rollout BuildingRender "建筑渲染" width:rolWidth 
    (
        group "建筑渲染" (
            button 'Building_render' "渲染本体帧" height:24 width:button_width2 align:#center across:2
            --button 'Building_render2' "渲染两次本体帧" height:24 width:button_width2 align:#center
            button 'Building_Anim' "建筑动画" height:24 width:button_width2 align:#center 
            button 'Building_Wall_1' "围墙自动对准" height:24 width:button_width2 align:#center across:2
            button 'Building_Wall_2' "输出围墙帧" height:24 width:button_width2 align:#center
        )
        on Building_render pressed do --本体帧
        (
            try(
            Ra2_Basic_Render_Function \
            (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "建筑本体帧渲染" 1 "逆时针" "默认"  0 0 "当前" "随场景" "100%" "遮挡"\
            "Building" "A"
            ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
        )
        on Building_Anim pressed do --建筑动画帧
        (
            try(
            Ra2_Basic_Render_Function \
            (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "建筑动画帧渲染" 1 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
            "BuildingAnim" "A"
            ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
        )







    )



rollout CustomSetting "自定义设置选项" width:rolWidth 
    (
         group "在这里重新指定各种常用字符串" (
            
            edittext 'Name_CenterDummy' "中心虚拟块自定义名称" text:"centerdummy" width:380 align:#right
            edittext 'Name_ShadowCaster' "投影灯自定义名称" text:"投影灯" width:380 align:#right
            edittext 'Name_Camera' "摄像机自定义名称" text:"RA2目标摄像机" width:380 align:#right
            edittext 'Name_ShadowPlane' "ShadowPlane自定义名称" text:"ShadowPlane" width:380 align:#right
            button 'ParametersUpdate' "更新重要变量" height:30 width:300 align:#center

    )
        group "主要变量" (
            button 'ParametersCheck' "查看重要变量" height:30 width:300 align:#center
        )
         on ParametersUpdate pressed do --更新重要变量
    (
        Global_CenterDummy= Name_CenterDummy.text
        Global_ShadowCaster= Name_ShadowCaster.text
        Global_Camera= Name_Camera.text
        Global_ShadowPlane= Name_ShadowPlane.text
        messagebox "主要变量已更新，仅适用于当前会话"
    )
        on ParametersCheck pressed do --查看主要变量
    (
        messagebox ("当前脚本主要变量如下：\n\n"+"中心块："+(Global_CenterDummy as string)+"\n"+"投影灯："+(Global_ShadowCaster as string)+"\n"+"摄像机："+(Global_Camera as string)+"\n"+"阴影板："+(Global_ShadowPlane as string)+"\n\n\n") width:400
    )
    )

rollout InfantryRenderSubmenu "步兵渲染子窗口" width:(rolWidth+50) 
    (
         group "步兵帧手动渲染" (
            button 'Inf_Stand' "Stand" height:24 width:button_width_INF align:#center across:7
            button 'Inf_Walk' "Walk" height:24 width:button_width_INF align:#center
            button 'Inf_Fireup' "Fireup" height:24 width:button_width_INF align:#center
            button 'Inf_Idle1' "Idle_1" height:24 width:button_width_INF align:#center
            button 'Inf_Idle2' "Idle2" height:24 width:button_width_INF align:#center 
            button 'Inf_Die1' "Die_1" height:24 width:button_width_INF align:#center 
            button 'Inf_Die2' "Die_2" height:24 width:button_width_INF align:#center
            button 'Inf_Crawl' "Crawl" height:24 width:button_width_INF align:#center across:7
            button 'Inf_Cheer' "Cheer" height:24 width:button_width_INF align:#center
            button 'Inf_FireP' "FireP" height:24 width:button_width_INF align:#center
            button 'Inf_Deploy' "Deploy" height:24 width:button_width_INF align:#center
            button 'Inf_Deployed' "Deployed" height:24 width:button_width_INF align:#center
            button 'Inf_Deployfire' "Dep_Fire" height:24 width:button_width_INF align:#center
            button 'Inf_Thread' "Thread" height:24 width:button_width_INF align:#center
            button 'Inf_Swim' "Swim" height:24 width:button_width_INF align:#center  across:7
            button 'Inf_Wetattack' "Wet_Fire" height:24 width:button_width_INF align:#center
            button 'Inf_WetIdle' "WetIdle" height:24 width:button_width_INF align:#center
            button 'Inf_Wetdie' "Wetdie" height:24 width:button_width_INF align:#center
            button 'Inf_Up' "Up" height:24 width:button_width_INF align:#center
            button 'Inf_Down' "Down" height:24 width:button_width_INF align:#center
            button 'Inf_Fly' "Fly" height:24 width:button_width_INF align:#center
            button 'Inf_Hover' "Hover" height:24 width:button_width_INF align:#center across:7
            button 'Inf_Tumble' "Tumble" height:24 width:button_width_INF align:#center
            button 'Inf_FireFly' "FireFly" height:24 width:button_width_INF align:#center
            button 'Inf_2ndFire' "2ndFire" height:24 width:button_width_INF align:#center
            button 'Inf_2ndFireProne' "2ndFire_P" height:24 width:button_width_INF align:#center
            button 'Inf_Para' "paradrop" height:24 width:button_width_INF align:#center
            button 'Inf_Panic' "Panic" height:24 width:button_width_INF align:#center
            button 'Inf_Shovel' "Shovel" height:24 width:button_width_INF align:#center  across:3
            button 'Inf_Carry' "Carry" height:24 width:button_width_INF align:#center
            button 'Inf_Guard' "Guard" height:24 width:button_width_INF align:#center 

            label infco "======自定义步兵帧======" align:#center across:1
            edittext 'Inf_prefix' "帧前缀" text:"RN" width:300 align:#left across:1
            button 'Inf_Single' "渲染单向" height:24 width:button_width2 align:#center across:2
            button 'Inf_All' "渲染8向" height:24 width:button_width2 align:#center
    )
    on Inf_Stand pressed do --站立帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵站立帧渲染" 8 "逆时针" "默认"  0 0 "当前" "随场景" "100%" "遮挡"\
        "INF8" "A"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    on Inf_Walk pressed do --步行帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵步行帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "B"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    on Inf_Fireup pressed do --攻击帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵攻击帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "C"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    on Inf_Idle1 pressed do --闲置1帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵第一闲置帧渲染" 1 "逆时针" "默认"  0 -135 "活动" "随场景" "100%" "遮挡"\
        "INF8" "D"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    on Inf_Idle2 pressed do --闲置2帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵第二闲置帧渲染" 1 "逆时针" "默认"  0 -225 "活动" "随场景" "100%" "遮挡"\
        "INF8" "E"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    on Inf_Die1 pressed do --死亡1帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵第一死亡帧渲染" 1 "逆时针" "默认"  0 -135 "活动" "随场景" "100%" "遮挡"\
        "INF8" "F"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    on Inf_Die2 pressed do --死亡1帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵第二死亡帧渲染" 1 "逆时针" "默认"  0 -225 "活动" "随场景" "100%" "遮挡"\
        "INF8" "G"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    on Inf_Crawl pressed do --爬行帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵爬行帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "H"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    on Inf_Cheer pressed do --欢呼帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵欢呼帧渲染" 1 "逆时针" "默认"  0 135 "活动" "随场景" "100%" "遮挡"\
        "INF8" "I"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
   on Inf_FireP pressed do --匍匐攻击帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵匍匐攻击帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "J"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
  on Inf_Deploy pressed do --部署帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵部署帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "K"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )

  on Inf_Deployed pressed do --部署状态帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵部署状态帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "L"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Deployfire pressed do --部署开火帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵部署开火帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "M"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Thread pressed do --原地游泳帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵原地游泳帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "N"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Swim pressed do --移动游泳帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵移动游泳帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "O"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Wetattack pressed do --攻击游泳帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵攻击游泳帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "P"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )

 on Inf_WetIdle pressed do --闲置游泳帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵闲置游泳帧渲染" 1 "逆时针" "默认"  0 135 "活动" "随场景" "100%" "遮挡"\
        "INF8" "Q"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Wetdie pressed do --死亡游泳帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵死亡游泳帧渲染" 1 "逆时针" "默认"  0 -135 "活动" "随场景" "100%" "遮挡"\
        "INF8" "R"
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )

 on Inf_Up pressed do --爬起来帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵爬起来帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RA" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Down pressed do --趴下帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵趴下帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RB" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Fly pressed do --飞行帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵飞行帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RC" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Hover pressed do --悬停帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵悬停帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RD" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Tumble pressed do --掉落帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵掉落帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RE" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_FireFly pressed do --空中开火帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵空中开火帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RF" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_2ndFire pressed do --第二武器开火帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵第二武器开火帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RG" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_2ndFire pressed do --第二武器开火帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵第二武器开火帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RG" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_2ndFireProne pressed do --第二武器匍匐开火帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵第二武器匍匐开火帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RH" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Para pressed do --伞降帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵伞降帧渲染" 1 "逆时针" "默认"  0 180 "当前" "随场景" "100%" "遮挡"\
        "INF8" "RI" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Panic pressed do --恐慌帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵恐慌帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RJ" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Shovel pressed do --铲子帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵铲子帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RK" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )

 on Inf_Carry pressed do --携带矿物帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵携带矿物帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RL" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
 on Inf_Guard pressed do --警戒帧
    (
        try(
        Ra2_Basic_Render_Function \
        (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
        "步兵警戒帧渲染" 8 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
        "INF8" "RM" -- S被影子占用，为避免混淆从RA计算起
        ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
    )
    
    )




    rollout AnimRenderSubmenu "动画渲染子窗口" width:(rolWidth+50) 
    (
         group "动画渲染" (
            button 'Anim_Default' "一般动画" height:24 width:button_width align:#center across:4
            button 'Anim_Firing' "开火动画" height:24 width:button_width align:#center 
            button 'Anim_Proj' "抛射体\\建筑塔" height:24 width:button_width align:#center 
            button 'Anim_Proj_Dynamic' "动态抛射体" height:24 width:button_width align:#center 
            button 'Anim_SHP_Turret' "SHP载具的炮塔" height:24 width:button_width align:#center across:1
        )
        on Anim_Default pressed do --一般动画
        (
            try(
            Ra2_Basic_Render_Function \
            (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "一般动画渲染" 1 "逆时针" "默认"  0 0 "当前" "随场景" "100%" "遮挡"\
            "Anim" "A" -- S被影子占用，为避免混淆从RA计算起
            ) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
        )
        on Anim_Firing pressed do --开火动画
        (
            try(
            Ra2_Basic_Render_Function \
            (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "开火动画渲染" 32 "顺时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
            "Anim" "F" -- S被影子占用，为避免混淆从RA计算起
            ) catch (messagebox ("============F=====================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
        )
        on Anim_Proj pressed do --开火动画
        (
            try(
            Ra2_Basic_Render_Function \
            (getNodeByName (GlobaBl_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "抛射体\\建筑塔渲染" 32 "逆时针" "默认"  0 0 "当前" "随场景" "100%" "遮挡"\
            "Anim" "B" -- S被影子占用，为避免混淆从RA计算起
            ) catch (messagebox ("============F=====================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
        )
        on Anim_Proj_Dynamic pressed do --动态抛射体
        (
            try(
            Ra2_Basic_Render_Function \
            (getNodeByName (GlobaBl_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "动态抛射体渲染" 32 "逆时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
            "Anim" "C" -- S被影子占用，为避免混淆从RA计算起
            ) catch (messagebox ("============F=====================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
        )
        on Anim_SHP_Turret pressed do --SHP载具的炮塔
        (
            try(
            Ra2_Basic_Render_Function \
            (getNodeByName (GlobaBl_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "SHP载具的炮塔渲染" 32 "顺时针" "默认"  0 0 "活动" "随场景" "100%" "遮挡"\
            "SHP_Turret" "AT" -- S被影子占用，为避免混淆从RA计算起
            ) catch (messagebox ("============F=====================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误")     
        )


        )
   


        rollout InfantryModelsSubmenu "步兵零件子窗口" width:(rolWidth+50) 
        (
             group "导入武器" (
                button 'Inf_Model_1' "武器1 QBZ191" height:24 width:button_width align:#center across:4
                button 'Inf_Model_2' "武器2 86s" height:24 width:button_width align:#center 
                button 'Inf_Model_3' "武器3 AKM" height:24 width:button_width align:#center 
                button 'Inf_Model_4' "武器4 G36C" height:24 width:button_width align:#center 
                button 'Inf_Model_5' "武器5 VHS2" height:24 width:button_width align:#center across:4
                button 'Inf_Model_6' "武器6 AKS74U" height:24 width:button_width align:#center 
                button 'Inf_Model_7' "武器7 69式40火" height:24 width:button_width align:#center 
                button 'Inf_Model_8' "武器8 M110SAAS" height:24 width:button_width align:#center 
            )
            group "导入原版身体护甲" (
                button 'Inf_Model2_1' "护甲1 动员兵" height:24 width:button_width align:#center across:4
                button 'Inf_Mode2l_2' "护甲2 心灵突击" height:24 width:button_width align:#center
                button 'Inf_Mode2l_3' "护甲3 GI" height:24 width:button_width align:#center
                button 'Inf_Mode2l_4' "护甲4 飞兵" height:24 width:button_width align:#center
                button 'Inf_Model2_5' "护甲5 超时空" height:24 width:button_width align:#center across:1            
            )
            group "导入动画 该栏目请在导入时选择更新动画选项" (
                button 'Inf_Anim_1' "持枪跑步" height:24 width:button_width align:#center across:4
                button 'Inf_Anim_2' "爬行" height:24 width:button_width align:#center
                button 'Inf_Anim_3' "向前死亡" height:24 width:button_width align:#center
                button 'Inf_Anim_4' "向后死亡" height:24 width:button_width align:#center
            )




            on Inf_Model_1 pressed do --导入武器1
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\红枫 QBZ191.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model_2 pressed do --导入武器2
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\红枫 86s.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )   
            on Inf_Model_3 pressed do --导入武器3
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\红枫 AKM.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model_4 pressed do --导入武器4
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\红枫 G36C.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model_5 pressed do --导入武器5
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\红枫2 VHS2.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model_6 pressed do --导入武器6
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\红枫 AKS74U.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model_7 pressed do --导入武器7
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\红枫 69式40火.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model_8 pressed do --导入武器8
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\红枫 M110SAAS.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
               
           on Inf_Model2_1 pressed do --导入身体1
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\原版 动员兵.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model2_2 pressed do --导入身体2
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\原版 心灵突击.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model2_3 pressed do --导入身体3
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\原版 GI.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )
            on Inf_Model2_4 pressed do --导入身体4
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\原版 飞兵.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )     
            on Inf_Model2_5 pressed do --导入身体5
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\原版 超时空.FBX" #noPrompt 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )         
            on Inf_Anim_1 pressed do --持枪跑步
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\动画 持枪跑步.FBX" 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )               
            
            on Inf_Anim_2 pressed do --爬行
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\动画 爬行.FBX" 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )               
            on Inf_Anim_3 pressed do --向前死亡
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\动画 向前死亡.FBX" 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )              
            on Inf_Anim_4 pressed do --向后死亡
            (
                try(
                    importFile "D:\\RA2Scripts\\Models_inf\\动画 向后死亡.fbx" 
                ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
            )              

            
            )





            rollout OtherModelsSubmenu "其他子窗口" width:(rolWidth+50) 
            (
                 group "导入" (
                    button 'Other_Gunfire' "枪火" height:24 width:button_width align:#center across:4
         
                )
    
                on Other_Gunfire pressed do --导入武器1
                (
                    try(
                        mergeMAXFile "D:\RA2Scripts\Gunfire.max"
                    ) catch (messagebox ("=================================\n"+"导入失败！\n") title:"发生致命错误")     
                )

                )
    




























rollout CustomRender "自定义渲染" width:rolWidth 
    (
        group "自定义渲染" (
            dropdownlist Co_faces "旋转面数" items:#("1", "4", "8", "16","32", "64","128","256") selection:1 width:button_width2 align:#center across:3
            dropdownlist Co_spring "旋转方向" items:#("顺时针", "逆时针") selection:1 width:button_width2 align:#center
            dropdownlist Co_Pitch "俯仰方向（暂时不可用）" items:#("默认", "带斜坡") selection:1 width:button_width2 align:#center

            dropdownlist Co_Range "渲染范围" items:#("活动", "当前") selection:1 width:button_width2 align:#center across:3
            dropdownlist Co_ShadowDirection "影子方向" items:#("随场景", "正下方") selection:1 width:button_width2 align:#center
            dropdownlist Co_ShadowScale "影子大小" items:#("100%", "50%") selection:1 width:button_width2 align:#center

            dropdownlist Co_HideMeshWhenShadow "本体遮挡阴影" items:#("遮挡", "不遮挡") selection:1 width:button_width2 align:#center across:1

            edittext 'Co_prefix' "帧前缀" text:"A" width:300 align:#left across:1
            button 'Co_Render' "开始渲染" height:24 width:button_width2 align:#center 
        )
        on Co_Render pressed do --自定义渲染，启动
        (

            --Global_CenterDummy="centerdummy"
            --Global_ShadowCaster="投影灯"
            --Global_Camera="RA2目标摄像机"
            --Global_ShadowPlane="ShadowPlane"
            --try(destroydialog Test) catch() 
            --messagebox (Global_Camera as string)

            --try(
            Ra2_Basic_Render_Function \
            (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "自定义渲染" (Co_faces.selected as integer) (Co_spring.selected) (Co_Pitch.selected) 0 0 (Co_Range.selected as string) (Co_ShadowDirection.selected as string) (Co_ShadowScale.selected as string)  (Co_HideMeshWhenShadow.selected as string)\
            "Custom" Co_prefix.text
            --) catch (messagebox ("=================================\n"+"渲染函数运行中发生致命错误或被手动停止\n"+"渲染任务未完全执行\n"+"请检查重要场景对象名称和脚本是否一致\n\n") title:"发生致命错误") 
                        

                        /*
            Ra2_Basic_Render_Function \
            (getNodeByName (Global_Camera as string)) (getNodeByName (Global_CenterDummy as string)) (getNodeByName (Global_ShadowCaster as string)) \
            "自定义渲染" (Co_faces.selected as integer) (Co_spring.selected) \
            (Co_Pitch.selected) "Custom" Co_prefix.text
            */
            
    )
    )



-- 主要卷展栏

rollout ASRS_MainUI "ASRS主菜单 1.5" width:300
    (
       
        group "主要设置" (
            button 'OpenSC' "场景导入与设置" height:48 width:130 align:#center across:2        
        
            button 'OpenCC' "摄像机与渲染尺寸" height:48 width:130 align:#center 
        )
        group "渲染" (
            button 'OpenBR' "建筑渲染" height:48 width:130 align:#center across:2  

            button 'OpenINF' "步兵渲染" height:48 width:130 align:#center

            button 'OpenANIM' "动画渲染" height:48 width:130 align:#center across:2  

            button 'OpenCR' "自定义渲染" height:48 width:130 align:#center
        )
      --  group "动画" (
      --      button 'PFFLOWANIM' "预制粒子流源动画" height:48 width:130 align:#center across:2  
      --      button 'SCENEANIM' "预制场景动画" height:48 width:130 align:#center
      --  )
        group "对象" (
            button 'INFStructure' "预制步兵零件" height:48 width:130 align:#center across:2  
            button 'MISCStructure' "预制其他零件" height:48 width:130 align:#center
        )


--
        group "关于" (
        label 'basicinfo' "作者：红枫\n版本：V1.5 \n时间：2024/02/26" height:40 width:140 align:#left
        --label 'basicinfo1' "同戴子铃脚本通用默认工作目录" height:15 width:150 align:#right
        button 'Help' "帮助文档" height:24 width:button_width2 align:#center

        )

        --Ra2_Basic_Render_Function \
        --Camera_name CenterDummy_name ShadowCaster_name \ 
                                                        --指定操作对象名：摄像机、中心块、投影灯
        --Task_name Faces_Number Spring_Direction Pitch_Condition  \
                                                        --指定渲染参数：任务名称、面数、旋转方向、是否带有倾斜
        --Save_Path Save_prefix  SlientRender
                                                        --指定储存参数：储存路径、储存后缀、静默渲染

        
        
        on OpenSC pressed do --打开场景控制面板
        (
            createDialog SceneControl
            
        )
        on OpenCC pressed do --打开摄像机控制面板
        (
            createDialog CameraContorl
            
        )
        on OpenBR pressed do --打开建筑渲染
        (
            createDialog BuildingRender
            
        )
        on OpenINF pressed do --打开步兵面板
        (
            createDialog InfantryRenderSubmenu
            
        )        
        on OpenANIM pressed do --打开动画面板
        (
            createDialog AnimRenderSubmenu
            
        )        
        on INFStructure pressed do --打开步兵预制件面板
        (
            createDialog InfantryModelsSubmenu
            
        )        

        on MISCStructure pressed do --打开其他面板
        (
            createDialog OtherModelsSubmenu
            
        )        
        

        on OpenCR pressed do --打开自定义面板
        (
            createDialog CustomRender
            
        )        
        on Help pressed do --打开自定义面板
        (
            messagebox ("请直接询问作者")
        )        




    )



createDialog ASRS_MainUI
gc()
clearlistener()