local settings = require 'settings'
local colors = require 'colors'
local catppucin = require 'catppuccin'

local options = {
  position = 'e',
  padding_left = 0,
  padding_right = 0,
  icon = {
    drawing = false,
  },
  label = {
    string = 'ERR',
    color = catppucin.overlay1,
    highlight_color = colors.white,
    padding_left = 0,
    padding_right = 5,
    font = {
      style = settings.font.style_map['Bold'],
      size = 14.0,
    },
  },
}

local function mysplit(inputstr, sep)
  if sep == nil then
    sep = '%s'
  end
  local t = {}
  for str in string.gmatch(inputstr, '([^' .. sep .. ']+)') do
    table.insert(t, str)
  end
  return t
end

local uni = sbar.add('item', 'items.uni', {
  position = 'e',
  padding_right = 0,
  update_freq = 30,
})

local uni0 = sbar.add('item', 'items.uni.0', options)
local uni1 = sbar.add('item', 'items.uni.1', options)
local uni2 = sbar.add('item', 'items.uni.2', options)
local uni3 = sbar.add('item', 'items.uni.3', options)
local uni4 = sbar.add('item', 'items.uni.4', options)
local uni5 = sbar.add('item', 'items.uni.5', options)
local uni6 = sbar.add('item', 'items.uni.6', options)
local uni7 = sbar.add('item', 'items.uni.7', options)
local uni8 = sbar.add('item', 'items.uni.8', options)

uni:subscribe({ 'forced', 'routine', 'system_woke' }, function()
  sbar.exec('~/.pyenv/shims/python3 ~/.config/sketchybar/helpers/uni/uni.py', function(result)
    local strtable = mysplit(result, '\n')
    if strtable[1] == '1' then
      uni:set { drawing = false }
      uni0:set { label = { string = '' } }
      uni1:set { label = { string = '' } }
      uni2:set { label = { string = '' } }
      uni3:set { label = { string = '' } }
      uni4:set { label = { string = '' } }
      uni5:set { label = { string = '' } }
      uni6:set { label = { string = '' } }
      uni7:set { label = { string = '' } }
      uni8:set { label = { string = '' } }
    elseif strtable[1] == '2' then
      uni0:set { label = { string = strtable[2], highlight = true } }
      uni1:set { label = { string = strtable[3], highlight = false } }
      uni2:set { label = { string = strtable[4], highlight = true } }
      uni3:set { label = { string = strtable[5], highlight = false } }
      uni4:set { label = { string = strtable[6], highlight = true } }
      uni5:set { label = { string = '' } }
      uni6:set { label = { string = '' } }
      uni7:set { label = { string = '' } }
      uni8:set { label = { string = '' } }
    elseif strtable[1] == '3' then
      uni0:set { label = { string = strtable[2], highlight = true } }
      uni1:set { label = { string = strtable[3], highlight = false } }
      uni2:set { label = { string = strtable[4], highlight = true } }
      uni3:set { label = { string = strtable[5], highlight = false } }
      uni4:set { label = { string = strtable[6], highlight = true } }
      uni5:set { label = { string = strtable[7], highlight = false } }
      uni6:set { label = { string = strtable[8], highlight = true } }
      uni7:set { label = { string = strtable[9], highlight = false } }
      uni8:set { label = { string = strtable[10], highlight = true } }
    elseif strtable[1] == '4' then
      uni0:set { label = { string = strtable[2], highlight = true } }
      uni1:set { label = { string = strtable[3], highlight = false } }
      uni2:set { label = { string = strtable[4], highlight = true } }
      uni3:set { label = { string = '' } }
      uni4:set { label = { string = '' } }
      uni5:set { label = { string = '' } }
      uni6:set { label = { string = '' } }
      uni7:set { label = { string = '' } }
      uni8:set { label = { string = '' } }
    end
  end)
end)
