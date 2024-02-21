class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/d0b018ac6c3daa22c7b55b555dc927a5c734d430.tar.gz"
  version "2023.10.29"
  sha256 "4a74b0f90178384124a97324e86edd4aa0fed44ac280e23cf3454513b14e0a6a"
  license "Apache-2.0"

  livecheck do
    skip "This formula is not tagged, so there is no version to check"
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2023.10.29"
    rebuild 1
    sha256 cellar: :any,                 arm64_sonoma: "84d4a2c5cfc949b762cec7d198e6416ac6af70eaf6ad03844ea666abb354c415"
    sha256 cellar: :any,                 ventura:      "97455f312bdf307cae914dcee13111630aa63f8f9ea81f6a632ee062019afab4"
    sha256 cellar: :any,                 monterey:     "76703381c890c0af952dc3566536b9ebf2be22c7c44ed4ea411d531103ae9592"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "c8c73b9e0ea12975bb53c0168f2dc407ed1373a6993573834a2d54914f1d75ac"
  end

  deprecate! date: "2024-02-20", because: "this formula is now shiped by MaaCore"

  depends_on "cmake" => :build
  depends_on "eigen" => :build

  depends_on "onnxruntime"
  depends_on "opencv"

  def install
    cmake_args = %w[
      -DBUILD_SHARED_LIBS=ON
      -DCMAKE_POSITION_INDEPENDENT_CODE=ON
    ]
    system "cmake", "-S", ".", "-B", "build", *cmake_args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"
  end
end
