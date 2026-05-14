class Tla2toolsNojava < Formula
  desc "TLA+ command-line tools without Homebrew-managed Java"
  homepage "https://github.com/tlaplus/tlaplus"
  url "https://github.com/tlaplus/tlaplus/releases/download/v1.7.4/tla2tools.jar"
  sha256 "936a262061c914694dfd669a543be24573c45d5aa0ff20a8b96b23d01e050e88"
  license "MIT"

  def write_java_class_script(target, jar, main_class, zero_help: false)
    help_block = if zero_help
      <<~EOS
        if [[ "$#" -eq 1 && ( "$1" == "-help" || "$1" == "--help" || "$1" == "-h" ) ]]; then
          "$JAVA" -cp "#{jar}" #{main_class} -help || true
          exit 0
        fi
      EOS
    else
      ""
    end

    target.write <<~EOS
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

      #{help_block.chomp}
      exec "$JAVA" -cp "#{jar}" #{main_class} "$@"
    EOS
    chmod 0555, target
  end

  def install
    jar = libexec/"tla2tools.jar"
    libexec.install "tla2tools.jar"

    write_java_class_script bin/"tlc", jar, "tlc2.TLC", zero_help: true
    write_java_class_script bin/"tla2tools", jar, "tlc2.TLC", zero_help: true
    write_java_class_script bin/"tla2sany", jar, "tla2sany.SANY"
    write_java_class_script bin/"pcal", jar, "pcal.trans"
    write_java_class_script bin/"tla2tex", jar, "tla2tex.TLA"
  end

  def caveats
    <<~EOS
      This formula intentionally does not depend on Homebrew openjdk.
      It uses Java from JAVA_HOME, then ~/.asdf/shims/java, then PATH.
      Ensure Java 11+ is available before running tlc or the other TLA+ tools.
    EOS
  end

  test do
    output = shell_output("#{bin}/tlc -help 2>&1")
    assert_match "TLC", output
  end
end
