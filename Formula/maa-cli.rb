class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.10.tar.gz"
  sha256 "26f0b0d55d6bd547ac7ee20c7325974183ab32379ecb393138f7a177a402dc71"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.9"
    sha256 cellar: :any,                 arm64_sonoma: "381789e062b0c0ae594dfb0a231c4022cb9b98eb971d1f6f07d41bd751240d59"
    sha256 cellar: :any,                 ventura:      "5dd0f494dcf5d94d4e18f53cdaecbdf2fd9dc66dfdc5f11221e032397cf360e9"
    sha256 cellar: :any,                 monterey:     "4c5e943040df885ed5f586cad464c670f48d4e4ef8cf58c5698e3950dbdaf292"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c1df6d8ace105ee098d632a982f3208088beb5aa2b09b0ae3fa1528e935671d9"
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
