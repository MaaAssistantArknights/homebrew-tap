class MaaCore < Formula
  desc "Maa Arknights assistant Library"
  homepage "https://github.com/MaaAssistantArknights/MaaAssistantArknights/"
  url "https://github.com/MaaAssistantArknights/MaaAssistantArknights/archive/refs/tags/v5.3.0.tar.gz"
  sha256 "b5ebd040619b7d0efa8463183bcbb672b1b13a6e52e103370f4ba79973aec0a7"
  license "AGPL-3.0-only"

  livecheck do
    url :url
    regex(/^v?(\d+\.\d+\.\d+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/maa-core-5.3.0"
    sha256 arm64_sonoma: "ce7425faae7ef59b0a8475eeb6537f6c8cd2b0dbc7f8d05d375e57bc7c554c64"
    sha256 ventura:      "9c3b9f9dc4bef9987f9115bc5576cb9b92d6905ac21391369fff1025bc592eeb"
    sha256 x86_64_linux: "3b12f98d393208bdd185a0fba31984b2f0656c3f78f4da10105bbda2fb896a0e"
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
  depends_on "opencv" => :optional

  uses_from_macos "curl"

  # Apple clang < 15.0.0 does not fully support std::ranges
  on_ventura :or_older do
    depends_on "range-v3" => :build
  end

  conflicts_with "maa-core-beta", { because: "both provide libMaaCore" }

  fails_with gcc: "11"

  resource "fastdeploy_ppocr" do
    url "https://github.com/MaaAssistantArknights/FastDeploy/archive/0db6000aaac250824266ac37451f43ce272d80a3.tar.gz"
    sha256 "ac0bf5059f0339003e3e6e50c87e9455be508761e101e8898135f67b8a7c8115"
  end

  unless build.with? "opencv"
    depends_on "jpeg-turbo"
    depends_on "libpng"
    depends_on "libtiff"

    resource "opencv" do
      url "https://github.com/opencv/opencv/archive/refs/tags/4.9.0.tar.gz"
      sha256 "ddf76f9dffd322c7c3cb1f721d0887f62d747b82059342213138dc190f28bc6c"
    end
  end

  # Force find onnxruntime in CONFIG mode
  patch :DATA

  def install
    maacore_cmake_args = %W[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
      -DUSE_MAADEPS=OFF
      -DINSTALL_PYTHON=OFF
      -DINSTALL_RESOURCE=OFF
      -DINSTALL_FLATTEN=OFF
      -DWITH_EMULATOR_EXTRAS=OFF
      -DMAA_VERSION=v#{version}
    ]

    maacore_cmake_args << "-DUSE_RANGE_V3=ON" if OS.mac? && MacOS.version <= :ventura

    unless build.with? "opencv"
      resource("opencv").stage "opencv"

      # Remove bundled libraries to make sure formula dependencies are used
      libdirs = %w[ffmpeg libjasper libjpeg libjpeg-turbo libpng libtiff libwebp openexr openjpeg zlib]
      libdirs.each { |l| (buildpath/"opencv/3rdparty"/l).rmtree }

      # basic cmake args for opencv
      opencv_cmake_args = %W[
        -DCMAKE_CXX_STANDARD=17

        -DBUILD_SHARED_LIBS=OFF

        -DBUILD_LIST=core,imgproc,imgcodecs,videoio

        -DBUILD_ZLIB=OFF

        -DWITH_PNG=ON
        -DBUILD_PNG=OFF
        -DWITH_JPEG=ON
        -DBUILD_JPEG=OFF
        -DWITH_TIFF=ON
        -DBUILD_TIFF=OFF

        -DWITH_WEBP=OFF
        -DBUILD_WEBP=OFF
        -DWITH_OPENJPEG=OFF
        -DBUILD_OPENJPEG=OFF
        -DWITH_JASPER=OFF
        -DBUILD_JASPER=OFF
        -DWITH_OPENEXR=OFF
        -DBUILD_OPENEXR=OFF

        -DWITH_FFMPEG=#{OS.linux? ? "ON" : "OFF"}
        -DWITH_V4L=OFF
        -DWITH_GSTREAMER=OFF
        -DWITH_DSHOW=OFF
        -DWITH_1394=OFF
        -DWITH_CUDA=OFF
      ]

      opencv_buildpath = buildpath/"build/opencv"
      system "cmake", "-S", "opencv", "-B", opencv_buildpath,
        *opencv_cmake_args, *std_cmake_args
      # Remove reference to shims directory
      inreplace opencv_buildpath/"modules/core/version_string.inc", "#{Superenv.shims_path}/", ""
      system "cmake", "--build", opencv_buildpath
      maacore_cmake_args << "-DOpenCV_DIR=#{opencv_buildpath}"
    end

    system "cmake", "-S", ".", "-B", "build", *maacore_cmake_args, *std_cmake_args
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
