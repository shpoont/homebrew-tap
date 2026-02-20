class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.9.tar.gz"
  sha256 "347c1e39fd4ed591733c6ea20c6d6842c98d5d17539a83e0f6627d4931bae1b7"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.9"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "8336730bc945bb0cbf6597f5e893914e435e446487077d4e9101f9837939a829"
    sha256 cellar: :any_skip_relocation, sequoia:      "6b0195b436f47d4beb9559898cb7eaf44e57f87ff57428d59347fa01e288ce4b"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "6028dd54988618ce911e94649b3e35a39838d561cc6051fb0238116363eba8d5"
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
