class OpencvMaa < Formula
  desc "Minimal OpenCV build use by MAA"
  homepage "https://opencv.org/"
  url "https://github.com/opencv/opencv/archive/refs/tags/4.10.0.tar.gz"
  sha256 "b2171af5be6b26f7a06b1229948bbb2bdaa74fcf5cd097e0af6378fce50a6eb9"
  license "Apache-2.0"
  revision 2

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/opencv-maa-4.10.0_1"
    sha256 arm64_sonoma: "3bdafd8b170ee01d55564087ea70d60c9b4445fa2c5289a86242041a0c53105b"
    sha256 ventura:      "5b7ee96cb37d1709862f6338d54041f6eb0e71a45c168423eeafe4e9346b0f05"
    sha256 monterey:     "a9c6e2e9891138e9ef70f1077ec11504894da4894c874e4734c4c395916f0e30"
    sha256 x86_64_linux: "9c8e86ffc5d4e1e59eaebba39bce9f713632a13f4047f0dbb22cbac08dba1b67"
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
    libdirs.each { |l| rm_r(buildpath/"3rdparty"/l) }

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
