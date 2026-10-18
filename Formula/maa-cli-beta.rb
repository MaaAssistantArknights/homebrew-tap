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
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.6"
    sha256 cellar: :any, arm64_golden_gate: "55610ceb536a51aa6cc5b55910858b735a0014e72498e70990201ae1ed67b294"
    sha256 cellar: :any, arm64_tahoe:       "124aac1ce1c7c6161817bf6c994e388721d98929af0ab0e013e670f675a4d6cf"
    sha256 cellar: :any, arm64_sequoia:     "688b25fb2d0c0e3798102c5a79bd861a82d89130bed0284c53b178275e3325cb"
    sha256 cellar: :any, arm64_linux:       "24306d3a0423b2dcb9949c89d5ff8f6c4efb3c1bcb02f9fe1b933484aaacdce2"
    sha256 cellar: :any, x86_64_linux:      "9fe923d2a97b76880a6fd0df2083293b1cb8fbfcb74e969ac232d3a9b530d7ce"
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
