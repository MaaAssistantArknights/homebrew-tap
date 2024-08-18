cask "maa-cli-bin" do
  version "0.4.11"
  sha256 "2e81a14b0735c645211156810992ab7de5e82ec07acc78f1a7bfb10a3970a8bd"

  url "https://github.com/MaaAssistantArknights/maa-cli/releases/download/v#{version}/maa_cli-v#{version}-universal-apple-darwin.zip"
  name "maa-cli"
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"

  conflicts_with formula: "maa-cli"
  depends_on macos: ">= :big_sur"

  binary "maa_cli-universal-apple-darwin/maa"
end
