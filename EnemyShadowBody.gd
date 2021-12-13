extends KinematicBody2D

var ray_speed = 2000

func _physics_process(delta):
	var enemy_speed = get_node("../EnemyBody").velocity.x
	var velocity = Vector2(0,ray_speed)
	global_position.x = get_node("../EnemyBody").global_position.x
	move_and_slide(velocity)
