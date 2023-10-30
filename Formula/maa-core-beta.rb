class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v4.26.0-beta.3.tar.gz"
  sha256 "1c45e8e5fc4e089ec1ce5444f1c383aae4f2806e733d638bdc0ebc76d0b36f0c"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-4.26.0-beta.2"
    sha256 cellar: :any,                 ventura:      "4909880dee10d807ed1c10d9c10fa1d6131affd367690a4a45a0004a3abf44ae"
    sha256 cellar: :any,                 monterey:     "b2acbfdaba1e07579ec8d9e13c1cabaf38b0a9dfacee53553a3c1da1581ee1c4"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f7680b58cf280eac3b2b4133ab337e40c418fd350039c2b33655f1801ec86d98"
  end

  option "with-resource", "Install resource files"

  depends_on "asio" => :build
  depends_on "cmake" => :build
  depends_on "gcc" => :build if OS.linux?
  depends_on "range-v3" => :build

  depends_on "cpr"
  depends_on "fastdeploy_ppocr"
  depends_on "onnxruntime"
  depends_on "opencv"
  depends_on "zlib"

  uses_from_macos "curl"

  conflicts_with "maa-core", { because: "both provide libMaaCore" }

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
