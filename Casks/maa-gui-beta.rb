cask "maa-gui-beta" do
  version "4.28.0-beta.2"
  sha256 "5247d1d7803387b22403ed4ca80b56f89e1b2aa923f38a54575adbacc9287f70"

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
