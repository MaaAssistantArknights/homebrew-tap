cask "maa@beta" do
  version "5.28.0"
  sha256 "7f4f6bd1b22b9b444a8128ccb92c263a9a5f1c68b869b98219fc4eb8deca2deb"

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
