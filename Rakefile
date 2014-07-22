require 'date'

desc "push to the git repo, generate the site, and rsync it up"
task :deploy do
  $stdout.sync = true
  Bundler.with_clean_env do
    sh %{git pull --rebase} || abort("Pull failed, please resolve.")
    sh %{git push} || abort("Push failed, please resolve.")
  end
  sh %{jekyll build} || abort("Build failed, please resolve.")
  sh %{rsync -avz --delete-after -essh public/ arko:/home/arko.net/domains/andre.arko.net/web/public/}
end

desc "create a new post"
task :post, [:title] do |task, args|
  title = [args.title, *args.extras].compact.join(", ")
  abort("Usage: rake post['post title']") if title.empty?
  date = Date.today.strftime('%Y-%m-%d')
  name = title.gsub(/ /, '-').gsub(/[^\w-]/,'').downcase
  filename = File.join("_posts", "#{date}-#{name}.md")
  puts filename
  File.open(filename, "w") do |f|
    f.puts "---"
    f.puts "title: \"#{title}\""
    f.puts "layout: post"
    f.puts "---"
    f.puts
  end
  case ENV["EDITOR"]
  when /vim?/
    system "#{ENV["EDITOR"]} +5 #{Shellwords.escape(filename)}"
  when /mate/
    system "#{ENV["EDITOR"]} -l 5 #{Shellwords.escape(filename)}"
  end
end

desc "launch the preview server"
task :serve do
  sh %{jekyll serve -w}
end

task :default => :deploy
