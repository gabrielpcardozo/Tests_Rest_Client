require 'rest-client'
require 'json'
require 'pp'
#Metodo de autenticação temporário, enquanto não arrumo o arquivo de autenticação.
require 'dotenv'
Dotenv.load('teste.env')

#Coleta todas as informações do usuário autorizado.
def get_profile(access_token)
  url = "https://api.spotify.com/v1/me"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  JSON.parse(response.body)
end

#Profile "formatado" Nome Completo e Usuario
def format_profile(access_token)
  profile = get_profile(access_token)
#So fiz isso para "brincar" com as requisicoes.
  profile_name = profile["display_name"]
  id = profile["id"]
  #uri = profile["uri"].split(':').last
  return "Full Name: #{profile_name}, User: #{id}" 
end
#Muito necessario para diversas outras funcoes no programa.
def get_profile_id(access_token)
  profile = get_profile(access_token)
  #Coleta somente o ID para utilizacoes de acesso as informacoes do usuario em funcoes mais a frente.
  id = profile["id"]
  return id
end

#Coleta todas as músicas salvas disponiveis na conta autorizada.
def all_tracks(access_token)
  url = "https://api.spotify.com/v1/me/tracks"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  tracks = JSON.parse(response.body)
  #Para cada ITEM dentro de ITEMS estou coltando o album e a musica, do item salvo.
  
  #Criacao das hash para conseguir coletar os dados de forma separada caso necessario
  result = Hash.new {|hash, key| hash[key] = {"Track_Name" => "", "Track_ID" => ""}}
  
  tracks['items'].each do |item|
    track = item['track']['name']
    track_id = item['track']['id']  
  
    result[track]["Track_Name"] = track 
    result[track]["Track_ID"] = track_id
  end
  return result
end

#Coleta os albums da conta autorizada.
def get_albums(access_token)
  url = "https://api.spotify.com/v1/me/albums"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  albums = JSON.parse(response.body)
  
  result = Hash.new { |hash, key| hash[key] = [] }
  #result = Hash.new {|hash, key| hash[key] = {"Album_Name" => "", "Album_id" => ""}}
  #Coletando os nomes de cada album, para utilizar se necessario. 
  albums['items'].each do |item|
    album = item['album']
    album_type = item["album_type"]
    album_name = album['name']
    album_id = album["id"]

    #result[album_type] = album_type
    #result[album_name]["Album_Name"] = album_name
    #result[album_name]["Album_id"] = album_id

    #Como a hash foi criada como lista =[] estou passando todas as informacoes de uma so vez.
    result[album_type] << { "Album_Name" => album_name, "Album_id" => album_id }

  end
  return result
end

#Coleta as musicas de um album solcitado.
#id pode ser coletado das outras funcoes.
def get_album_tracks(access_token, id)
  url = "https://api.spotify.com/v1/albums/#{id}/tracks"
  response =  RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  album =  JSON.parse(response.body)["items"]
  
  result = []

  album.each do |item|
    track_name = item["name"]
    track_id = item["id"]

    result << { "Name" => track_name, "ID" => track_id }
  end
  
  return result
end

#Todos os albums no profile do usuario autorizado com o artista do album, quantidade de musicas e as musicas.
def format_album(access_token)
  url = "https://api.spotify.com/v1/me/albums"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  albums = JSON.parse(response.body)

  result = []
  #result = Hash.new {}
  
  albums['items'].each do |item|
    album = item['album']
    album_name = album['name']
    artist_names = album['artists'].map { |artist| artist['name'] }.join(', ')
    quantity_tracks = album['total_tracks']
    album_id = album['id']
    
    # Obter as músicas do álbum
    # Usa a funcao anterioro pass o ID do album coletado agora e coleta todas as musicas.
    tracks = get_album_tracks(access_token, album_id)
    track_names = tracks.map { |track| track["Name"]}.join(', ')
    
    result << "Álbum: #{album_name}, Artista(s): #{artist_names}, Total tracks: #{quantity_tracks}, Tracks: #{track_names}"     
  end
  return result
end

#Lista todas as playlists na conta para o usuario. 
def list_playlist(access_token)
  profile_id = get_profile_id(access_token)
  url = "https://api.spotify.com/v1/users/#{profile_id}/playlists"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  playlists_names = JSON.parse(response.body)
#Cria a Hash para a utilizacao do projeto.
  playlists_ids = Hash.new { |hash, key| hash[key] = { "playlist_name" => "", "playlist_id" => "" } }
#COleta os dados da API
  playlists_names["items"].each do |item|
    playlist_name = item['name']
    playlist_id = item['id']
#Adiciona os dados na Hash criada
    playlists_ids[playlist_name]["playlist_name"] = playlist_name
    playlists_ids[playlist_name]["playlist_id"] = playlist_id
  end
