class_name Player extends CharacterBody2D

@export_group("Movement")
@export var jump_height : float = 1.5
@export_subgroup("Air")
@export var fall_multiplier : float = 1.3
@export_group("Health")
@export var max_health : int = 3

@onready var default_gravity_amm : float = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var health := max_health
@onready var sprite : AnimatedSprite2D = $sprite
@onready var jump : AudioStreamPlayer = $jump
@onready var death : AudioStreamPlayer = $death
@onready var walk_vfx :GPUParticles2D = $walk_vfx

signal on_player_death
signal on_player_damage_taken

var dead_flag : bool = false

func _process(delta : float) -> void:
	walk_vfx.emitting = is_on_floor()

	var collision = move_and_collide(Vector2.RIGHT,true)
	if collision:
		var normal := collision.get_normal()
		sprite.rotation = normal.angle() + (PI/2)
	else:
		sprite.rotation = (Vector2.RIGHT + velocity).normalized().angle()

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
	if not is_on_floor() or dead_flag:
		return

	if Input.is_action_pressed("jump"):
		velocity.y = -_calculate_jump_velocity(jump_height)
		jump.play()

func _calculate_jump_velocity(target_height : float) -> float:
	return sqrt(2*default_gravity_amm * target_height)

func hit_player() -> void:
	if is_dead():
		return
	on_player_damage_taken.emit()


func respawn(new_pos : Vector2) -> void:
	position = new_pos
	velocity = Vector2.ZERO
	health = max_health
	dead_flag = false
	sprite.visible = true

func kill(killer : Node2D) -> void:
	if is_dead():
		return
	dead_flag = true
	on_player_death.emit(killer)
	health = 0
	velocity = Vector2.ZERO
	print("Player died!")
	death.play()
	sprite.visible = false

func is_dead() -> bool:
	return dead_flag

	# Play player death anim here
