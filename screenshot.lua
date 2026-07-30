local settings = {
	folder = "test"
}

-- to remove later
local test_str = "Gochuumon_wa_Usagi_Desu_ka_S01 EP08 (08m14s597ms)"

local conf_name = "screenshot.conf"

local function conf_path()
	return mp.command_native({"expand-path", "~~/script-opts/" .. conf_name})
end

local function save_opts

end

local function load_opts

end

local function regex_test(str)
	return str:match("^(.-)_S?(%d*)%s*EP(%d*)%s*%((%w*)%)$")
end

mp.add_key_binding("Ctrl+f", "testing", function()
	mp.msg.error(conf_path())
	mp.msg.error(regex_test(test_str))
end)