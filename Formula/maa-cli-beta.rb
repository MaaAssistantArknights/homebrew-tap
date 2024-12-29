class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.3.tar.gz"
  sha256 "e78200bd58e8481e81bd2daf996a65170864d761d1db88c637db38c33df2b29c"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.3"
    sha256 cellar: :any,                 arm64_sequoia: "fd904e9bf4f4dcfde67eec8a691e910462d279f97ce87c52a5afbf3bd60a576a"
    sha256 cellar: :any,                 arm64_sonoma:  "8fe73ee04b468909e1b903976f57cef34ffa06eaa9cd88cb28fe11a8027f7ecf"
    sha256 cellar: :any,                 ventura:       "d4f4cd1b7fbb79c633ba00138f7a5735b3827cb1bbefb681c5a7d3873bf8d442"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fcd0c7723a2f30399957f1291a9072bbec38ff9114c9d06bc31556cadebe4777"
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
