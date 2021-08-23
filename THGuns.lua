require ('lib.moonloader')
local imgui = require ('imgui')
local rkeys = require ('lib.rkeys')
local vkeys = require ('vkeys')
local inicfg = require ('inicfg')
local encoding = require 'encoding'
local imadd = require 'imgui_addons'
encoding.default = 'CP1251'
u8 = encoding.UTF8

--****************** [ Конфиг ] ***************
local config_direct = "\\THG\\pos.ini" --Директория конфига
local iniconfig = inicfg.load(nil, config_direct)
if iniconfig == nil then -- Если нет создаем
 ini = {
    main = {
        active = false,
        x=500,
        y=500
		   }
       }
     inicfg.save(ini, config_direct) -- сохраняем то что внесли
     iniconfig = inicfg.load(nil, config_direct) -- подключаем
end
--****************** [ Работа с директорией ] ***************
path_settings = getWorkingDirectory().."\\config"
if not doesDirectoryExist(path_settings..'\\THG') then
    createDirectory(path_settings..'\\THG')
end
filename_settings = path_settings.."\\THG\\buttons.txt"
--****************** [ Функции ] ***************
function deepcopy(orig)
  local orig_type = type(orig)
  local copy
  if orig_type == 'table' then
      copy = {}
      for orig_key, orig_value in next, orig, nil do
          copy[deepcopy(orig_key)] = deepcopy(orig_value)
      end
      setmetatable(copy, deepcopy(getmetatable(orig)))
  else -- number, string, boolean, etc
      copy = orig
  end
  return copy
end

local Luacfg = {
	_version = "9"
}
setmetatable(Luacfg, {
	__call = function(self)
		return self.__init()
	end
})
function Luacfg.__init()
	local self = {}
	local lfs = require "lfs"
	local inspect = require "inspect"
	
	function self.mkpath(filename)
		local sep, pStr = package.config:sub(1, 1), ""
		local path = filename:match("(.+"..sep..").+$") or filename
		for dir in path:gmatch("[^" .. sep .. "]+") do
			pStr = pStr .. dir .. sep
			lfs.mkdir(pStr)
		end
	end
	
	function self.load(filename, tbl)
		local file = io.open(filename, "r")		
		if file then 
			local text = file:read("*all")
			file:close()
			
			local lua_code = loadstring("return "..text)
			if lua_code then
				loaded_tbl = lua_code()
				
				if type(loaded_tbl) == "table" then
					for key, value in pairs(loaded_tbl) do
						tbl[key] = value
					end
					return true
				else
					return false
				end
			else
				return false
			end
		else
			return false
		end
  end
	
	function self.save(filename, tbl)
		self.mkpath(filename)
		
		local file = io.open(filename, "w+")
		if file then
			file:write(inspect(tbl))
			file:close()
			return true
		else
			return false
		end
	end
	
	return self
