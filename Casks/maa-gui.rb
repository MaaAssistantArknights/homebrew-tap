cask "maa-gui" do
  version "5.13.0"
  sha256 "3b4bc58e7adc19b9bfdcf029b63b2bb76026480f63844555c0bea1b819a0012a"

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
