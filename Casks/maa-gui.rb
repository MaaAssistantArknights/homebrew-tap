cask "maa-gui" do
  version "5.11.0"
  sha256 "fdcd6aafab4d03f1e55ce45abaf9cac4aa89d609c1ad42000aeda63f3eb249bd"

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
