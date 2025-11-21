local colors = require 'colors'
local icons = require 'icons'
local settings = require 'settings'

local volume_percent = sbar.add('item', 'right.volume.percent', {
  position = 'right',
  icon = { drawing = false },
  label = {
    string = '??%',
    font = { family = settings.font.numbers },
    color = colors.white,
  },
  padding_left = -2,
})

local volume_icon = sbar.add('item', 'right.volume.icon', {
  position = 'right',
  padding_right = -1,
  icon = {
    width = 0,
    align = 'left',
    color = colors.white,
    font = {
      style = settings.font.style_map['Regular'],
      size = 14.0,
    },
  },
  label = {
    width = 25,
    align = 'left',
    font = {
      style = settings.font.style_map['Regular'],
      size = 14.0,
    },
    color = colors.white,
  },
})

sbar.add('item', 'right.volume.padding', {
  position = 'right',
  width = settings.group_paddings,
})

volume_percent:subscribe('volume_change', function(env)
  local icon = icons.volume._0
  local volume = tonumber(env.INFO)
  sbar.exec('SwitchAudioSource -t output -c', function(result)
    Current_output_device = result:sub(1, -2)
    if Current_output_device == 'AirPods Max ' then
      icon = '􀺹'
    elseif Current_output_device == 'AirPods2' then
      icon = '􀟥'
    elseif Current_output_device == 'Arctis Nova Pro Wireless' then
      icon = '􀑈'
    elseif Current_output_device == 'AirPods4' or Current_output_device == 'Samantha’s AirPods' then
      icon = '􁄡'
    elseif Current_output_device == 'Ear (2)' then
      icon = '􀪷'
    elseif Current_output_device == 'iD4' then
      icon = '􀝎'
    else
      if volume > 60 then
        icon = icons.volume._100
      elseif volume > 30 then
        icon = icons.volume._66
      elseif volume > 10 then
        icon = icons.volume._33
      elseif volume > 0 then
        icon = icons.volume._10
      end
    end

    local lead = ''
    if volume < 10 then
      lead = '0'
    end

    volume_icon:set { label = icon }
    volume_percent:set { label = lead .. volume .. '%' }
  end)
end)

local function volume_scroll(env)
  local delta = env.SCROLL_DELTA
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end

volume_icon:subscribe('mouse.scrolled', volume_scroll)
volume_percent:subscribe('mouse.scrolled', volume_scroll)
