#Vai ser um testes com APIs para estudar melhor como funciona o Rest_Client. 

require 'rest_client'
require 'json'
require_relative 'helper_date'

#Testes iniciais.
#url = 'https://668d6fe8099db4c579f2f72e.mockapi.io/characters/v1/name'


#response = RestClient.get(url)
#puts response <- Primeiro teste, horrivel, preciso de uma forma para deixar semelhante ao Postman.
#response_format = JSON.parse(response.body)
#puts response_format


class  Characters_Service_Api
  def initialize
    @base_url = "https://668d6fe8099db4c579f2f72e.mockapi.io/characters/v1/"
  end
  
  def fetch_data(endpoint)
    url = @base_url + endpoint
    response = RestClient.get(url)
    JSON.parse(response.body)
  rescue RestClient::ExceptionWithResponse => e
    puts "Erro: #{e.response}"
  rescue RestClient::Exception => e
    puts "Erro: #{e.message}"
  end

  def name
    data = fetch_data('name')
    data.each do |character|
      puts "Character #{character['name']}"
    end
  end

  def id
    data = fetch_data('name')
    data.each do |character|
      puts "ID: #{character['id']}"
    end
  end

  def all_infos
    data = fetch_data('name')
    data.each do |character|
      puts "Name: #{character['name']}, ID:#{character["id"]}"
      puts "Picture: #{character['avatar']}"
      createdAt = Helper_Date.format_brazilian_date(character['createdAt'])
      puts "Create_Date: #{createdAt}"
      puts "\n"
    end
  end
end

service = Characters_Service_Api.new
#service.name
#service.id
service.all_infos