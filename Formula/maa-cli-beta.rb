class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.9-beta.1.tar.gz"
  sha256 "8240790d4e4a1019b28b78206308a09673c1dd1b7b5097c63363cc2c0dc9a116"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.8_2"
    sha256 cellar: :any,                 arm64_sonoma: "ba3eaf330fa639f3540131e9134bc5e2776061993d1b43217fd131cf7216922f"
    sha256 cellar: :any,                 ventura:      "4c8de4203d8b0eefd17c024035d773d7b0be4a0c8c99377916f9457ab28f4fe9"
    sha256 cellar: :any,                 monterey:     "9c2983983016ade1262ac405f97fdfe999edd27437f98df8c2be205bee7032fc"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "63d5cc15c81ee99367218978827a75f2de963af2d6952b36eef49dfcf8192974"
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
