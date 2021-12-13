extends Position2D

onready var player = get_node("../PlayerBody")

func _physics_process(_delta):
	var target = player.global_position
	var target_pos = lerp(global_position,target,0.15)
	global_position = target_pos
	
