class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "67e6d3005aba5cea67ca328096e25fc67e5bbc4ec74b368ffb92876f119726dd"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.4.1"
    sha256 cellar: :any,                 ventura:      "c7248ad094fcb1442bc94168590d5d1fefd748d624443f3a0bc208bad244ee7f"
    sha256 cellar: :any,                 monterey:     "edf943942f9adff0027ae4fe4156a9f5bfcc0a97c86ae0d28b87f87c9cf66890"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1fb481d46dbbdbb1bb72180028164683936fa5a525bc8486245a3450f02df026"
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
