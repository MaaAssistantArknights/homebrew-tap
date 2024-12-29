cask "maa-cli-bin" do
  version "0.5.3"
  sha256 "a2e5d17b7a51fbd2a05dfc57122ca5f3af72630578cfebeb9c7e758b936c7d72"

  url "https://github.com/MaaAssistantArknights/maa-cli/releases/download/v#{version}/maa_cli-v#{version}-universal-apple-darwin.zip"
  name "maa-cli"
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"

  conflicts_with formula: "maa-cli"
  depends_on macos: ">= :big_sur"

  binary "maa_cli-universal-apple-darwin/maa"
end
