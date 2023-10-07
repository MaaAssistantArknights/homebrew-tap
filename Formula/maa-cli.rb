class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.3.10.tar.gz"
  sha256 "6f607d37c5b961bcbbb8d91fd75ce1e7c3d7f218c9650b458699e6e9ff6268b4"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.3.9"
    sha256 cellar: :any_skip_relocation, ventura:      "c37355367fdd3128e05ac2a8233d123c0ce8da6dc8db78b16a3eb86cce4e8c8f"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "813564ded2453d43c101ac349800c58c1e1572d3f47a7070b51b2b4a1797178f"
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
