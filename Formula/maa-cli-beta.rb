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
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.6.0"
    sha256 cellar: :any,                 arm64_tahoe:   "0bc92ab843637685f8125069f411eab9e03dd3f285166a3c87b3baf11e1c1965"
    sha256 cellar: :any,                 arm64_sequoia: "0da0f1c233c768976f68a8373ed73b0e48965d427bb5f4fd9683c22fe130e9cf"
    sha256 cellar: :any,                 arm64_sonoma:  "3d100de95d27a2cc32beabae36fb57aa22f5698a5f436bcf4cf40cc924e033ef"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5d35bca52e138c6d447223fa4e4b5f6ebca4958eda6a0cfcb91a4d2025d9c850"
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
