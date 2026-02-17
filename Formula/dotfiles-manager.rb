class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.6.tar.gz"
  sha256 "70b92922b6d39d54ade74528d61bbef84bfece6cf7cfd560d540bb60707311d8"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.6"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "0fb9799d27b77c37988c7e738417a197bb9a6ee3a94658f8444e9770acc2b5c6"
    sha256 cellar: :any_skip_relocation, sequoia:      "69d8e3b3c1a442a93be4d263028ee7e8763f7a80739894134ba338c44b21cd5a"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e11d9227bade93c8f50d27f59c47a2ba089b3b1ba7bc6263d38e574188523020"
  end

  depends_on "go" => :build

  def install
    ldflags = "-s -w -X github.com/shpoont/dotfiles-manager/internal/app.buildVersion=#{version}"
    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/dotfiles-manager"
  end

  test do
    (testpath/".dotfiles-manager.yaml").write <<~YAML
      syncs:
        - target: .config/nvim
          source: .config/nvim
    YAML

    output = shell_output("#{bin}/dotfiles-manager --config #{testpath}/.dotfiles-manager.yaml status --json")
    assert_match "\"ok\":true", output
    assert_equal "dotfiles-manager version #{version}", shell_output("#{bin}/dotfiles-manager --version").strip
  end
end
