class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.2.tar.gz"
  sha256 "67e6d3005aba5cea67ca328096e25fc67e5bbc4ec74b368ffb92876f119726dd"
  license "AGPL-3.0-or-later"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.2"
    sha256 cellar: :any,                 ventura:      "0c2c06b6728cd3882563acc5f587fb48f9e7351986b700c55882689771f95fca"
    sha256 cellar: :any,                 monterey:     "bc20399a024c17dba90084c92555bb9fb4d038010e7cc8de029faf2e1f4fc5fd"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e5b3714b0a279e929662dc6add0f7096d78a56598754f3d3f59e568866883bdb"
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
    fish_completion.install "maa-cli/completions/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
