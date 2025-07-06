class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.6.tar.gz"
  sha256 "d1457417e5ff088c087547d9db9a2bac01ba53205e54cfabec4ea34e76a66bad"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.6"
    sha256 cellar: :any,                 arm64_sequoia: "1737015ed3267c0ba661f6d5ac407e3516382a20e30f3397c83bf132581fad86"
    sha256 cellar: :any,                 arm64_sonoma:  "859ab3477c0ce8275ec881ec2f890e07e3016654b4b3619d7f67fa187e2cfd8a"
    sha256 cellar: :any,                 ventura:       "22f3a836cd9cb018cd6741e014b6886007bff5d65e080e8fe6df55ed09a3260c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "7918d77579d85ca52076315abd131a3090f334f1ae150f3feeb9698eb3f00188"
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
