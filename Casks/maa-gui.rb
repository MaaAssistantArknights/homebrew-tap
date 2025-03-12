cask "maa-gui" do
  version "5.14.0"
  sha256 "5d4601b19738add5636fdc2e0e1a9d0c116fc6e4f9575b8d65fe34af27530354"

  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/releases/download/v#{version}/MAA-v#{version}-macos-universal.dmg",
      verified: "github.com/MaaAssistantArknights/MaaAssistantArknights/"
  name "MAA.app"
  desc "GUI for MAA (MaaAssistantArknights)"
  homepage "https://maa.plus/"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  auto_updates true
  conflicts_with cask: "MaaAssistantArknights/tap/maa-gui-beta"
  depends_on macos: ">= :big_sur"

  app "MAA.app"
end
