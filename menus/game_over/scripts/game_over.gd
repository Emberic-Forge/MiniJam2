class_name GameOverMenu extends CanvasLayer

@export_file var main_menu_scene : String

@onready var title : Label= $layout/title
@onready var score : Label = $layout/score

@onready var retry  : Button = $layout/buttons/retry
@onready var main_menu : Button = $layout/buttons/main_menu

var world_scroller : WorldScroller2D
var progress = []
var scene_load_status = 0

func _ready() -> void:
	retry.button_down.connect(_restart_game)
	main_menu.button_down.connect(_load_main_menu)
	disable()

func init(scroller : WorldScroller2D) -> void:
	world_scroller = scroller

func enable() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	var tween = get_tree().create_tween()
	tween.tween_property(title.label_settings,"font_color", Color.WHITE,1)
	tween.tween_property(score.label_settings, "font_color", Color.WHITE,1)
	tween.parallel().tween_property(retry, "modulate", Color.WHITE, 1)
	tween.parallel().tween_property(main_menu, "modulate", Color.WHITE, 1)

func disable() -> void:
	title.label_settings.font_color = Color(0,0,0,0)
	score.label_settings.font_color = Color(0,0,0,0)
	retry.modulate = Color(0,0,0,0)
	main_menu.modulate = Color(0,0,0,0)
	process_mode = Node.PROCESS_MODE_DISABLED

func update_score(new_score : int) -> void:
	score.text = "Score: %s" % str(new_score)

func _restart_game() -> void:
	world_scroller.new_game()

func _load_main_menu() -> void:
	ResourceLoader.load_threaded_request(main_menu_scene, "", true)
	pass

func _process(delta : float) -> void:
	scene_load_status = ResourceLoader.load_threaded_get_status(main_menu_scene, progress)
	if scene_load_status == ResourceLoader.THREAD_LOAD_LOADED:
		var scene = ResourceLoader.load_threaded_get(main_menu_scene)
		get_tree().change_scene_to_packed(scene)
