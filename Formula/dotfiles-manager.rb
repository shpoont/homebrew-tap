class DotfilesManager < Formula
  desc "Config-driven dotfiles synchronization tool"
  homepage "https://github.com/shpoont/dotfiles-manager"
  url "https://github.com/shpoont/dotfiles-manager/archive/refs/tags/v0.1.10.tar.gz"
  sha256 "79e7ad8737fef3ed4870a2ecb876a158b98b1fd84e21671be0a0edc4d46d146d"

  bottle do
    root_url "https://github.com/shpoont/homebrew-tap/releases/download/dotfiles-manager-0.1.10"
    sha256 cellar: :any_skip_relocation, arm64_tahoe:  "c302cea0b50a7270dd41bd435d92b8dc7da45bd0b1080fe41e21e1626b2ce292"
    sha256 cellar: :any_skip_relocation, sequoia:      "bb286382c9d16ff4214238d48005f064c9e9080b4f13f8bad09877b2dacbf772"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "1ce16f8ac6a9053f1bc4ee30ee9009066f5920394dcbb486dcedef8b5386f2fb"
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
