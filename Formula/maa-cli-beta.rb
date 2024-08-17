class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.11-beta.1.tar.gz"
  sha256 "c8d490896327b864467da262e923748168fd467ca9ffc06ff20655d650ea2e11"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.11-beta.1"
    sha256 cellar: :any,                 arm64_sonoma: "22d2c06cb05fb18d8bb419d8747a7f05170b892187478d43842c15db808403a0"
    sha256 cellar: :any,                 ventura:      "6fc7d7c774bccf4ccf19023af7347870ddd726b93debbf07ab79c637b4c7fb60"
    sha256 cellar: :any,                 monterey:     "6abfd1497f6b096db7ca63e32e55dcd105ee20ece91ece1f162e328c34c4ad13"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "3734414c97b039102da4d80d579ab96092c03d11ba413cd72d67388aaa42109c"
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

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
