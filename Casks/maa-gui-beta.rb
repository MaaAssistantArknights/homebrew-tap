cask "maa-gui-beta" do
  version "5.18.3"
  sha256 "5ac80fc639b4c4b5c26fd70b10e9615c3c45c38a05343529ad982b4a3340e582"

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
