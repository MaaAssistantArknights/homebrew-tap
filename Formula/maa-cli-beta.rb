class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.8.tar.gz"
  sha256 "2ebb71420c17edec7687ce24a9e4f238ce6ad87d691c923547d46ae9cb8f4bfe"
  license "AGPL-3.0-only"
  revision 1

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.8"
    sha256 cellar: :any,                 arm64_sonoma: "72348619e31a2f79555a81b477da4b7494969672bc382a53eabfdcc3ad3680b4"
    sha256 cellar: :any,                 ventura:      "e032c4e97fcdfbe61b97e48e2ad3f5a8921973441079deb493ef2cae80044759"
    sha256 cellar: :any,                 monterey:     "0e92036f7b3053d7df19f64121083cd3e47044dea8547205d572d7a60d09dd31"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b2d84b346bd30a58d73f836f35a03c1d159c18a4bf9cab008915565db7351b5e"
  end

  option "without-libgit2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  depends_on "libgit2" => :recommended
  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl@3" if OS.linux? || build.with?("libgit2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"
    ENV["MAA_VERSION"] = version.to_s

    features = []
    features += ["git2"] if build.with? "libgit2"
    features += ["core_installer"] if build.with? "core-installer"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