#Mapeia todas as informacoes coletadas e deixa disponivel para as proximas funcoes
  playlists_ids.map do |name, info|
    
    {
      name: info["playlist_name"],
      id: info["playlist_id"]
    }

  end
end
#Coleta as infformacao de uma playlist unica, usando o id da playlist anterior.
def get_playlist_id(access_token, playlist_name)
 #Chama a funcao que lista todas as playlists da conta
  all_playlists = list_playlist(access_token)
#Localiza a playlist pelo nome passado no parametro da funcao get_playlist_id
  playlist = all_playlists.find { |pl| pl[:name].downcase == playlist_name.downcase }
#Se a playlist foi econtrada, coleta o ID, caso contrariop mensagem de NOT FOUND.
  if playlist
    return playlist[:id]
  else
    puts "Playlist '#{playlist_name}' não encontrada."
    return nil
  end
end

#Coleta somente as musicas das playlists pelo ID.
#A Playlist anterior coleta o ID logo conseguimos usa-la aqui, para coletar as musicas de uma playlist.
def get_playlist_tracks(access_token, playlist_id)
  url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
  response = RestClient.get(url, { Authorization: "Bearer #{access_token}" })
  tracks = JSON.parse(response.body)
  #Mapeia todas as musicas na variavel RESPONSE.
  track_names = tracks['items'].map { |item| item['track']['name'] }
  #Separa as musicas com , 
  track_names.join(', ')
end

#Coleta todas as playlists e suas musicas uma ao lado da outra.
#Semelhante a funcao format_album porem agora das playlists da conta autorizada.
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
  #Nessa URL temos dois parametros opcionais e alteraveis. 
  url = "https://api.spotify.com/v1/me/top/tracks?time_range=short_term&limit=5"
    #time_range -> E o tempo da consulto, SHORT quer dizer que ele filtra as musicas mais escutadas de semanas atras.
    #limit -> So coleta as ultimas 5 musicas mais escutadas disponiveis.
  response = RestClient.get(url, {Authorization: "Bearer #{access_token}"})
  most_listen = JSON.parse(response.body)
  
  result = []

  most_listen['items'].each do |item|
    #Mapeando todas as musicas que estao na variavel RESPONSE
    artists = item['artists'].map { |artist| artist['name'] }.join(", ")
    track = item['name']

    result << "Artista: #{artists}, Música: #{track}"
  end

  return result

end


#Cria um resumo da conta autenticada, como albums, musicas mais escutadas, principais playlists e principais podcasts
def resume_profile(access_token)
  result = []
  #Profile resume
  my_profile = get_profile(access_token)
  name = my_profile["display_name"]
  user = my_profile["id"]
  result << name
  result << user
  result << "------"
  #Best Musics -  Resume das musicas mais escutadas
  best_musics = most_musics_listen(access_token)
  result << best_musics
  result << "------"
  #My playlists - coleta todas as playlists da minha conta. 
  my_playlists = list_playlist(access_token)
  result << my_playlists

  return result
end

#E uma funcao de busca por nome
#a funcao devolve ate 10 musicas com o nome aproximadamente.
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

  #Apos coletar os possiveis resultados e necessario formatar os resultados para 
  search["tracks"]["items"].each do |item|
    track_name = item["name"]
    artist_name = item["artists"].map { |artist| artist["name"] }.join(", ")
    artist_profile = item["artists"].first["external_urls"]["spotify"]
    track_album = item["album"]["external_urls"]["spotify"]
#Adiciona as informacoes na lista criada. 
    infos = "Music Name: #{track_name}, Artist Name: #{artist_name}, Artist Profile: #{artist_profile}, Album: #{track_album}"
    result << "-" * infos.length
    result << infos
  end

  return result
  
end
#Aqui e um helper para as proximas funcoes que eu vou precisar mais para a funcao a seguir time_to_listen.
def milliseconds_to_minutes(milliseconds)
  seconds = milliseconds / 1000.0
  minutes = seconds / 60.0
  minutes.round(2)
end

