--[[ Init - Localize Functions ]]
local io_write, os_execute, print, string_format, os_date, io_open, string_gmatch, string_gsub, io_popen, string_find, io_read, os_exit
	= io.write, os.execute, print, string.format, os.date, io.open, string.gmatch, string.gsub, io.popen, string.find, io.read, os.exit



--[[ Init - Color Functions ]]
local pairs=pairs;local tostring=tostring;local setmetatable=setmetatable;local a=string.char;local b={}local c={}function c:__tostring()return self.value end;function c:__concat(d)return tostring(self)..tostring(d)end;function c:__call(e)return self..e..b.reset end;c.__metatable={}local function f(g)return setmetatable({value=a(27)..'['..tostring(g)..'m'},c)end;local h={reset=0,clear=0,bright=1,dim=2,underscore=4,blink=5,reverse=7,hidden=8,black=30,red=31,green=32,yellow=33,blue=34,magenta=35,cyan=36,white=37,onblack=40,onred=41,ongreen=42,onyellow=43,onblue=44,onmagenta=45,oncyan=46,onwhite=47}for i,j in pairs(h)do b[i]=f(j)end--ansicolors mini
local ansicolors = b
local _reset, _white, _black = ansicolors.reset.value, ansicolors.white.value, ansicolors.black.value

local _onblack = ansicolors.onblack.value
local _ColorDefault = string_format("%s%s%s", _reset, _onblack, _white)
local function ColorDefault()
	io_write(_ColorDefault)
end
local _onblue = ansicolors.onblue.value
local _ColorBlue = string_format("%s%s%s", _reset, _onblue, _white)
local function ColorBlue()
	io_write(_ColorBlue)
end
local _onred = ansicolors.onred.value
local _ColorRed = string_format("%s%s%s", _reset, _onred, _white)
local function ColorRed()
	io_write(_ColorRed)
end
local _onyellow = ansicolors.onyellow.value
local _ColorYellow = string_format("%s%s%s", _reset, _onyellow, _black)
local function ColorYellow()
	io_write(_ColorYellow)
end
local _ongreen = ansicolors.ongreen.value
local _ColorGreen = string_format("%s%s%s", _reset, _ongreen, _black)
local function ColorGreen()
	io_write(_ColorGreen)
end



--[[ Init - Startup ]]
ColorDefault() os_execute("cls && title JM36 Stand Console")
ColorBlue() print("\n", string_format("[ JM36 Stand Console ] - %s - Wrapper Started", os_date()), "\n") ColorDefault()



--[[ Read ini config ]]
local function string_endsWith(str, ending)
	return ending == "" or str:sub(-#ending) == ending
end
local function string_split(inputstr,sep)
	sep = sep or "%s" local t,n={},0
	for str in string_gmatch(inputstr, "([^"..sep.."]+)") do
		n=n+1 t[n]=str
	end
return t end
local config, configFile = {}, io_open("JM36_Stand_Console.ini")
if configFile then
	local function string_startsWith(str, start)
		return str:sub(1, #start) == start
	end
	for line in configFile:lines() do
		if not (string_startsWith(line, "[") and string_endsWith(line, "]")) then
			line = string_gsub(line, "\n", "")
			line = string_gsub(line, "\r", "")
			if line ~= "" and string_find(line, "=") then
				line = string_split(line, "=")
				config[line[1]] = line[2]
			end
		end
	end
	configFile:close()
end

--[[ Failsafe/Backup/Defaults ]]
local config_StandDirGTA
if true then
	local _config_StandDirGTA = io_popen("powershell [Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData)")
	config_StandDirGTA = string_gsub(_config_StandDirGTA:read("*a"), "\n", "").."\\Stand\\"
	_config_StandDirGTA:close()
end
string_endsWith = nil
local config_PreserveLogs = config.PreserveLogs~="false"
local config_RegExHighlightRed = string_split(config.RegExHighlightRed or " Marking , as modder for ,] Blocked , blocked from , crash from , is spectating , Exception ,0x, Stack trace:,GTA5+0x,<unknown>", ",")
local config_RegExHighlightRedNum = #config_RegExHighlightRed
string_split = nil
config = nil



--[[ What's currently running ]]
local IsOpen_GTA
local function IsOpenUpdate()
	local _IsOpen_GTA = io_popen('tasklist | findstr GTA5.exe')
	IsOpen_GTA = string_find(_IsOpen_GTA:read("*a"), "GTA5.exe")
	_IsOpen_GTA:close()
end



--[[ Core/Loop ]]
local logFileStand, logFileStandChat = io_open(config_StandDirGTA.."Log.txt"), io_open(config_StandDirGTA.."Chat.txt")
if not IsOpen_GTA then
	for line in logFileStand:lines() do end
	for line in logFileStandChat:lines() do end
end
while true do
	if IsOpen_GTA then
		for line in logFileStand:lines() do
			local Hostile
			for i=1, config_RegExHighlightRedNum do
				if string_find(line, config_RegExHighlightRed[i]) then
					Hostile = true
				break end
			end
			if not Hostile then
				print(line)
			else
				ColorRed() print(line) ColorDefault()
			end
		end
		for line in logFileStandChat:lines() do
			print(line)
		end
	end
	IsOpenUpdate()
	if not IsOpen_GTA and logFileFrontier then
		ColorYellow() print("\n", string_format("[ JM36 Stand Console ] - %s - Wrapper Lost Grand Theft Auto V", os_date()), "\n") ColorDefault()
	end
	if not IsOpen_GTA then
		ColorYellow() print("\n", string_format("[ JM36 Stand Console ] - %s - Wrapper Running Solo | Press [ENTER] To Recommence", os_date()), "\n") ColorDefault()
		if not io_read() then os_exit() end
		ColorGreen() print("\n", string_format("[ JM36 Stand Console ] - %s - Wrapper Resumed", os_date()), "\n") ColorDefault()
	end
end