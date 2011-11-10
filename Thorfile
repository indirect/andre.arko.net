class Default < Thor

  desc "deploy", "push to the git repo, generate the site, and rsync it up"
  def deploy
    $stdout.sync = true
    system %{git push} || abort("Push failed, please resolve.")
    system %{jekyll} || abort("Build failed, please resolve.")
    system %{rsync -avz -essh public/ arko:/home/arko.net/domains/andre.arko.net/web/public/}
  end

  desc "symlink", "server command to symlink year directories into arko.net to maintain links to old post URLs and such"
  def symlink
    $stdout.sync = true
    system %{cd /home/arko.net/web && git clean -f}
    pubdir = "/home/arko.net/domains/andre.arko.net/web/public/"
    Dir.chdir(pubdir)
    Dir["*/"].each do |d|
      o = pubdir + d.chop
      n = "/home/arko.net/web/public/#{d.chop}"
      if File.exist?(n)
        puts "#{n} already linked"
        next
      end
      puts "#{o} → #{n}"
      system %{ln -f -s #{o} #{n}}
    end
  end

  desc "post TITLE [FORMAT]", "Create a new post"
  def post(title, format = nil)
    date = Date.today.strftime('%Y-%m-%d')
    name = title.gsub(/ /, '-').gsub(/[^\w-]/,'').downcase
    ext = (format || "md")
    filename = File.join("_posts", "#{date}-#{name}.#{ext}")
    File.open(filename, "w") do |f|
      f.puts "---"
      f.puts "title: #{title}"
      f.puts "layout: post"
      f.puts "---"
    end
    `mate -l 5 #{filename}`
  end

end
