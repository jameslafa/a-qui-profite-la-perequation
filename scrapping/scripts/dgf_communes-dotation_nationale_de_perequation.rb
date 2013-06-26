require 'open-uri'
require 'nokogiri'
require 'sqlite3'

def is_number?(to_test)
  true if Float(to_test) rescue false
end

begin
  start_time = Time.now

  # Open the database
  db = SQLite3::Database.open "../db.sqlite"

  db.results_as_hash = true

  communes = db.execute "SELECT id, nom FROM commune where id > '28041'"

  commune_count = communes.count
  commune_current_idx = 1

  communes.each do |commune|
    # Get the html dom of the requested page
    document = Nokogiri::HTML(open("http://modules.dgcl.interieur.gouv.fr/dgcl_dotation/consultation/edit4.php?dot=c14&insee=#{commune['id']}"))

    # Extract table cell value
    valeur = document.xpath("//table[3]/tr[2]/td[2]").text

    #remove white spaces in number stored as integer in the database
    valeur.gsub!(/\s+/, "")

    # If the value is not a number, set it to nil and we'll check it later
    valeur = 'NULL' if !is_number?(valeur)

    #puts "INSERT INTO dgf VALUES(\"#{commune['id']}\",\"#{commune['nom']}\",#{valeur})"
    db.execute "INSERT INTO dgf VALUES(\"#{commune['id']}\",\"#{commune['nom']}\",#{valeur})"

    puts "Done #{commune['id']} => #{commune_current_idx} on #{commune_count}"
    commune_current_idx += 1
  end

  stop_time = Time.now
  puts "Done #{commune_count} elements in #{stop_time - start_time} seconds"

rescue SQLite3::Exception => e

    puts "Exception occured"
    puts e

ensure
    db.close if db
end

