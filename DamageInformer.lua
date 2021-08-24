--******[ Описание Скрипта ]*******
script_authors('Leon4ik')
script_version('1.3')
script_version_number(2)
--******[ Библиотеки ]*******
require ('lib.moonloader')
local sampev = require ('lib.samp.events')
local vkeys = require ('vkeys')
local inicfg = require ('inicfg')
-- Inicfg
local ini = "DamageInformer/settings.ini"
local mainini = inicfg.load(nil, ini)
if mainini == nil then 
    main =  {
        main = 
        {
			nicks = false,
			takedamage = false,
			givedamage = false,
            TDx = 700,
            TDy = 450,
            GDx = 1100,
            GDy = 450,
            kolokol=false,
            volume=30
        }
    }
        inicfg.save(main, ini) 
        mainini = inicfg.load(nil, ini)
end 
-- variables
local font = renderCreateFont("Arial Black", 13, 12)
local font2 = renderCreateFont("Arial Black", 9, 13)
local TID = nil
local GID = nil
local TakeDamage = nil
local GiveDamage = nil
local combo = {}
local Render_y = mainini.main.GDy
local Render_y2 = mainini.main.TDy
local active = false
local shara = nil
local mode, mode2 = false, false 

for i=0,1000 do
    table.insert(combo, {0,nil})
end

local Texts = {"Обосран","Выебан","Опущен","Унижен"}

function main()
    while not isSampAvailable() do wait(100) end
    repeat wait(0) until sampIsLocalPlayerSpawned()
    sampAddChatMessage('[{1E90FF}DMGInformer{FFFFFF}] Author:{42aaff} Leon4ik{FFFFFF}. /dmgi', -1) 
	
	sampRegisterChatCommand("dmgi",function()
        sampAddChatMessage("[{1E90FF}DMGInformer{FFFFFF}]:",-1)
        sampAddChatMessage("{1E90FF}/dmgtake{FFFFFF} - включить/выключить полученный урон",-1)
        sampAddChatMessage("{1E90FF}/dmggive{FFFFFF} - включить/выключить наносимый урон",-1)
        sampAddChatMessage("{1E90FF}/dmgnick{FFFFFF} - включить/выключить ники",-1)
        sampAddChatMessage("{1E90FF}/dmgkol{FFFFFF} - включить/выключить колокол",-1)
        sampAddChatMessage("{1E90FF}/dmgkolv{FFFFFF} - Сменить громкость колокола от 0 до 100",-1)
        sampAddChatMessage("{1E90FF}/dmgс 1-2{FFFFFF} - Сменить положение Получаемого[1] или Наносимого[2] урона",-1)
	end)
    sampRegisterChatCommand("dmgс",function(arg)
        if tonumber(arg) == 1 then
            set()
        elseif tonumber(arg) == 2 then
            set2()
        else 
            sampAddChatMessage('[{1E90FF}DMGInformer{FFFFFF}]: Неправильный режим. Нужно 1 или 2.',-1)
        end
    end)
    sampRegisterChatCommand("dmgkolv",function(arg)
        if type(tonumber(arg)) == 'number' then
            if tonumber(arg) > 0 and tonumber(arg) < 101 then
                sampAddChatMessage(mainini.main.takedamage and '[{1E90FF}DMGInformer{FFFFFF}]: Звук сменён с {008000}'..mainini.main.volume ..'{FFFFFF} на {008000}'..arg,-1)
                mainini.main.volume = tonumber(arg)
                inicfg.save(mainini, ini)
            else sampAddChatMessage('[{1E90FF}DMGInformer{FFFFFF}]: Нужно число больше 0 и не больше 100!',-1) end
        else sampAddChatMessage('[{1E90FF}DMGInformer{FFFFFF}]: Нужно число!',-1) end
    end)

    sampRegisterChatCommand("dmgtake",function()
        mainini.main.takedamage = not mainini.main.takedamage 
        sampAddChatMessage(mainini.main.takedamage and '[{1E90FF}DMGInformer{FFFFFF}]: Полученный урон {008000}включён' or '[{1E90FF}DMGInformer{FFFFFF}]: Полученный урон {ff0000}выключен',-1)
        inicfg.save(mainini, ini)
    end)
        
    sampRegisterChatCommand("dmgnick",function()
        mainini.main.nicks = not mainini.main.nicks 
        sampAddChatMessage(mainini.main.nicks and '[{1E90FF}DMGInformer{FFFFFF}]: Ники {008000}включены' or '[{1E90FF}DMGInformer{FFFFFF}]: Ники {ff0000}выключены',-1 )
        inicfg.save(mainini, ini)
    end)
        
    sampRegisterChatCommand("dmggive",function()
        mainini.main.givedamage = not mainini.main.givedamage 

        sampAddChatMessage(mainini.main.givedamage and '[{1E90FF}DMGInformer{FFFFFF}]: Нанесёный урон {008000}включён' or '[{1E90FF}DMGInformer{FFFFFF}]: Нанесёный урон {ff0000}выключен',-1)
        inicfg.save(mainini, ini)
    end)
    sampRegisterChatCommand("dmgkol",function()
        mainini.main.kolokol = not mainini.main.kolokol 

        sampAddChatMessage(mainini.main.kolokol and '[{1E90FF}DMGInformer{FFFFFF}]: Колокол {008000}включён' or '[{1E90FF}DMGInformer{FFFFFF}]: Колокол {ff0000}выключен',-1)
        inicfg.save(mainini, ini)
    end)

    lua_thread.create(times)
    lua_thread.create(render)
