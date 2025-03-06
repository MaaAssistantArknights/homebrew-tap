class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.4.tar.gz"
  sha256 "279687300627929a92e1791ccb9fb79a66b9f9554f1d872020a442fbde3898e3"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.4"
    sha256 cellar: :any,                 arm64_sequoia: "a05252a881e4a584fb2f841bb84932d7b49a99c55b21dcdef0a4900e0401d2ea"
    sha256 cellar: :any,                 arm64_sonoma:  "3b644f23f93638a9da728fbbd3f0a71ee6d7ca24e481e68aa1417b9878943f4f"
    sha256 cellar: :any,                 ventura:       "5f74e0045aab79fca89672003cc59df342bd8af51c89c8235ee596b5931a3109"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fb4da3f1d59e44d8b7a2b93263c464e2805d5c8089c454820d5a4acf1df606ee"
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
    fish_completion.install "#{package_path}/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
