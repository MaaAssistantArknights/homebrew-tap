cask "maa-gui" do
  version "5.16.4"
  sha256 "81a98fd128650d2a07a5940c16c6ab10a83ad0d9b605911f3e2cc63e72331172"

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
