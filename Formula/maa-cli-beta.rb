class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.3.tar.gz"
  sha256 "f781c5935283b7728591851be6d8b90552f85192042ab305752a903eb1ec20f1"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.7.2"
    sha256 cellar: :any,                 arm64_tahoe:   "23d7242f8c1364f72356ae1f399e79da9aefdc405feae317c83402b9b4c687d2"
    sha256 cellar: :any,                 arm64_sequoia: "6d409ada21e6798f92a6baac463f73b11b0b6e26eeb04df072f94bea5ea44ab1"
    sha256 cellar: :any,                 arm64_sonoma:  "4a1dffab38813bd4c41e9cfdbd81429eedab56f918d8fd82a174e30f6864fcee"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "018bcae8028ff80cfe7b808cd8a188534647960b066f7317df5852090f87d1d5"
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
