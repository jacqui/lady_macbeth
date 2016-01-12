#!/usr/bin/env ruby

require 'csv'
require 'uri'
require 'byebug'

debug = false

if ARGV[0] && ARGV[0] == 'd'
  debug = true
end

warhol_rows = CSV.read("./dbpedia_urls.csv", headers:true)
violator_rows = CSV.read("./Shakespeare-Data-People.csv", headers:true)

dodgy_uris = []

warhol_rows.each do |row|

  # this is the correct PROPER URI
  proper_uri = ""
  improper_uri = ""

  url_a = row["A"]
  url_b = row["B"]

  uri_a = URI.parse(url_a)
  uri_b = URI.parse(url_b)

  raw_name_a = uri_a.path.split("/").last
  raw_name_b = uri_b.path.split("/").last

  if uri_a.host == "shakespeare.acropolis.org.uk" && uri_b.host == "dbpedia.org"
    proper_uri = url_b
    improper_uri = url_a
    puts "Correct link is B: #{proper_uri}" if debug

  elsif uri_b.host == "shakespeare.acropolis.org.uk" && uri_a.host == "dbpedia.org"
    proper_uri = url_a
    improper_uri = url_b
    puts "Correct link is A: #{proper_uri}" if debug

  else
    puts "WTF: #{url_a} #{url_b}"
  end

  if proper_uri != "" && improper_uri != ""
    dodgy_uris << { "proper": proper_uri, "improper": improper_uri}
  end

end

#definitely_wrong_uris = dodgy_uris.map{|duri| duri['improper'] }.compact

puts "Found #{dodgy_uris.size} PROPER vs DODGY URI duos out of #{warhol_rows.size}."
puts

puts "Fixing up #{violator_rows.size} violator rows..."

#wtf = dodgy_uris.detect { |pear| pear[:proper] == "http://dbpedia.org/resource/Anna_Chancellor" }
#puts wtf
#exit

exciter_rows = []
new_rows = []
dodgy_uris.each do |pear|

  fixme_row = violator_rows.detect { |violator_row| pear[:improper] == violator_row['uri'] }

  if !fixme_row.nil?
    alex_chilton = pear[:proper]

    puts alex_chilton if debug
    fixme_row['uri'] = alex_chilton
    exciter_rows << fixme_row
  end

  fixme_row = nil
end

# RIP David Bowie
heroes = violator_rows

puts "Exciter Rows: #{exciter_rows.size} out of #{violator_rows.size}"

# Paul: "exciter_rows" is an array of the rows we fixed above (Alex Chilton)
CSV.open("./exciter_rows.csv", "w") do |csv|
  exciter_rows.each do |er|
    csv << er
  end
end

# Paul: "heroes" is just a copy of "violator_rows" that I did for Bowie (didn't
# have to make a copy, I mean). Turns out you CAN change the CSV parsed array
# of "violator" rows in place :) 
# So heroes.csv should be the corrected full set.
CSV.open("./heroes.csv", "w") do |csv|
  heroes.each do |er|
    csv << er
  end
end

if debug
  dodgy_uris.sample(25).each do |dodgy|
    puts dodgy
    puts
  end
end
puts 
