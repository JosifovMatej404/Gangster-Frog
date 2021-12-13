extends KinematicBody2D

var speed = Vector2(rand_range(10,50),150)
var gravity = 500
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var up_direction = Vector2.UP

var health
var max_health = 100
var player
var state_machine

var in_range
var shock
var healthbar
var dead 

func _ready():
	health = max_health
	shock = false
	state_machine = $AnimationTree.get("parameters/playback")
	healthbar = get_node("HealthBar/TextureProgress")
	healthbar.value = max_health
	
	in_range = false
	

func take_damage():
	health = health - player.damage
	healthbar.value = health
	shock = true
	if health <= 10:
		dead = true
	
func hurt():
	shock = true
		
func calculate_velocity(dir,vel,delta):
	var new_vel = vel
	
	
	if !is_on_floor():
		new_vel.y += gravity * delta
		
	if is_on_floor() && !in_range && !shock:	
		new_vel.x = dir * speed.x
	elif in_range && !shock:
		new_vel.x = 0
		
	if shock:
		if $AnimatedSprite.flip_h:
			new_vel = Vector2(2,-50)
		else:
			new_vel = Vector2(-2,-50)
		shock = false
		
	if dead:
		new_vel = Vector2.ZERO
				
	return new_vel
	

func _physics_process(delta):
	player = get_parent().get_node("../PlayerNode").get_node("PlayerBody")
	get_direciton()
	manage_animations()
	velocity = calculate_velocity(direction,velocity,delta)
	move_and_slide(velocity,up_direction)
	
func get_direciton():
	if !in_range:
		direction = -1 if player.get_node("CollisionShape2D").global_position.x < $CollisionShape2D.global_position.x else 1
	else:
		direction = 0
	
func manage_animations():
	if !dead:
		if !in_range:
			if velocity.y > 0 && !shock && is_on_floor():
				if direction == -1:
					state_machine.travel("Run_Left")
				else:
					state_machine.travel("Run_Right")
		elif shock:
			state_machine.travel("Hurt")
		else:
			state_machine.travel("Idle")
	else:
		state_machine.travel("Dying")
		

func _on_EnemyRange_body_entered(body):
	if body.name != "EnemyBody" && body.name != "Range" && body.name != "Ground":
		in_range = true
		


func _on_EnemyRange_body_exited(body):
	if body.name != "EnemyBody" && body.name != "Range" && body.name != "Ground":
		in_range = false
