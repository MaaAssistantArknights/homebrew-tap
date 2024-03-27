cask "maa-cli-bin" do
  version "0.4.5"
  sha256 "14adc4f797aa0d9746c11d067a17b688575f2e32d7d47941105f1f7d648a3d5e"

  url "https://github.com/MaaAssistantArknights/maa-cli/releases/download/v#{version}/maa_cli-v#{version}-universal-apple-darwin.zip"
  name "maa-cli"
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"

  conflicts_with formula: "maa-cli"
  depends_on macos: ">= :big_sur"

  binary "maa_cli-universal-apple-darwin/maa"
end