end
--****************** [ Таблица клавиш ] ***************
luacfg = Luacfg()
cfg = {
    hotkey_deagle = {vkeys.VK_1},
    hotkey_shotgun = {vkeys.VK_2},
    hotkey_m4 = {vkeys.VK_3},
    hotkey_rifle = {vkeys.VK_4},
    hotkey_rpg = {vkeys.VK_5},
    hotkey_armour = {vkeys.VK_6}
}
luacfg.load(filename_settings, cfg)
--****************** [ Переменные ] ***************
local hotkeys = {   -- хоткей
 hotkey_deagle = {v = deepcopy(cfg.hotkey_deagle)},
 hotkey_shotgun = {v = deepcopy(cfg.hotkey_shotgun)},
 hotkey_m4 = {v = deepcopy(cfg.hotkey_m4)},
 hotkey_rifle = {v = deepcopy(cfg.hotkey_rifle)},
 hotkey_rpg = {v = deepcopy(cfg.hotkey_rpg)},
 hotkey_armour = {v = deepcopy(cfg.hotkey_armour)}
}
local THG_Text = -- Вывод сообщения
{
    '-------------------------------------------------',
    '{33aa33}/thg{FFFFFF} - сменить положение панели',
    '{33aa33}/thg.help{FFFFFF} - помощь по командам',
    '{33aa33}/thg.m{FFFFFF} - сменить бинды кнопок',
    '-------------------------------------------------'
}
local Gun_Info = -- Информация о оружии
{
    weapon = {24,25,31,33,35},
    name_weapon = {'{ff0000}Deagle','{ffff00}ShotGun','{ff0000}M4','{ffff00}Rifle','{ff0000}RPG-7','{808080}Бронежилет'},
    th_name = {'deag','shot','m4','rif','rpg','ar'},
    bool_weapon = {false,false,false,false,false,false}
}
local variables = { -- переменные
    text = '',
    font = renderCreateFont("Arial Black", 11, 12),
    font2 = renderCreateFont("Arial Black", 9, 12),
    Active = imgui.ImBool(iniconfig.main.active),
    window = imgui.ImBool(false)
}
--****************** [ Main] ***************
function main()
    while not isSampAvailable() do wait(100) end
    repeat wait(0) until sampIsLocalPlayerSpawned()
    sampAddChatMessage("{FFFFFF}[{1E90FF}Take/Hide Guns{FFFFFF}] Author:{42aaff} Leon4ik", -1)
    sampRegisterChatCommand("thg.m",function()
        variables.window.v = not variables.window.v
    end)
    sampRegisterChatCommand("thg.help",function()
        for k,v in ipairs(THG_Text) do
            sampAddChatMessage(v,-1)
        end
    end)
    sampRegisterChatCommand("thg",set)
	
    if variables.Active.v then
        deagle = rkeys.registerHotKey(hotkeys.hotkey_deagle.v, true, function()
            if Gun_Info.bool_weapon[1] then
                sampSendChat('/hide '..Gun_Info.th_name[1])
            else 
                sampSendChat('/take '..Gun_Info.th_name[1])
            end
        end)
        shotgun = rkeys.registerHotKey(hotkeys.hotkey_shotgun.v, true, function()
            if Gun_Info.bool_weapon[2] then
                sampSendChat('/hide '..Gun_Info.th_name[2])
            else 
                sampSendChat('/take '..Gun_Info.th_name[2])
            end
        end)
        m4 = rkeys.registerHotKey(hotkeys.hotkey_m4.v, true, function()
            if Gun_Info.bool_weapon[3] then
                sampSendChat('/hide '..Gun_Info.th_name[3])
            else 
                sampSendChat('/take '..Gun_Info.th_name[3])
            end
        end)
        rifle = rkeys.registerHotKey(hotkeys.hotkey_rifle.v, true, function()
            if Gun_Info.bool_weapon[4] then
                sampSendChat('/hide '..Gun_Info.th_name[4])
            else 
                sampSendChat('/take '..Gun_Info.th_name[4])
            end
        end)
        rpg = rkeys.registerHotKey(hotkeys.hotkey_rpg.v, true, function()
            if Gun_Info.bool_weapon[5] then
                sampSendChat('/hide '..Gun_Info.th_name[5])
            else 
                sampSendChat('/take '..Gun_Info.th_name[5])
            end
        end)
        armour = rkeys.registerHotKey(hotkeys.hotkey_armour.v, true, function()
            if Gun_Info.bool_weapon[6] then
                sampSendChat('/hide '..Gun_Info.th_name[6])
            else 
                sampSendChat('/take '..Gun_Info.th_name[6])
            end
        end)
    end

    while true do
    wait(0)
    if variables.Active.v then
            variables.text = ''
            for k,v in ipairs(Gun_Info.weapon) do
                if hasCharGotWeapon(PLAYER_PED, v) then
                    variables.text = variables.text .. Gun_Info.name_weapon[k]..'\n'
                    Gun_Info.bool_weapon[k] = true
                else 
                    Gun_Info.bool_weapon[k] = false
                end
            end
            if getCharArmour(playerPed) > 0 then
                variables.text = variables.text..Gun_Info.name_weapon[6]
                Gun_Info.bool_weapon[6] = true
            else 
                Gun_Info.bool_weapon[6] = false
            end
            renderFontDrawText(variables.font, "Активные слоты:\n{ffff00}", iniconfig["main"]["x"],iniconfig["main"]["y"]-20,bit.bor(00255000, 0xFF000000))
            renderFontDrawText(variables.font2, variables.text, iniconfig["main"]["x"],iniconfig["main"]["y"],bit.bor(00255000, 0xFF000000))
            if mode then  -- нижняя панель
                local nx, ny = getCursorPos()
                iniconfig["main"]["x"] = nx
                iniconfig["main"]["y"] = ny
                if isKeyJustPressed(13) then
                    showCursor(false, false)
                    mode = false
                    inicfg.save(iniconfig, config_direct)
                end
            end
    end
        imgui.Process = variables.window.v
    end
