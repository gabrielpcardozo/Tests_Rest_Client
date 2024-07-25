require "rest-client"
require "json"
require "base64"


class Authentication
  @@auth = {
    CLIENT_ID: "bbbf86d4fca54a26981fff30fcf6b305",
    CLIENT_SECREAT:'669ee7038f2f421da2c506a6fbe48f41',
  }  
  
  def get_token_client_authorization
    url = 'https://accounts.spotify.com/api/token'
    auth = Base64.strict_encode64("#{@@auth[:CLIENT_ID]}:#{@@auth[:CLIENT_SECREAT]}")
  
    response = RestClient.post(url, { grant_type: 'client_credentials' },
                               Authorization: "Basic #{auth}",
                               Content_Type: 'application/x-www-form-urlencoded')
    access_token = JSON.parse(response.body)['access_token']
    return access_token 
  end
end


#teste = Authentication.new
#puts teste.get_token_client_authorization