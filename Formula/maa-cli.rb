class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.8.tar.gz"
  sha256 "2ebb71420c17edec7687ce24a9e4f238ce6ad87d691c923547d46ae9cb8f4bfe"
  license "AGPL-3.0-only"
  revision 1

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.8"
    sha256 cellar: :any,                 arm64_sonoma: "939614e4cee4ba5d0268dc2538613580aac24339b19ae8e9579a21520b060dfc"
    sha256 cellar: :any,                 ventura:      "f99f33e43c4085d66f83133ca6e11e6cb7b18c26358d9bb91072b8fd6a8520bd"
    sha256 cellar: :any,                 monterey:     "5ad07950ac5fb796d5f013c36145386a5a4e62699aed0516d90de9c7677e4901"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "82438f3350974538ba6eb135aaf980e73d9ca9d2431c4148285aa0efc9f2b2b7"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl" if OS.linux? || build.with?("git2")
  depends_on "libgit2" => :recommended
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
