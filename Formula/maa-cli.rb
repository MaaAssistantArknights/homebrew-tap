class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.3.tar.gz"
  sha256 "f781c5935283b7728591851be6d8b90552f85192042ab305752a903eb1ec20f1"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.3"
    sha256 cellar: :any,                 arm64_tahoe:   "4082b1dfb0991b18df54ed6925e67a6932c86631ff8bdf1e5abd4f24bb0fdb63"
    sha256 cellar: :any,                 arm64_sequoia: "eb13f278c56f9a89130dcb0d4379ba823b3645baa5ec8a4e04f5553120ab2b5a"
    sha256 cellar: :any,                 arm64_sonoma:  "edd0f0bb4c3112e7d683846f52bda86a5582c7501d686a17f5b413c684c60382"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "299a1fc29b289eda3a52950b2a3de8bde1dde5ab4ff90b0e8dc486e9a4b00aff"
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
