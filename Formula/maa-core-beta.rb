class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.5.0-beta.1.tar.gz"
  sha256 "cf3aa8c204608f667cd4acb5afdf662c375e482102e4de13fbbd2d5bb9433e89"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-5.5.0-beta.1"
    sha256 cellar: :any,                 arm64_sonoma: "085b9b857a66fae5e6bf9cda54fa309648cf66ca3efb3b721d5bc746ad8f16c3"
    sha256 cellar: :any,                 ventura:      "d002687dda39175126642efb8a90658c820f07bff897a1a2af8fdd989376d2d8"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "830ced0525ab9dc4584211ea571cf1c2f3132b3baa6a214c9cadfd4b52b625fd"
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
