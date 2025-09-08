class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.8.tar.gz"
  sha256 "02248effb2569855ee6b157cfc009977e405d6a9da3a1ef3f502e5b92cb2dcb4"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.7"
    sha256 cellar: :any,                 arm64_sequoia: "4bb6bcd77c5957e694e6f03a48a72dde0fcd4f3babeaf6a17c88977bcaa7feba"
    sha256 cellar: :any,                 arm64_sonoma:  "7d631d02938a42b34217b07d5715d9307ed31251923e447007d6026bca554e04"
    sha256 cellar: :any,                 ventura:       "27d9330a20de54a469b6b582166d2555061c94dda82174427b7661ec692026e8"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "4c22e9d297c54b534c5b8bf63a78a73a2d187f3d123c25639ce10d897f608b48"
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
