class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.7.tar.gz"
  sha256 "634461c24378af4c71c0e9f956f5c3e9cc3715984c8351a455400c75019bb9e7"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.6"
    sha256 cellar: :any,                 arm64_sequoia: "d8d96f6c6d88d060e496d2c6a0a8d68ac95ecf1e6b0bea6e109d127821f66f2c"
    sha256 cellar: :any,                 arm64_sonoma:  "fc390116dcd092339c444a0a7917e6f082abf8e1307fa30ad6518d8a1de98f23"
    sha256 cellar: :any,                 ventura:       "f0e51264425f4179e822ef6d0a44145cdd727f36f650b1ff18dd45bdd8159a5c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "e0b30eb68d576d6d3621a471658722f10d869b03a87aa5165f4a0a4a0bfa1aed"
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
