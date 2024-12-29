class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.3.tar.gz"
  sha256 "e78200bd58e8481e81bd2daf996a65170864d761d1db88c637db38c33df2b29c"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.2"
    sha256 cellar: :any,                 arm64_sequoia: "a07c9bd2f98664858458c6fc6c105203099c1dda676a4c286c88907e76e8853d"
    sha256 cellar: :any,                 arm64_sonoma:  "ff6e3143acd9e5f9c3a370cb0d5c1c09e47d0f321723ecaf8b00842bcd7fd3bf"
    sha256 cellar: :any,                 ventura:       "bf4f61b70797606f8e30c42166fcc7c779bb75d45760a8dde9280e6e3a59bc33"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "eb4d91b1fdc02b6e03d0aac13ec39629cdb8c60d41e5e705b3e2c0382a51c423"
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

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
