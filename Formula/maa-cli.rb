class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.3.11.tar.gz"
  sha256 "da9c3ba72b93519f7382d3c518da76ce9e9f1e05806e8f6d0f580363226631ed"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.3.10"
    sha256 cellar: :any_skip_relocation, ventura:      "127ab4936f1e1a1b99ca43864b1eaf1d8fe96b0a6352b4079dc72d788c380fe7"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "38d5ca88ad760a1b08ffa18f1035db10805eb866fecfada2de4934c84fb43507"
  end

  depends_on "rust" => :build

  def install
    system "cargo", "install", "--path", "maa-cli", "--locked", "--root", prefix,
           "--no-default-features", "--bin", "maa"
    fish_completion.install "maa-cli/share/fish/vendor_completions.d/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
