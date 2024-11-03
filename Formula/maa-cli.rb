class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "f9d59f66b4823cdebe8d98399d5c20c72085038ae8d4434000900bf74a3d2aeb"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.1"
    sha256 cellar: :any,                 arm64_sequoia: "c42c25d7b5cd14b7d49082223b0d1a9c3aa4c21d3381ea84d584922bf0a71493"
    sha256 cellar: :any,                 arm64_sonoma:  "aef906d2e14a4bce845554c364688b594a2431e3d3a2d98c3af9cd397f10f792"
    sha256 cellar: :any,                 ventura:       "0d7d0a8a51b63fed14430186f26e0ef457c42be119bd824ac76a0f412070f9fa"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7b9ea7b604e826df7390f6f3dd84cc9f04ae9d68db38d950584d02e66476f21e"
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
