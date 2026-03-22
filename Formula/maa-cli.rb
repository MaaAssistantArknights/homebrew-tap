class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "052c8761bdfb918e2787127744286ece0df98fd8f8a1e6cabde1f5b9b347057c"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.2"
    sha256 cellar: :any,                 arm64_tahoe:   "97631482a29f719361a708dd8403d131e51ad6e6154163d8fbb82429188efc08"
    sha256 cellar: :any,                 arm64_sequoia: "d860a685fd7868d0361b4732622016c4e25b4f997802caaf8ec60e72413dc114"
    sha256 cellar: :any,                 arm64_sonoma:  "5a78345439c26d38b329a6ac532893ddb3e382e726c8e052168ac0c1302cc171"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "dacb981a672330822a6f13221ef75297295c3d944351428bbd7708d56e7d9a3b"
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