end

function times()
    while true do wait(30)
        Render_y = Render_y - 1
        if Render_y < mainini.main.GDy - 50 then Render_y = mainini.main.GDy  GiveDamage = nil TID = nil end
        Render_y2 = Render_y2 - 1
        if Render_y2 < mainini.main.TDy - 50 then Render_y2 = mainini.main.TDy  TakeDamage = nil GID = nil end
    end
end

function render()
    while true do wait(0)
		if GiveDamage ~= nil and GID ~= nil and not sampIsPlayerPaused(GID) then
			if mainini.main.givedamage then
				renderFontDrawText(font,string.format('{29871f}%0.1f'.."{ff0000}(x"..combo[GID][1]..")",GiveDamage), mainini.main.GDx, Render_y, -1)
			end
			if mainini.main.nicks then
				renderFontDrawText(font2,sampGetPlayerNickname(GID).."["..GID.."]", mainini.main.GDx, mainini.main.GDy+30, sampGetPlayerColor(GID))
			end
		elseif GiveDamage ~= nil and GID ~= nil and  sampIsPlayerPaused(GID) then
			if mainini.main.givedamage then
				renderFontDrawText(font,'{808080}AFK', mainini.main.GDx, Render_y, -1)
			end
			if mainini.main.nicks then
				renderFontDrawText(font2,sampGetPlayerNickname(GID).."["..GID.."]", mainini.main.GDx, mainini.main.GDy+30, sampGetPlayerColor(GID))
			end
		end
		
		if TakeDamage ~= nil and sampIsPlayerConnected(TID) and TID ~= nil then
			if mainini.main.takedamage then
				renderFontDrawText(font,string.format('{83020e}%0.1f',TakeDamage), mainini.main.TDx, Render_y2, -1)
			end
			if  mainini.main.nicks and mainini.main.takedamage then 
				renderFontDrawText(font2,sampGetPlayerNickname(TID).."["..TID.."]", mainini.main.TDx, mainini.main.TDy+30, sampGetPlayerColor(TID))
			end
		end
        if mainini.main.givedamage and active then
            renderFontDrawText(font,'{83020e}'..shara, mainini.main.GDx, mainini.main.GDy-70, -1)
        end
        if mode then  -- нижняя панель
            local nx, ny = getCursorPos()
            mainini.main.TDx = nx
            mainini.main.TDy = ny
            if isKeyJustPressed(13) then
                showCursor(false, false)
                mode = false
                inicfg.save(mainini, ini)
            end
        end
        if mode2 then  -- нижняя панель
            local nx, ny = getCursorPos()
            mainini.main.GDx = nx
            mainini.main.GDy = ny
            if isKeyJustPressed(13) then
                showCursor(false, false)
                mode2 = false
                inicfg.save(mainini, ini)
            end
        end
        for k,v in ipairs(combo) do
            if combo[k][1] > 0 and combo[k][2] ~= nil and os.time() - combo[k][2] > 5 then combo[k][1] = 0 combo[k][2] = nil end
        end
	end
end

function sampev.onPlayerDeath(id)
    if id == GID then
        lua_thread.create(function()
            shara = Texts[math.random(1,#Texts)]
            active = true
            wait(1000)
            shara = nil
            active = false
        end)
    end
end


function sampev.onSendTakeDamage(playerId, damage, weapon, bodypart)
	TakeDamage = damage
	TID = playerId
	Render_y2 = mainini.main.TDy
end

function sampev.onSendGiveDamage(playerId, damage, weapon, bodypart)
	GiveDamage = damage
	GID = playerId
	combo[GID][1] = combo[GID][1] + 1
    combo[GID][2] = os.time()
	Render_y = mainini.main.GDy
    if mainini.main.kolokol and doesFileExist('moonloader/config/DamageInformer/kolokol.mp3') then
        local audio = loadAudioStream('moonloader/config/DamageInformer/kolokol.mp3')
        setAudioStreamState(audio, 1)
        setAudioStreamVolume(audio, mainini.main.volume)
    end
end

function set(i) -- перемещение
    sampAddChatMessage('[{1E90FF}DMGInformer{FFFFFF}]: Нажмите {ffff00}Enter {FFFFFF} чтобы сохранить координаты',-1)
    mode = true
    showCursor(true, true)
end
function set2(i) -- перемещение
    sampAddChatMessage('[{1E90FF}DMGInformer{FFFFFF}]: Нажмите {ffff00}Enter {FFFFFF} чтобы сохранить координаты',-1)
    mode2 = true
    showCursor(true, true)
end