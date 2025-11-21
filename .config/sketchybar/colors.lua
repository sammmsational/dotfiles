local catppuccin = require 'catppuccin'

return {
  black = catppuccin.crust,
  white = catppuccin.rosewater,
  red = catppuccin.red,
  green = catppuccin.green,
  blue = catppuccin.blue,
  yellow = catppuccin.yellow,
  orange = catppuccin.peach,
  pink = catppuccin.pink,
  purple = catppuccin.mauve,
  other_purple = catppuccin.lavender,
  cyan = catppuccin.sky,
  grey = catppuccin.overlay2,
  dirty_white = catppuccin.text,
  dark_grey = catppuccin.surface0,
  transparent = 0x00000000,
  bar = {
    bg = catppuccin.transparent,
    border = 0xff2c2e34,
  },
  popup = {
    bg = catppuccin.base,
    border = catppuccin.transparent,
  },
  spaces = {
    active = catppuccin.red,
    inactive = catppuccin.rosewater,
    background = catppuccin.surface0,
  },

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
      return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
