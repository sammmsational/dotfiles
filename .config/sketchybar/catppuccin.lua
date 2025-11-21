return {
  rosewater = 0xFFF4DBD6,
  flamingo = 0xFFF0C6C6,
  pink = 0xFFF5BDE6,
  mauve = 0xFFC6A0F6,
  red = 0xFFED8796,
  maroon = 0xFFEE99A0,
  peach = 0xFFF5A97F,
  yellow = 0xFFEED49F,
  green = 0xFFA6DA95,
  teal = 0xFF8BD5CA,
  sky = 0xFF91D7E3,
  sapphire = 0xFF7DC4E4,
  blue = 0xFF8AADF4,
  lavender = 0xFFB7BDF8,
  text = 0xFFCAD3F5,
  subtext1 = 0xFFB8C0E0,
  subtext0 = 0xFFA5ADCB,
  overlay2 = 0xFF939AB7,
  overlay1 = 0xFF8087A2,
  overlay0 = 0xFF6E738D,
  surface2 = 0xFF5B6078,
  surface1 = 0xFF494D64,
  surface0 = 0xFF363A4F,
  base = 0xFF24273A,
  mantle = 0xFF1E2030,
  crust = 0xFF181926,
  transparent = 0x00000000,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then
      return color
    end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
