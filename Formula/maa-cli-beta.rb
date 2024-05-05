class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.8-beta.1.tar.gz"
  sha256 "a0ff4d2f95146e78106e36952a5a4a62c7664e6a572a7bea1648d1bf36f7ecac"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.8-beta.1"
    sha256 cellar: :any,                 arm64_sonoma: "555b87e30a788ea2794cc2eb99ad4a6bcfc561dd4cefb2a5307f60c2c5c0b280"
    sha256 cellar: :any,                 ventura:      "5068b237088a6e04c8b0205db47af3f7c490304d71df840da9746ac33e060a0e"
    sha256 cellar: :any,                 monterey:     "951ba31c6f7540c67a85fd3f1ecb64365d8b23ab268aaa71a655e4f8a6b4ce3e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "69130425feba7048d4c7b93230532debb30232cf45e09b29775d0bb4e51507be"
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
