local settings = require 'settings'
local colors = require 'colors'

local cal = sbar.add('item', 'right.calendar', {
  icon = {
    color = colors.white,
    font = {
      style = settings.font.style_map['Bold'],
      size = 14.0,
    },
  },
  label = {
    color = colors.white,
    align = 'left',
    font = {
      style = settings.font.style_map['Bold'],
      size = 14.0,
    },
  },
  position = 'right',
  update_freq = 1,
})

sbar.add('item', 'right.calendar.padding', {
  position = 'right',
  width = settings.group_paddings,
})

cal:subscribe({ 'forced', 'routine', 'system_woke' }, function(env)
  cal:set { icon = os.date '%a, %d %b.', label = os.date '%H:%M' }
  -- cal:set { icon = os.date '%d.%m.', label = os.date '%H:%M' }
end)
