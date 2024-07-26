require 'sinatra'
require 'rest-client'
require 'securerandom'
require 'uri'
require 'json'

class SpotifyAuth
  CLIENT_ID = 'bbbf86d4fca54a26981fff30fcf6b305'
  CLIENT_SECRET = '669ee7038f2f421da2c506a6fbe48f41'
  REDIRECT_URI = 'http://localhost:8888/callback'
  SCOPE = 'user-read-private user-read-email'

  def self.generate_state
    SecureRandom.hex(8)
  end

  def self.login_url(state)
    query_params = {
      response_type: 'code',
      client_id: CLIENT_ID,
      scope: SCOPE,
      redirect_uri: REDIRECT_URI,
      state: state
    }

    "https://accounts.spotify.com/authorize?" + URI.encode_www_form(query_params)
  end

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

enable :sessions

get '/login' do
  state = SpotifyAuth.generate_state
  session[:state] = state
  redirect SpotifyAuth.login_url(state)
end

get '/callback' do
  if params[:state] != session[:state]
    halt 400, "State mismatch"
  end

  begin
    tokens = SpotifyAuth.fetch_token(params[:code])
    "Token de acesso: #{tokens['access_token']}"
  rescue RestClient::ExceptionWithResponse => e
    status e.http_code
    "Falha ao obter o token: #{e.response}"
  end
end

#code
#AQCgTkO_TtxqCKqU4Qqs1F53dY8sSEdtPDxuya_zJwcpPvo0CNQR1uecItnfl_Hp4au-Ab2Bl4bEXDgT4o86Tw1LLXG9wr_hs3tm5lKyutxYi6d2sWqW11nUmAAGOCwvgborN6BaRu73CwhwOSjjmB7v0ezMOAueizmSAxrFDLwObu8Zw1-thfxMOTQ0-aMUm_oufk2x5cJeVDj0S-4HPWjMOWGExA&state=b30341f1604f5a79