#E uma funcao onde coletamos as musicas mais escutadas e o tempo em cada musica.
def time_to_listen(access_token)
  #URL com as informacoes necessarias
  #Essa url coleta as ultimas musicas escutadas.
  url = "https://api.spotify.com/v1/me/player/recently-played"

  #Usa o restclient para coletar as informacoes das 50 ultimas musicas
  response = RestClient.get("#{url}?limit=50", { Authorization: "Bearer #{access_token}" })

  # Devolve em formato Json.
  recently_listened = JSON.parse(response.body)
  #Crio uma hash(dicionario) para ter um padrao do que eu quero de informacoes coletadas.
  track_info = Hash.new { |hash, key| hash[key] = { "artist" => "", "total_time" => 0, "repeat_time" => 0 , "music_id" => ""} }
    # { |hash, key|...} -> Aqui e passado para a hash dois parametros a propria HASH e sua KEY, sempre que for acessar essa Hash e assim que ele deve ser chamada.
    # hash[key] = { ... } -> Define que toda KEY criada vai conter os seguintes VALUES -> "artist" => "", "total_time" => 0, "repeat_time" => 0 , "music_id" => ""
  
  #Nesse bloco comecamos a coletar as informacoes dentro da URL da API e armazenamos em variaveis 
  recently_listened["items"].each do |item|
    track_name = item["track"]["name"]
    #Como uma musica pode ter  mais de um artista precisamos utilizar o .map para coletar todos os nomes disponiveis.
    artist_name = item["track"]["artists"].map { |artist| artist["name"] }.join(", ")
      #item["track"]["artists"].map -> Coleta todo interavel que esta presente nessa possicao de - ["track"]["artists"] e os mapeia com o .map
      #{ |artist| artist["name"] } -> Cria um novo interavel somente com os nomes de artistas encontrados nessa possicao - artist["name"]
      #.join(", ") -> Para cada artista encontrado separa com uma ", " para ficarem separados corretamente como: artista_1, artista_2, ...
    duration_ms = item["track"]["duration_ms"]
    music_id = item["track"]["id"]

    # Atualiza as informações da música, em nosso dicionario track_info
    track_info[track_name]["artist"] = artist_name
    #Para cada musica que se repete o "repeteat_time" conta mais 1.
    track_info[track_name]["repeat_time"] += 1
    track_info[track_name]["music_id"] = "spotify:track:#{music_id}"

    # Calcula o tempo total escutado
    total_minutes = milliseconds_to_minutes(duration_ms) * track_info[track_name]["repeat_time"]
    #Como a API entrega cada musica em milesegundos tive que criar uma funcao para transformar em muinuto, e depois mutiplicar com as vezes repetidas para ter o valor de tempo total.
    track_info[track_name]["total_time"] = total_minutes
    #aqui atualizamos o tatal do tempo escutado de cada musica apos mutiplicar com as vezes repetidas e ser transformado em minutos.
  end  
  #Transforma todos os dados coletados e armazenados em track_info acessiveis. 
  track_info.map do |name, info|
    #.map -> Mapeia cada musica sendo KEY = name, VALUE = info
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
  #So retorna o dicionario da funcao anterioe para o programador ter uma nocao de como ficou o Hash inteiro.
  return time_to_listen(access_token)
end

#Ordena as musicas em ordem decrecente
def sort_musics_most_listened(access_token)
  #Coleta a funcao todas as musicas em uma variavel
  musics = time_to_listen(access_token)

  # Ordena as músicas pelo número de vezes que foram escutadas (repeat_time) em ordem decrescente com o parametero -> -music[:repeat_time]
  sorted_musics = musics.sort_by { |music| -music[:repeat_time] }

  # Formata o resultado final para exibição
  sorted_musics.map do |music|
    "Musica: #{music[:name]}, Artista: #{music[:artist]}, Tempo escutado: #{music[:total_time]} minutos, Vezes escutado: #{music[:repeat_time]}\n"
  end.join("\n")
end

def most_listened_ids(access_token)
  musics = time_to_listen(access_token)

  # Ordena as músicas pelo número de vezes que foram escutadas (repeat_time) em ordem decrescente
  sorted_musics = musics.sort_by { |music| -music[:repeat_time] }

  # Retorna uma lista de IDs das músicas mais escutadas
  sorted_musics.map { |music| music[:music_id] }
end

#E uma funcao de criacao de playlist, todos os parametros sao DEFAULT, caso o usuario esqueca de preencher alguma informacao. 
def create_playlist_default(access_token, playlist_name="default", playlist_description="default", public = false)
  #coleta o id para usar o ID dessa conta.
  user_id = get_profile_id(access_token)
  url = "https://api.spotify.com/v1/users/#{user_id}/playlists"
  #as informacoes que vao ser utilizadas para criar a playlist.
  data = {
    name: playlist_name,
    description: playlist_description,
    public: public
    }.to_json
#Usa o metodo post para criar a playlist.
  response = RestClient.post(url, data, {Authorization: "Bearer #{access_token}", content_type: :json, accept: :json})
  new_playlist = JSON.parse(response.body)
#Retorna a playlist, mas nao seria necessario.
  return new_playlist
end
#e uma funcao input que da a opcao do usuario criar uma playlist com o NOME e DESCRICAO descrito.
def create_playlist(access_token)
  playlist_name = input("Qual o nome da sua playlist?")
  description = input("Qual a descrição da sua playlist?")
#Usando a playlist anterior para economizar codigo.
  default_playlist = create_playlist_default(access_token, playlist_name, description)
  return default_playlist
