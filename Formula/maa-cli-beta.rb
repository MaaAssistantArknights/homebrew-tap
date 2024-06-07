class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.8-beta.2.tar.gz"
  sha256 "03928ea5a5424db8bd444f30544719d93dac63ca333c3d3488cc6ea54f3e17ed"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.8-beta.1"
    rebuild 1
    sha256 cellar: :any,                 arm64_sonoma: "5db08ad1e0c75a6eb04f31a231218aa8b307823733de435b3044379fe1e7986e"
    sha256 cellar: :any,                 ventura:      "59bf2f8383bc681941ba0d10555d7482caf485c90fcc34274de01a38962ebfd7"
    sha256 cellar: :any,                 monterey:     "2ea5e10e4a8094412e4ad61486cbdeadb4b4f369107fbd74b92c1f6b85bbad5a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c539409186f31acd0a8e4e41017eee5cb2f96870837dd5490befb5fd89b15003"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl" if OS.linux? || build.with?("git2")
  depends_on "libgit2" => :recommended
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
