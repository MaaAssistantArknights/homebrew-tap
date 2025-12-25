class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.6.0-beta.3.tar.gz"
  sha256 "dcb2e304f8ab669bf42a8824edbcc04dafbb44aa9adb441e03bf01249dc754e3"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.6.0-beta.2"
    sha256 cellar: :any,                 arm64_tahoe:   "124348a82d5b3b418c3f1ea90227391b8872721bc86f4ee1e0a5dd9408a11093"
    sha256 cellar: :any,                 arm64_sequoia: "975a585aeb35736e9d4bc4253c5a1bd9878c31b2fda911291c93ec63d29d6c67"
    sha256 cellar: :any,                 arm64_sonoma:  "9b26b1680b90468ea8a1839eb1277f114a184d3d161c0c1dbfb18f61e7242ba0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "81a684e018b24e80db6fc59e672ccc78b8479a2e2603a881d97b83c2c5c8d6f4"
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
