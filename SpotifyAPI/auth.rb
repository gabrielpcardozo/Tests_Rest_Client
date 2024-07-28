#GEMs
require 'sinatra'
require 'rest-client'
require 'securerandom'
require 'uri'
require 'json'
require 'dotenv/load'

#Criação da classe
class SpotifyAuth
  #Declaração dos ID, aqui deve ser feito via arquivo .env
  CLIENT_ID = ENV['CLIENT_ID']
  CLIENT_SECRET = ENV['CLIENT_SECRET']
  REDIRECT_URI = ENV['REDIRECT_URI']
  SCOPE = 'user-read-private user-read-email'

  #Necessário a criação do state para previnir ataques CSRF.
  def self.generate_state
    SecureRandom.hex(8)
  end

  #Contrução da URL de login e permissão de conta de usuário. 
  def self.login_url(state)
    query_params = {
      response_type: 'code',
      client_id: CLIENT_ID,
      scope: SCOPE,
      redirect_uri: REDIRECT_URI,
      state: state
    }

    "https://accounts.spotify.com/authorize?" + URI.encode_www_form(query_params)
    #Exemplo da URL completa
    #https://accounts.spotify.com/authorize?response_type=code&client_id=bbbf86d4fca54a26981fff30fcf6b305&scope=user-read-private user-read-email&redirect_uri=http://localhost:8888/callback&state=<16caracteres aleatorios>
  end

  #trocar um código de autorização por um token de acesso
  def self.fetch_token(code)
    response = RestClient.post('https://accounts.spotify.com/api/token', {
      grant_type: 'authorization_code',
      code: code,
      redirect_uri: REDIRECT_URI,
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET
    }, { accept: :json })

    JSON.parse(response.body)
  end
end

#hAbilita as sessões do Servidor.
enable :sessions

#Cria a nossa url de Login para permitir que cada usuario APROVE a utilizacao dos dados.
get '/login' do
  state = SpotifyAuth.generate_state
  session[:state] = state
  logger.info("state: #{state}")
  redirect SpotifyAuth.login_url(state)
  #<localhost>/login -> é o path correto para garantir os parametros.
  #Apos a autorizacao
    #https://getaccess/callback?code=AQD6-e_Kj7ltUvJz8T7yvoU-dk8rC6e-ZH_5FX4L2wtMJ86tQ1B1myFUj5E48ez7DUXqXx0t8nnI5QAdlc4073fwgsHVldIqq7YoekfX-flvLpUhdGB9bEzoRznhFLs-Li-BH4xmPCYTbAnoVXe7tNU5F2XtgkOr6EwncNV55bN7dPPHG_VAprxLMVXS_X-vZdJUwd0CkGEDShsFk7DHUNrz&state=441f6aa7fb707163
end

#Cria a url de <callback> para coelta do acces_token e informacoes necessarias como na Documentacao.
get '/callback' do
  if params[:state] != session[:state]
    logger.error("state Session #{session[:state]} \n state params #{params[:state]}")
    halt 400, "State mismatch"
  end

  #Faz as trocas de dos codigos de autorizacao pelos token de acesso. 
  begin
    tokens = SpotifyAuth.fetch_token(params[:code])
    logger.info("Acces_Token: #{tokens['access_token']}")
    session[:access_token] = tokens['access_token']
    "Token de acesso: #{tokens['access_token']}"
  rescue RestClient::ExceptionWithResponse => e
    logger.error("Failed to obtain token: #{e.response}")
    status e.http_code
    "Falha ao obter o token: #{e.response}"
  end
end

get '/profile' do
  acces_token = session[:acces_token]

  if acces_token.nil?
    redirect '/login'
  else 
    #Chama a API
    begin
      user_info =RestClient.get('https://api.spotify.com/v1/me', {
        Authorization: "Bearer #{access_token}"
      })

      #chama a api para coletas as informacoes do user
      playlists = RestClient.get('https://api.spotify.com/v1/me/playlists', {
        Authorization: "Bearer #{access_token}"
      })

      user_info_json =JSON.parse(user_info.body)
      playlists_json =JSON.parse(playlists.body)

      erb :profile, locals: { user_info: user_info_json, playlists: playlists_json }
    rescue RestClient::ExceptionWithResponse => e
      logger.error("Failed to fetch user info or playlists: #{e.response}")
      "Erro ao obter informações do usuário ou playlists: #{e.response}"
    end
  end
end