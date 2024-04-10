class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.5.tar.gz"
  sha256 "af9f23549dd3d29356510ab5043d409ca549cf4483fdcd55d9019143386f619e"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.5"
    sha256 cellar: :any,                 arm64_sonoma: "63022b807b43f317eda82aea073fd2aaf7c0a6bdd51d49ca94b44e2d2382267c"
    sha256 cellar: :any,                 ventura:      "9f7ac5c2e9eb046bcfd55a43878404e43ca638ae295859a1eb0313a7fefa94f5"
    sha256 cellar: :any,                 monterey:     "140afedfcbeb53df398f14c04cf38ed8e132fcb5e55efce929c8901db60a0345"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "adf63595bf7364926566b071a799fc60808a00ebef215a955efffe1f44fcbf56"
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
