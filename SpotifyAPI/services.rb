require 'rest-client'
require 'json'
#Metodo de autenticação temporário, enquanto não arrumo o arquivo de autenticação.
require 'dotenv'
Dotenv.load('teste.env')


def get_profile(access_token)
  url = "https://api.spotify.com/v1/me"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  JSON.parse(response.body)
end

def format_profile(access_token)
  profile = get_profile(access_token)
  
  puts profile["display_name"]
  uri = profile["uri"]
  puts uri.split(':').last

end


def get_albums(access_token)
  url = "https://api.spotify.com/v1/me/albums"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  JSON.parse(response.body)
end

def format_albums(access_token)
  albums_data = get_albums(access_token)

  albums_data["items"].each do |item|
    album = item["album"]
    album_name = album["name"]
    puts "Album: #{album_name}"

    album["artists"].each do |artist|
      artist_name = artist["name"]
      puts "  Artist: #{artist_name}"
    end
    puts "-" * 40
  end
end

access_token = ENV['ACCESS_TOKEN']

puts get_profile(access_token)
puts format_profile(access_token)
#albums = get_albums(access_token)
#teste_album = JSON.pretty_generate(get_albums(access_token))
#format_albums(access_token)
puts JSON.pretty_generate(format_albums(access_token))