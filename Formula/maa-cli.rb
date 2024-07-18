class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.8.tar.gz"
  sha256 "2ebb71420c17edec7687ce24a9e4f238ce6ad87d691c923547d46ae9cb8f4bfe"
  license "AGPL-3.0-only"
  revision 2

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.8_1"
    sha256 cellar: :any,                 arm64_sonoma: "3cd7ca4edab66a41fb0552c29cf146942d4e2c18c4d7b7ad13ae79b7ae389718"
    sha256 cellar: :any,                 ventura:      "f30f71f22e1d1a3cd2bb3d3cde6719679b42e04df313807777b5ebe652e992de"
    sha256 cellar: :any,                 monterey:     "6547bfaaac0bfc3f2b7036e7d965addc4d471c63ea0d6a32102caab292493500"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8483bdb5d22fb8f8d570f23fb05450401e5ae59abb54966f6df6508d3300998a"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl@3" if OS.linux? || build.with?("git2")

  uses_from_macos "zlib"

  conflicts_with "maa-cli-beta", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"
    ENV["MAA_VERSION"] = version.to_s

    features = []
    features += ["git2", "git2/vendored-libgit2"] if build.with? "git2"
    features += ["core_installer"] if build.with? "core-installer"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
