class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.9-beta.1.tar.gz"
  sha256 "8240790d4e4a1019b28b78206308a09673c1dd1b7b5097c63363cc2c0dc9a116"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.9-beta.1"
    sha256 cellar: :any,                 arm64_sonoma: "2c10a4026ab2b84eb688426b0ea95a243167b9631803c954c43dbed5a5bc4973"
    sha256 cellar: :any,                 ventura:      "744cb947de303831b8fcc336a22235c0bf237e89e9eb0e7022249c256e79a764"
    sha256 cellar: :any,                 monterey:     "06d6e4252350fd356470a8dc02b329f20c02e65482fd22a81c48f2040bfc7db4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "205130eeaaf5aa529a474a293459211751b05de4d40ce937461e630a2f6f2200"
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

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
