extends KinematicBody2D

var ray_speed = 2000

func _physics_process(delta):
	var player_speed = get_node("../PlayerBody").velocity.x
	var velocity = Vector2(0,ray_speed)
	global_position.x = get_node("../PlayerBody").global_position.x
	move_and_slide(velocity)
