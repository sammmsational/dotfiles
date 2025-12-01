local uni = sbar.add('item', 'uni', {
  position = 'right',
  update_freq = 30,
  icon = { drawing = false },
  label = {
    string = 'ERR',
    padding_right = 10,
    padding_left = 10,
  },
  background = {
    drawing = true,
  },
})

uni:subscribe({ 'forced', 'routine', 'system_woke' }, function()
  sbar.exec('~/.pyenv/shims/python3 ~/.config/sketchybar/helpers/uni.py', function(result)
    uni:set { label = result }
  end)
end)
