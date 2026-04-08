class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.3.tar.gz"
  sha256 "f781c5935283b7728591851be6d8b90552f85192042ab305752a903eb1ec20f1"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.3"
    sha256 cellar: :any,                 arm64_tahoe:   "9a6d9751754e3a7b981f4541b22a9edf656befdf58bb10bf7fae027d28604eb7"
    sha256 cellar: :any,                 arm64_sequoia: "fd1b347e0074f01a13cf8158ad47303ef5f838dc5561c57c3672586853f8144f"
    sha256 cellar: :any,                 arm64_sonoma:  "32dc6628cf77c6425268274a65fe03f5a0051aa7fa144363557be7d7b2fc4739"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c98630ed01ac470e44acb2cd3f3cc0b97c2b66afaebc7e15a0ab725699cb923b"
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
