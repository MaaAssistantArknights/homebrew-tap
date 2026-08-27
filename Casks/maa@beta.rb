cask "maa@beta" do
  version "6.17.0-beta.7"
  sha256 "365a1c00cf530bf5b8eac0b54d7040abdc2a4588fd3ee253c018e1ca9b096a1b"

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
  depends_on macos: :big_sur

  app "MAA.app"
end
