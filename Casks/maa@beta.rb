cask "maa@beta" do
  version "6.21.0-beta.2"
  sha256 "3cee56dc3e467574019a4450f7aca1c05e5146ee0485da129d5cf2e2963b6f3e"

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
