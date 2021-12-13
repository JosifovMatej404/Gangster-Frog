extends KinematicBody2D

var speed = Vector2(100,150)
var gravity = 300
var direction = Vector2.ZERO
var velocity = Vector2.ZERO
var up_direction = Vector2.UP
var idle
var jumping
var attacking
var landing
var attack1
var attack2
var attack3
var running
var state_machine

var damage
var in_range
var take_damage
var Enemybody
var enemies = 3
func _ready():
	state_machine = $AnimationTree.get("parameters/playback")
	damage = 10
	in_range = false
	take_damage = false

func _physics_process(delta):
	direction = get_direction()
	velocity = calculate_velocity(direction, velocity, delta)
	player_input()
	manage_animations()
	move_and_slide(velocity,up_direction)
	
func calculate_velocity(dir,vel, delta):
	var new_vel = vel
	
	new_vel.x = dir.x * speed.x 
	
	if !is_on_floor():
		new_vel.y += gravity * dir.y * delta
	elif Input.is_action_just_pressed("jump") && !jumping:
		new_vel.y = -speed.y
		
	if  is_on_floor() && new_vel.x == 0 && !attacking && !jumping && !running:
		idle = true
	else:
		idle = false
		
	if attacking:
		new_vel = Vector2.ZERO
	
	return new_vel
	
func get_direction():
	return Vector2(
		Input.get_action_strength("run_right") -  Input.get_action_strength("run_left"),
		-1 if Input.is_action_just_pressed("jump") else 1)
		
		
func player_input():
	if Input.is_action_just_pressed("attack") && is_on_floor():
		attacking = true
		attack1 = true
		
	if Input.get_action_strength("run_right") - Input.get_action_strength("run_left") != 0 && is_on_floor():
		running = true 
	else:
		running = false
		
	if is_on_floor() && direction.y == -1 && !jumping:
		jumping = true
	
func manage_animations():
	if !landing:
		if !idle && !attacking && is_on_floor() && running && !jumping:
			if Input.is_action_pressed("run_left"):
				state_machine.travel("run_left")
			elif Input.is_action_pressed("run_right"):
				state_machine.travel("run_right")
		elif attacking:
			if attack1:
				state_machine.travel("Punch")
			if attack2:
				state_machine.travel("Punch2")
			if attack3:
				state_machine.travel("Punch3")
		elif jumping:
			state_machine.travel("Jump_loop")
				
		elif idle:
			state_machine.travel("idle")
	else:
		state_machine.travel("Land")
		
func finish_attack():
	attack1 = false
	if Input.is_action_pressed("attack"):
		attack2 = true
	else:
		attacking = false
	
func finish_attack_2():
	attack2 = false
	if Input.is_action_pressed("attack"):
		attack3 = true
	else:
		attacking = false

func finish_attack_3():
	attack3 = false
	attacking = false
	
func finish_jump():
	jumping = false
	
func finish_landing():
	landing = false
	
func damage():
	if in_range && !Enemybody.dead:
		Enemybody.take_damage()
	

func _on_GroundDetector_body_entered(body):
	if body.name == "Ground" && jumping:
		landing = true

func AOE():
	for i in enemies:
		var enemy = get_parent().get_node("../EnemyNode" + str(i)).get_node("EnemyBody")
		if enemy.in_range:
			enemy.take_damage()
			print("yes")

func _on_Range_body_exited(body):
	if body.name != "PlayerBody" && body.name != "Walls":
		in_range = false

func _on_Range_body_entered(body):
	if body.name != "PlayerBody" && body.name != "Walls":
		in_range = true
		Enemybody = body

