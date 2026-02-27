class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.1.tar.gz"
  sha256 "ce7d4d76ae9f850c9e44fe76c74c10302d0519ebbbf4803ad02466ab72cae2f9"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.1"
    sha256 cellar: :any,                 arm64_tahoe:   "e42bdb7f35ae88bc013528efff53e78db42ad18f5fd49349bcd81c52408690f4"
    sha256 cellar: :any,                 arm64_sequoia: "cc20a3aa09038d19b387c976e58f6614f71528a925af7de87549f827e0534041"
    sha256 cellar: :any,                 arm64_sonoma:  "a0c72439f30cf90b152d508c4a8b54402114bdf11da941549848a4eac6ff67b2"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "8a6b0caec83949e3d88547b2a86974da6a665e7909aad049b75e2053596eb21e"
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
