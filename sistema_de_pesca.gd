extends Area2D
@onready var pescador_scene = preload("res://pescador.tscn")
var pescador_scene_instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pescador_scene_instance = pescador_scene.instantiate()
	add_child(pescador_scene_instance)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_peixe_area_2d_area_entered(area: Area2D) -> void:
	Dados.acertou_peixe = true


func _on_peixe_area_2d_area_exited(area: Area2D) -> void:
	Dados.acertou_peixe = false
	
func determinar_tempo_pesca() -> void:
	pass
