class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.3.9.tar.gz"
  sha256 "f82c64966b2393b5876406b19d3be87e738f39788fdb47b74b8d58ff5b7db975"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.3.8"
    rebuild 1
    sha256 cellar: :any_skip_relocation, ventura:      "d9867be5b86b3b3633399797e03c6c0aa8d75bcbbb6828bf7e6d2b220f8668c0"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7b2ce5b35d8b556681417a1d319aa0fbf576cdaacb7e299d23b81a1b4f461030"
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
