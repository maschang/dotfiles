-- opt + space: アプリ検索ランチャー
local chooser = hs.chooser.new(function(selection)
  if selection then
    hs.application.launchOrFocus(selection.text)
  end
end)

chooser:bgDark(true)
chooser:fgColor({ hex = "#e8e8e8" })
chooser:subTextColor({ hex = "#888888" })
chooser:placeholderText("アプリ名を入力...")
chooser:width(25)
chooser:rows(10)
chooser:searchSubText(true)

local function buildAppList()
  local apps = {}
  local seen = {}

  -- 起動中のアプリ（ステータス付き）
  hs.application.enableSpotlightForNameSearches(true)
  for _, app in ipairs(hs.application.runningApplications()) do
    local name = app:name()
    local bundleID = app:bundleID()
    if name and name ~= "" and app:kind() == 1 and not seen[name] then
      seen[name] = true
      local icon = bundleID and hs.image.imageFromAppBundle(bundleID) or nil
      table.insert(apps, {
        text = name,
        subText = "起動中",
        image = icon,
        bundleID = bundleID,
      })
    end
  end

  -- /Applications 内のアプリ
  local installed = hs.execute("ls /Applications/ | sed 's/.app$//'")
  for name in installed:gmatch("[^\n]+") do
    if not seen[name] then
      seen[name] = true
      local bundleID = hs.application.infoForBundlePath("/Applications/" .. name .. ".app")
      local bid = bundleID and bundleID.CFBundleIdentifier or nil
      local icon = bid and hs.image.imageFromAppBundle(bid) or nil
      table.insert(apps, {
        text = name,
        subText = "",
        image = icon,
      })
    end
  end

  table.sort(apps, function(a, b)
    -- 起動中のアプリを上に
    if (a.subText == "起動中") ~= (b.subText == "起動中") then
      return a.subText == "起動中"
    end
    return a.text < b.text
  end)

  return apps
end

hs.hotkey.bind({ "alt" }, "space", function()
  chooser:choices(buildAppList)
  chooser:show()
end)
