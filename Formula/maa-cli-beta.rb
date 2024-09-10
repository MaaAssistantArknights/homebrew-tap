class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.0-beta.1.tar.gz"
  sha256 "38fc94d13eab66881311ae313a75063804417e59c1ed33331f297cc99a65e8fd"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.0-beta.1"
    sha256 cellar: :any,                 arm64_sonoma: "f6addca9e9159f78b9cac8d85591e0fe2e344b65ba709006bae5f16a8deb28ba"
    sha256 cellar: :any,                 ventura:      "633d4fcc2436a3d42b487b5b1ec277a70c372b2dd95a7a0181458c9fa1886bc1"
    sha256 cellar: :any,                 monterey:     "9ce15b0bf90b283fad98eccd9e53101d8df634a289937fc2711b2e51ef93f88e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "39722c6439a0341a4d1fd9b7e05f693009012272e57db896f4e38759614f16e3"
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
