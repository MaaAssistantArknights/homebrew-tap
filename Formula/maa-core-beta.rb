class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.16.6.tar.gz"
  sha256 "103363a07f66e54609fa1e8dabc168fa1ed806935184fcf9774bfc1e3339c4cf"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-5.16.5"
    sha256 cellar: :any,                 arm64_sequoia: "620c25affb1252f751e417c2caa4be09ae4c8d0f730b6b45b93878d18b4bfdeb"
    sha256 cellar: :any,                 arm64_sonoma:  "1e9ed3a8d06315ebe152d772044f73cd2fd50e10b354737e0570291e54b991ec"
    sha256 cellar: :any,                 ventura:       "449813290334a2048a998eff4609752d9ccfb4c61d26f890079d6f35d6261e40"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "31f0c5f5f8f44a870f45752ca982166bc367023eb05d4bfa2badda63935ec223"
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
      # Force building with llvm clang
      cmake_args << "-DCMAKE_C_COMPILER=#{Formula["llvm"].opt_bin}/clang"
      cmake_args << "-DCMAKE_CXX_COMPILER=#{Formula["llvm"].opt_bin}/clang++"
      # Force using llvm libc++
      ENV.append "LDFLAGS", "-L#{Formula["llvm"].opt_prefix}/lib/c++"
    end

    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    (share/"maa").install "resource" if build.with? "resource"
  end
end

__END__
diff --git a/CMakeLists.txt b/CMakeLists.txt
index 59846c7d5..e18c027c9 100644
--- a/CMakeLists.txt
+++ b/CMakeLists.txt
@@ -81,7 +81,7 @@ if (BUILD_TEST)
     target_link_libraries(test MaaCore)
 endif (BUILD_TEST)

-find_package(OpenCV REQUIRED COMPONENTS core imgproc imgcodecs videoio)
+find_package(OpenCV REQUIRED COMPONENTS core imgproc imgcodecs videoio features2d xfeatures2d)
 find_package(ZLIB REQUIRED)
 find_package(cpr CONFIG REQUIRED)
