class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.7.tar.gz"
  sha256 "c1a0a6ff6fd83c2aa8a6c66cc6b6afe9d877c6eecb9004905172ae0741b698eb"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.7"
    sha256 cellar: :any, arm64_golden_gate: "1c438c359fba2c85235f4ba12681df98f4acb7c4dab98827bedfcb7860d41d3a"
    sha256 cellar: :any, arm64_tahoe:       "42b0f1dc81427f78cfdb39d0b98c6b5fad9c6b99f77f800bc798551b092359fc"
    sha256 cellar: :any, arm64_sequoia:     "8782f93d3e8bacd15b299f6cc9abf3569cf564a56b8788036ac72a050a329e08"
    sha256 cellar: :any, arm64_linux:       "ed4e9bcf080a2571bb55eb2fef7fc69e28e16a3f01c69ceaeae69c22c1babb5d"
    sha256 cellar: :any, x86_64_linux:      "ad5684db3d999b13b73ffdad45d01961f582a84ab9431b2c0cfec3dd80d3eb1a"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl@4" if OS.linux? || build.with?("git2")

  uses_from_macos "zlib"

  conflicts_with "maa-cli-beta", because: "both provide maa"

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
