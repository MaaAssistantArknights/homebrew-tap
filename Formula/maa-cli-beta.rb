class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.6.0-beta.1.tar.gz"
  sha256 "bd4fd206a89a2162652699dc1087d7d8b379a38d9b5482f33d26d3163d749c08"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.6.0-beta.1"
    sha256 cellar: :any,                 arm64_tahoe:   "4b779aa08c67253e678f9f15f5bd88392ab0845ca82777916f9b3ba0e6260492"
    sha256 cellar: :any,                 arm64_sequoia: "5efde360c5c3bf1a6e78e9903327b54081ac69d93803052757557099f0431e2a"
    sha256 cellar: :any,                 arm64_sonoma:  "7071473162564037bbd61fcc95863f9c9eb158aa09c9202fe7997dbe07e3e7c5"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "faf447a9465f85eb5318df56d25a0ca4d79d825f4049b8860914055b2d22e6cb"
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
