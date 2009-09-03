class Deploy < Thor::Group
  desc "Updates repo at andre.arko.net and runs the generate task on the server"

  # everything squeezed into one method so it only sshes once
  def run_deploy
    $stdout.sync = true
    system %{ssh arko "cd /home/arko.net/domains/andre.arko.net/web && git clean -f && git pull && thor generate"}
  end
end

class Generate < Thor::Group
  desc "Runs jekyll and symlinks year directories into arko.net"

  # everything squeezed into one method so it only sshes once
  def run_generate
    $stdout.sync = true
    pubdir = "/home/arko.net/domains/andre.arko.net/web/public/"
    Dir.chdir(pubdir)
    Dir["*/"].each do |d|
      o = pubdir + d.chop
      n = "/home/arko.net/web/public/#{d.chop}"
      puts "#{o} → #{n}"
      system %{ln -f -s #{o} #{n}}
    end
  end
end
