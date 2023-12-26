class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v4.28.4.tar.gz"
  sha256 "83e6aca832645241861a4000e6fe24c482e4e996fca8d25c7aee6146b49ac1d3"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-4.28.4"
    sha256 cellar: :any,                 ventura:      "33155c9e7681c6f19554b8ef6b40f704895ba82600e0ec98785bcf863a9d6248"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8dc6ae8d396fca29befa17b83d6d9949e01027a91d90b5cf5f45576ef3436b10"
  end

  option "with-resource", "Install resource files"

  depends_on "asio" => :build
  depends_on "cmake" => :build
  depends_on "range-v3" => :build

  depends_on "cpr"
  depends_on "fastdeploy_ppocr"
  depends_on macos: :ventura # upstream only compiles on macOS 13
  depends_on "onnxruntime"
  depends_on "opencv"

  uses_from_macos "curl"

  conflicts_with "maa-core-beta", { because: "both provide libMaaCore" }

  fails_with gcc: "11"

  def install
    # patch CMakeLists.txt
    inreplace "CMakeLists.txt" do |s|
      s.gsub! "RUNTIME\sDESTINATION\s.", " "
      s.gsub! "LIBRARY\sDESTINATION\s.", " "
      s.gsub! "PUBLIC_HEADER\sDESTINATION\s.", " "
      s.gsub! "find_package(asio ", "# find_package(asio "
      s.gsub! "asio::asio", ""
      s.gsub! "MaaDerpLearning", "fastdeploy_ppocr"
      s.gsub! "install(DIRECTORY resource DESTINATION .)", "install(DIRECTORY resource DESTINATION ./share/maa)"
    end

    # patch ONNXRuntime
    # The ONNXRuntime header files are installed to $HOMEBREW_PREFIX/include/onnxruntime
    onnxruntime_related_files = %w[
      cmake/FindONNXRuntime.cmake
      src/MaaCore/Config/OnnxSessions.h
      src/MaaCore/Vision/Battle/BattlefieldDetector.cpp
      src/MaaCore/Vision/Battle/BattlefieldClassifier.cpp
    ]
    inreplace onnxruntime_related_files, "onnxruntime/core/session", "onnxruntime"

    cmake_args = %W[
      -DUSE_MAADEPS=OFF
      -DINSTALL_PYTHON=OFF
      -DINSTALL_RESOURCE=#{build.with?("resource") ? "ON" : "OFF"}
      -DINSTALL_THIRD_LIBS=OFF
      -DMAA_VERSION=v#{version}
    ]
    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end
end
