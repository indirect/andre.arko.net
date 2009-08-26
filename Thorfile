class Deploy < Thor::Group
  desc "Updates repo at andre.arko.net and runs jekyll"

  # everything squeezed into one method so it only sshes once
  def run_deploy
    $stdout.sync = true
    system %{ssh arko "cd /home/arko.net/domains/andre.arko.net/web && git clean -f && git pull && jekyll"}
  end
end
