namespace :file do
    desc 'changes the meta tags'
    task :all_string_migration => :environment do
      file_list = Dir.glob("db/migrate/*")
      file_list.each 



      regex = /@meta_tag/
      # only 'r' since you will only read the file,
      # although you could use 'r+' and just change the lineno
      # back to 0 when finished reading...
      file = File.open('app/controllers/site_controller.rb', 'r')
      lines = []
      file.each_line do |line|
        # i don't think you need the found variable,
        # it is simple if-then/else
        (line =~ regex) ? (lines << replace_line(line)) : (lines << line)
      end
      file.close
      file = File.open('app/controllers/site_controller.rb', 'w')
      # you could also join the array beforehand,
      # and use one big write-operation,
      # i don't know which approach would be faster...
      lines.each{|line| file.write line}
      file.close
    end

    def replace_line(line)
      meta_tags = MetaTag.all.map { |tag| tag["tag"] }
      new_tag = meta_tags.sample(1)[0]
      line = "@meta_tag = #{new_tag}\n" # added the newline
    end
end

#
# require 'tempfile'
#
# def file_edit(filename, regexp, replacement)
#   Tempfile.open(".#{File.basename(filename)}", File.dirname(filename)) do |tempfile|
#     File.open(filename).each do |line|
#       tempfile.puts line.gsub(regexp, replacement)
#     end
#     tempfile.fdatasync
#     tempfile.close
#     stat = File.stat(filename)
#     FileUtils.chown stat.uid, stat.gid, tempfile.path
#     FileUtils.chmod stat.mode, tempfile.path
#     FileUtils.mv tempfile.path, filename
#   end
# end
#
# file_edit('/tmp/foo', /foo/, "baz")