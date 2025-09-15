class MaaCoreBeta < Formula
  desc "Maa Arknights assistant Library (beta)"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.25.0-beta.4.tar.gz"
  sha256 "8c895656ab1a030743c66cbe559a7ba1ced9f7b21d6d819202b95b9f394b7e5f"
  license "AGPL-3.0-only"

  livecheck do
    url :stable
    regex(/^v?(\d+\.\d+\.\d+(?:-(?:beta|rc)\.\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-beta-5.24.2"
    sha256 cellar: :any,                 arm64_sequoia: "0ba2c160b072d623f3a5c0f9944a61323e3925fc3d099d471a33d96a9aee9067"
    sha256 cellar: :any,                 arm64_sonoma:  "b46ffb9451c3d778433995b83ce5ead33a78a2f91953d11c94a1043d3ae7a83b"
    sha256 cellar: :any,                 ventura:       "d7c984c56de86a2ed8b696aa7faca0bd8eea6a49679e6e5d337dd712ed8265c7"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "49a09bdab3444d4f7907b60da4008d79520844951c080a706aa935de34987bc6"
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
