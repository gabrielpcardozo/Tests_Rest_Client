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

def get_profile_id(access_token)
  profile = get_profile(access_token)
  id = profile["id"]
  return id
end

#Coleta todas as músicas.
def all_tracks(access_token)
  url = "https://api.spotify.com/v1/me/tracks"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  tracks = JSON.parse(response.body)
  
  tracks['items'].each do |item|
    track = item['album']
    return track['name']
  end
end

#Coleta somente o nome de todos os albums salvos na conta.
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

#Lista todas as playlists na conta para o usuario saber oq ele esta procurando. 
def list_playlist(access_token)
  #id = get_profile_id(access_token)
  url = "https://api.spotify.com/v1/users/#{get_profile_id(access_token)}/playlists"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  playlists_name = JSON.parse(response.body)

  result = []

  playlists_name["items"].each do |item|
    playlist_name = item['name']

    result << playlist_name
  end

  return result

end

#Verifica se o nome passado pelo usuario e valido, e coleta o id da playlist
def get_name_for_id(access_token)
  puts "Qual Playlist você deseja?"
  input_playlist = gets.chomp.downcase

  url = "https://api.spotify.com/v1/users/#{get_profile_id(access_token)}/playlists"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  playlists = JSON.parse(response.body)
  
  playlists["items"].each do |item|
    playlist_name = item['name']
    if input_playlist == playlist_name.downcase
      playlist_id = item["id"]
      return playlist_id
    end
  end
  puts "Playlist não encontrada, confira as suas playlists:"
  list = list_playlist(access_token)
  return list
end

#Coleta somente as musicas das playlists pelo ID.
def get_playlist_tracks(access_token, playlist_id)
  url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  tracks = JSON.parse(response.body)
  track_names = tracks['items'].map { |item| item['track']['name'] }
  track_names.join(', ')
end

#Coleta todas as playlists e suas musicas uma ao lado da outra.
def get_all_playlists(access_token)
  profile = get_profile(access_token)
  id = profile["id"]
  
  url = "https://api.spotify.com/v1/users/#{id}/playlists"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  playlists = JSON.parse(response.body)

  #Armazena o resultado do bloco e consulta na API
  result = []
  #Contador para o total de musicas vai ser usado so depois do end.
  all_tracks = 0

  playlists['items'].each do |item|
    playlist = item['name']
    count_tracks = item['tracks']["total"]
    all_tracks = count_tracks + all_tracks
    
    playlist_id = item['id']
    track_names = get_playlist_tracks(access_token, playlist_id)
    
    #Retorno de todas as playlists e musicas.
    result << "Playlist: #{playlist}, Quantidade de Músicas: #{count_tracks}, Músicas: #{track_names}"
  end
  result << "No total temos: #{playlists['items'].size} playlists e temos temos #{all_tracks} músicas"
  return result.join("\n")
end

#Musicas mais escutadas da conta autenticada
def most_musics_listen(access_token)
  url = "https://api.spotify.com/v1/me/top/tracks?time_range=short_term&limit=5"
  response = RestClient.get(url, {Authorization: "Bearer #{access_token}"})
  most_listen = JSON.parse(response.body)
  
  result = []

  most_listen['items'].each do |item|
    artists = item['artists'].map { |artist| artist['name'] }.join(", ")
    track = item['name']

    result << "Artista: #{artists}, Música: #{track}"
  end

  return result
end


#Cria um resumo da conta autenticada, como albums, musicas mais escutadas, principais playlists e principais podcasts
def resume_profile(access_token)
  result = []
  #Profile
  my_profile = get_profile(access_token)
  name = my_profile["display_name"]
  user = my_profile["id"]
  result << name
  result << user
  result << "------"
  #Best Musics
  best_musics = most_musics_listen(access_token)
  result << best_musics
  result << "------"
  #My playlists
  my_playlists = list_playlist(access_token)
  result << my_playlists

  return result
end

