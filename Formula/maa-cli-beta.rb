class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.9.tar.gz"
  sha256 "0f616e054010bdf1c14690d1c8c1777bbd68d8d6f039e0a97767c8c59cee33fa"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.9"
    sha256 cellar: :any,                 arm64_tahoe:   "7bdaeac01700e59b1090e995479f4eb38efce66edcf1bbdb6e3539e1661cb528"
    sha256 cellar: :any,                 arm64_sequoia: "1454b71f455593effc86a5ebccab31872ac112a43066b81d872f92f2900335f1"
    sha256 cellar: :any,                 arm64_sonoma:  "1db054433583a7222c460b1f057a164ddd4f2f0631a96146b2ea9fdc12a9b9e4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4664078a2b75ee011193230202e0fdf531ff6780c6d7c68f70273ea14e0b2de3"
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
