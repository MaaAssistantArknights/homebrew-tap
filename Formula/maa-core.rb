class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.16.3.tar.gz"
  sha256 "c7ab1c28cf43388aeb67c73982b895cd5e2b8c0430f8d421f5d02598259edeb9"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-5.16.2"
    sha256 cellar: :any,                 arm64_sequoia: "1548f5a0262e01047d1c827643eff171956197712ba9dde5b3252fc6d85873e7"
    sha256 cellar: :any,                 arm64_sonoma:  "a32c3734e738e017287a641c1279353c819c297458899dab1a6b98025d6df984"
    sha256 cellar: :any,                 ventura:       "9e8f183805bc475d88b81762d6c6a76c25343f6c1f4ab0f548834bae3eeb306e"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "d2f46c9c5daf6f03faac415730c15b84d7dacc4692f5d4223ca9e0dcfc052e60"
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
