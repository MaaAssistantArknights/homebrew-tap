class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.4.tar.gz"
  sha256 "21979d35ecb5a3a617e2e8b89acd4e9de1256b8f44c07ae63f6d4773bfee161f"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.4"
    sha256 cellar: :any,                 arm64_tahoe:   "21861f63460cde7ede99ac9d25934cf5903e25d3cee6c9e8208f1b98a33fee35"
    sha256 cellar: :any,                 arm64_sequoia: "8aa217948e1305cfab2e786b564be38146d5df7f580237e9e8b60a0e286f200b"
    sha256 cellar: :any,                 arm64_sonoma:  "c9a6dbde65639580054185e32fc00f92c518a623df4559a8dfe65cafe14b1e88"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "38fa12aad452dbe557effa66a7026a0a115b7e91531ca2a90dd837898253abf1"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl@3" if OS.linux? || build.with?("git2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"
    ENV["MAA_VERSION"] = version.to_s

    features = []
    features += ["git2", "git2/vendored-libgit2"] if build.with? "git2"
    features += ["core_installer"] if build.with? "core-installer"

    package_path = "crates/maa-cli"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: package_path)
    fish_completion.install "#{package_path}/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
