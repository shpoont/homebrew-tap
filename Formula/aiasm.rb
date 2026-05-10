class Aiasm < Formula
  desc "Terminal-first session manager for Codex sessions"
  homepage "https://github.com/shpoont/aiasm"
  url "ssh://git@github.com/shpoont/aiasm.git",
      tag:      "v0.1.0",
      revision: "be75a4bb4705036b216aa5fd3b0fa79fac850b35"

  head "ssh://git@github.com/shpoont/aiasm.git", branch: "main"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/aiasm-0.1.0"
    sha256 cellar: :any_skip_relocation, arm64_tahoe: "37a83fb089bc9563421d91795e5e1db6bf525d637142cd9b0244bf713f95726e"
    sha256 cellar: :any_skip_relocation, sequoia:     "7f2eea9339c5e820c17072c24bb48c1f2fbe1ff6a58a5355d3b38b7edbe848d8"
  end

  depends_on "go" => :build
  depends_on "tmux"

  def install
    system "go", "build", *std_go_args(ldflags: "-s -w -X aiasm/internal/version.Version=#{version}"), "./cmd/aiasm"
  end

  def caveats
    <<~EOS
      AIASM expects the Codex CLI to already be installed and authenticated.
      The upstream repository is private; source and --HEAD installs require
      GitHub credentials that can clone ssh://git@github.com/shpoont/aiasm.git.
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aiasm --version")
  end
end
