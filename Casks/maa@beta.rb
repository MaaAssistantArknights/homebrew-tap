cask "maa@beta" do
  version "6.3.0-beta.4"
  sha256 "dbf806dddae717bd2c0c51d9414f5894575c7e426759498759581033222662f3"

  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/releases/download/v#{version}/MAA-v#{version}-macos-universal.dmg",
      verified: "github.com/MaaAssistantArknights/MaaAssistantArknights/"
  name "MAA.app"
  desc "Beta version of MAA (MaaAssistantArknights)"
  homepage "https://maa.plus/"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  auto_updates true
  conflicts_with cask: "maa"
  depends_on macos: ">= :big_sur"

  app "MAA.app"
end
