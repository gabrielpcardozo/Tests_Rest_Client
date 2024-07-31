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
  albums = JSON.parse(response.body)
  
  albums['items'].each do |item|
    album = item['album']
    puts album['name']
  end
end

def musics_album(access_token)
  url = "https://api.spotify.com/v1/me/albums"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  albums = JSON.parse(response.body)

  albums['items'].each do |item|
    album = item['album']
    album_name = album['name']
    artist_names = album['artists'].map { |artist| artist['name'] }.join(', ')
    puts "Álbum: #{album_name}, Artista(s): #{artist_names}"
  end
end

  
  #['items'][1]['album']['artists'][0]['name']


access_token = ENV['ACCESS_TOKEN']

#puts get_profile(access_token)
#puts format_profile(access_token)
#get_albums(access_token)
musics_album(access_token)


url = "https://api.spotify.com/v1/me/albums"
response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
url = JSON.parse(response.body)
#puts JSON.pretty_generate(url["items"])