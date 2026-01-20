cask "playcover-maa" do
  version "3.1.0.maa.1"
  sha256 "5f61e78362ff4b6e99b28e7641894cab0c6f667214eb9ed77ae7325e5c5ae534"

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
  depends_on macos: ">= :monterey"

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
