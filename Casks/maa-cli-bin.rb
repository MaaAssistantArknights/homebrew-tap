cask "maa-cli-bin" do
  version "0.5.2"
  sha256 "2dd09dc9d7e7a11e482990415e3c37d7d3211c85ca4a2bb92228b45a2b3691d8"

  url "https://github.com/MaaAssistantArknights/maa-cli/releases/download/v#{version}/maa_cli-v#{version}-universal-apple-darwin.zip"
  name "maa-cli"
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"

  conflicts_with formula: "maa-cli"
  depends_on macos: ">= :big_sur"

  binary "maa_cli-universal-apple-darwin/maa"
end
