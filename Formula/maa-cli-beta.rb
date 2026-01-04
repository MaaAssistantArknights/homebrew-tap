class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.6.0.tar.gz"
  sha256 "c8eb31c23d962df7440b5746f70da27ff081d8fa0b63b82c061fa7e49dd12683"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.6.0-beta.4"
    sha256 cellar: :any,                 arm64_tahoe:   "247143282a56dc8f68967a87bbf63934a75458abf24a964103906c5774fa89de"
    sha256 cellar: :any,                 arm64_sequoia: "b56b1c9992ed48b2d682662df7fb975da2017b043cf48ad14b3c13cb3bdb3be4"
    sha256 cellar: :any,                 arm64_sonoma:  "08a2a1e11eea8a7f642fde18fd4d898b95e6500330b8de32140761a658a220fa"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "3424a8f0200d10f9b55c84ac9ef1926d01ed0619733aa039f23d13937631ce47"
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
