class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.3.tar.gz"
  sha256 "570de2d7d18eced73f5be5e4677c628d4a4d13e443bf234fe40ae9f365954d47"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.3"
    sha256 cellar: :any,                 ventura:      "d126f9788c6cd63d0be60f92a10303dc6c09a09d3f0dacf2c68f82d831a3215d"
    sha256 cellar: :any,                 monterey:     "1aaf12598c2530b84d0394cef9c871d441ca8fc5132f3cc441ffa4a31bc327c8"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f29628b3938193bb7d9c9471a7fdeaf4d5252fe84d2f38fcf8a2976941076989"
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
