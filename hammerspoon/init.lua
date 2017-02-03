-- cf. http://qiita.com/naoya@github/items/81027083aeb70b309c14
-- cf. https://github.com/kkamdooong/hammerspoon-control-hjkl-to-arrow/blob/master/init.lua
local function keyCode(key, modifiers)
   modifiers = modifiers or {}

   return function()
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), true):post()
      hs.timer.usleep(1000)
      hs.eventtap.event.newKeyEvent(modifiers, string.lower(key), false):post()
   end
end

local function keyCodeSet(keys)
   return function()
      for _, keyEvent in ipairs(keys) do
         keyEvent()
      end
   end
end

local function remapKey(modifiers, key, keyCode)
   hs.hotkey.bind(modifiers, key, keyCode, nil, keyCode)
end


local function disableAllHotkeys()
   for _, v in ipairs(hs.hotkey.getHotkeys()) do
      v['_hk']:disable()
   end
end

local function enableAllHotkeys()
   for _, v in ipairs(hs.hotkey.getHotkeys()) do
      v['_hk']:enable()
   end
end

local function handleGlobalAppEvent(name, event, app)
   ignoreApps = { 'iTerm2', 'Emacs', 'IntelliJ' }
   if event == hs.application.watcher.activated then
      -- hs.alert.show(name)
      for _, v in ipairs(ignoreApps) do
         if string.find(name, v) then
            disableAllHotkeys()
            return
         end
      end
      enableAllHotkeys()
   end
end

-- Anti-Paste Blocking
hs.hotkey.bind({"cmd", "alt"}, "V", function()
      hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

appsWatcher = hs.application.watcher.new(handleGlobalAppEvent)
appsWatcher:start()

-- カーソル移動
remapKey({'ctrl'}, 'f', keyCode('right'))
remapKey({'ctrl'}, 'b', keyCode('left'))
remapKey({'ctrl'}, 'n', keyCode('down'))
remapKey({'ctrl'}, 'p', keyCode('up'))
remapKey({'ctrl'}, 'e', keyCode('right', {'cmd'}))
remapKey({'ctrl'}, 'a', keyCode('left', {'cmd'}))

-- テキスト編集
remapKey({'ctrl'}, 'w', keyCode('x', {'cmd'}))
remapKey({'cmd'}, 'w', keyCode('c', {'cmd'}))
remapKey({'ctrl'}, 'y', keyCode('v', {'cmd'}))
remapKey({'ctrl'}, 'd', keyCode('forwarddelete'))
remapKey({'ctrl'}, 'h', keyCode('delete'))
remapKey({'ctrl'}, 'k', keyCodeSet({
         keyCode('right', {'cmd', 'shift'}),
         keyCode('x', {'cmd'})
}))
remapKey({'ctrl'}, 'm', keyCode('return'))
remapKey({'ctrl'}, 'j', keyCode('return'))

-- コマンド
remapKey({'ctrl'}, 's', keyCode('f', {'cmd'}))
remapKey({'ctrl'}, '/', keyCode('z', {'cmd'}))
remapKey({'ctrl'}, 'g', keyCode('escape'))

-- ページスクロール
remapKey({'ctrl'}, 'v', keyCode('pagedown'))
remapKey({'alt'}, 'v', keyCode('pageup'))
remapKey({'cmd', 'shift'}, ',', keyCode('home'))
remapKey({'cmd', 'shift'}, '.', keyCode('end'))

-- misc
remapKey({'alt'}, 'tab', keyCode('f1', {'cmd'}))
remapKey({'alt', 'shift'}, 'tab', keyCode('f1', {'cmd', 'shift'}))
