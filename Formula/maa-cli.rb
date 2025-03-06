class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.4.tar.gz"
  sha256 "279687300627929a92e1791ccb9fb79a66b9f9554f1d872020a442fbde3898e3"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.3"
    sha256 cellar: :any,                 arm64_sequoia: "0089b87e73fc8c2453fc37c2a7c2547306568e2ea5a92954e745db7a45af8e39"
    sha256 cellar: :any,                 arm64_sonoma:  "f3eb3d23cfa526d75c6243fd2268a4c1a283382733fbf55734cd5dfadbe516c5"
    sha256 cellar: :any,                 ventura:       "0a181cffa3136bc2532681feb92dc1ec67f905e2ffac3e91f620965ebc9e17a0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "25a45fb39fc82b0eb0e8170daa35148df30ea8052e58183682ec76c7da0d61c5"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl@3" if OS.linux? || build.with?("git2")

  uses_from_macos "zlib"

  conflicts_with "maa-cli-beta", { because: "both provide maa" }

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
