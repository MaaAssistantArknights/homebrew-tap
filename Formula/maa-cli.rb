class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.6.tar.gz"
  sha256 "8d7660d0d9bf0b1d8b7e48987ad48edd820a07c2da38a752b294c1f938a11450"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.6"
    sha256 cellar: :any,                 arm64_sonoma: "a8e9f3cb2bdd29e5b7673ab635c306bfb9a7c1495a475d829c0a6041065b6546"
    sha256 cellar: :any,                 ventura:      "4ca2443225c5c7cfa7118d17bb420d13553aad1c72b967603e30fffdbc99e0a4"
    sha256 cellar: :any,                 monterey:     "f6894269b520de0659efeb1c348944ce6beb6624bae39018304dc2d8e743bc35"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2363e737d8e80600b6f83f29b3d2c422644443d0ee3da363d2af03fdebae8fb9"
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
