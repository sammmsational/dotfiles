-- local theme = require 'themes.catppuccin'
local theme = require 'themes.nord'

return {
  black = theme.black,
  white = theme.white,
  red = theme.red,
  green = theme.green,
  blue = theme.blue,
  yellow = theme.yellow,
  orange = theme.orange,
  pink = theme.pink,
  purple = theme.purple,
  cyan = theme.cyan,
  light_grey = theme.light_grey,
  grey = theme.grey,
  dark_grey = theme.dark_grey,

  text = theme.text,
  background = theme.background,
  blackout = 0xFF000000,
  transparent = 0x00000000,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
      return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
