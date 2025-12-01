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
    print(result)
    if result == '0' then
      uni:set { label = '', background = { drawing = false } }
    else
      uni:set { label = result, background = { drawing = true } }
    end
  end)
end)
