class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.2.0-rc.2.tar.gz"
  sha256 "3fbb849c3ad4c178c030c8b845ae6856a2ed23a7926d9614b2c126f4539a85d3"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.2.0-rc.2"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "a979e1e52ae40a4a9324fe22d8c9f874f204ca7ace2a4fd07b0dd335cbb54c78"
    sha256 cellar: :any_skip_relocation, sequoia:      "5631320c700fcfee293019e1ff43482f847eae555d79bd6830ad572b90816664"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "d205057b74ee61c1fdf2d371482bce300e9ed0a964f62ea43c3da164859331fb"
  end

  BUILD_COMMIT = "cdfba1b7d35384f0c91bd4460bc96cb049e71fcd"
  BUILD_DATE = "2026-06-16T16:23:58Z"
  BUILD_CHANNEL = "prerelease"
  BUILD_PROVENANCE = "homebrew-source"

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
