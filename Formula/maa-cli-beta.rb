class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.0-beta.5.tar.gz"
  sha256 "83b49ec7b47dd729c8eaabd3231233ccb885060f032793f7d948d57fafc3c9fe"
  license "AGPL-3.0-or-later"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.0-beta.4"
    sha256 cellar: :any,                 ventura:      "09e406447a4f7030c040305da006e08f958cad96cb61d9f33048cefc0364e26f"
    sha256 cellar: :any,                 monterey:     "0fbe1f530b3be8674ad3d10b979ab0beb188d99820e90685f864ef9eb31fbc09"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "ede7d097f565a8fd5c17de5db02f388d28ebe5c3155d49ff804eb0227e041aa8"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl" if OS.linux? || build.with?("git2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"

    # patch version
    inreplace "maa-cli/Cargo.toml" do |s|
      s.sub!(/(version\s*=\s*)"[^"]+"/, "version = \"#{version}\"")
    end
    inreplace "Cargo.lock" do |s|
      s.sub!(/name\s*=\s*"maa-cli"\s*\n\s*version\s*=\s*"[^"]+"/,
        "name = \"maa-cli\"\nversion = \"#{version}\"")
    end

    features = []
    features += ["git2"] if build.with? "git2"
    features += ["core_installer"] if build.with? "core-installer"

    system "cargo", "install", "--no-default-features",
      "--features", features.join(","), *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/share/fish/vendor_completions.d/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
