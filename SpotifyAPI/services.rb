require 'rest-client'
require 'json'
require 'base64'
require_relative 'auth'

def get_profile(access_token)
  url = "https://api.spotify.com/v1/me"

  response = RestClient.get(url,  Authorization: "Bearer #{access_token}")

  return JSON.parse(response.body)
end

def get_albums(access_token)
  url = "https://api.spotify.com/v1/me/albums/contains?ids=382ObEPsp2rxGrnsizN5TX%2C1A2GTWGtFfWp7KSQTwWOyo%2C2noRn2Aes5aoNVsU6iWThc'"

  response = RestClient.get(url, Authorization: "Bearer #{access_token}")

  return JSON.parse(response.body)
end


authorization = Authentication.new
teste = get_albums(authorization.get_token_client_authorization)
puts teste