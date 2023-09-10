cask "maa-gui-beta" do
  version "4.24.0-beta.2"
  sha256 "d88d1cecd2207725b7fbb2fa1053902e90a6da1ba2bf46eabd747e10aadd69f4"

  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/releases/download/v#{version}/MAA-v#{version}-macos-universal.dmg"
  name "MAA.app"
  desc "Mac GUI for MAA (MaaAssistantArknights)"
  homepage "https://maa.plus/"

  app "MAA.app"

  conflicts_with cask: "MaaAssistantArknights/tap/maa-gui"
end
