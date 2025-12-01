local settings = require 'settings'
local colors = require 'colors'

-- Equivalent to the --default domain
sbar.default {
  updates = 'when_shown',
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map['Bold'],
      size = 14.0,
    },
    color = colors.text,
    padding_left = settings.left_padding,
    padding_right = settings.paddings,
    background = { image = { corner_radius = 9 } },
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style_map['Light'],
      size = 13.0,
    },
    color = colors.text,
    padding_left = settings.paddings,
    padding_right = settings.right_padding,
  },
  background = {
    height = 28,
    corner_radius = 13,
    color = colors.background,
    border_width = 0,
    border_color = colors.grey,
    image = {
      corner_radius = 9,
      border_color = colors.grey,
      border_width = 1,
    },
  },
  popup = {
    background = {
      border_width = 2,
      corner_radius = 9,
      border_color = colors.grey,
      color = colors.background,
      shadow = { drawing = true },
    },
    blur_radius = 50,
  },
  padding_left = 5,
  padding_right = 5,
  scroll_texts = true,
}
