class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.3.1.tar.gz"
  sha256 "e98bb51d163adfd7e54a325b46a9b30bd3019d15d1d4b9cc02726617213c0921"
  license "AGPL-3.0-only"
  revision 1

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-5.3.1"
    sha256 arm64_sonoma: "44a20277b8b9e1d728c0a52f3c88bf9338f33c8b03740ca27b3e0cbd5c784de7"
    sha256 ventura:      "dc5f08c7f3288421c46be9fb43c6c8dd7fd1ac34c7413d5f12a701004d8449fb"
    sha256 x86_64_linux: "15ce59944c7847fd13e020ca6319ef7287cd16190ef595f2b9e8aa2bf46250c9"
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

  # Apple clang < 15.0.0 does not fully support std::ranges
  on_ventura :or_older do
    depends_on "range-v3" => :build
  end

  conflicts_with "maa-core-beta", { because: "both provide libMaaCore" }

  fails_with gcc: "11"

  # Force find onnxruntime in CONFIG mode
  patch :DATA

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

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 240a7b212..81748becb 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -91,7 +91,7 @@ if(USE_MAADEPS)
     find_package(MaaDerpLearning REQUIRED)
     list(APPEND maa_libs MaaDerpLearning)
 else()
-    find_package(onnxruntime REQUIRED) # provided by onnxruntime>=1.16
+    find_package(onnxruntime CONFIG REQUIRED) # provided by onnxruntime>=1.16
     list(APPEND maa_libs onnxruntime::onnxruntime)
     if(DEFINED fastdeploy_SOURCE_DIR)
         # TODO: FetchContent github.com/MaaAssistantArknights/FastDeploy
