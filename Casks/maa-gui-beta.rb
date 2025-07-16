cask "maa-gui-beta" do
  version "5.20.0-beta.2"
  sha256 "68c16c503e41c99a4f2c76e34263781006a9923da3544ac93b31569958e00246"

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
