extends CharacterBody2D

@export var player_size: Vector2i = Vector2i(250, 250)
const SPEED = 120.0
var vetor: Vector2 = Vector2.ZERO
var parado = false
var ultima_direcao = ""
var anim_loop_temp: String = ""
var is_fishing = false
var peixe_detectado = false
var original_position = Dados.personagem_position
var hud_instance

@onready var sistema_de_pesca_scene = preload("res://sistema_de_pesca.tscn")
var sistema_de_pesca_scene_instance
var cancelled_fishing = false  
var recolhendo_vara = false
var animmation_finish = false
var raridade_peixe: float = 0

func _ready() -> void:
	$AnimatedSprite2D.play("parado")

	Dados.fishing_timer = Timer.new()
	Dados.fishing_timer.wait_time = randf_range(3.0, 7.0)  # Tempo aleatório entre 3 e 7 segundos
	Dados.fishing_timer.one_shot = true  # Apenas dispara uma vez por vez que o jogador pesca
	Dados.fishing_timer.connect("timeout", Callable(self, "_on_fishing_timer_timeout"))
	add_child(Dados.fishing_timer)
	
	sistema_de_pesca_scene_instance = sistema_de_pesca_scene.instantiate()

	$Area2D.connect("input_event", Callable(self, "_on_input_event"))

	$AnimatedSprite2D.connect("animation_finished", Callable(self, "_on_animation_finished"))
	
func _physics_process(delta: float) -> void:
	var direction = Vector2.ZERO
	
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")

	if direction != Vector2.ZERO and is_fishing:
		cancel_fishing() 
		
	if direction != Vector2.ZERO:
		vetor = direction.normalized() * SPEED
		parado = false

	else:
		vetor = Vector2.ZERO
		parado = true
		if not is_fishing:
			$AnimatedSprite2D.play("parado")

	velocity = vetor
	move_and_slide()


func _on_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		start_fishing()

func start_fishing():
	if not is_fishing:
		is_fishing = true
		$AnimatedSprite2D.play("lancar_vara")
		raridade_peixe = determinar_raridade_peixe(position.x, position.y)
		var tempo_pesca_peixe_final = tempo_pesca_peixe(raridade_peixe) 
		Dados.fishing_timer.wait_time =  raridade_peixe * tempo_pesca_peixe(raridade_peixe) 
		Dados.fishing_timer.start()
	elif peixe_detectado and Dados.acertou_peixe:
		recolher_vara()
		
func tempo_pesca_peixe(raridade_peixe) -> float:
	var raridade_int = int(raridade_peixe)
	match raridade_int:
		1,2:
			return 7
		3,4:
			return 5
		5:
			return 6
		_:
			return 10

func _on_fishing_timer_timeout():
	$AnimatedSprite2D.play("peixe_na_linha")
	peixe_detectado = true
	add_child(sistema_de_pesca_scene_instance)

func cancel_fishing():
	animmation_finish = false
	is_fishing = false
	peixe_detectado = false
	Dados.acertou_peixe = false
	cancelled_fishing = true  

	if Dados.fishing_timer.is_stopped() == false:
		Dados.fishing_timer.stop()

	remove_child(sistema_de_pesca_scene_instance)
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("parado")

func recolher_vara():
	get_parent().hud_scene_instance.atualizar_peixes()
	remove_child(sistema_de_pesca_scene_instance)
	animmation_finish = true
	$AnimatedSprite2D.play("recolher_vara")
	await recolher_animacao()
	if animmation_finish:
		peixe_detectado = false
		is_fishing = false
		Dados.acertou_peixe = false
		if Dados.fishing_timer.is_stopped() == false:
			Dados.fishing_timer.stop()	

func recolher_animacao() -> void:
	await $AnimatedSprite2D.animation_finished

func determinar_raridade_peixe(pos_x, pos_y) -> int:
	var raridade_faixas = [
		{ "min_x": 0, "max_x": 500, "min_y": 0, "max_y": 300, "raridade": randf_range(1, 2) },
		{ "min_x": 500, "max_x": 1000, "min_y": 0, "max_y": 500, "raridade": randf_range(2, 3) },
		{ "min_x": 1000, "max_x": 1500, "min_y": 0, "max_y": 600, "raridade": randf_range(3, 4) },
		{ "min_x": 1500, "max_x": 2000, "min_y": 0, "max_y": 700, "raridade": randf_range(4, 5) }
	]
	
	for faixa in raridade_faixas:
		if pos_x >= faixa["min_x"] and pos_x <= faixa["max_x"] and pos_y >= faixa["min_y"] and pos_y <= faixa["max_y"]:
			return faixa["raridade"]
	
	return 1 
