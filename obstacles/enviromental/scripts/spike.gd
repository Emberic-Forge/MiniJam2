class_name Obstacle2D extends Area2D

func _on_body_entered(body : Variant) -> void:
	if body is not Player:
		return

	var player := body as Player
	player.alter_health(-1, self)
