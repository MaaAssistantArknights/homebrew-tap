class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.5.0.tar.gz"
  sha256 "a639ec8c6da9fb8e45bef516f3f9a51a8a71bf529a16f8bf237792b1f07cface"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-5.5.0-beta.2"
    sha256 cellar: :any,                 arm64_sonoma: "e661727db54f60f7a4ee72abf84219addba4eaef5d0ca7cb273686de5f272d2e"
    sha256 cellar: :any,                 ventura:      "16c9b77ab9cc083a536e1618e6702d5ceae06dde85d7ca3a329f13e4f866d3e8"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "008489fe8c65cf3665b3c085c52abe7f4c5e59f221c15af06822e357e1816d04"
  end

  option "with-resource", "Install resource files" if OS.linux?
  option "without-resource", "Don't install resource files" if OS.mac?

  depends_on "asio" => :build
  depends_on "cmake" => :build

  depends_on "cpr"
  depends_on "fastdeploy_ppocr"
  depends_on macos: :ventura # upstream only compiles on macOS 13
  depends_on "onnxruntime"

  # opencv is a very large dependency, and we only need a small part of it
  # so we build our own opencv if user does not want to install opencv by homebrew
  if build.with? "opencv"
    depends_on "opencv"
  else
    depends_on "opencv-maa"
  end

  uses_from_macos "curl"
  uses_from_macos "zlib"

  # Apple clang < 15.0.0 does not fully support std::ranges
  on_ventura :or_older do
    depends_on "range-v3" => :build
  end

  conflicts_with "maa-core", { because: "both provide libMaaCore" }

  fails_with gcc: "11"

  def install
    cmake_args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
      -DUSE_MAADEPS=OFF
      -DINSTALL_PYTHON=OFF
      -DINSTALL_RESOURCE=OFF
      -DINSTALL_FLATTEN=OFF
      -DWITH_EMULATOR_EXTRAS=OFF
      -DMAA_VERSION=v#{version}
    ]

    cmake_args << "-DUSE_RANGE_V3=ON" if OS.mac? && MacOS.version <= :ventura

    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (share/"maa").install "resource" if build.with? "resource"
  end
end
