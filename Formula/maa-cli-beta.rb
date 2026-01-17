class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.0.tar.gz"
  sha256 "12b28c57d9d57fae5ba24775ba11e6791c399306f7cb9312dc0fea8abcf6396e"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.0"
    sha256 cellar: :any,                 arm64_tahoe:   "4a104ce521d599830de91eb2fd801cc4ee6ebea5598e6afbd489a9221f3c3b65"
    sha256 cellar: :any,                 arm64_sequoia: "13d16ac8381101a1525903570c1e3c1709c89c87cb587532f168dc649c49fdd6"
    sha256 cellar: :any,                 arm64_sonoma:  "b4ad74acaba9f98c459dad7aa868373d110a1d2a3431ab11484fe486f07c6fa0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "937c78efa9acbe3ac434b45c1299327ad5c13932238ac5c62803bf37e2392267"
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
