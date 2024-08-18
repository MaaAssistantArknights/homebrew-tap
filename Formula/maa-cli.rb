class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.11.tar.gz"
  sha256 "9844ef0baf29ca61e7688cc3dcad4ccb8c6644d11b743a3a5f2191c231d874a9"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.10"
    sha256 cellar: :any,                 arm64_sonoma: "ad50eeb1032593a4b92aedaf7a76ae40d05ec8ba55662a8100124822832cdaf2"
    sha256 cellar: :any,                 ventura:      "195d7f284d1ad124eec122ee933c5e0738733365e6a0508089312512e17afb37"
    sha256 cellar: :any,                 monterey:     "1224736ae48f35b73586c4ab75e6b196b89301ad70cabe28fadbe46ecf3efba4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b560cf7ae8d8bc10bb41f677eebcf41d92f069ee847dd4878a9f7e2ba49282d3"
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
