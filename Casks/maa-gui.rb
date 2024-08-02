cask "maa-gui" do
  version "5.5.11451"
  sha256 "d930196adae952a8481e9415ca18fb82876198df5890cfc4eb25ebc1da44e675"

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
