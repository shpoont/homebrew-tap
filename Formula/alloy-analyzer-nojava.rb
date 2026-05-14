class AlloyAnalyzerNojava < Formula
  desc "Alloy Analyzer without Homebrew-managed Java"
  homepage "https://alloytools.org"
  url "https://search.maven.org/remotecontent?filepath=org/alloytools/org.alloytools.alloy.dist/6.2.0/org.alloytools.alloy.dist-6.2.0.jar"
  sha256 "6037cbeee0e8423c1c468447ed10f5fcf2f2743a2ffc39cb1c81f2905c0fdb9d"
  license "Apache-2.0"

  conflicts_with "alloy-analyzer", because: "both install an alloy executable"
  conflicts_with "grafana-alloy", because: "both install an alloy executable"

  def install
    jar = libexec/"alloy.jar"
    libexec.install "org.alloytools.alloy.dist-#{version}.jar" => "alloy.jar"

    (bin/"alloy").write <<~EOS
      #!/bin/bash
      set -e

      JAVA=""
      for JAVA_CANDIDATE in \
        "${JAVA_HOME:-}/bin/java" \
        "${HOME}/.asdf/shims/java" \
        "${HOME}"/.asdf/installs/java/*/bin/java \
        /Users/shpoont/.asdf/installs/java/*/bin/java \
        "$(command -v java || true)"
      do
        if [[ -x "${JAVA_CANDIDATE}" ]] && "${JAVA_CANDIDATE}" -version >/dev/null 2>&1; then
          JAVA="${JAVA_CANDIDATE}"
          break
        fi
      done

      if [[ -z "${JAVA}" ]]; then
        echo "Error: Java 11+ is required. Install/activate Java or set JAVA_HOME." >&2
        exit 127
      fi

      exec "$JAVA" -jar "#{jar}" "$@"
    EOS
    chmod 0555, bin/"alloy"
  end

  def caveats
    <<~EOS
      This formula intentionally does not depend on Homebrew openjdk.
      It uses Java from JAVA_HOME, then ~/.asdf/shims/java, then PATH.
      Ensure Java is available before running alloy.
    EOS
  end

  test do
    output = shell_output("#{bin}/alloy --help 2>&1")
    assert_match "Alloy command line", output
  end
end
