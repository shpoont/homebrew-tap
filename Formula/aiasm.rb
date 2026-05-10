class Aiasm < Formula
  desc "Terminal-first session manager for Codex sessions"
  homepage "https://github.com/shpoont/aiasm"
  head "ssh://git@github.com/shpoont/aiasm.git", branch: "main"

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
