class FastdeployPpocr < Formula
  desc "Stripped-down version of PaddlePaddle/FastDeploy"
  homepage "https://github.com/MaaAssistantArknights/FastDeploy"
  url "https://github.com/MaaAssistantArknights/FastDeploy/archive/2896b6d3641c18218209c496ea149a773373fa8b.tar.gz"
  version "2024.5.30"
  sha256 "5ee3dbad183b56ebf42569497c58a646d069a92fef54afce108d1e3422bb03f9"
  license "Apache-2.0"
  revision 1

  livecheck do
    skip "This formula is not tagged, so there is no version to check"
  end

  bottle do
    root_url "https://github.com/MaaAssistantArknights/homebrew-tap/releases/download/fastdeploy_ppocr-2024.5.30_1"
    sha256 cellar: :any,                 arm64_sequoia: "ca519100e0e4f703db74244b03cd5d246a3336066bf7ae46217ecf325f8ebb99"
    sha256 cellar: :any,                 arm64_sonoma:  "4e7c7eddd21e887eb0c249de0edb872131dd6909c076f6b4d73ac97b244c9964"
    sha256 cellar: :any,                 ventura:       "e1449f168adc183b3c0b1c540a9fb1fda8bcf1cc824b3d8ae056782a9eb8137b"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "5465189517c0fcee48cb48711c8c3f04ab951bf9182e053be0e81c84d8453490"
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
