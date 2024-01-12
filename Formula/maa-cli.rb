class MaaCli < Formula
  desc "Command-line tool for MAA (MaaAssistantArknights)"
  homepage "https://github.com/MaaAssistantArknights/maa-cli/"
  url "https://github.com/MaaAssistantArknights/maa-cli/archive/refs/tags/v0.4.0.tar.gz"
  sha256 "f6c06542c76db7f0d3cc9e051d1438d896076f6389e0584c2b4f45715d75447b"
  license "AGPL-3.0-or-later"

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-cli-0.3.12"
    rebuild 2
    sha256 cellar: :any_skip_relocation, ventura:      "512ce1412ec4ba8f1ffb87a4f9e88998100ecf7e37ce22073673ed3e5bd42dcf"
    sha256 cellar: :any_skip_relocation, monterey:     "346084c75b8e0ade17a2f79df57e12dbc7c63a5e73dcf7b20298eac8e65009f8"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "91f133c630dfe4cf598d61596947eb155db9f4553e51cfc068bab46b5df66a05"
  end

  depends_on "rust" => :build

  conflicts_with "maa-cli-beta", { because: "both provide maa" }

  def install
    ENV["CARGO_PROFILE_RELEASE_CODEGEN_UNITS"] = "1"
    ENV["CARGO_PROFILE_RELEASE_LTO"] = "true"
    ENV["CARGO_PROFILE_RELEASE_STRIP"] = "true"
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "maa-cli")
    fish_completion.install "maa-cli/share/fish/vendor_completions.d/maa.fish"
  end

  test do
    assert_match "maa #{version}", shell_output("#{bin}/maa --version")
  end
end
