class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.5.tar.gz"
  sha256 "3f288b98e783a4ff230982d5c235c179ccc97617b7da1fe61f6766412ea6badd"
  license "AGPL-3.0-only"
  revision 1


  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.5"
    sha256 cellar: :any, arm64_tahoe:   "974f7f9a2e2ef949dee6bacb85c1b77d2306f66f7473a9cf4b9e14432551a615"
    sha256 cellar: :any, arm64_sequoia: "3fa01e966bd32acaa4fa24055997ca34d5375efc3a2a536c8cc18a2daa18b5b1"
    sha256 cellar: :any, arm64_sonoma:  "bf3668286eb5cafb843e333ab814989ce2910c3d5a891bfa943698b08cd047f8"
    sha256 cellar: :any, x86_64_linux:  "5a9e9d592f704be7352e3542a9fc32ce5bef4d04667393b524acd3a663cacce4"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl@3" if OS.linux? || build.with?("git2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli", { because: "both provide maa" }

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
