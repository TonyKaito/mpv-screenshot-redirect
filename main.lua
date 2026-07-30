----------------------------IMPORTS----------------------------

--local mp = require('mp')

----------------------------DEALING WITH SETTINGS----------------------------
local settings = {
	folder = "test",
	test = "red"
}

-- to remove later
local test_str = "Gochuumon_wa_Usagi_Desu_ka_S01 EP08 (08m14s597ms)"
local test_filename = "【VCC二次会】一度も伝わることのないお絵描き伝言ゲームｗｗｗ【切り抜き だるまいずごっど 葛葉 じゃすぱー わいわい 井口理 ⧸Gartic Phone】 [H15-PkzDOJ8].mp4"

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

local function load_opts()
	local f = io.open(conf_path(), "r")
	if not f then 
		-- create it or smth
	end
	
	for line in f:lines() do
		local k, v = line:match("^%s*([%w_]+)%s*=%s*(%S+)")
		if k and v then
			settings[k] = tonumber(v) or v
			mp.msg.error(("loaded %s: %s"):format(k, v))
		end
	end	
	f:close()
	
	mp.msg.error("load complete")
	save_opts()
end

----------------------------HELPER FUNCTIONS----------------------------
local function remove_extension(file_name)
	return file_name:gsub("%.%w+$", "")
end

local function remove_text_in_parentheses(str)
	return str:gsub("%b()", ""):gsub("（.-）", "")
end

local function remove_text_in_brackets(str)
    return str:gsub('%b[]', ''):gsub('【.-】', '')
end

local function remove_special_characters(str)
    return str:gsub('[%c%p%s]', ''):gsub('　', '')
end

----------------------------CORE FUNCTIONALITY----------------------------

local function regex_test(str)
	return str:match("^(.-)_S?(%d*)%s*EP(%d*)%s*%((%w*)%)$")
end

local function get_file_info()
	local file_name = mp.get_property("filename")
--	mp.msg.error(file_name)

	local operations = {
		remove_extension,
		remove_text_in_parentheses, 
		remove_text_in_brackets, 
		remove_special_characters
	}
	for _, funct in ipairs(operations) do
		file_name = funct(file_name) or nil
	end
	
	return file_name
end

mp.add_key_binding("Ctrl+f", "testing", function()
	mp.msg.error(conf_path())
	mp.msg.error(get_file_info())
	load_opts()
end)

