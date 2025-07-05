cask "playcover-maa" do
  version "3.1.0.maa"
  sha256 "fbe0150a4eda2331dbf6dbe72e52a1c69a7156ddd8e668dccd53b804634b89a4"

  url "https://github.com/hguandl/PlayCover/releases/download/v#{version}/PlayCover-v#{version}.dmg"
  name "PlayCover.app"
  desc "Fork of PlayCover used by MAA"
  homepage "https://github.com/hguandl/PlayCover/"

  auto_updates true
  conflicts_with cask: "playcover-community"
  depends_on macos: ">= :big_sur"

  app "PlayCover.app"
end
