class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.9.tar.gz"
  sha256 "a1a822876283d97dca2eabba315ab0bc20b9e1886ede892c696f548bb8e524e6"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.8_2"
    sha256 cellar: :any,                 arm64_sonoma: "a901520dec6c8964d8ab02064e338836ccee59bb7b295552615c484ae86c0644"
    sha256 cellar: :any,                 ventura:      "3b9eb2d1f821e7191fa60afce6e0001f2831bb53b9fd34111b942292a78843f8"
    sha256 cellar: :any,                 monterey:     "78cb48832e60e8372862e1171a7c662b14bd26513049e474b27241aa747e8e79"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ca4477e05f3f311d34abacd7a6d39b2a6012278d90698170c30275a3f70d8114"
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

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
