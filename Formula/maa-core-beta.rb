class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v4.26.0-beta.2.tar.gz"
  sha256 "9d6234dd7aadad0ee23d40bf0f1f8bb82eb34403c83008d25f79e9c8d2208c82"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  option "with-resource", "Install resource files"

  depends_on "asio" => :build
  depends_on "cmake" => :build
  depends_on "range-v3" => :build

  depends_on "cpr"
  depends_on "fastdeploy_ppocr"
  depends_on "onnxruntime"
  depends_on "opencv"
  depends_on "zlib"

  conflicts_with "maa-core", { because: "both provide libMaaCore" }

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
