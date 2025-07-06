class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.6.tar.gz"
  sha256 "d1457417e5ff088c087547d9db9a2bac01ba53205e54cfabec4ea34e76a66bad"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.5"
    sha256 cellar: :any,                 arm64_sequoia: "3593642a8770bbb54c158f58b701c9ec3bc14e17c92b0387ffb640cd078b805f"
    sha256 cellar: :any,                 arm64_sonoma:  "f2937f0b7379a2d5b0faf8195f7617e3e3f04ba1e3fcf37b75d00bd3daf78a79"
    sha256 cellar: :any,                 ventura:       "49e206e212957033afe50d48f26a8cc45c8c7f4c2059191f307de2a930518ef1"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "68925cf0e2a345d63b28631e18ee244a2f142d3330295a656e3110664e4cade0"
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
