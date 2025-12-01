local colors = require 'colors'

-- Equivalent to the --bar domain
sbar.bar {
  topmost = 'window',
  height = 38,
  color = colors.transparent,
  padding_right = 5,
  padding_left = 10,
  blur_radius = 10,
  notch_width = 206 + 2, -- 206 is the actual width
}
