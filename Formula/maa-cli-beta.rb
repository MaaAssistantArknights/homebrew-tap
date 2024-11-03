class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "f9d59f66b4823cdebe8d98399d5c20c72085038ae8d4434000900bf74a3d2aeb"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.1"
    sha256 cellar: :any,                 arm64_sequoia: "90391a75a39bd37d888624f7901489fc8679a85df6837ff4185ba3d75c3047f4"
    sha256 cellar: :any,                 arm64_sonoma:  "f013a2df21ceda9a816643ff8a64a591ad17edd7044ab27442e0ee3e9dc790fa"
    sha256 cellar: :any,                 ventura:       "72ab0dfa47586a9397e4362f0982cd8860968fea253c4c86230f8983c3e65276"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5e597486c6a637bddbe3b1850ed6a99b2f1e9471d0765e05aba5d5385d03d446"
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

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
