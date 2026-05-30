class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.5.tar.gz"
  sha256 "3f288b98e783a4ff230982d5c235c179ccc97617b7da1fe61f6766412ea6badd"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.5"
    sha256 cellar: :any, arm64_tahoe:   "639d5e59f28610580d160d1a8751fa8761314914ebc873cfff43d8539b2a7627"
    sha256 cellar: :any, arm64_sequoia: "471dcc7638f0cad42a43fd109d8e66ffafab8a1c0b0a27ce1f98cca23d2d7863"
    sha256 cellar: :any, arm64_sonoma:  "2f045ea4f9414a83f0ca6783d16e2b07b62b7d58ba6eee4d395100ebc04a428c"
    sha256 cellar: :any, x86_64_linux:  "1ac0364c638a66df78a53480b2e4db18d9ea996c8d9dfa9b4067575d6450a459"
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