end
#As playlists anteriores so criam a playlist vazia, aqui vamos adicionar "ITEMS" musicas dentro da playlist
def add_music(access_token, playlist_id, track_uris)
  #URL da playlist que vai receber as musicas.
  url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
#Precisamos da URI da musica para musica ser adicionada em uma playlist
  data = {
    uris: track_uris
  }.to_json
#Usa o metodo post para pegar a playlist(URL), as musicas(DATA) e conseguimos colocar as musicas na playlist.
  response = RestClient.post(url, data, {Authorization: "Bearer #{access_token}", content_type: :json, accept: :json})

  return response
end
#Foi uma ideia de criar uma playlist com as musicas mais escutadas na ordem correta.
def create_most_listened_playlist(access_token)
  #Criar a playlist "Mais Escutadas"
  playlist_name = "Mais Escutadas"
  playlist_description = "Playlist com as músicas mais escutadas recentemente."
  new_playlist = create_playlist_default(access_token, playlist_name, playlist_description)
  
  # Obter o ID da nova playlist criada
  playlist_id = new_playlist["id"]

  #Coletar os IDs das músicas mais escutadas
  most_listened_ids = most_listened_ids(access_token)

  #Adicionar as músicas à playlist
  add_music(access_token, playlist_id, most_listened_ids)
  
  puts "Playlist 'Mais Escutadas' criada com sucesso!"
end
#Meio confuso, mas da a opcao de reordenar a playlist.
def sort_playlist(access_token, playlist_id, range_start = 0 , insert_before = 0, range_length = 0)
=begin
DOC
curl --request PUT \
--url https://api.spotify.com/v1/playlists/3cEYpjA9oz9GiPac4AsH4n/tracks \
--header 'Authorization: Bearer 1POdFZRZbvb...qqillRxMr2z' \
--header 'Content-Type: application/json' \
--data '{
  "range_start": 1,
  "insert_before": 3,
  "range_length": 2
}' 
=end

   data = {
    range_start: range_start,
    insert_before: insert_before,
    range_length: range_length
   }

  url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
  response = RestClient.put(url, data, {Authorization: "Bearer #{access_token}}",content_type: :json, accept: :json})

  return response
end
#Atualiza uma playlist que ja existe e ja possue musicas armazenadas dentro dela. 
def update_playlist(access_token, playlist_id, new_ids)
  url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"

  data = {
    uris: new_ids
  }.to_json

  response = RestClient.put(url, data, {Authorization: "Bearer #{access_token}", content_type: :json, accept: :json})

  return response
end
#Atualiza a playlist criada com as musicas mais escutadas.
def refresh_playlist_most_listened(access_token)
  #Playlist procurada
  playlist_name = "Mais Escutadas"
  #coleta o id da playlist
  playlist_id = get_playlist_id(access_token, playlist_name)
#Coleta as novas musicas 
  new_musics = most_listened_ids(access_token)
#Atualiza a playlist com as musicas passadas.
  update_playlist(access_token, playlist_id, new_musics)
end

#Deleta uma playlist pelo nome
def delete_playlist(access_token, playlist_name)
  playlist_id = get_playlist_id(access_token, playlist_name)
  url = "https://api.spotify.com/v1/playlists/#{playlist_id}/followers"
  
  response = RestClient.delete(
    url,
    Authorization: "Bearer #{access_token}"
  )
  
  return response
  #Essa funcao ela tem uma explicacao, pois ela nao exclui de fato a playlist encontrada ela so deixa de seguir.
  #Para o spotify vc deixar de seguir uma playlist e o mesmo cenario, porem caso algum outro usuario esteja seguindo essa playlist ela ainda vai existir.
end

#Remove da playlist passada a musica especificada. 
def delete_playlists_tracks(access_token, playlist_name, tracks)
  playlist_id = get_playlist_id(access_token, playlist_name)
  url = "https://api.spotify.com/v1/playlists/#{playlist_id}/tracks"
  
  data = {
    uri: tracks
}.to_json

  response = RestClient.delete(
    url, data,
    {Authorization: "Bearer #{access_token}", content_type: :json, accept: :json}
  )
  
  return response
  
end

#access_token = ENV['ACCESS_TOKEN']

#puts get_profile(access_token)
#puts format_profile(access_token)
#puts get_profile_id(access_token)
#pp all_tracks(access_token)
#pp get_albums(access_token)
#puts get_album_tracks(access_token, "7EPrkhjTBrwAV8yAKCmY0Y")
#puts format_album(access_token)
#puts list_playlist(access_token)
#puts get_playlist_id(access_token,"My Connection")
#puts get_playlist_tracks(access_token,"1Cg9fb6El6ba5FbnjeW6CQ")
#puts get_all_playlists(access_token)
#puts most_musics_listen(access_token)
#uts resume_profile(access_token)