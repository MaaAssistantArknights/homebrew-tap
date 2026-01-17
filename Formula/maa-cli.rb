class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "12b28c57d9d57fae5ba24775ba11e6791c399306f7cb9312dc0fea8abcf6396e"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.6.0"
    sha256 cellar: :any,                 arm64_tahoe:   "60f834372809f67fcfe8acf34670cadc6d6af6cb2d8c99f13f875d641386ae39"
    sha256 cellar: :any,                 arm64_sequoia: "3cfd4b452738492add681230a9f8e7d78d5a9d923fdea53d58ccdc412b333b45"
    sha256 cellar: :any,                 arm64_sonoma:  "516fd52ad11b180cb96b99600879d51755594580bdb18a57bd994be1e9212b79"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "45cff0ee91f70510307504918fa3a8126d37f0a7ac2bf07a81a584adf7c8d6d3"
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

    package_path = "crates/maa-cli"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: package_path)
    fish_completion.install "#{package_path}/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
