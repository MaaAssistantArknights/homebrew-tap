class MaaCliBeta < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.5.4-beta.2.tar.gz"
  sha256 "e2dbd1607801e1fb780320b1acb7a61721e4c62f6dea1902d8927221a655c4fb"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-beta-0.5.4-beta.2"
    sha256 cellar: :any,                 arm64_sequoia: "240c36f5ed50fe3b3dcee9897358c3b7df5a6ec2d98050a2bbc12e75150c7343"
    sha256 cellar: :any,                 arm64_sonoma:  "73997329a64916119467e157f3d686ecfde444d9f3cf537bc0e1de61dbb0e477"
    sha256 cellar: :any,                 ventura:       "a6ba975c7fda8ee14153c630b671b61f3c13e517d080de9e86ff68e572e7e4ab"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "943383ad870feb0cc06c26e7e8158bbc2ca2dc7cb6e64990ff8a9994b14703b4"
  end

  option "without-git2", "Don't build with libgit2 resource updater backend"
  option "without-core-installer", "Don't build with core installer"

  depends_on "rust" => :build

  # openssl is always required on Linux
  # while it's only required on macOS when building with git2
  depends_on "openssl@3" if OS.linux? || build.with?("git2")
  uses_from_macos "zlib"

  conflicts_with "maa-cli", { because: "both provide maa" }

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
