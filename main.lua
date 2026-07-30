----------------------------DEALING WITH SETTINGS----------------------------
local settings = {
	folder = "test",
	test = "red"
}

-- to remove later
local test_str = "Gochuumon_wa_Usagi_Desu_ka_S01 EP08 (08m14s597ms)"

local conf_name = "screenshot.conf"

local function conf_path()
	return mp.command_native({"expand-path", "~~/script-opts/" .. conf_name})
end

local function save_opts()
	local f = io.open(conf_path(), "w+")
	if not f then
		mp.msg.error("could not load thing properly")
		return
	end
	
	f:write("")
	
	local keys = {}
	for k in pairs(settings) do
		mp.msg.error(k)
		table.insert(keys, k)
	end
	table.sort(keys)
	
	for _,key in ipairs(keys) do
		local value = settings[key]
		if type(value) == "number" then
			f:write(("%s=%.4f\n"):format(key, value))
		else
			f:write(("%s=%s\n"):format(key, tostring(value)))
		end
	end
	f:close()
	mp.osd_message(("did stuff in %s"):format(conf_path()))
end

--local function load_opts()

-- end

----------------------------CORE FUNCTIONALITY----------------------------

local function regex_test(str)
	return str:match("^(.-)_S?(%d*)%s*EP(%d*)%s*%((%w*)%)$")
end

mp.add_key_binding("Ctrl+f", "testing", function()
	mp.msg.error(conf_path())
--	mp.msg.error(regex_test(test_str))
	save_opts()
end)