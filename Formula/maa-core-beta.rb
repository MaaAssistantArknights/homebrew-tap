class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.3.1.tar.gz"
  sha256 "e98bb51d163adfd7e54a325b46a9b30bd3019d15d1d4b9cc02726617213c0921"
  license "AGPL-3.0-only"
  revision 1

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-5.3.1_1"
    sha256 cellar: :any,                 arm64_sonoma: "58308a8cc23b014b7395b90345645ec8dac294d6d9dbd7d9bf2189f7e6c57031"
    sha256 cellar: :any,                 ventura:      "f73920a5d3bea1a8d1ead45f9740110d5280bdf83c81030b8fd65b4b99bacee5"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "eb12234c7730659c6937fb4b996487426c9c3426de04a15a397c9f2d0ba127b4"
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

  conflicts_with "maa-core", { because: "both provide libMaaCore" }

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

    if OS.linux?
      cmake_args += %W[
        -DZLIB_LIBRARY=#{Formula["zlib"].opt_lib}/libz.so
      ]
    end

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
