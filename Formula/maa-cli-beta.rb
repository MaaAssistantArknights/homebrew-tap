class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.6.0-beta.3.tar.gz"
  sha256 "dcb2e304f8ab669bf42a8824edbcc04dafbb44aa9adb441e03bf01249dc754e3"
  license "AGPL-3.0-only"
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.6.0-beta.3"
    sha256 cellar: :any,                 arm64_tahoe:   "e77b725480d14d376368703f643befcbdb9570e6d00652fe0ce148ae9aafcca2"
    sha256 cellar: :any,                 arm64_sequoia: "51c63c8d4c29ecc4528a50ffff880e8ff9568676ff2a1db28c40939644fb1f26"
    sha256 cellar: :any,                 arm64_sonoma:  "b5fa22fcfaad070c86f8dfd94e7305b7ebe03564c54ba8e519a3176761ac29d4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c6d64db1fcac725b1e3ccf7ddac0299e7c16affb040c29d5384bbadf2ef4ae7b"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  depends_on "libgit2" if build.with?("git2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"
    ENV["MAA_VERSION"] = version.to_s

    features = []
    features += ["git2"] if build.with? "git2"
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
