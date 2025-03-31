class_name MainMenuLayer extends CanvasLayer

@export_file var game_scene : String
@export_file var options_menu : String

@onready var play : Button = $elements/play
@onready var options : Button = $elements/options

var scene_load_status = 0
var progress = []

func _ready() -> void:
	play.button_down.connect(_on_game_start)
	options.button_down.connect(_on_options_enable)

func _on_game_start() -> void:
	ResourceLoader.load_threaded_request(game_scene,"", true)


func _on_options_enable() -> void:
	var ins = load(options_menu).instantiate()
	add_child(ins)


func _process(delta : float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(game_scene, progress)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get(game_scene)
		get_tree().change_scene_to_packed(scene)
