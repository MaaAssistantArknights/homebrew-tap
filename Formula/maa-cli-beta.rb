class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.0-beta.1.tar.gz"
  sha256 "c13ffc7222f736f703dbc848fe27d6f74c2ef9ba81e4da9afb335f9d7a18531e"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.0-beta.1"
    sha256 cellar: :any,                 arm64_tahoe:   "84156445e61aa0d520c7555f108d82b5b270617ee5e5c2508b87bba3d6838bf9"
    sha256 cellar: :any,                 arm64_sequoia: "1f8014741e79bd4f81bb179eebe9716642a7d08b8c4142a964d8c153635340de"
    sha256 cellar: :any,                 arm64_sonoma:  "1fc341aadd6b4adff3876152016c6d290ee04053af6f6a5e682c60af1ceca27d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "98a2e6b238a666172a1dd50f56fdfab00f8dab9cedee01854115e4c9a1dbed24"
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
