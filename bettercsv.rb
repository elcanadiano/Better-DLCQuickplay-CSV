#!/usr/bin/ruby
require 'csv'
require 'set'
require 'optparse'

# Reads through each file argument passed in. Checks to see where the title and
# artist is and then extracts those into a hash. It sorts it then it "prints it
# in a better format."
songs = Hash.new {|h, k| h[k] = SortedSet.new}
new_songs = Hash.new {|h, k| h[k] = SortedSet.new}

# Options list.
options = {
  striprb3: false,
  verbose: false,
  compare: false
}

# Parse the options
optparse = OptionParser.new do |opts|
  opts.banner = "Usage: ruby bettercsv.rb [options] file1 file2 ..."

  opts.on('-s', '--striprb3', 'Strip (RB3 version) from song title') do
    options[:striprb3] = true
  end

  # This displays the help screen, all programs are assumed to have this option.
  opts.on('-h', '--help', 'Display this screen') do
    puts opts
    exit
  end

  # Verbose mode. Prints out extra logs into standard error.
  opts.on('-v', '--verbose', 'Print verbose mode') do
    options[:verbose] = true
  end

  # If two filenames were passed in along with the comparison mode flag, we
  # check to see what files were in the other
  opts.on('-c', '--compare', 'Comparison mode') do
    options[:compare] = true
  end
end

# Strip the options
optparse.parse!

i = 0
ARGV.each do |arg|
  STDERR.puts "Processing #{arg}" if options[:verbose]
  has_errors = false
  begin
    handler = open(arg)
    CSV.parse(handler, headers: true, encoding: "windows-1252:utf-8") do |row|
      if row['Artist'].nil? || row['Title'].nil?
        STDERR.puts "Either the artist or song title was not found in #{arg}."
        has_errors = true
        break
      end

      song_title = row['Title'].strip
      artist     = row['Artist'].strip

      # If the striprb3 option is enabled, let's strip any occurance of ' (RB3 version)' from the
      # song title.
      song_title.gsub!(' (RB3 version)', '') if options[:striprb3]

      # If compare is set and a given parsed song already appears in the songs list, add it into the new_songs list.
      if options[:compare] && i > 0 && (!songs.include?(artist) || !songs[artist].include?(song_title))
        new_songs[artist] << song_title
        STDERR.puts "New song: #{artist} - #{song_title}" if options[:verbose]
      end

      songs[artist] << song_title

      STDERR.puts "Processed #{artist} - #{song_title}" if options[:verbose]
    end
    STDERR.puts "Successfully processed the artist and songs of #{arg} successfully!" if !has_errors
  rescue Errno::ENOENT
    STDERR.puts "Could not process the file #{arg}."
  end
  i += 1
end

if songs.empty?
  STDERR.puts 'No song information was processed. The program will now exit.'
  exit
end

puts 'Artist,Song Title'

#songs.each do |artist, songs|
songs.keys.sort.each do |artist|
  puts "\"#{artist}\","

  songs[artist].each do |song|
    puts ",\"#{song}\""
  end

  puts ','
end

if !new_songs.empty?
  puts ','
  puts 'New Songs,'
  puts ','

  puts 'Artist,Song Title'

  #new_songs.each do |artist, songs|
  new_songs.keys.sort.each do |artist|
    puts "\"#{artist}\","

    new_songs[artist].each do |song|
      puts ",\"#{song}\""
    end

    puts ','
  end
end

STDERR.puts 'Processed successfully!'
