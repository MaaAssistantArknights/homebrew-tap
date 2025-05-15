class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.16.5.tar.gz"
  sha256 "f509dd9fb534840d56965591ee75a17d5b7497ab9baaf7f0df694d9540f1dfe3"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-5.16.5"
    sha256 cellar: :any,                 arm64_sequoia: "238bf0e5a33e26680e1316b07fa27373d400c1cfdf6c35a77c463ff6646f60f7"
    sha256 cellar: :any,                 arm64_sonoma:  "295169ceb4ac4da2d1537ba571ec892a7eabdb360533bb8b1f26621f3eac880a"
    sha256 cellar: :any,                 ventura:       "79748f947a1043d8675202f154d76715c54e10a87f565481ce29ba5675659c72"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6541c5014bd72da6b1c782535e3b026a8f7d9077bd37d8a8536e8136cf2e7a31"
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

  conflicts_with "maa-core-beta", { because: "both provide libMaaCore" }

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
 index 59846c7d5..c2222214b 100644
 --- a/CMakeLists.txt
 +++ b/CMakeLists.txt
 @@ -81,7 +81,7 @@ if (BUILD_TEST)
      target_link_libraries(test MaaCore)
  endif (BUILD_TEST)

  -find_package(OpenCV REQUIRED COMPONENTS core imgproc imgcodecs videoio)
  +find_package(OpenCV REQUIRED COMPONENTS core imgproc imgcodecs videoio features2d)
  +find_package(OpenCV QUIET COMPONENTS xfeatures2d)
  find_package(ZLIB REQUIRED)
  find_package(cpr CONFIG REQUIRED)
