require 'rest-client'
require 'json'
#Metodo de autenticação temporário, enquanto não arrumo o arquivo de autenticação.

HEADERS = {Authorization: "Bearer BQBbd4mwboO5Z36eYkzbr44VSHAeRYVY2ayeTKjwURbMVD09qcGedzIz4CvkKdmiYHdOrbLWc7zDNsMxrOfzZYXNft6hG8Mz3vNilxRI7BfQ64ruI2H_c94SZ8_lD2stiW-45LgxQiBFkb4Z5-lIA01AQMTJCHZwqWANHXJnwRlMsaxpBDrxSAY59Fan5tYjaTA"}

#profile_data = RestClient.get("https://api.spotify.com/v1/me", headers)

#data = JSON.parse(profile_data.body)
#puts data

def get_profile(access_token)
  url = "https://api.spotify.com/v1/me"

  response = RestClient.get(url,  Authorization: "Bearer #{access_token}")

  return JSON.parse(response.body)
end

puts profile.get_profile(HEADERS)

def get_albums(access_token)
  url = "https://api.spotify.com/v1/me/albums"

  response = RestClient.get(url, Authorization: "Bearer #{access_token}")

  return JSON.parse(response.body)
end

puts albums.get_albums(HEADERS)