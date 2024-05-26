class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/0db6000aaac250824266ac37451f43ce272d80a3.tar.gz"
  version "2024.3.13"
  sha256 "ac0bf5059f0339003e3e6e50c87e9455be508761e101e8898135f67b8a7c8115"
  license "Apache-2.0"
  revision 3

  livecheck do
    skip "This formula is not tagged, so there is no version to check"
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2024.3.13_2"
    sha256 arm64_sonoma: "13db488b2af912d0b66bcded53ccc09450872aa3631fa78b2df95feec3cff432"
    sha256 ventura:      "6bbaf751506a86e70c9c89ad985def4ac1b99791b7c21bb76dbf2e122e3cff59"
    sha256 monterey:     "91e29be827804762a05377051671346b47020d72a178120e84f9293e25622da0"
    sha256 x86_64_linux: "224307698e908cebf523fd60dbc3fed2d6cd0bf8bde7830413324d927914964e"
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
