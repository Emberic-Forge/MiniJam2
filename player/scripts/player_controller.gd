class_name Player extends CharacterBody2D

@export_group("Movement")
@export var movement_speed : float = 3.0
@export var jump_height : float = 1.5
@export_subgroup("Air")
@export var fall_multiplier : float = 1.3

@onready var default_gravity_amm : float = ProjectSettings.get_setting("physics/2d/default_gravity")

func _physics_process(delta : float) -> void:
	_handle_gravity(delta)
	_handle_jump()

	move_and_slide()

func _handle_gravity(delta : float) -> void:
	if is_on_floor():
		return
	var grav_amm := default_gravity_amm * fall_multiplier if velocity.y < 0.1 else default_gravity_amm
	velocity.y += grav_amm * delta


func _handle_jump() -> void:
	if not is_on_floor():
		return

	if Input.is_action_pressed("jump"):
		velocity.y = -_calculate_jump_velocity(jump_height)


func _calculate_jump_velocity(target_height : float) -> float:
	return sqrt(2*default_gravity_amm * target_height)
