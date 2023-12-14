class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v4.28.0.tar.gz"
  sha256 "295b888174da3a14a4bc09378f92e969dfdd161835603ae66b42aed6535be23c"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-4.28.0"
    sha256 cellar: :any,                 ventura:      "797f89848eb221eef605bfdb6a7bea672b927caf95540a49e514066765cad801"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "36da83a995f8b971addf1f8c735dbcfc0a394cc3a0c43c541de840b4b09049aa"
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
  depends_on "zlib"

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
