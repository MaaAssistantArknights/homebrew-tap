class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.6.tar.gz"
  sha256 "8d7660d0d9bf0b1d8b7e48987ad48edd820a07c2da38a752b294c1f938a11450"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.4.6-beta.2"
    sha256 cellar: :any,                 arm64_sonoma: "847970cc59bcfc2a0cacb95eb081d117125bd9c56043a732bed267f112695b81"
    sha256 cellar: :any,                 ventura:      "2bcbc39095aa94761d7250e70e6e8e1f089372427664e711e70ea56f6b38471a"
    sha256 cellar: :any,                 monterey:     "3f9f05545fcdbc633230d4cd9a750d2db1658438fb538cd50dcff1df9e131d9d"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7e26576e472d2ab05081ca6c685fed371fc1fce1a66754dc3df051bbda025cb4"
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
