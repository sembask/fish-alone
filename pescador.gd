extends CharacterBody2D

@export var player_size: Vector2i = Vector2i(250, 250)
const SPEED = 120.0
var vetor: Vector2 = Vector2.ZERO
var parado = false
var ultima_direcao = ""
var anim_loop_temp: String = ""
var is_fishing = false
var peixe_detectado = false
var fishing_timer: Timer
var original_position = Dados.personagem_position
var hud_instance
var sistema_de_pesca_scene_instance
@onready var sistema_de_pesca_scene = preload("res://sistema_de_pesca.tscn")
var cancelled_fishing = false  
var recolhendo_vara = false
var animmation_finish = false

func _ready() -> void:
	$AnimatedSprite2D.play("parado")

	fishing_timer = Timer.new()
	fishing_timer.wait_time = randf_range(3.0, 7.0)  # Tempo aleatório entre 3 e 7 segundos
	fishing_timer.one_shot = true  # Apenas dispara uma vez por vez que o jogador pesca
	fishing_timer.connect("timeout", Callable(self, "_on_fishing_timer_timeout"))
	add_child(fishing_timer)
	
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
		Dados.personagem_position.y = position.y

		fishing_timer.start()
	elif peixe_detectado and Dados.acertou_peixe:
		recolher_vara()

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

	if fishing_timer.is_stopped() == false:
		fishing_timer.stop()

	remove_child(sistema_de_pesca_scene_instance)
	$AnimatedSprite2D.stop()
	$AnimatedSprite2D.play("parado")

func recolher_vara():
	animmation_finish = true
	print("lalalala", animmation_finish)
	get_parent().hud_scene_instance.atualizar_peixes()
	remove_child(sistema_de_pesca_scene_instance)
	$AnimatedSprite2D.play("recolher_vara")
	await recolher_animacao()
	print("balela", animmation_finish)
	if animmation_finish:
		print("tocou dps do await")
		peixe_detectado = false
		is_fishing = false
		Dados.acertou_peixe = false
		print("Pegou o peixe")
		if fishing_timer.is_stopped() == false:
			fishing_timer.stop()	
		print("final - recolher_vara")

func recolher_animacao() -> void:
	await $AnimatedSprite2D.animation_finished
