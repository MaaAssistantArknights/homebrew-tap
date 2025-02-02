cask "maa-gui-beta" do
  version "5.13.0-beta.2"
  sha256 "9e3e1ef28bd22dd389a9c16d5b5ed35acbfeb943b462a20f3d46c4f6097fb4f3"

  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/releases/download/v#{version}/MAA-v#{version}-macos-universal.dmg",
      verified: "github.com/MaaAssistantArknights/MaaAssistantArknights/"
  name "MAA.app"
  desc "GUI for MAA (MaaAssistantArknights)"
  homepage "https://maa.plus/"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  auto_updates true
  conflicts_with cask: "MaaAssistantArknights/tap/maa-gui"
  depends_on macos: ">= :big_sur"

  app "MAA.app"
end
