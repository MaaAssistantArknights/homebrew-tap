class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "7abd1b7f0be04240ac0934e23ee79e87b296c3a2f464b648ca07ee63599b2783"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.0"
    sha256 cellar: :any,                 arm64_sequoia: "6a7067fc523aa2c00716333671ac88a9a1ccf90dc5cd420d2bc9b5012817cb7f"
    sha256 cellar: :any,                 arm64_sonoma:  "08b286bbb17baacfc48a8975b7ea542a0a30bac163e2d92235eaca2c5f3de0fd"
    sha256 cellar: :any,                 ventura:       "3683fc9ac634704ad2646556d68e0120b01985340891400c8d9fcee8716b1638"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "48fb8ac5ca4ec459dde32b430e43fd66c81907ed034dc824f5a8d0b86619afc0"
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
