-- opt + t: WezTerm
-- opt + c: Google Chrome
-- opt + s: Slack
local apps = {
  { key = "[", app = "WezTerm" },
  { key = "]", app = "Google Chrome" },
  { key = "s", app = "Slack" },
}

for _, entry in ipairs(apps) do
  hs.hotkey.bind({ "alt" }, entry.key, function()
    hs.application.launchOrFocus(entry.app)
  end)
end
