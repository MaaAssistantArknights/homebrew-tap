class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "7abd1b7f0be04240ac0934e23ee79e87b296c3a2f464b648ca07ee63599b2783"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.12"
    sha256 cellar: :any,                 arm64_sonoma: "c3675d79f1727b83e9f83e6f666ee4e50f843ca6a891644f000cf652994f4149"
    sha256 cellar: :any,                 ventura:      "09a2844ff6ceddf806e4e9192eb56a3ccc4f1ace39f26c441ae34d80caddb0e0"
    sha256 cellar: :any,                 monterey:     "60646c1fc4434902eb883231dea91dd9beea2e5dc9569fd5375238bfbcdaaa8d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "2b33a089a7b6cdd1dba14f9d73fa80581eeaff40adba2f9509e39df587aa1a4f"
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
