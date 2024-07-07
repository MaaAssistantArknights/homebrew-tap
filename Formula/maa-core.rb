class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.4.0.tar.gz"
  sha256 "3adfda5c5342f020f5340fec83bac123f6ee29dfc0239185441a9d0dfe66233d"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-5.3.1_3"
    sha256 cellar: :any,                 arm64_sonoma: "579b065752d17bb7a35ba433de433c62e05a746d3482df9e4945d42f0075382f"
    sha256 cellar: :any,                 ventura:      "6d3ab33306ef90bb186cdba0cb26ba77f36bda54b63720954502ae0d7cb9fff8"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "7521c124b21a1b5d30a91acd6101bf726e0ecdf6162174a8282c16bd6cfb1375"
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
