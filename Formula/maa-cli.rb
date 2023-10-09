class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.3.11.tar.gz"
  sha256 "da9c3ba72b93519f7382d3c518da76ce9e9f1e05806e8f6d0f580363226631ed"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.3.11"
    sha256 cellar: :any_skip_relocation, ventura:      "763fb408cbb8e86d901363f65378df59ed90bf0153bb3e374e257b5819de8a72"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2511923437e5cee3ce0811e08950b21313de9aa0170d3c6dff472a4f46bd0324"
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
