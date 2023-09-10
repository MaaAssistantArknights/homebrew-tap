class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.3.8.tar.gz"
  license "AGPL-3.0-or-later"
  sha256 "d107e426a599cd489c273aabf0dae50f3dbfdb050275b11fb05627d2e4998a5b"

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--path", "maa-cli", "--lcoked", "--root", prefix, "--bin", "maa"
    fish_completion.install "maa-cli/share/fish/vendor_completions.d/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
