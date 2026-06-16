class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.2.0-rc.1.tar.gz"
  sha256 "cb1cf3bf09ad807537c77c5d9582f4845cc9c3b341d5d2f9b7bf7a24ee51a979"

  BUILD_COMMIT = "cd127ba0969c07eba05916004547e0094303f9cb"
  BUILD_DATE = "2026-06-15T18:06:25Z"
  BUILD_CHANNEL = "prerelease"
  BUILD_PROVENANCE = "homebrew-source"
  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.2.0-rc.1"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "f0a78666973e2a943b192f1b0910e82cfe51d69ea7fd0c1a1c35ea9f39a730d1"
    sha256 cellar: :any_skip_relocation, sequoia:      "3c4a365d5c7e7d1dd98065b5bd92b51d804b416780f865a90e2d0b53fa677480"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6623294064381363d2b8a0b2c068417fd552c5324fba05e95f44dda52383ef81"
  end

  depends_on "go" => :build

  def install
    # Build static Go bottles so the executable does not depend on a
    # Homebrew-relocated dynamic loader path.
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/shpoont/dotfiles-manager/internal/app.buildVersion=#{version}
      -X github.com/shpoont/dotfiles-manager/internal/app.buildCommit=#{BUILD_COMMIT}
      -X github.com/shpoont/dotfiles-manager/internal/app.buildDate=#{BUILD_DATE}
      -X github.com/shpoont/dotfiles-manager/internal/app.buildChannel=#{BUILD_CHANNEL}
      -X github.com/shpoont/dotfiles-manager/internal/app.buildProvenance=#{BUILD_PROVENANCE}
    ].join(" ")
    system "go", "build", *std_go_args(ldflags: ldflags), "./cmd/dotfiles-manager"
  end

  test do
    (testpath/".dotfiles-manager.yaml").write <<~YAML
      syncs:
        - target: .config/nvim
          source: .config/nvim
    YAML

    output = shell_output("#{bin}/dotfiles-manager --config #{testpath}/.dotfiles-manager.yaml status --json")
    assert_match '"ok":true', output

    version_output = shell_output("#{bin}/dotfiles-manager --version").strip
    assert_match "dotfiles-manager version=#{version}", version_output
    assert_match "commit=#{BUILD_COMMIT}", version_output
    assert_match "date=#{BUILD_DATE}", version_output
    assert_match "channel=#{BUILD_CHANNEL}", version_output
    assert_match "provenance=#{BUILD_PROVENANCE}", version_output
    refute_match "version=dev", version_output
    refute_match "commit=unknown", version_output
    refute_match "date=unknown", version_output
    refute_match "channel=dev", version_output
    refute_match "provenance=unspecified", version_output
  end
end
