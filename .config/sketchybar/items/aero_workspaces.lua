local colors = require 'colors'
local app_icons = require 'app_icons'

local function add_windows(space, space_name)
  sbar.exec('aerospace list-windows --format %{app-name} --workspace ' .. space_name, function(windows)
    local icon_line = ''
    for app in windows:gmatch '[^\r\n]+' do
      local lookup = app_icons[app]
      local icon = ((lookup == nil) and app_icons['Default'] or lookup)
      icon_line = icon_line .. ' ' .. icon
    end

    sbar.animate('tanh', 10, function()
      space:set {
        label = {
          string = icon_line == '' and '—' or icon_line,
          padding_right = icon_line == '' and 8 or 12,
        },
      }
    end)
  end)
end

sbar.exec('aerospace list-workspaces --all', function(spaces)
  for space_name in spaces:gmatch '[^\r\n]+' do
    local space = sbar.add('item', 'space.' .. space_name, {
      icon = {
        string = space_name,
        color = colors.spaces.inactive,
        highlight_color = colors.spaces.background,
        padding_left = 8,
      },
      label = {
        font = 'sketchybar-app-font:Regular:14.0',
        string = '',
        color = colors.spaces.inactive,
        highlight_color = colors.spaces.background,
        y_offset = -1,
      },
      background = {
        drawing = true,
        color = colors.spaces.background,
      },
      click_script = 'aerospace workspace ' .. space_name,
      padding_left = space_name == '1' and 0 or 4,
    })

    add_windows(space, space_name)

    space:subscribe('aerospace_workspace_change', function(env)
      local selected = env.FOCUSED_WORKSPACE == space_name
      if selected then
        space:set {
          background = { color = colors.spaces.inactive },
          icon = { highlight = true },
          label = { highlight = true },
          add_windows(space, space_name),
        }
      else
        space:set {
          background = { color = colors.spaces.background },
          icon = { highlight = false },
          label = { highlight = false },
          add_windows(space, space_name),
        }
      end

      if selected then
        sbar.animate('tanh', 8, function()
          space:set {
            background = {
              shadow = {
                distance = 0,
              },
            },
            y_offset = -4,
            padding_left = 8,
            padding_right = 0,
          }
          space:set {
            background = {
              shadow = {
                distance = 4,
              },
            },
            y_offset = 0,
            padding_left = 4,
            padding_right = 4,
          }
        end)
      end
    end)

    space:subscribe('space_windows_change', function()
      print('space ' .. space_name .. ' window change')
      add_windows(space, space_name)
    end)

    -- custom script ran from aerospace.toml to update icons on move node
    space:subscribe('update_spaces', function()
      add_windows(space, space_name)
      print('space ' .. space_name .. ' updated')
    end)

    space:subscribe('mouse.clicked', function()
      sbar.animate('tanh', 8, function()
        space:set {
          background = {
            shadow = {
              distance = 0,
            },
          },
          y_offset = -4,
          padding_left = 8,
          padding_right = 0,
        }
        space:set {
          background = {
            shadow = {
              distance = 4,
            },
          },
          y_offset = 0,
          padding_left = 4,
          padding_right = 4,
        }
      end)
    end)
  end
end)
