class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.7.tar.gz"
  sha256 "5337e0fba937eca0de616cd3405fdc29018bf9eedd644374fa793429fe3e609d"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.7"
    rebuild 1
    sha256 cellar: :any,                 arm64_sonoma: "bc431505193ac2df960e52bf3f3bf28f4c348c9cdcf091ed03ef0c20ea192695"
    sha256 cellar: :any,                 ventura:      "9d353aa2853c9830a6f82c4ded472f9bacad32ede6cf4a670ece333813b25187"
    sha256 cellar: :any,                 monterey:     "75f3e5ed33e08b23b56b826dee84b3534851c3b614f933840b2ce158802aa651"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "32a2749c24a9cd43e12cf4ce0b779194796f266b3592a2f9ce5408c063e7ffa3"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl" if OS.linux? || build.with?("git2")
  depends_on "libgit2" => :recommended
  uses_from_macos "zlib"

  conflicts_with "maa-cli-beta", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"

    features = []
    features += ["git2"] if build.with? "git2"
    features += ["core_installer"] if build.with? "core-installer"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
