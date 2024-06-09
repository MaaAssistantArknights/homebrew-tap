class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.4.0-beta.1.tar.gz"
  sha256 "d431c70a7907c1b265681552ed2225e1da8a7700d88a6b1b53bb807c9132e6bc"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-5.4.0-beta.1"
    sha256 cellar: :any,                 arm64_sonoma: "07693e4a077fd4a28f47789ea02f35e88cc9ad23e99c30bb5234a6dcb57181f7"
    sha256 cellar: :any,                 ventura:      "c888a81f29ced1a7e2b2301a7237525071d9613b772645f04877446a355d9db2"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "492d341835399636d0a64dd6a6d839cfb7afce0e2c604fdd717ab8bfec1ff7e4"
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
