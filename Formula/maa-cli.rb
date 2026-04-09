class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.4.tar.gz"
  sha256 "21979d35ecb5a3a617e2e8b89acd4e9de1256b8f44c07ae63f6d4773bfee161f"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.4"
    sha256 cellar: :any,                 arm64_tahoe:   "815f239ca2dc3efcfa9767bdc6065eaa74a9c2cf37f13926ebfed2bcfcad15fe"
    sha256 cellar: :any,                 arm64_sequoia: "c647ce4e9d63e7a43e0e974fcd96786c6b839f184e2eb39da7601ca593caae4b"
    sha256 cellar: :any,                 arm64_sonoma:  "dde4ec9b33e5711deb2adb8d81d949a88a71883d1315407729bdf3fd37a55139"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "bc7b5d80d9472d1e078b992aa4aa759b54c2761df61e086d169d3a4c36b75f81"
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
