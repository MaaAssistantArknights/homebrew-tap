class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.12.tar.gz"
  sha256 "47a450c74ac499f4b3d92459afdff04c53bac008628011be9c1744c7fb672839"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.12"
    sha256 cellar: :any,                 arm64_sonoma: "5f8947172c1339d2c595358419095bc654ca6ba5ad317f9099e62c4292350e29"
    sha256 cellar: :any,                 ventura:      "1275e9ad034d850a1a8934d917a481f09e4518ea992d744259223b01334661bc"
    sha256 cellar: :any,                 monterey:     "18b44e030f176a9751622140f138729d7824fb94bbd3ad9cf46c7ab6eb369344"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "a7e2b93c1ad66a82699e9f3242853e00f3e0f5cfe707a85d64f2e77515d4033f"
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
