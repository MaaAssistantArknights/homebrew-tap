class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "f6c06542c76db7f0d3cc9e051d1438d896076f6389e0584c2b4f45715d75447b"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.0"
    sha256 cellar: :any,                 ventura:      "31dab525997b348dc34c3fdb53b7562195583d0b1c909ddfaa42f55f42cf289a"
    sha256 cellar: :any,                 monterey:     "16060a6a901f61783071e6ae1c7c56ce2ec325361a85c4d0dafa515a76ae16fc"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "81e02aff5a4a86e413dcc4668acb3b4bff29be4fe7204301b7f66f3070f0ccb3"
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
