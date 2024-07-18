class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.8.tar.gz"
  sha256 "2ebb71420c17edec7687ce24a9e4f238ce6ad87d691c923547d46ae9cb8f4bfe"
  license "AGPL-3.0-only"
  revision 2

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.8_1"
    sha256 cellar: :any,                 arm64_sonoma: "49b5683a8ba6b0396d2605fe38be23c7a297dd3092a22f5cfdb05f4fda36fa9e"
    sha256 cellar: :any,                 ventura:      "7deb6ad39bbfa8c421f23fa91124a9e7ebf0ef263c40ad800c750c3717148bc6"
    sha256 cellar: :any,                 monterey:     "9cd4022e52de83f72a7aa502ab0c5eff55f91c2eab2223e3fa87cbcdf09d3194"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "4f711b34cd01695b9baf1adda523320848181d2022697c11251e9fc2e5e9219c"
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
