class OpencvMaa < Formula
  desc "Minimal OpenCV build use by MAA"
  homepage "https://opencv.org/"
  url "https://github.com/opencv/opencv/archive/refs/tags/4.9.0.tar.gz"
  sha256 "ddf76f9dffd322c7c3cb1f721d0887f62d747b82059342213138dc190f28bc6c"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/opencv-maa-4.9.0"
    sha256 arm64_sonoma: "117cb390c7d2c1650883e87b73a90ae24f5f1d0a24b2b554f4a589d31a48ffb7"
    sha256 ventura:      "aceb7ea37240b05cebb9dc3147c3f5bedbbc9ce8fb0beeaa7c9110edeb357404"
    sha256 monterey:     "10335add8cfbea029220677d61f1f066ca2aa0e96cdff9a86f10b5621b2bf572"
    sha256 x86_64_linux: "af4e5e583d7056a813df3698058555114189595cf2dd60e11a2b73b393de41e5"
  end

  depends_on "cmake" => :build
  depends_on "eigen" => :build

  depends_on "jpeg-turbo"
  depends_on "libpng"

  uses_from_macos "zlib"

  on_linux do
    depends_on "ffmpeg@6"
    depends_on "openblas"
  end

  conflicts_with "opencv", { because: "this is a minimal build of OpenCV" }

  def install
    # Remove bundled libraries to make sure formula dependencies are used
    libdirs = %w[ffmpeg libjasper libjpeg libjpeg-turbo libpng libtiff libwebp openexr openjpeg protobuf tbb zlib]
    libdirs.each { |l| (buildpath/"3rdparty"/l).rmtree }

    cmake_args = %W[
      -DCMAKE_CXX_STANDARD=17

      -DBUILD_LIST=core,imgproc,imgcodecs,videoio

      -DBUILD_ZLIB=OFF

      -DWITH_EIGEN=ON

      -DWITH_PNG=ON
      -DBUILD_PNG=OFF
      -DWITH_JPEG=ON
      -DBUILD_JPEG=OFF
      -DWITH_TIFF=OFF
      -DWITH_WEBP=OFF
      -DWITH_OPENJPEG=OFF
      -DWITH_JASPER=OFF
      -DWITH_OPENEXR=OFF

      -DWITH_FFMPEG=#{OS.linux? ? "ON" : "OFF"}
      -DWITH_V4L=OFF
      -DWITH_GSTREAMER=OFF
      -DWITH_DSHOW=OFF
      -DWITH_1394=OFF

      -DWITH_CUDA=OFF

      -DWITH_PROTOBUF=OFF
      -DBUILD_opencv_python3=OFF
    ]

    # HACK: avoid opencv install data
    cmake_args << "-DOPENCV_OTHER_INSTALL_PATH=#{buildpath}/tmp"

    if OS.linux?
      cmake_args += %W[
        -DOpenBLAS_LIB=#{Formula["openblas"].opt_lib}/libopenblas.so
        -DPNG_LIBRARY=#{Formula["libpng"].opt_lib}/libpng.so
        -DJPEG_LIBRARY=#{Formula["jpeg-turbo"].opt_lib}/libjpeg.so
        -DZLIB_LIBRARY=#{Formula["zlib"].opt_lib}/libz.so
      ]
    end

    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    inreplace "build/modules/core/version_string.inc", "#{Superenv.shims_path}/", ""
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end

  test do
    (testpath/"test.cpp").write <<~EOS
      #include <opencv2/opencv.hpp>
      #include <iostream>
      int main() {
        std::cout << CV_VERSION << std::endl;
        return 0;
      }
    EOS
    system ENV.cxx, "-std=c++17", "test.cpp", "-I#{include}/opencv4", "-o", "test"
    assert_equal shell_output("./test").strip, version.to_s
  end
end
