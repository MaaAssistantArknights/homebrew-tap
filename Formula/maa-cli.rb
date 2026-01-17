class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "12b28c57d9d57fae5ba24775ba11e6791c399306f7cb9312dc0fea8abcf6396e"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.0"
    sha256 cellar: :any,                 arm64_tahoe:   "ac71c8b4398bb578c84e88ed71ad4112f5ae4c7bfee8a4c1b0263406b7d5a992"
    sha256 cellar: :any,                 arm64_sequoia: "2abcd93362795a4c7d2bd10b88b082fe212f4230356fcc3e1870b779e4cec4da"
    sha256 cellar: :any,                 arm64_sonoma:  "ceb400fbece1af2b8ea2a9963f8b46f405b459229ff25e9d29338ec6b6370373"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "0cbc7f7011a68c85e7cb130f98932d7c1a33bfb9e9ad741c6855759fc6d19bf1"
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
