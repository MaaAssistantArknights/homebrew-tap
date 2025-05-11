class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.5.tar.gz"
  sha256 "dab57ee5051c2a65c773e8acf05326e89d1e9d8c0591586a397c4078a2583f7d"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.5"
    sha256 cellar: :any,                 arm64_sequoia: "4f3fba81ea6a3a17f28a9fa606f9b54573bc65d74a853cbfeb721ba0a136cfc7"
    sha256 cellar: :any,                 arm64_sonoma:  "d2698e4ec7d9167e65275fb233eecc1354d04fb40e6c91ec83e6d6cea04ebc28"
    sha256 cellar: :any,                 ventura:       "e148bc7a70422c18f3ff03f64f335edd4baac08430a737a01404d2c4e7c8c75e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "fecc0d771043165806216eb44215ff241e06cb9b6c524c5ea16d2b0112fd273c"
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
