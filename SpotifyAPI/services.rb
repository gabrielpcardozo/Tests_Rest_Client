require 'rest-client'
require 'json'
#Metodo de autenticação temporário, enquanto não arrumo o arquivo de autenticação.
require 'dotenv'
Dotenv.load('teste.env')

#Coleta todo o retorno do profile do usuario permitido. 
def get_profile(access_token)
  url = "https://api.spotify.com/v1/me"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  JSON.parse(response.body)
end

#Profile "formatado" Nome Completo e Usuario
def format_profile(access_token)
  profile = get_profile(access_token)

  profile_name = profile["display_name"]
  id = profile["id"]
  #uri = profile["uri"].split(':').last
  return "Full Name: #{profile_name}, User: #{id}" 
end

#Coleta somente o nome de todos os albums.
def get_albums(access_token)
  url = "https://api.spotify.com/v1/me/albums"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  albums = JSON.parse(response.body)
  
  albums['items'].each do |item|
    album = item['album']
    return album['name']
  end
end

#Coleta um album com o seu ID de parâmetro.
def get_album_tracks(access_token, id)
  url = "https://api.spotify.com/v1/albums/#{id}/tracks"
  response =  RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  album =  JSON.parse(response.body)["items"]
  return album
end

#Todos os albums no profile do usuario autorizado com o artista do album, quantidade de musicas e as musicas.
def album_info(access_token)
  url = "https://api.spotify.com/v1/me/albums"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  albums = JSON.parse(response.body)

  result = []

  albums['items'].each do |item|
    album = item['album']
    album_name = album['name']
    artist_names = album['artists'].map { |artist| artist['name'] }.join(', ')
    quantity_tracks = album['total_tracks']
    album_id = album['id']
    
    # Obter as músicas do álbum
    tracks = get_album_tracks(access_token, album_id)
    track_names = tracks.map { |track| track['name'] }.join(', ')
    
    result << "Álbum: #{album_name}, Artista(s): #{artist_names}, Total tracks: #{quantity_tracks}, Tracks: #{track_names}"     
  end

  return result
end

#
def get_playlist_tracks(access_token, playlist_id)
  url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  tracks = JSON.parse(response.body)
  track_names = tracks['items'].map { |item| item['track']['name'] }
  track_names.join(', ')
end

#Coleta todas as playlists e suas musicas uma ao lado da outra.
def get_playlists(access_token)
  profile = get_profile(access_token)
  id = profile["id"]
  
  url = "https://api.spotify.com/v1/users/#{id}/playlists"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  playlists = JSON.parse(response.body)

  result = []
  playlists['items'].each do |item|
    playlist = item['name']
    count_tracks = item['tracks']["total"]
    
    playlist_id = item['id']
    track_names = get_playlist_tracks(access_token, playlist_id)
    
    result << "Playlist: #{playlist}, Quantidade de Músicas: #{count_tracks}, Músicas: #{track_names}"
  end
  result << "No total temos: #{playlists['items'].size} playlists"
  
  return result.join("\n")
end

#Musicas mais escutadas da conta autenticada
def most_listen(access_token)
  url = "https://api.spotify.com/v1/me/top/tracks?time_range=long_term&limit=5"
  response = RestClient.get(url, {Authorization: "Bearer #{access_token}"})
  most_listen = JSON.parse(response.body)
  
  result = []

  most_listen['items'].each do |item|
    album = item['album']
    artists = album['artists'][0]['name']
    track = album['name']

   result << "Artista: #{artists}, Music: #{track}"
  end
  return result
end

access_token = ENV['ACCESS_TOKEN']

#puts get_profile(access_token)
#puts format_profile(access_token)
#get_albums(access_token)
#puts album_info(access_token)
#get_album_tracks(access_token)
puts get_playlists(access_token)
#puts most_listen(access_token)


url = "https://api.spotify.com/v1/me/top/tracks?time_range=long_term&limit=5"
response = RestClient.get(url, { Authorization: "Bearer #{access_token}"})
url = JSON.parse(response.body)
#puts JSON.pretty_generate(url)