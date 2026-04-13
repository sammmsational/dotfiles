local iceportal = sbar.add('item', 'iceportal', {
  position = 'q',
  update_freq = 10,
  icon = { drawing = false },
  label = {
    string = 'ERR',
    padding_right = 10,
    padding_left = 10,
  },
})

iceportal:subscribe({ 'forced', 'routine', 'system_woke' }, function()
  sbar.exec('~/.pyenv/shims/python3 ~/.config/sketchybar/helpers/iceportal.py', function(result)
    print(result)
    iceportal:set { label = result }
  end)
end)
