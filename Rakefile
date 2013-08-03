require 'date'

desc "push to the git repo, generate the site, and rsync it up"
task :deploy do
  $stdout.sync = true
  sh %{which pygmentize} || abort("Can't find pgyments, please install it first.")
  sh %{git pull --rebase} || abort("Pull failed, please resolve.")
  sh %{git push} || abort("Push failed, please resolve.")
  sh %{bundle exec jekyll build} || abort("Build failed, please resolve.")
  sh %{rsync -avz --delete-after -essh public/ arko:/home/arko.net/domains/andre.arko.net/web/public/}
end

desc "create a new post"
task :post, [:title, :ext] do |task, args|
  puts [task, args].inspect
  title = args[:title] || abort("Usage: rake post['post title'] or rake post['post title',ext]")
  ext = args[:ext] || "md"
  date = Date.today.strftime('%Y-%m-%d')
  name = title.gsub(/ /, '-').gsub(/[^\w-]/,'').downcase
  filename = File.join("_posts", "#{date}-#{name}.#{ext}")
  puts filename
  next
  File.open(filename, "w") do |f|
    f.puts "---"
    f.puts "title: #{title}"
    f.puts "layout: post"
    f.puts "---"
  end
  case ENV["EDITOR"]
  when /vim?/
    system "#{ENV["EDITOR"]} +5 #{Shellwords.escape(filename)}"
  when /mate/
    system "#{ENV["EDITOR"]} -l 5 #{Shellwords.escape(filename)}"
  end
end

task :default => :deploy
