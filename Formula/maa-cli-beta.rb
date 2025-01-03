class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.4-beta.1.tar.gz"
  sha256 "141d64a7d17d7102780e87eb23d230893b0a7b850ef94d014300e6fd5fbc42c5"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.4-beta.1"
    sha256 cellar: :any,                 arm64_sequoia: "85fd8064bf84e46acfe7fd1147e47ddbf2b6bc450e84f9002773d5d7b8111fce"
    sha256 cellar: :any,                 arm64_sonoma:  "9580745fa89d982424d587e4391fdfbfcbe0f644b7d9dbfbb8bf60c90171eefd"
    sha256 cellar: :any,                 ventura:       "832c652d600d77b5c6f1f44333154824c049cd458d6a4a90792812e9d0958fec"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4cbf91a08020d9b29d6d22c9b249cab89f860edc71d9f85e357d26fc3bac628c"
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
