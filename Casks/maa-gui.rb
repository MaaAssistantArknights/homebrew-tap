cask "maa-gui" do
  version "4.23.3"
  sha256 "214d4cab70f6a9eb10543fb0b59169bb3f8f7c2f6b9efd27154f3de2bbc834d0"

  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/releases/download/v#{version}/MAA-v#{version}-macos-universal.dmg"
  name "MAA.app"
  desc "GUI for MAA (MaaAssistantArknights)"
  homepage "https://maa.plus/"

  conflicts_with cask: "MaaAssistantArknights/tap/maa-gui-beta"

  app "MAA.app"
end
