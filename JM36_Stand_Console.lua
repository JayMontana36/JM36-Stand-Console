--[[ Init - Localize Functions ]]
local print, string_format, os_date, io_open, io_popen, string_find
	= print, string.format, os.date, io.open, io.popen, string.find



--[[ Init - Color Functions ]]
local ansicolors = {}
do
	local a=pairs;local b=tostring;local c=setmetatable;local d=string.char;local e={}function e:__tostring()return self.value end;function e:__concat(f)return b(self)..b(f)end;function e:__call(g)return self..g..ansicolors.reset end;e.__metatable={}local function h(i)return c({value=d(27)..'['..b(i)..'m'},e)end;local j={reset=0,clear=0,bright=1,dim=2,underscore=4,blink=5,reverse=7,hidden=8,black=30,red=31,green=32,yellow=33,blue=34,magenta=35,cyan=36,white=37,onblack=40,onred=41,ongreen=42,onyellow=43,onblue=44,onmagenta=45,oncyan=46,onwhite=47}for k,l in a(j)do ansicolors[k]=h(l)end
end

local ColorDefault = {self=0}
local ColorBlue = {self=0}
local ColorRed = {self=0}
local ColorYellow = {self=0}
local ColorGreen = {self=0}
do
	local io_write = io.write
	local metatable = {__call = function(self) io_write(self.self) end}
	
	local setmetatable = setmetatable
	
	local _reset, _white, _black = ansicolors.reset.value, ansicolors.white.value, ansicolors.black.value
	
	ColorDefault.self	= string_format("%s%s%s", _reset, ansicolors.onblack.value, _white)		setmetatable(ColorDefault,	metatable)
	ColorBlue.self		= string_format("%s%s%s", _reset, ansicolors.onblue.value, _white)		setmetatable(ColorBlue,		metatable)
	ColorRed.self		= string_format("%s%s%s", _reset, ansicolors.onred.value, _white)		setmetatable(ColorRed,		metatable)
	ColorYellow.self	= string_format("%s%s%s", _reset, ansicolors.onyellow.value, _black)	setmetatable(ColorYellow,	metatable)
	ColorGreen.self		= string_format("%s%s%s", _reset, ansicolors.ongreen.value, _black)		setmetatable(ColorGreen,	metatable)
end



--[[ Init - Startup ]]
ColorDefault() os.execute("cls && title JM36 Stand Console")
ColorBlue() print("\n", string_format("[ JM36 Stand Console ] - %s - Wrapper Started", os_date()), "\n") ColorDefault()



--[[ Read ini config ]]
local config_RegExHighlightRed
do
	
	local function string_split(inputstr,sep)
		sep = sep or "%s" local t,n={},0
		for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			n=n+1 t[n]=str
		end
	return t end
	
	local config, configFile = {}, io_open("JM36_Stand_Console.ini")
	if configFile then
		local function string_endsWith(str, ending)
			return ending == "" or str:sub(-#ending) == ending
		end
		local function string_startsWith(str, start)
			return str:sub(1, #start) == start
		end
		for line in configFile:lines() do
			if not (string_startsWith(line, "[") and string_endsWith(line, "]")) then
				line = string.gsub(line, "\n", "")
				line = string.gsub(line, "\r", "")
				if line ~= "" and string_find(line, "=") then
					line = string_split(line, "=")
					config[line[1]] = line[2]
				end
			end
		end
		configFile:close()
	end
	
	config_RegExHighlightRed = string_split(config.RegExHighlightRed or " Marking , as modder for ,] Blocked , blocked from , crash from , is spectating , Exception ,0x, Stack trace:,GTA5%+0x,<unknown>, ---- ,---- ERROR INFORMATION BEGINS ----,Type:,Uncaught,ACCESS_VIOLATION,%(GTA5.exe%+,Stack Trace:,%(KERNEL32.DLL%+,BaseThreadInitThunk,%(ntdll.dll%+,RtlUserThreadStart,---- ERROR INFORMATION ENDS ----,Event:,EVENT:,triggered a modder detection:,Crash Event,Kick Event,Modded Event,Invite from,Freeze from,Invalid model sync by,Caught an exception%.,%.dll,%.exe,  0", ",")

end
local config_RegExHighlightRedNum = #config_RegExHighlightRed



--[[ What's currently running ]]
local IsOpen_GTA



--[[ Core/Loop ]]
local coroutine = coroutine
local yield = coroutine.yield
local wrap = coroutine.wrap
local Loop =
{
	wrap(function() -- Logs Display
		local config_StandDirGTA
		do
			local _config_StandDirGTA = io_popen("powershell [Environment]::GetFolderPath([Environment+SpecialFolder]::ApplicationData)")
			config_StandDirGTA = string.gsub(_config_StandDirGTA:read("*a"), "\n", "").."\\Stand\\"
			_config_StandDirGTA:close()
		end
		local logFileStand, logFileStandChat = io_open(config_StandDirGTA.."Log.txt"), io_open(config_StandDirGTA.."Chat.txt")
		if not IsOpen_GTA then
			for line in logFileStand:lines() do end
			for line in logFileStandChat:lines() do end
		end
		local yield = yield
		while true do
--			if IsOpen_GTA then
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
--			end
			yield()
		end
	end),
	function() -- Detect Game
		local _IsOpen_GTA = io_popen('tasklist | findstr GTA5.exe')
		IsOpen_GTA = string_find(_IsOpen_GTA:read("*a"), "GTA5.exe")
		_IsOpen_GTA:close()
	end,
	wrap(function()
		local WasOpen_GTA = IsOpen_GTA
		local yield = yield
		while true do
			if IsOpen_GTA ~= WasOpen_GTA then
				if not IsOpen_GTA then
					ColorYellow() print("\n", string_format("[ JM36 Stand Console ] - %s - Wrapper Lost Grand Theft Auto V", os_date()), "\n") ColorDefault()
					
					ColorYellow() print("\n", string_format("[ JM36 Stand Console ] - %s - Wrapper Running Solo | Press [ENTER] To Recommence", os_date()), "\n") ColorDefault()
					if not io.read() then os.exit() end
					ColorGreen() print("\n", string_format("[ JM36 Stand Console ] - %s - Wrapper Resumed", os_date()), "\n") ColorDefault()
				end
				WasOpen_GTA = IsOpen_GTA
			end
			yield()
		end
	end),
}

local LoopNum = #Loop
while true do
	for i=1, LoopNum do
		Loop[i]()
	end
end