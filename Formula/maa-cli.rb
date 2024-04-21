class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.6.tar.gz"
  sha256 "8d7660d0d9bf0b1d8b7e48987ad48edd820a07c2da38a752b294c1f938a11450"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.5"
    rebuild 1
    sha256 cellar: :any,                 arm64_sonoma: "ab356daaab360fa6dd4fa649f3d018881bad06d8a74292f5d556e8d1937e0197"
    sha256 cellar: :any,                 ventura:      "6cb9b3c74a901d7939b63079e88dc5e91944284d3b263227d8ad62ab24408faa"
    sha256 cellar: :any,                 monterey:     "ccf540f4027989e2aa366bb41dcdf5e4bd060c457b95b72405bb4076fb925339"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "28778f784fc9f5852f58079d1b1c4a4b6fb32403eee53d38da9fa7efa944423c"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl" if OS.linux? || build.with?("git2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli-beta", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"

    features = []
    features += ["git2"] if build.with? "git2"
    features += ["core_installer"] if build.with? "core-installer"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
