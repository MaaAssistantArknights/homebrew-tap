cask "playcover-maa" do
  version "3.1.0.maa.10"
  sha256 "116afe00e85f71d8d8381a5750299df2473604ce29c2efc1fcaeecf9a10286e6"

  url "https://github.com/hguandl/PlayCover/releases/download/v#{version}/PlayCover-v#{version}.dmg"
  name "PlayCover.app"
  desc "Fork of PlayCover used by MAA"
  homepage "https://github.com/hguandl/PlayCover/"

  livecheck do
    regex(/^v?(\d+\.\d+\.\d+\.maa(?:\.\d+)?)$/i)
  end

  auto_updates true
  conflicts_with cask: "playcover-community"
  depends_on arch: :arm64
  depends_on macos: :monterey

  app "PlayCover.app"

  zap trash: [
    "~/Library/Application Support/io.playcover.PlayCover",
    "~/Library/Caches/io.playcover.PlayCover",
    "~/Library/Containers/io.playcover.PlayCover",
    "~/Library/Frameworks/PlayTools.framework",
    "~/Library/Preferences/io.playcover.PlayCover.plist",
    "~/Library/Saved Application State/io.playcover.PlayCover.savedState",
  ]
end