end
--****************** [ Imgui ] ***************
function imgui.OnDrawFrame()
  if variables.window.v then
    imgui.ShowCursor = true
    imgui.SetNextWindowPos(imgui.ImVec2(imgui.GetIO().DisplaySize.x / 2, imgui.GetIO().DisplaySize.y / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
    imgui.SetNextWindowSize(imgui.ImVec2(190, 200), imgui.Cond.FirstUseEver)
    imgui.Begin('HotKeys', variables.window, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoCollapse)
    imgui.Text(variables.Active.v and u8"Скрипт включён" or u8"Скрипт выключен")
    imgui.SameLine()
    if imadd.ToggleButton(u8'##active', variables.Active) then
        iniconfig.main.active = variables.Active.v
        inicfg.save(iniconfig, config_direct)
    end

    local tLastKeys = {}
    if variables.Active.v then
        if require('imgui_addons').HotKey("##hotkey_deagle", hotkeys.hotkey_deagle, tLastKeys, 100) then
        rkeys.changeHotKey(deagle, hotkeys.hotkey_deagle.v)
        cfg.hotkey_deagle = deepcopy(hotkeys.hotkey_deagle.v)
        luacfg.save(filename_settings, cfg)
        end
        imgui.SameLine()
        imgui.Text('Deagle') 

        if require('imgui_addons').HotKey("##hotkey_shotgun", hotkeys.hotkey_shotgun, tLastKeys, 100) then
        rkeys.changeHotKey(shotgun, hotkeys.hotkey_shotgun.v)
        cfg.hotkey_shotgun = deepcopy(hotkeys.hotkey_shotgun.v)
        luacfg.save(filename_settings, cfg)
        end
        imgui.SameLine()
        imgui.Text('ShotGun') 

        if require('imgui_addons').HotKey("##hotkey_m4", hotkeys.hotkey_m4, tLastKeys, 100) then
            rkeys.changeHotKey(m4, hotkeys.hotkey_m4.v)
            cfg.hotkey_m4 = deepcopy(hotkeys.hotkey_m4.v)
            luacfg.save(filename_settings, cfg)
        end
        imgui.SameLine()
        imgui.Text('M4') 
    
        if require('imgui_addons').HotKey("##hotkey_rifle", hotkeys.hotkey_rifle, tLastKeys, 100) then
            rkeys.changeHotKey(rifle, hotkeys.hotkey_rifle.v)
            cfg.hotkey_rifle = deepcopy(hotkeys.hotkey_rifle.v)
            luacfg.save(filename_settings, cfg)
        end
        imgui.SameLine()
        imgui.Text('Rifle') 

        if require('imgui_addons').HotKey("##hotkey_rpg", hotkeys.hotkey_rpg, tLastKeys, 100) then
            rkeys.changeHotKey(rpg, hotkeys.hotkey_rpg.v)
            cfg.hotkey_rpg = deepcopy(hotkeys.hotkey_rpg.v)
            luacfg.save(filename_settings, cfg)
        end
        imgui.SameLine()
        imgui.Text('RPG') 

        if require('imgui_addons').HotKey("##hotkey_armour", hotkeys.hotkey_armour, tLastKeys, 100) then
            rkeys.changeHotKey(armour, hotkeys.hotkey_armour.v)
            cfg.hotkey_armour = deepcopy(hotkeys.hotkey_armour.v)
            luacfg.save(filename_settings, cfg)
        end
        imgui.SameLine()
        imgui.Text('Armour') 
    end
    imgui.End()
  end
end

function set(i) -- перемещение
    mode = true
    showCursor(true, true)
end

function bluetheme()
    imgui.SwitchContext()
    local colors = imgui.GetStyle().Colors;
    local icol = imgui.Col
    local ImVec4 = imgui.ImVec4

    imgui.GetStyle().WindowPadding = imgui.ImVec2(8, 8)
    imgui.GetStyle().WindowRounding = 5.0
    imgui.GetStyle().FramePadding = imgui.ImVec2(5, 3)
    imgui.GetStyle().ItemSpacing = imgui.ImVec2(4, 4)
    imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(5, 5)
    imgui.GetStyle().IndentSpacing = 9.0
    imgui.GetStyle().ScrollbarSize = 17.0
    imgui.GetStyle().ScrollbarRounding = 16.0
    imgui.GetStyle().GrabMinSize = 7.0
    imgui.GetStyle().GrabRounding = 6.0
    imgui.GetStyle().ChildWindowRounding = 6.0
    imgui.GetStyle().FrameRounding = 6.0

    colors[icol.Text]                   = ImVec4(0.90, 0.90, 0.90, 1.00);
    colors[icol.TextDisabled]           = ImVec4(0.60, 0.60, 0.60, 1.00);
    colors[icol.WindowBg]               = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.ChildWindowBg]          = ImVec4(0.13, 0.13, 0.13, 1.00);
    colors[icol.PopupBg]                = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.Border]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.BorderShadow]           = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.FrameBg]                = ImVec4(0.26, 0.46, 0.82, 0.59);
    colors[icol.FrameBgHovered]         = ImVec4(0.26, 0.46, 0.82, 0.88);
    colors[icol.FrameBgActive]          = ImVec4(0.28, 0.53, 1.00, 1.00);
    colors[icol.TitleBg]                = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.TitleBgActive]          = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.TitleBgCollapsed]       = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.MenuBarBg]              = ImVec4(0.26, 0.46, 0.82, 0.75);
    colors[icol.ScrollbarBg]            = ImVec4(0.11, 0.11, 0.11, 1.00);
    colors[icol.ScrollbarGrab]          = ImVec4(0.26, 0.46, 0.82, 0.68);
    colors[icol.ScrollbarGrabHovered]   = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ScrollbarGrabActive]    = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ComboBg]                = ImVec4(0.26, 0.46, 0.82, 0.79);
    colors[icol.CheckMark]              = ImVec4(1.000, 0.000, 0.000, 1.000)
    colors[icol.SliderGrab]             = ImVec4(0.263, 0.459, 0.824, 1.000)
    colors[icol.SliderGrabActive]       = ImVec4(0.66, 0.66, 0.66, 1.00);
    colors[icol.Button]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.ButtonHovered]          = ImVec4(0.26, 0.46, 0.82, 0.59);
    colors[icol.ButtonActive]           = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.Header]                 = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.HeaderHovered]          = ImVec4(0.26, 0.46, 0.82, 0.74);
    colors[icol.HeaderActive]           = ImVec4(0.26, 0.46, 0.82, 1.00);
    colors[icol.Separator]              = ImVec4(0.37, 0.37, 0.37, 1.00);
    colors[icol.SeparatorHovered]       = ImVec4(0.60, 0.60, 0.70, 1.00);
    colors[icol.SeparatorActive]        = ImVec4(0.70, 0.70, 0.90, 1.00);
    colors[icol.ResizeGrip]             = ImVec4(1.00, 1.00, 1.00, 0.30);
    colors[icol.ResizeGripHovered]      = ImVec4(1.00, 1.00, 1.00, 0.60);
    colors[icol.ResizeGripActive]       = ImVec4(1.00, 1.00, 1.00, 0.90);
    colors[icol.CloseButton]            = ImVec4(0.00, 0.00, 0.00, 1.00);
    colors[icol.CloseButtonHovered]     = ImVec4(0.00, 0.00, 0.00, 0.60);
    colors[icol.CloseButtonActive]      = ImVec4(0.35, 0.35, 0.35, 1.00);
    colors[icol.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[icol.PlotLinesHovered]       = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[icol.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[icol.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[icol.TextSelectedBg]         = ImVec4(0.00, 0.00, 1.00, 0.35);
    colors[icol.ModalWindowDarkening]   = ImVec4(0.20, 0.20, 0.20, 0.35);
end
bluetheme()