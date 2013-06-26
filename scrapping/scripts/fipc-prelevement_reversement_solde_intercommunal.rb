require 'open-uri'
require 'nokogiri'
require 'sqlite3'

begin
  start_time = Time.now

  # Open the database
  db = SQLite3::Database.open "../db.sqlite"

  db.results_as_hash = true

  epcis = db.execute "SELECT * FROM epci"

  epci_count = epcis.count
  epci_current_idx = 1

  # Get results for every "code siren"
  epcis.each do |epci|
    documents = {
      :prelevement  => Nokogiri::HTML(open("http://modules.dgcl.interieur.gouv.fr/dgcl_dotation/consultation/edit3.php?dot=e06&siren=#{epci['siren']}")),
      :reversement  => Nokogiri::HTML(open("http://modules.dgcl.interieur.gouv.fr/dgcl_dotation/consultation/edit3.php?dot=e07&siren=#{epci['siren']}")),
      :solde        => Nokogiri::HTML(open("http://modules.dgcl.interieur.gouv.fr/dgcl_dotation/consultation/edit3.php?dot=e08&siren=#{epci['siren']}"))
    }

    values = {
      :prelevement  => nil,
      :reversement  => nil,
      :solde        => nil
    }

    documents.each do |key, value|
      document_values = value.xpath("//table[3]/tr[2]/td")
      values[key] = document_values[1].text.gsub(/\s+/, "")
    end

    #puts "INSERT INTO fipc VALUES(null,\"#{epci['siren']}\",\"#{epci['nom']}\",\"#{epci['departement_id']}\",#{values[:prelevement]},#{values[:reversement]},#{values[:solde]})"
    db.execute "INSERT INTO fipc VALUES(null,\"#{epci['siren']}\",\"#{epci['nom']}\",\"#{epci['departement_id']}\",#{values[:prelevement]},#{values[:reversement]},#{values[:solde]})"

    puts "Done #{epci['siren']} => #{epci_current_idx} on #{epci_count}"
    epci_current_idx += 1
  end

  stop_time = Time.now
  puts "Done #{epci_count} elements in #{stop_time - start_time} seconds"

rescue SQLite3::Exception => e

    puts "Exception occured"
    puts e

ensure
    db.close if db
end