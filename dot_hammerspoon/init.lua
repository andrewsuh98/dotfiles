-- Keyboard remaps for managed work Macs where Karabiner's virtual HID driver
-- cannot be approved. Hammerspoon still needs Privacy & Security > Accessibility.

local event = hs.eventtap.event
local eventTypes = event.types
local props = event.properties

local SOURCE_MARKER = 0x48534B42 -- "HSKB"
local KEY = {
  h = 4,
  j = 38,
  k = 40,
  l = 37,
}

local terminalBundles = {
  ["net.kovidgoyal.kitty"] = true,
  ["com.googlecode.iterm2"] = true,
  ["com.apple.Terminal"] = true,
}

-- A numpad layer is intentionally deferred until the core remaps are proven.

local vimArrows = {
  [KEY.h] = "left",
  [KEY.j] = "down",
  [KEY.k] = "up",
  [KEY.l] = "right",
}

local controlDown = false
local controlUsed = false
local remappedDown = {}
local wakeTimer

-- hidutil applies simple remaps below the event-tap layer, so they continue to
-- work during Secure Input. It replaces the complete UserKeyMapping list.
local function applyHIDMappings()
  local output, success = hs.execute([[
    /usr/bin/hidutil property --set '{"UserKeyMapping":[
      {"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x7000000E0},
      {"HIDKeyboardModifierMappingSrc":0x700000031,"HIDKeyboardModifierMappingDst":0x70000002A},
      {"HIDKeyboardModifierMappingSrc":0x70000002A,"HIDKeyboardModifierMappingDst":0x700000031}
    ]}'
  ]])
  if not success then
    hs.alert.show("hidutil mapping failed")
    hs.printf("hidutil mapping failed: %s", output)
  end
end

-- TCC permissions cannot be granted programmatically. Explain the one-time
-- requirement and offer a shortcut to the correct System Settings pane.
if not hs.settings.get("keyboard_remaps_input_monitoring_prompted") then
  local choice = hs.dialog.blockAlert(
    "Hammerspoon Input Monitoring",
    "The Caps/Control and Backslash/Backspace mappings require Hammerspoon under Privacy & Security > Input Monitoring. Enable it, then fully quit and reopen Hammerspoon.",
    "Open Settings",
    "Already Enabled",
    "informational"
  )
  if choice == "Open Settings" then
    hs.execute([[/usr/bin/open 'x-apple.systempreferences:com.apple.preference.security?Privacy_ListenEvent']])
  else
    hs.settings.set("keyboard_remaps_input_monitoring_prompted", true)
  end
end

applyHIDMappings()

local function isMarked(e)
  return e:getProperty(props.eventSourceUserData) == SOURCE_MARKER
end

local function postKey(key, isDown, flags)
  local generated = event.newKeyEvent(flags or {}, key, isDown)
  generated:setProperty(props.eventSourceUserData, SOURCE_MARKER)
  generated:post()
end

local function postStroke(key, flags)
  postKey(key, true, flags)
  postKey(key, false, flags)
end

local function passthroughFlags(e, includeControl)
  local old = e:getFlags()
  local flags = {}
  if old.cmd then table.insert(flags, "cmd") end
  if old.alt then table.insert(flags, "alt") end
  if old.shift then table.insert(flags, "shift") end
  if old.fn then table.insert(flags, "fn") end
  if includeControl then table.insert(flags, "ctrl") end
  return flags
end

local function frontmostIsTerminal()
  local app = hs.application.frontmostApplication()
  return app and terminalBundles[app:bundleID()] or false
end

local keyboardTap = hs.eventtap.new({
  eventTypes.keyDown,
  eventTypes.keyUp,
  eventTypes.flagsChanged,
}, function(e)
  if isMarked(e) then
    return false
  end

  local kind = e:getType()
  local code = e:getKeyCode()
  local isDown = kind == eventTypes.keyDown
  local isUp = kind == eventTypes.keyUp

  -- macOS maps Caps to Control before Hammerspoon sees it. A Control press is
  -- an Escape tap only when no key or additional modifier is used with it.
  if kind == eventTypes.flagsChanged then
    local flags = e:getFlags()
    local nowDown = flags.ctrl or false
    if nowDown and not controlDown then
      controlDown = true
      controlUsed = flags.cmd or flags.alt or flags.shift or flags.fn or false
    elseif not nowDown and controlDown then
      controlDown = false
      if not controlUsed then
        postStroke("escape")
      end
    elseif controlDown then
      controlUsed = true
    end
    return false
  end

  -- Preserve a remap until keyUp even if Control is released first.
  if isUp and remappedDown[code] then
    postKey(remappedDown[code], false)
    remappedDown[code] = nil
    return true
  end

  if isDown and controlDown then
    controlUsed = true
  end

  -- Ctrl-HJKL becomes arrows outside terminal emulators. Other held modifiers
  -- (Shift/Command/Option/Fn) are preserved, while Control is consumed.
  if (isDown or isUp) and vimArrows[code]
      and e:getFlags().ctrl
      and not frontmostIsTerminal() then
    local target = vimArrows[code]
    if isDown then
      remappedDown[code] = target
    end
    postKey(target, isDown, passthroughFlags(e, false))
    return true
  end

  return false
end)

keyboardTap:start()
hs.autoLaunch(true)

-- UserKeyMapping is cleared at restart and can be cleared when keyboard
-- services are recreated, so restore it shortly after the Mac wakes.
local wakeWatcher = hs.caffeinate.watcher.new(function(eventType)
  if eventType == hs.caffeinate.watcher.systemDidWake then
    if wakeTimer then wakeTimer:stop() end
    wakeTimer = hs.timer.doAfter(1, applyHIDMappings)
  end
end)
wakeWatcher:start()

if not hs.accessibilityState() then
  hs.alert.show("Hammerspoon needs Accessibility permission")
end
