local icons = require 'icons'

local volume = sbar.add('item', 'volume', {
  position = 'right',
  label = {
    width = 48,
  },
  icon = {
    width = 32,
  },
})

volume:subscribe('volume_change', function(env)
  local icon = icons.volume._0
  local value = tonumber(env.INFO)
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
      if value > 60 then
        icon = icons.volume._100
      elseif value > 30 then
        icon = icons.volume._66
      elseif value > 10 then
        icon = icons.volume._33
      elseif value > 0 then
        icon = icons.volume._10
      end
    end

    local lead = ''
    if value < 10 then
      lead = '0'
    end

    volume:set { icon = icon, label = lead .. value .. '%' }
  end)
end)

local function volume_scroll(env)
  local delta = env.SCROLL_DELTA
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta .. ')"')
end
