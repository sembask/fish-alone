extends CanvasLayer

# Referência ao label
@onready var label_peixes = $Label

# Função para atualizar o número de peixes coletados
func atualizar_peixes():
	Dados.peixes_pescados += 1
	label_peixes.text = "Peixes Coletados: " + str(Dados.peixes_pescados)
