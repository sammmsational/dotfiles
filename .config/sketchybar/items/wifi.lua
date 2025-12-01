local icons = require 'icons'
local colors = require 'colors'

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

local wifi = sbar.add('item', 'wifi', {
  position = 'right',
  label = {
    string = 'something broke',
    color = colors.text,
  },
  background = {
    drawing = true,
    color = colors.background,
  },
})

wifi:subscribe({ 'wifi_change', 'system_woke' }, function()
  sbar.exec('~/.pyenv/shims/python3 ~/.config/sketchybar/helpers/network.py', function(result)
    local strtable = mysplit(result, '\n')
    if strtable[1] ~= '0' then
      if strtable[2] == '1' then
        Wifi_icon = icons.wifi.vpn
        Wifi_icon_color = colors.green
        Wifi_draw_label = true
      else
        Wifi_icon = icons.wifi.connected
        Wifi_icon_color = colors.text
        Wifi_draw_label = true
      end
    else
      Wifi_icon = icons.wifi.disconnected
      Wifi_icon_color = colors.red
      Wifi_draw_label = false
    end

    wifi:set {
      icon = {
        string = Wifi_icon,
        color = Wifi_icon_color,
      },
      label = {
        string = strtable[1],
        drawing = Wifi_draw_label,
      },
    }
  end)
end)
