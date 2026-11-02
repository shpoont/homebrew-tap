class KrakenCli < Formula
  desc "AI-native CLI for the Kraken exchange"
  homepage "https://github.com/krakenfx/kraken-cli"
  license "MIT"
  revision 1

  if OS.mac? && Hardware::CPU.arm?
    url "https://github.com/krakenfx/kraken-cli/releases/download/v0.5.1/kraken-cli-aarch64-apple-darwin.tar.gz"
    sha256 "b999d2a161e6ab44a63d39c051bfb43cb4f4955ebdc2e5cd9571480c8a27f9f3"
  end

  if OS.mac? && Hardware::CPU.intel?
    url "https://github.com/krakenfx/kraken-cli/releases/download/v0.5.1/kraken-cli-x86_64-apple-darwin.tar.gz"
    sha256 "72cab500b25432506973818b5b16d400280bc937603e3080a24b5b4c7635594e"
  end

  if OS.linux? && Hardware::CPU.arm? && Hardware::CPU.is_64_bit?
    url "https://github.com/krakenfx/kraken-cli/releases/download/v0.5.1/kraken-cli-aarch64-unknown-linux-gnu.tar.gz"
    sha256 "6faa83a6f78b096b3a429094fec78d102fcb1dfdd1fc0358755c463a2ec9a215"
  end

  if OS.linux? && Hardware::CPU.intel?
    url "https://github.com/krakenfx/kraken-cli/releases/download/v0.5.1/kraken-cli-x86_64-unknown-linux-gnu.tar.gz"
    sha256 "a5110521449d74d3d334acb42ffee3b5a7b50112ec845159c1f4a63335148263"
  end

  def install
    bin.install "kraken", "kraken-mcp", "kraken-shell"
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kraken --version")
    assert_match version.to_s, shell_output("#{bin}/kraken-mcp --version")
    assert_match version.to_s, shell_output("#{bin}/kraken-shell --version")
  end
end
