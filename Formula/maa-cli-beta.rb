class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.9.tar.gz"
  sha256 "a1a822876283d97dca2eabba315ab0bc20b9e1886ede892c696f548bb8e524e6"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.9"
    sha256 cellar: :any,                 arm64_sonoma: "760cde106dddf47bc0cf3f5cc0fba7a294d48ab57496a45f3b4f957ab9a5929e"
    sha256 cellar: :any,                 ventura:      "45072e9f2f4e6c0135f70247bd8592454f5d49c4ddba6789e4e387ed9b2d060f"
    sha256 cellar: :any,                 monterey:     "68d8e7265d93e1b1c24e65aa2efd527d45c247247fcb5160d9a84dd7f4b5f647"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "db5a6e96d5a9b24c9f28b7b92cdb1e8da252fb738f4828d41f984ebdf17ca489"
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
