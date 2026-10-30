cask "maa@beta" do
  version "6.21.0-beta.3"
  sha256 "6d72f011f2300eeafab3e4e5d2937f91e4cd024812664b69ae2a61d2ede4ce55"

  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/releases/download/v#{version}/MAA-v#{version}-macos-universal.dmg"
  name "MAA.app"
  desc "Beta version of MAA (MaaAssistantArknights)"
  homepage "https://maa.plus/"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  auto_updates true
  conflicts_with cask: "maa"
  depends_on macos: :sonoma

  app "MAA.app"
end
