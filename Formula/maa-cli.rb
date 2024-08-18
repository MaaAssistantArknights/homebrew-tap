class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.11.tar.gz"
  sha256 "9844ef0baf29ca61e7688cc3dcad4ccb8c6644d11b743a3a5f2191c231d874a9"
  license "AGPL-3.0-only"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.11"
    sha256 cellar: :any,                 arm64_sonoma: "5f39b2ac7c2204adccb7c140e45ca435041273ff2659c4c75838ce3b9fa18fd9"
    sha256 cellar: :any,                 ventura:      "faa584e5868784ae9a947ceda192f4a845a5996b0eb8336104e9c04969f98795"
    sha256 cellar: :any,                 monterey:     "a81b255cdfa49d32ce03f2ec46e5d4c775073bbc674a1e50820c8cb37ba9305b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "88b9e939c31941b02568a0acd242626970b0a22c5e3ec0667c131cc83818241f"
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
