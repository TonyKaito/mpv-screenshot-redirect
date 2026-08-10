----------------------------IMPORTS----------------------------

--local mp = require('mp')
local utils = require('mp.utils')

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
local function get_script_dir()
	return mp.command_native({"expand-path", "~~/scripts/screenshot/"})
end

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

local function create_directory(path, folder_name)
--	utils.subprocess({
--		args = (utils.getcwd() and {}) or {}
--	})
	os.execute("mkdir " .. path .. folder_name) -- NOTE(kt): simple work around for now. not sure how cross-platform this is
	mp.msg.error("smth")
end

local function get_temp_folder()
	return os.getenv("TEMP")
end

-- NOTE(kt): i'm sure there's a better way to do this, might be costly to open the file
local function folder_exists(file_path)
	f = io.open(file_path, 'r')
	if f then
		f:close()
		return true
	end
	return false
end

local function debug_table(poggers)
	for k, v in pairs(poggers) do
		if type(v) == "table" then
			mp.msg.error("Key: " .. k)
			debug_table(v)
		else
			mp.msg.error("Key: " .. k .. " Value: " .. v)
		end
	end
end

----------------------------CORE FUNCTIONALITY----------------------------

local function parse_cmt(str)
	if str == nil then
		return ""
	end
	return str:match("(.-)%s*EP(%d*)%s*%((%w*)%)")
end

local function parse_sound(str)
	if not str then
		return ""
	end
	return str:match(".*_(%d*m%d*s%d*ms)[_-](%d*m%d*s%d*ms)%..*")
end

local function parse_img(str)
	if not str then
		return ""
	end
	return str:match(".*_(%d*m%d*s%d*ms)[_-](%d*m%d*s%d*ms)%..*")
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


local function extract_fields_info(card_details)
	local extracted_info = {}
	for _, info in ipairs(card_details) do
		local id, sound, img, cmt = table.unpack(info)
		if (sound == nil) then goto continue end
		sound = sound:gsub("\r", "")
		local start_ts, end_ts = parse_sound(sound)
		
		if (img == nil) then goto continue end
		img = img:gsub("\r", "")
		local start_backup, end_backup = parse_img(img)
		
		if start_backup and not start_ts then start_ts = start_backup end
		if end_backup and not end_ts then end_ts = end_backup end
--		mp.msg.error("=====")
--		mp.msg.error(sound_ts == start_ts and "true" or ((sound_ts or "") .. " vs " .. (start_ts or "")))
--		mp.msg.error(sound_ts2 == end_ts and "true" or ((sound_ts2 or "") .. " vs " .. (end_ts or "")))
--		mp.msg.error("=====")
		
		if (cmt == nil) then goto continue end
		cmt = cmt:gsub("\r", "")
		
		local name, ep, screenshot_ts = parse_cmt(cmt)
		
		extracted_info[id] = {name, ep, start_ts, end_ts}
		::continue::
	end
	return extracted_info
end

----------------------------ANKI INTERFACING----------------------------
-- NOTE(kt): lame workaround where i use powershell instead to do the curl requests (assumes powershell installation)
-- might need to do something else instead in the future (sometimes, the most permanent solutions are the supposed temporary ones)
-- output has all the id's separated by \n

-- TODO(kt): Ensure UTF-8 Encoding
local function curl_request_note_ids()
	local handle = io.popen('powershell.exe -File ' .. get_script_dir() .. 'anki_curl.ps1' .. ' > ' .. get_script_dir() .. 'result.log') -- powershell command
	handle:close()
	return
end

-- NOTE(kt): will probably remove, since we probably don't need
local function get_note_ids()
	local f = io.open(get_script_dir() .. 'result.log', 'r')
	if not f then
		mp.msg.error("result.log does not exist, or at least could not be found")
		return
	end
	
	local ids = {}
	for line in f:lines() do
		table.insert(ids, line)
	end
	
	f:close()
	return ids
end

-- TODO(kt): Ensure UTF-8 Encoding
local function curl_request_note_fields()
	local f = io.open(get_script_dir() .. 'result.log', 'r')
	if not f then
		mp.msg.error("result.log does not exist, or at least could not be found")
		return
	end
	f:close()
	
	local handle = io.popen('powershell.exe -File ' .. get_script_dir() .. 'test.ps1' .. ' > ' .. get_script_dir() .. 'important_thing.log') -- powershell command
	handle:close()
	return
end

local function get_card_details()
local cds = io.open(get_script_dir() .. 'important_thing.log', 'r')
	if not cds then
		mp.msg.error("important_thing.log does not exist, or at least could not be found")
		return
	end
	
	-- somehow assert the lines are the same first
	local card_details = {}
	local count = 1
	for line in cds:lines() do
		table.insert(card_details, {})
		for token in string.gmatch(line, "[^|]+") do
			table.insert(card_details[count], token)
		end
		count = count + 1
	end
	
	cds:close()
	return card_details
end

local function ankiconnect_curl_request()
--	curl_request_note_ids()
--	curl_request_note_fields()

--	local note_ids = get_note_ids() -- will probably remove, since we probably don't need
	local card_details = get_card_details()
	
	return card_details
end

----------------------------EVENT LISTENING----------------------------
-- mostly testing purposes for now
mp.add_key_binding("Ctrl+f", "testing", function()
	mp.msg.error(conf_path())
	mp.msg.error(get_file_info())
--	load_opts()
--	create_directory(test_path, get_file_info())
--	mp.msg.error(generate_unique_temp())
--	mp.msg.error(ankiconnect_curl_request())
	local test_val = ankiconnect_curl_request()
--	mp.msg.error(parse_cmt(test_str))
	test_val = extract_fields_info(test_val)
	debug_table(test_val)
end)

