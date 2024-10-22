extends Node2D

@onready var _MainWindow: Window = get_window()
@onready var pescador_scene = preload("res://pescador.tscn")
var pescador_scene_instance 
@onready var hud_scene = preload("res://HUD.tscn")
var hud_scene_instance
var world_offset: = Vector2i.ZERO
@onready var _MainScreen: int = _MainWindow.current_screen
@onready var _MainScreenRect: Rect2i = DisplayServer.screen_get_usable_rect(_MainScreen)

func _ready() -> void:

	pescador_scene_instance = pescador_scene.instantiate()
	add_child(pescador_scene_instance)
	
	hud_scene_instance = hud_scene.instantiate()
	add_child(hud_scene_instance)
	
	pescador_scene_instance.position = Dados.personagem_position
	_MainWindow.borderless = true
	_MainWindow.transparent_bg = true
	_MainWindow.transparent = true
	_MainWindow.always_on_top = true
	_MainWindow.unresizable = true	
	_MainWindow.gui_embed_subwindows = false
	_MainWindow.min_size = pescador_scene_instance.player_size * Vector2i(pescador_scene_instance.get_node("Camera2D").zoom)
	_MainWindow.size = _MainWindow.min_size
	
	ProjectSettings.set_setting("display/window/per_pixel_transparency/allowed", true)

	world_offset = Vector2i(_MainScreenRect.size.x / 2, _MainScreenRect.size.y)
	
func _process(delta: float) -> void:
	_MainWindow.position = get_window_pos_from_camera()

func get_window_pos_from_camera()->Vector2i:
	return (Vector2i(pescador_scene_instance.get_node("Camera2D").global_position + pescador_scene_instance.get_node("Camera2D").offset) - pescador_scene_instance.player_size / 2) * Vector2i(pescador_scene_instance.get_node("Camera2D").zoom) 
