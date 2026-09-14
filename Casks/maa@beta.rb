cask "maa@beta" do
  version "6.18.0-beta.1"
  sha256 "d8491837626de80f414f9e7628f995246cb2195b41439caf117eb55dbf5f5fa8"

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
