extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_peixe_area_2d_area_entered(area: Area2D) -> void:
	Dados.acertou_peixe = true


func _on_peixe_area_2d_area_exited(area: Area2D) -> void:
	Dados.acertou_peixe = false
	
func determinar_raridade_peixe() -> int:
	return randf_range(1, 6)
	
func determinar_tempo_pesca() -> void:
	pass
