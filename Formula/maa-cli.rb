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
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.6"
    sha256 cellar: :any, arm64_golden_gate: "d8d3a2582858d218ac5b8e4e6398db7ae0d921dce711ad08d4abe332912f2ef1"
    sha256 cellar: :any, arm64_tahoe:       "612394a42f8192e463b8715bab58a51ba683f9f0aec20a097ea372755e024053"
    sha256 cellar: :any, arm64_sequoia:     "9f0d0d7259e771c70cd834bc74f4fe1db1a755418790aff4d18a5598c120857b"
    sha256 cellar: :any, arm64_linux:       "48b570663a74f76ad245544a438283fe31cc6452372b5194fc98d005a35c414f"
    sha256 cellar: :any, x86_64_linux:      "2bba29b88ffdb24f56bc881e36eae809e12268d2b40c35064e09abbef98fc12f"
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
