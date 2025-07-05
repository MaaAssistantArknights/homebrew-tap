cask "playcover-maa" do
  version "3.1.0.maa"
  sha256 "09b78ffc5a9366fbc3eb970952a5c544a6411f67a50b568ccab293ce6adcee57"

  url "https://github.com/hguandl/PlayCover/releases/download/v#{version}/PlayCover-v#{version}.dmg"
  name "PlayCover.app"
  desc "Fork of PlayCover used by MAA"
  homepage "https://github.com/hguandl/PlayCover/"

  auto_updates true
  conflicts_with cask: "playcover-community"
  depends_on macos: ">= :big_sur"

  app "PlayCover.app"
end
