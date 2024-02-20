class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.1.0.tar.gz"
  sha256 "388a3f81dbd4f4623f0e51e800e6492fd35f4321389c9003443810f719c24d18"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-5.1.0"
    sha256 cellar: :any,                 ventura:      "d5ef0bcab2b06097009bef759704671fdc783a5e84d84c0eadcb7d0866831dff"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "f03514d4a14b1e8a7c5bc13372fd94a9dc9727a10696a675f7c41771ba0ea8dd"
  end

  option "with-resource", "Install resource files" if OS.linux?
  option "without-resource", "Don't install resource files" if OS.mac?

  depends_on "asio" => :build
  depends_on "cmake" => :build
  depends_on "eigen" => :build
  depends_on "range-v3" => :build

  depends_on "cpr"
  depends_on macos: :ventura # upstream only compiles on macOS 13
  depends_on "onnxruntime"
  depends_on "opencv"

  uses_from_macos "curl"

  conflicts_with "maa-core-beta", { because: "both provide libMaaCore" }

  fails_with gcc: "11"

  resource "fastdeploy_ppocr" do
    url "https://github.com/MaaAssistantArknights/FastDeploy/archive/d0b018ac6c3daa22c7b55b555dc927a5c734d430.tar.gz"
    sha256 "4a74b0f90178384124a97324e86edd4aa0fed44ac280e23cf3454513b14e0a6a"
  end

  def install
    # patch CMakeLists.txt
    inreplace "CMakeLists.txt" do |s|
      s.gsub! "RUNTIME\sDESTINATION\s.", ""
      s.gsub! "LIBRARY\sDESTINATION\s.", ""
      s.gsub! "PUBLIC_HEADER\sDESTINATION\s.", ""
      s.gsub! "find_package(asio ", "# find_package(asio "
      s.gsub! "asio::asio", ""
      s.gsub! "find_package(MaaDerpLearning ", "# find_package(MaaDerpLearning "
      s.gsub! "MaaDerpLearning", "fastdeploy_ppocr"
      s.gsub!(/^(list\(APPEND CMAKE_MODULE_PATH.*)\n/, <<~EOS
        \\1

        add_subdirectory( ${SOURCE_DIR_FASTDEPLOY} ${BINARY_DIR_FASTDEPLOY} EXCLUDE_FROM_ALL SYSTEM)
        include_directories(SYSTEM ${SOURCE_DIR_FASTDEPLOY})
        install(TARGETS fastdeploy_ppocr)
        message(${CMAKE_CURRENT_LIST_FILE})
      EOS
      )
    end

    # patch ONNXRuntime
    # The ONNXRuntime header files are installed to $HOMEBREW_PREFIX/include/onnxruntime
    # The ONNXRuntime should be all lowercase for fastdeploy_ppocr
    inreplace "CMakeLists.txt", "ONNXRuntime", "onnxruntime"
    inreplace "cmake/FindONNXRuntime.cmake" do |s|
      s.gsub! "find_path(ONNXRuntime_INCLUDE_DIR NAMES onnxruntime/core/session/onnxruntime_c_api.h)",
        "find_path(onnxruntime_INCLUDE_DIR NAMES onnxruntime_c_api.h PATH_SUFFIXES onnxruntime)"
      s.gsub! "ONNXRuntime", "onnxruntime"
    end
    onnxruntime_related_files = %w[
      src/MaaCore/Config/OnnxSessions.h
      src/MaaCore/Vision/Battle/BattlefieldDetector.cpp
      src/MaaCore/Vision/Battle/BattlefieldClassifier.cpp
    ]
    inreplace onnxruntime_related_files, "onnxruntime/core/session", "onnxruntime"

    (buildpath/"fastdeploy_ppocr").install resource("fastdeploy_ppocr")

    cmake_args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
      -DUSE_MAADEPS=OFF
      -DINSTALL_PYTHON=OFF
      -DINSTALL_RESOURCE=OFF
      -DSOURCE_DIR_FASTDEPLOY=#{buildpath/"fastdeploy_ppocr"}
      -DBINARY_DIR_FASTDEPLOY=#{buildpath/"build-fastdeploy_ppocr"}
      -DMAA_VERSION=v#{version}
    ]

    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (share/"maa").install "resource" if build.with? "resource"
  end
end
