-- Anti-Paste Blocking
hs.hotkey.bind({"cmd", "alt"}, "V", function()
      hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- https://gist.github.com/nozma/e0bd02ab88370461a3f521a93c2c1f7c#file-init-lua
-- HANDLE SCROLLING

local deferred = false

-- List of apps to exclude from custom scrolling behavior
local excludedApps = {
    "Plasticity",
    "Bambu Studio",
    "Fusion"
}

-- Function to check if the frontmost app is in the excluded list
local function isExcludedApp()
    local frontApp = hs.application.frontmostApplication()
    return frontApp and hs.fnutils.contains(excludedApps, frontApp:name())
end


overrideRightMouseDown = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDown }, function(e)
    if isExcludedApp() then
        return false -- Allow default behavior in excluded apps
    end
    deferred = true
    return true
end)

overrideRightMouseUp = hs.eventtap.new({ hs.eventtap.event.types.rightMouseUp }, function(e)
    if isExcludedApp() then
        return false -- Allow default behavior in excluded apps
    end
    if (deferred) then
        overrideRightMouseDown:stop()
        overrideRightMouseUp:stop()
        hs.eventtap.rightClick(e:location())
        overrideRightMouseDown:start()
        overrideRightMouseUp:start()
        return true
    end

    return false
end)


local oldmousepos = {}
local scrollmult = 2	-- negative multiplier makes mouse work like traditional scrollwheel

local last_scroll_time = 0  -- 前回のスクロールイベント発火時間
local debounce_interval = 0.01  -- デバウンス間隔（秒）

dragRightToScroll = hs.eventtap.new({ hs.eventtap.event.types.rightMouseDragged }, function(e)
    if isExcludedApp() then
        return false -- Allow default behavior in excluded apps
    end
    -- デバウンス処理: 短時間に発生しないようにする
    local current_time = hs.timer.secondsSinceEpoch()
    if current_time - last_scroll_time < debounce_interval then
        return true
    end
    last_scroll_time = current_time

    deferred = false

    oldmousepos = hs.mouse.absolutePosition()

    local dx = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaX'])
    local dy = e:getProperty(hs.eventtap.event.properties['mouseEventDeltaY'])

    -- モディファイアキーを取得してリストに追加
    local modifiers = hs.eventtap.checkKeyboardModifiers()
    local scrollModifiers = {}
    if modifiers['cmd'] then table.insert(scrollModifiers, 'cmd') end
    if modifiers['alt'] then table.insert(scrollModifiers, 'alt') end
    if modifiers['shift'] then table.insert(scrollModifiers, 'shift') end
    if modifiers['ctrl'] then table.insert(scrollModifiers, 'ctrl') end
    if modifiers['fn'] then table.insert(scrollModifiers, 'fn') end

    local scroll = hs.eventtap.event.newScrollEvent({dx * scrollmult, dy * scrollmult}, scrollModifiers,'pixel')

    -- put the mouse back
    hs.mouse.absolutePosition(oldmousepos)

    return true, {scroll}
end)

overrideRightMouseDown:start()
overrideRightMouseUp:start()
dragRightToScroll:start()
