class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.8.tar.gz"
  sha256 "4d49965fd486579c0f1d3f5a79a0252d022d92261f56ecc48d239f14bba29cc1"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.8"
    sha256 cellar: :any, arm64_golden_gate: "8d8d471a1896d38637c5183d10617fdecc1fbe65d6661931d25fe8702025ef1a"
    sha256 cellar: :any, arm64_tahoe:       "6ad10c97a21ea2c8165bf2e21764ac30467e74116a605316d51c773449ee180a"
    sha256 cellar: :any, arm64_sequoia:     "81a7da52fb9a2c2e2b1aa3843e8b593afa8874bd2038bf254bca34859a077d47"
    sha256 cellar: :any, arm64_linux:       "f0079ab6660ac20f8f0feeaf80444723ac48cc9798efe5a1a63abd05f53561b4"
    sha256 cellar: :any, x86_64_linux:      "ec9b6f6cf49c45d903cb57c23548da468d23942e1d09e0c4e76122fad7203a95"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl@4" if OS.linux? || build.with?("git2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli", because: "both provide maa"

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"
    ENV["MAA_VERSION"] = version.to_s
    ENV["OPENSSL_DIR"] = formula_opt_prefix("openssl@4") if OS.linux? || build.with?("git2")

    features = []
    features += ["git2", "git2/vendored-libgit2"] if build.with? "git2"
    features += ["core_installer"] if build.with? "core-installer"

    package_path = "crates/maa-cli"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: package_path)
    {
      bash_completion/"maa"      => "bash",
      zsh_completion/"_maa"      => "zsh",
      fish_completion/"maa.fish" => "fish",
    }.each do |completion, shell|
      completion.write Utils.safe_popen_read({ "MAA_COMPLETE" => shell }, bin/"maa")
    end
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
