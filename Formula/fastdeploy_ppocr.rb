class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/2896b6d3641c18218209c496ea149a773373fa8b.tar.gz"
  version "2024.5.30"
  sha256 "5ee3dbad183b56ebf42569497c58a646d069a92fef54afce108d1e3422bb03f9"
  license "Apache-2.0"
  revision 3

  livecheck do
    skip "This formula is not tagged, so there is no version to check"
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2024.5.30_2"
    sha256 cellar: :any,                 arm64_sequoia: "256dd7f87299d72018585fce1ae7907dec50739b49c1170684ac075f46612638"
    sha256 cellar: :any,                 arm64_sonoma:  "ab74696a066d6fbcbd1fa0e279e1a8faca5acc0664dd589f5d73fbc5849faeea"
    sha256 cellar: :any,                 ventura:       "a0e693eac3e9d8d751b08d92833354b515db76f62644b4fa58327c27502f9e38"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6a608ccf5204dc03b5e123d912eb0c945affbab38706c72583eb3af5d353aea1"
  end

  depends_on "cmake" => :build
  depends_on "eigen" => :build

  depends_on "onnxruntime"

  # opencv is a very large dependency, and we only need a small part of it
  # so we build our own opencv if user does not want to install opencv by homebrew
  if build.with? "opencv"
    depends_on "opencv"
  else
    depends_on "opencv-maa"
  end

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
