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
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2024.5.30_3"
    sha256 cellar: :any,                 arm64_sequoia: "70510d2948461b6009dabbbe1f76c84bc64efa1da26a2445162b2e60ef2c7e0e"
    sha256 cellar: :any,                 arm64_sonoma:  "081a48de3c0d9495e31be338a52c000ea37c5b57853d32d6f6a2f424d08ee91f"
    sha256 cellar: :any,                 ventura:       "d03b0875b474e8afc5c1c9d149d447261578302e7388a0c12a418a1490903b58"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "6cac94a9f189b7f1240567fc4e944bccd716141aeeda7d6d4168ab2e15e6a0f8"
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
