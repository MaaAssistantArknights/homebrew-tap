cask "maa@beta" do
  version "6.18.0-beta.2"
  sha256 "876a9ae04ef834765165936f5ee4a0e10fae137c1529f91a2a61d0114824ed98"

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
