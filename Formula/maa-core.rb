class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v4.28.3.tar.gz"
  sha256 "ced8d9df4a09a2da87d5f21dc5987fd2a0fcc084d030093cab6205ff9b410218"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-4.28.2"
    sha256 cellar: :any,                 ventura:      "eff825b92049ee450144a92c3abdd07fe201d0401d234289b690c69ef365899b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8b4b0da3eacfa8eeaca78f5f65088a1f4574b8e363d049e9149997aa0f4e3614"
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
