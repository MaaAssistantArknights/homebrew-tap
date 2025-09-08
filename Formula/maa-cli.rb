class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.8.tar.gz"
  sha256 "02248effb2569855ee6b157cfc009977e405d6a9da3a1ef3f502e5b92cb2dcb4"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.7"
    sha256 cellar: :any,                 arm64_sequoia: "68279b5393e465568f9af7d0d99a10e109dff991910789ef4a57aa97a0a3e51f"
    sha256 cellar: :any,                 arm64_sonoma:  "4c644f2ef1615e012bc2fbc8044491633c2e56579f0be18b0a1d46879c2049f0"
    sha256 cellar: :any,                 ventura:       "49a736f7143bae86c58ae0bec43f389471455b43429de3e7ad9428b4630951da"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "054f8a6be08f7d3c7605597580f8a8e9e94ffd78f5e6fe3f0472ca78b5e59432"
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
