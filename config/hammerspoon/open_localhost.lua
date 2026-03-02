-- opt + l: ポート番号を入力して localhost をブラウザで開く
-- 前回入力したポート番号を記憶する
local lastPort = "3000"

hs.hotkey.bind({ "alt" }, "l", function()
  local button, input = hs.dialog.textPrompt("Open localhost", "ポート番号を入力", lastPort, "Open", "Cancel")
  if button == "Open" and input ~= "" then
    lastPort = input
    hs.urlevent.openURL("http://localhost:" .. input)
  end
end)
