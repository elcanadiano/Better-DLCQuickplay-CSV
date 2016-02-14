#!/usr/bin/ruby
require 'csv'
require 'set'
require 'optparse'

# Reads through each file argument passed in. Checks to see where the title and
# artist is and then extracts those into a hash. It sorts it then it "prints it
# in a better format."
songs = Hash.new {|h, k| h[k] = SortedSet.new}

# Options list. List of supported argument options:
#
# -striprb3 strips " (RB3 version)" from the song title.
# -h displays the help.

options = {
  striprb3: false
}

# Parse the optiosn
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: ruby bettercsv.rb [options] file1 file2 ..."

  opts.on( '-s', '--striprb3', 'Strip (RB3 version) from song title' ) do
    options[:striprb3] = true
  end

  # This displays the help screen, all programs are
  # assumed to have this option.
  opts.on( '-h', '--help', 'Display this screen' ) do
    puts opts
    exit
  end
end

# Strip the options
optparse.parse!

ARGV.each do |arg|
  has_errors = false
  begin
    handler = open(arg)
    csv_string = handler.read.encode!("UTF-8", "UTF-8", invalid: :replace)
    CSV.parse(csv_string, headers: true) do |row|
      if row['Artist'].nil? || row['Title'].nil?
        STDERR.puts "Either the artist or song title was not found in #{arg}."
        has_errors = true
        break
      end

      song_title = row['Title']

      # If the striprb3 option is enabled, let's strip any occurance of ' (RB3 version)' from the
      # song title.
      song_title.gsub!(' (RB3 version)', '') if options[:striprb3]
      STDERR.puts song_title if options[:striprb3]

      songs[row['Artist']] << song_title.strip
      #STDERR.puts "#{row['Artist']} #{row['Title']}"
    end
    STDERR.puts "Successfully processed the artist and songs of #{arg} successfully!" if !has_errors
  rescue Errno::ENOENT
    STDERR.puts "Could not process the file #{arg}."
  end
end

if songs.empty?
  STDERR.puts 'No song information was processed. The program will now exit.'
  exit
end

puts 'Artist,Song Title'

songs.each do |artist, songs|
  puts "\"#{artist}\","

  songs.each do |song|
    puts ",\"#{song}\""
  end

  puts ','
end