def search_track(access_token, input_search, type="default", limit=10)
  url = 'https://api.spotify.com/v1/search'
  params = {
    q: input_search,
    limit: limit,
    type: "track"
  }
  # Syntax_URL -> https://api.spotify.com/v1/search?q=query_search%name&type=typek&limit=<number>
  #URL -> https://api.spotify.com/v1/search?q=track%oneofus&type=track&limit=3

  response = RestClient.get(url, {Authorization: "Bearer #{access_token}", params: params})
  search = JSON.parse(response.body)

  result = []

  search["tracks"]["items"].each do |item|
    track_name = item["name"]
    artist_name = item["artists"].map { |artist| artist["name"] }.join(", ")
    artist_profile = item["artists"].first["external_urls"]["spotify"]
    track_album = item["album"]["external_urls"]["spotify"]

    infos = "Music Name: #{track_name}, Artist Name: #{artist_name}, Artist Profile: #{artist_profile}, Album: #{track_album}"
    result << "-" * infos.length
    result << infos
  end

  return result
  
end

def milliseconds_to_minutes(milliseconds)
  seconds = milliseconds / 1000.0
  minutes = seconds / 60.0
  minutes.round(2)
end

def time_to_listen(access_token)
  url = "https://api.spotify.com/v1/me/player/recently-played"
  params = { limit: 50 }

  response = RestClient.get(url, { Authorization: "Bearer #{access_token}", params: params })
  recently_listened = JSON.parse(response.body)

  track_info = Hash.new { |hash, key| hash[key] = { "artist" => "", "total_time" => 0, "repeat_time" => 0 , "music_id" => ""} }

  recently_listened["items"].each do |item|
    track_name = item["track"]["name"]
    artist_name = item["track"]["artists"].map { |artist| artist["name"] }.join(", ")
    duration_ms = item["track"]["duration_ms"]
    music_id = item["track"]["id"]

    # Atualiza as informações da música
    track_info[track_name]["artist"] = artist_name
    track_info[track_name]["repeat_time"] += 1
    track_info[track_name]["music_id"] = music_id

    # Calcula o tempo total escutado
    total_minutes = milliseconds_to_minutes(duration_ms) * track_info[track_name]["repeat_time"]
    track_info[track_name]["total_time"] = total_minutes
  end
=begin
  Cria o resultado final
  result = track_info.map do |name, info|
    #"Musica: #{name}, Artista: #{info['artist']}, Tempo escutado: #{info['total_time']} minutos, Vezes escutado: #{info['repeat_time']}\n"
=end
  
  track_info.map do |name, info|
    {
      name: name,
      artist: info["artist"],
      total_time: info["total_time"],
      repeat_time: info["repeat_time"],
      music_id: info["music_id"]
    }
  end
end

def hash_most_listened(access_token)
  return time_to_listen(access_token)
end

def sort_musics_most_listened(access_token)
  musics = time_to_listen(access_token)

  # Ordena as músicas pelo número de vezes que foram escutadas (repeat_time) em ordem decrescente
  sorted_musics = musics.sort_by { |music| -music[:repeat_time] }

  # Formata o resultado final para exibição
  sorted_musics.map do |music|
    "Musica: #{music[:name]}, Artista: #{music[:artist]}, Tempo escutado: #{music[:total_time]} minutos, Vezes escutado: #{music[:repeat_time]}\n"
  end.join("\n")
end

access_token = ENV['ACCESS_TOKEN']

#puts get_profile(access_token)
#puts format_profile(access_token)
#puts get_profile_id(access_token)
#get_albums(access_token)
#puts album_info(access_token)

#get_album_tracks(access_token)
#puts get_playlists(access_token)
#puts list_playlist(access_token)
#puts get_name_for_id(access_token)
#test =  get_name_for_id(access_token)
#puts test
#puts get_playlist_tracks(access_token,test)
#puts most_musics_listen(access_token)
#puts resume_profile(access_token)
#puts all_tracks(access_token)
#puts search_track(access_token, "One Of Us")
#puts time_to_listen(access_token)
puts hash_most_listened(access_token)
puts sort_musics_most_listened(access_token)

=begin
url = "https://api.spotify.com/v1/me/top/tracks?time_range=long_term&limit=5"
response = RestClient.get(url, { Authorization: "Bearer #{access_token}"})
url = JSON.parse(response.body)
puts JSON.pretty_generate(url)
=end