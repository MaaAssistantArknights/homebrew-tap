cask "maa-cli-bin" do
  version "0.4.8"
  sha256 "4561a297171de486b0fe80a610df2a0c2bdfcac0bc09cb5e7bdeea74bfd1ba3b"

  url "https://github.com/MaaAssistantArknights/maa-cli/releases/download/v#{version}/maa_cli-v#{version}-universal-apple-darwin.zip"
  name "maa-cli"
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"

  conflicts_with formula: "maa-cli"
  depends_on macos: ">= :big_sur"

  binary "maa_cli-universal-apple-darwin/maa"
end
