require 'open-uri'
require 'uri'
require 'nokogiri'
require 'sqlite3'

begin
  start_time = Time.now

  # Open the database
  db = SQLite3::Database.open "../db.sqlite"

  db.results_as_hash = false

  # Get all departement ids from table
  departement_ids = db.execute "SELECT id FROM departement"

  #get all the result in a one-dimension array
  departement_ids.flatten!

  departement_ids.each do |departement_id|

    fetch_url = "http://modules.dgcl.interieur.gouv.fr/dgcl_dotation/consultation/edit0.php?type=1&dept=#{departement_id}"

    while fetch_url do
      # Get the html dom of the requested page
      document = Nokogiri::HTML(open(fetch_url))
      puts fetch_url

      # Extract table cells where values are
      epci_lines = document.xpath("//table[3]/tr[@class='tr1' or @class='tr2']")

      epci_lines.each do |epci|
        siren = epci.xpath("td")[0].text
        nom = epci.xpath("td")[1].text

        #puts "INSERT INTO epci VALUES(\"#{departement_id}\",\"#{siren}\",\"#{nom}\")"
        db.execute "INSERT INTO epci VALUES(\"#{departement_id}\",\"#{siren}\",\"#{nom}\")"
      end

      if document.xpath("//table[4]/tr/td/a[text()='suivant >>']").count > 0
        old_uri = URI.parse "http://modules.dgcl.interieur.gouv.fr/dgcl_dotation/consultation/edit0.php?type=1&dept=#{departement_id}"
        new_uri = URI.parse document.xpath("//table[4]/tr/td/a[text()='suivant >>']")[0].attr("href")
        fetch_url = old_uri.merge(new_uri).to_s
      else
        fetch_url = false
      end
    end
  end

  stop_time = Time.now
  puts "Job done in #{stop_time - start_time} seconds"

rescue SQLite3::Exception => e

    puts "Exception occured"
    puts e

ensure
    db.close if db
end

