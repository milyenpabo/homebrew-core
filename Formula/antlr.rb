class Antlr < Formula
  desc "ANother Tool for Language Recognition"
  homepage "https://www.antlr.org/"
  url "https://www.antlr.org/download/antlr-4.10.1-complete.jar"
  sha256 "41949d41f20d31d5b8277187735dd755108df52b38db6c865108d3382040f918"
  license "BSD-3-Clause"

  livecheck do
    url "https://www.antlr.org/download.html"
    regex(/href=.*?antlr[._-]v?(\d+(?:\.\d+)+)-complete\.jar/i)
  end

  bottle do
    sha256 cellar: :any_skip_relocation, all: "3022c791eae0f662f7973526d756ed73123bc863e7901729062f08600507a10e"
  end

  depends_on "openjdk"

  def install
    prefix.install "antlr-#{version}-complete.jar"

    (bin/"antlr").write <<~EOS
      #!/bin/bash
      CLASSPATH="#{prefix}/antlr-#{version}-complete.jar:." exec "#{Formula["openjdk"].opt_bin}/java" -jar #{prefix}/antlr-#{version}-complete.jar "$@"
    EOS

    (bin/"grun").write <<~EOS
      #!/bin/bash
      exec "#{Formula["openjdk"].opt_bin}/java" -classpath #{prefix}/antlr-#{version}-complete.jar:. org.antlr.v4.gui.TestRig "$@"
    EOS
  end

  test do
    path = testpath/"Expr.g4"
    path.write <<~EOS
      grammar Expr;
      prog:\t(expr NEWLINE)* ;
      expr:\texpr ('*'|'/') expr
          |\texpr ('+'|'-') expr
          |\tINT
          |\t'(' expr ')'
          ;
      NEWLINE :\t[\\r\\n]+ ;
      INT     :\t[0-9]+ ;
    EOS
    ENV.prepend "CLASSPATH", "#{prefix}/antlr-#{version}-complete.jar", ":"
    ENV.prepend "CLASSPATH", ".", ":"
    system "#{bin}/antlr", "Expr.g4"
    system "#{Formula["openjdk"].bin}/javac", *Dir["Expr*.java"]
    assert_match(/^$/, pipe_output("#{bin}/grun Expr prog", "22+20\n"))
  end
end
