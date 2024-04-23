class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.7.tar.gz"
  sha256 "5337e0fba937eca0de616cd3405fdc29018bf9eedd644374fa793429fe3e609d"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.7"
    sha256 cellar: :any,                 arm64_sonoma: "156bd6399538f0c333cf174534b08b2dee8365de326e1ad08499bf9aea9e69cd"
    sha256 cellar: :any,                 ventura:      "2abb302ce984e1178dde40dff00fac0038a1080fb10ed32e1745eb0e6c6c3768"
    sha256 cellar: :any,                 monterey:     "8c437ae84e609af085a38ba5fc1c39f672abd0c42d83128bc62615bb819f71fa"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "76bc0735fba839a3b8af2578ad5f8eb566ea603de828907687a3defce3dae999"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl" if OS.linux? || build.with?("git2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli-beta", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"

    features = []
    features += ["git2"] if build.with? "git2"
    features += ["core_installer"] if build.with? "core-installer"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
