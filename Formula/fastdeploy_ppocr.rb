class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/0db6000aaac250824266ac37451f43ce272d80a3.tar.gz"
  version "2024.3.13"
  sha256 "ac0bf5059f0339003e3e6e50c87e9455be508761e101e8898135f67b8a7c8115"
  license "Apache-2.0"
  revision 4

  livecheck do
    skip "This formula is not tagged, so there is no version to check"
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2024.3.13_3"
    sha256 cellar: :any,                 arm64_sonoma: "144198f09d5c0fa3f7ab2291ee78aeafa726358dbd27f7ec251f598b398829b8"
    sha256 cellar: :any,                 ventura:      "5310a87908556a2691f9eccf6e60061285d50b4225831307041712f6ad95c7c8"
    sha256 cellar: :any,                 monterey:     "c68268427ed8fc8bc3039c2b0a385617a66637a78a51230f96b1f4619656e6bf"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "547dd1440a3902d56e5fb2b851004378973798a9be1991b36593162382f2ddbf"
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
