require 'httparty'

def create_routes_array
  hubs = ["LAX", "PHX", "DFW", "ORD", "CLT", "DCA", "PHL", "LGA", "JFK", "MIA"]

  airports = []
  CSV.foreach('airports.csv', headers: true) do |row|
    airports << row['IATA']
  end

  routes = []

  hubs.each do |hub|
    airports.delete(hub)
    airports.each do |airport|
      routes << "#{hub} - #{airport}"
    end
  end

  routes
end

def calculate_distance(route)
  origin, destination = route.split(" - ")

  puts "Calculating distance between #{origin} and #{destination}"

  url = "https://airport.api.aero/airport/distance/#{origin}/#{destination}?units=mile"
  headers = { 'x-apikey' => ENV['AERO_KEY'], 'accept' => 'application/json' }
  response = HTTParty.get(url, headers: headers)

  distance = response.parsed_response['distance'].gsub("," , "").to_i
end

def create_distances_hash
  distances = {}
  routes = create_routes_array

  routes.each do |route|
    distances[route] = calculate_distance(route)
  end

  distances
end

def create_distances_csv
  distances = create_distances_hash

  CSV.open('distances.csv', "wb") do |csv|
    csv << ["Route", "Origin", "Destination", "Distance"]
    distances.each do |route, distance|
      origin, destination = route.split(" - ")
      csv << [route, origin, destination, distance]
    end
  end

  puts "CSV of airport distances generated"
end

create_distances_csv
