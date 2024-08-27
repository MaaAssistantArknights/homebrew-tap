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
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.11"
    sha256 cellar: :any,                 arm64_sonoma: "2dd3baf56966c1e7f60f98391ae17b8d3138992909a8f5f94fa97a76cd8e772b"
    sha256 cellar: :any,                 ventura:      "1e2343f36192bb18764dfef572111453ca7f758a85b2a0a6ae21e922dace66ba"
    sha256 cellar: :any,                 monterey:     "0b4a12fc16959ae24191fc6e8a90b052551627772d6b50ebd5a7bed302179679"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1812337a99e914e071cba0698e84a56533d80492924222ab39ccfa16584b3636"
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
