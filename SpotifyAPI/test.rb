list = [1, 10, 8, 9, 11]

# Implementando bubble sort para ordenar a lista do maior para o menor
# Aqui e um dos meus testes para ordenar as musicas mais escutadas do maior para o menos.

# Pega o tamanho do interavel.
n = list.length
#Inicia o loop.
loop do
  # e uma variavel de CONTROLE onde vou usa-la para finalizar o loop
  swapped = false
  #Aqui eu pego a possicao -1 e faco dela um |i| = |item|
  (n-1).times do |i|
    #Aqui comeca a ordenacao, IF "item" da lista for <menor< que o "item" a sua frente.
    if list[i] < list[i+1]
      #Aqui faz a troca de possicao, caso for true na linha acima a ordem e alterar os itens.
      list[i], list[i+1] = list[i+1], list[i]
      #Variavel de controle =  true encerra o loop.
      swapped = true
    end
  end
  break unless swapped
end

puts list