class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.4.tar.gz"
  sha256 "279687300627929a92e1791ccb9fb79a66b9f9554f1d872020a442fbde3898e3"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.4"
    sha256 cellar: :any,                 arm64_sequoia: "bea1ce7810d1bd4d894f16eb522aff27ef04524fa0c4531314d283b0439337b1"
    sha256 cellar: :any,                 arm64_sonoma:  "36d4af8699444a5d43203a7af2840b51cc6b87dc2740728d56c2bf9324928b59"
    sha256 cellar: :any,                 ventura:       "2a2ab4997b564b950b44b23e8937d188e029bcd1686fb50002b539151106dfaa"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "460f9ce7cc495619997859d8a9976f677a7937dfec316c23f5498e2d9b49f1c7"
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
    fish_completion.install "#{package_path}/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
