class OpencvMaa < Formula
  desc "Minimal OpenCV build use by MAA"
  homepage "https://opencv.org/"
  url "https://github.com/opencv/opencv/archive/refs/tags/4.12.0.tar.gz"
  sha256 "44c106d5bb47efec04e531fd93008b3fcd1d27138985c5baf4eafac0e1ec9e9d"
  license "Apache-2.0"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+)$/i)
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/opencv-maa-4.11.0_1"
    sha256 arm64_sequoia: "ea12ef8f357a7780b0cae5eb66f98a6e0d3d4fd7c3dd8693a844498b90540a16"
    sha256 arm64_sonoma:  "f1309f0bcd6c3cc19f154c1f305a8e7facb640d472df0138fede7bcd5d433298"
    sha256 ventura:       "15cd603ab5317dc49315c99e1f07dd219dfd530f0b7cf4c57643909433e9e1b8"
    sha256 x86_64_linux:  "e6b129e0a5bd00c41954da3fe009f8e7e652ba5813d18136437ef9675209dccc"
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

  resource "contrib" do
    url "https://github.com/opencv/opencv_contrib/archive/refs/tags/4.12.0.tar.gz"
    sha256 "4197722b4c5ed42b476d42e29beb29a52b6b25c34ec7b4d589c3ae5145fee98e"

    livecheck do
      formula :parent
    end
  end

  def install
    resource("contrib").stage buildpath/"opencv_contrib"

    # Remove bundled libraries to make sure formula dependencies are used
    libdirs = %w[ffmpeg libjasper libjpeg libjpeg-turbo libpng libtiff libwebp openexr openjpeg protobuf tbb zlib]
    libdirs.each { |l| rm_r(buildpath/"3rdparty"/l) }

    cmake_args = %W[
      -DCMAKE_CXX_STANDARD=17

      -DBUILD_LIST=core,imgproc,imgcodecs,videoio,features2d,xfeatures2d

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

      -DBUILD_opencv_features2d=ON
      -DBUILD_opencv_xfeatures2d=ON

      -DOPENCV_ENABLE_NONFREE=ON
      -DOPENCV_EXTRA_MODULES_PATH=#{buildpath}/opencv_contrib/modules
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
