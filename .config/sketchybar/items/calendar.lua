local settings = require 'settings'
local colors = require 'colors'

local calendar = sbar.add('item', 'calendar', {
  icon = {
    padding_right = 0,
    font = {
      style = settings.font.style_map['Bold'],
      size = 14.0,
    },
  },
  label = {
    align = 'left',
    font = {
      style = settings.font.style_map['Bold'],
      size = 14.0,
    },
  },
  position = 'right',
  update_freq = 1,
  click_script = 'sketchybar --reload',
})

calendar:subscribe({ 'forced', 'routine', 'system_woke' }, function(env)
  calendar:set { icon = os.date '%a, %d %b.', label = os.date '%H:%M' }
  -- cal:set { icon = os.date '%d.%m.', label = os.date '%H:%M' }
end)
