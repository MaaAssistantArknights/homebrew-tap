class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.7.2.tar.gz"
  sha256 "052c8761bdfb918e2787127744286ece0df98fd8f8a1e6cabde1f5b9b347057c"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.7.1"
    sha256 cellar: :any,                 arm64_tahoe:   "4eabe1d96565dc0ace8db175a07cf84308b793fd0252b88452ecfc2de367f213"
    sha256 cellar: :any,                 arm64_sequoia: "c57cc70f7e4513c300bf9a3be8c7aaaf70c8dd2f3bdac8a98322027d09ef243b"
    sha256 cellar: :any,                 arm64_sonoma:  "3c6885e7ece6b6e3b3beadc635143b7a75255f7064ae7c93ca2ee7be84f939b4"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "096f4986d5e26dc1b002406cce9bde2c7fbfa1dd9c9a7650b5c3c480a91ab6d2"
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
