class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.3.tar.gz"
  sha256 "e78200bd58e8481e81bd2daf996a65170864d761d1db88c637db38c33df2b29c"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.2"
    sha256 cellar: :any,                 arm64_sequoia: "d76a6b600c4e972e71c84237879f4b60ef091685399b457f7ec4561772988f16"
    sha256 cellar: :any,                 arm64_sonoma:  "32e07836d8925a4f7fae9ef06771ac46337770784d17dee6a327103fd670364d"
    sha256 cellar: :any,                 ventura:       "07cfd7a517e7b1cf0042e99053d8c225a1a43367595a4f9848d72a611bac5944"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "17cf74cd3d208aa00094c8d4de36e70f104a73c1888fc9c91b1df12c4e75da21"
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
