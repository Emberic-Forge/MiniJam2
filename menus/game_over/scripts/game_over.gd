class_name GameOverMenu extends CanvasLayer

@onready var title : Label= $layout/title
@onready var score : Label = $layout/score

@onready var retry  : Button = $layout/buttons/retry
@onready var main_menu : Button = $layout/buttons/main_menu

var world_scroller : WorldScroller2D

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

func _restart_game() -> void:
	world_scroller.new_game()

func _load_main_menu() -> void:
	pass
