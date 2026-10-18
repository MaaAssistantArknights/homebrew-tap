class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.7.tar.gz"
  sha256 "c1a0a6ff6fd83c2aa8a6c66cc6b6afe9d877c6eecb9004905172ae0741b698eb"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.7"
    sha256 cellar: :any, arm64_golden_gate: "9ee5f571e2ac4356701b76e90616f9da01d57c49e6203dc2931f5e2a9f487007"
    sha256 cellar: :any, arm64_tahoe:       "16a2dc7df27a4dceb3d296a32a5559c76b75a07466a5cd859b34c39a3faad5ed"
    sha256 cellar: :any, arm64_sequoia:     "e7fe14d86ca32ba2475a2c2d8612982c86ec16105daa68b9ecb56ae3465796f2"
    sha256 cellar: :any, arm64_linux:       "fde89798005fa7fd70f51a95d2ed0d6af8eab1a4ab032271d685bd66d3cd9eca"
    sha256 cellar: :any, x86_64_linux:      "7dbf0dcf5154ec68cce7d463c17f965895328e78bf06fc690e304d10636ac03c"
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
