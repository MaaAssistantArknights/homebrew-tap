class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.6.0-beta.1.tar.gz"
  sha256 "c5713197390d0c3394a550e4885570c99a0768d0df106618760fa3d78c2a1f60"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-5.6.0-beta.1"
    sha256 cellar: :any,                 arm64_sonoma: "b08d3588ce73200974b9c6963dc744798915e8cdf143af7fecadf56f1646b6e5"
    sha256 cellar: :any,                 ventura:      "6c645e4dbaf1bbec4f145cc35186635f40d05ea1fbdc43e74c1efcef8b7f51aa"
    sha256 cellar: :any,                 monterey:     "6755b65bddeab12f397b6437e2afc6f8db690d93e92ff86febc525c8af0d230e"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "8fecd3387cc47d55f290d83f840280177bdba5adbb6a3093921b3cb9981e9a9e"
  end

  option "with-resource", "Install resource files" if OS.linux?
  option "without-resource", "Don't install resource files" if OS.mac?

  depends_on "asio" => :build
  depends_on "cmake" => :build

  depends_on "cpr"
  depends_on "fastdeploy_ppocr"
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

  on_ventura :or_older do
    depends_on "llvm"
  end

  conflicts_with "maa-core", { because: "both provide libMaaCore" }

  fails_with gcc: "11"

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

    if OS.mac? && MacOS.version <= :ventura
      # Force building with llvm clang on ventura or older
      cmake_args << "-DCMAKE_C_COMPILER=#{Formula["llvm"].opt_bin}/clang"
      cmake_args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm"].opt_bin}/clang++"
      # Force link to libc++ of llvm
      cmake_args << "-DLIBCXX_PATH=#{Formula["llvm"].opt_prefix}/lib/c++"
    end

    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (share/"maa").install "resource" if build.with? "resource"
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 47d60c60e..608f98db0 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -53,6 +53,14 @@ else ()
     endif ()
 endif ()

+# When building with llvm clang, we need to link to libc++ of llvm explicitly
+# References:
+# https://github.com/Homebrew/homebrew-core/issues/169820
+# https://github.com/llvm/llvm-project/issues/77653
+if (DEFINED LIBCXX_PATH)
+    target_link_options(MaaCore PRIVATE "-L${LIBCXX_PATH}")
+endif ()
+
 if (WIN32)
     #注意：相比VS版本缺少了 -D_CONSOLE -D_WINDLL 两项
     target_compile_definitions(MaaCore PRIVATE ASST_DLL_EXPORTS _UNICODE UNICODE)
