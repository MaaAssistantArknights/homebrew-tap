class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.9.tar.gz"
  sha256 "0f616e054010bdf1c14690d1c8c1777bbd68d8d6f039e0a97767c8c59cee33fa"
  license "AGPL-3.0-only"
  revision 1

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.9"
    sha256 cellar: :any,                 arm64_tahoe:   "235c6fb8439721f3d37c9e3da7479c73733d73cfba47640e993c9c9cc5eb88bd"
    sha256 cellar: :any,                 arm64_sequoia: "ba9083faee4b3c439540a6a2f7d563cbcf0392dd1da8347aa7c6999c124b7243"
    sha256 cellar: :any,                 arm64_sonoma:  "939478e537bd5116c7a64ac78c1d737bd9e496d18a4911933623d9e9b5300d67"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "ed41298b03030a732a6edec4e7cf918b4e82927f92771ca224887971b1a665ac"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  depends_on "libgit2" if build.with?("git2")

  uses_from_macos "zlib"

  conflicts_with "maa-cli-beta", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"
    ENV["MAA_VERSION"] = version.to_s

    features = []
    features += ["git2"] if build.with? "git2"
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
