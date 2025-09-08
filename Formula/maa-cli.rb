class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.8.tar.gz"
  sha256 "02248effb2569855ee6b157cfc009977e405d6a9da3a1ef3f502e5b92cb2dcb4"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.5.8"
    sha256 cellar: :any,                 arm64_sequoia: "6892dfe1df0367f7a960dbd86c8a82013b1eba25318bf629874a1eb8eb7a06b5"
    sha256 cellar: :any,                 arm64_sonoma:  "941142f071b437c426236f42ab5e018b9c238989758d3c9c13e6d8c3b6ea4372"
    sha256 cellar: :any,                 ventura:       "8e53f9d509d5bfdda4eb82a3740ce09d73807755e6e386f681b68432ae0789c7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "c29577a47d4d27d9dd61a30319a4949dab8b185188a93489eb80905704d5962b"
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

    package_path = "crates/maa-cli"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: package_path)
    fish_completion.install "#{package_path}/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
