class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.8.tar.gz"
  sha256 "4d49965fd486579c0f1d3f5a79a0252d022d92261f56ecc48d239f14bba29cc1"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.8"
    sha256 cellar: :any, arm64_golden_gate: "90961f7030bf48fef6cbe44ddffab8e410bc46be4c6b8de02a46465b1c221dc4"
    sha256 cellar: :any, arm64_tahoe:       "a89412e2c952756f9f6be226f70993d7390244989e6920792562cda9e876f974"
    sha256 cellar: :any, arm64_sequoia:     "4c92e3e65cab83a9102ec1f42c553aed5e79dbe139fc0f5599b7034af28ade36"
    sha256 cellar: :any, arm64_linux:       "0b273f564cf097edaa1feac5f8388871f983d8968e94f4a9a592c04f8039dad4"
    sha256 cellar: :any, x86_64_linux:      "c83b88f84dc532e62c3bf40c9ac95975f92466ad0510900926f74ce78b508f66"
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
