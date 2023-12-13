class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.3.12.tar.gz"
  sha256 "f6742323dcf201bb0c05e542cc6dc674ba08c8dba292d7b39c956490b1b3bbc2"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.3.12"
    rebuild 1
    sha256 cellar: :any_skip_relocation, ventura:      "ba1cad00a5386ae02796d34b1c139e34ea68f7878185022c39b8d5c95b62d5a7"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c062a0a3dbc7d738fbea1eb22719c3b6be55a528fcadccb0b6606f15521e422b"
  end

  depends_on "rust" => :build

  conflicts_with "maa-cli-beta", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/share/fish/vendor_completions.d/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
