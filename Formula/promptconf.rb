class Promptconf < Formula
  desc "Configurable powerline prompt for zsh"
  homepage "https://github.com/gleete/promptconf"
  url "https://github.com/gleete/promptconf/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "f7de54e85821fe3531d0edf7a334b052638e1f50fcc616ce8c48a6165e8f127a"
  license "MIT"
  head "https://github.com/gleete/promptconf.git", branch: "main"

  def install
    pkgshare.install "promptconf.zsh"
  end

  def caveats
    <<~EOS
      Add to your ~/.zshrc:

        source #{opt_pkgshare}/promptconf.zsh

      Then run `promptconf wizard`.

      Using oh-my-zsh? Set ZSH_THEME="" and source promptconf after
      oh-my-zsh.sh, so nothing else competes for PROMPT.
    EOS
  end

  test do
    system "zsh", "-n", pkgshare/"promptconf.zsh"
    output = shell_output("zsh -fc 'source #{pkgshare}/promptconf.zsh; print -r -- $PROMPTCONF_SCHEME'")
    assert_equal "agnoster", output.strip
  end
end
