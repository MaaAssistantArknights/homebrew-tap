class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.4.tar.gz"
  sha256 "01ce14f3c6c8a5ed60ccfbf4f76f7a20ba4df21c5f6f358c7b9fd0d391223636"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.4"
    sha256 cellar: :any,                 arm64_sonoma: "a7a42413d69537e55988c0ff6d6d894000805191d91991aff48780ef0686283a"
    sha256 cellar: :any,                 ventura:      "9dedbb882facb0c37d260b809ddf44d4ecbe28491a5bf87019746239c1f6f782"
    sha256 cellar: :any,                 monterey:     "6d3e2a03f5ceb3bd0300767d9faab3e6ec1970c912cc5c48f58eb28d8b3151ed"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "b1d4fb1c7005609c35e4126b79faaeb10e7dd0f1230d6c74446cbc2128592cb0"
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
