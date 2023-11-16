extends CharacterBody2D

# mvoement
const SPEED := 300.0
var JUMP_VELOCITY := -325.0

# gravity
var gravity = Game.gravity

# tilemap
var current_terrain: int = 0

# coyote timer and jump buffer
var is_jumping = false
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer = $JumpBuffer
@onready var right_cast = $RightCast
@onready var left_cast = $LeftCast
const preload_gun = preload("res://scenes/items/gun.tscn")
@onready var actionable_finder: Area2D = $Direction/ActionableFinder

@onready var up_cast = $UpCast
@onready var down_cast = $DownCast
var current_up_collides = []
var previous_up_collides = []

var direction = Input.get_axis("ui_left", "ui_right")
var knockback = Vector2(0,0)
var hurt = false
var big_fall = false

# singleton
@onready var Audio = get_tree().root.get_node("Audio")


func spawn_gun() -> void:
	var gun = preload_gun.instantiate()
	self.add_child(gun)
	gun.position.y = -16

func remove_gun() -> void:
	var gun = $gun
	self.remove_child(gun)
	
func _on_Game_has_gun_signal() -> void:
	if Game.has_gun == true:
		self.spawn_gun()
	else:
		self.remove_gun()
	
func _ready():
	Game.has_gun_signal.connect(_on_Game_has_gun_signal)
	if Game.has_gun == true:
		self.spawn_gun()

# actions to perform when jumping (both player controlled or frog hopping)
func jump(vel : float = self.JUMP_VELOCITY):
	# prevent double jumps
	jump_buffer.stop()
	coyote_timer.stop()
	# jump
	velocity.y = vel
	# anim.play("Jump")
	Audio.get_node("jump").play()
	is_jumping = true

func jump_cut():
	if gravity > 0:
		if velocity.y < -100:
			velocity.y = -100
	else:
		if velocity.y > 100:
			velocity.y = 100



func _unhandled_input(_event: InputEvent) -> void:
	# Handle Dialogue.
	if Input.is_action_just_pressed("ui_accept"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return
#		if actionables.size() == 0:
#			for balloon in get_tree().get_nodes_in_group("dialogue"):
#				# balloon.queue_free()
#				pass
					


func _physics_process(delta):
	
	# check for big fall
	if abs(velocity.y) > 500:
		big_fall = true
		
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.y >= 0:
		is_jumping = false
		
	# Perform actions only when not hurt
	if not hurt:
		
		# Handle Jump.
		if Input.is_action_just_pressed("ui_up"):
			if is_on_floor() or !coyote_timer.is_stopped():
				self.jump()
			else:
				jump_buffer.start()
		if Input.is_action_just_released("ui_up"):
			self.jump_cut()
		# Perform movement and other inputs based on terrain type
		# Also perform this when changing terrain
		do_terrain_action()
	
	
	# move and slide
	var was_on_floor = is_on_floor()
	move_and_slide()
	

	
	
	
	# crates
	# stand on crates method 1 (collision layers)
#	if down_cast.is_colliding():
#		var c = down_cast.get_collider()
#		if c:
#			if c.is_in_group("moveable"):
#				if !c.get_collision_layer_value(1):
#					c.set_collision_layer_value(1, true)
#					print("ON collision")
	# stand on crates method 2 (area2d)
	# see signal methods below
		
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider.is_in_group("moveable"):
			if collider is RigidBody2D:
				# apply force to move crates
				if right_cast.is_colliding() or left_cast.is_colliding():
					if collision.get_normal().is_normalized():
						var impulse_dir = -1 * collision.get_normal()
						var impulse_force = 1000.0
						var impulse = impulse_dir * impulse_force
						collider.apply_central_force(impulse)
				
					
				
	
	
	# play sound for falls
	if !was_on_floor and is_on_floor():
		# print("just landed")
		if big_fall:
			Audio.get_node("bigfall").play()
			big_fall = false
		else:
			# Audio.get_node("fall").play()
			pass
		
		
	# coyote time and jump buffer
	if was_on_floor and !is_on_floor() and !is_jumping:
		coyote_timer.start()
	if is_on_floor() and !jump_buffer.is_stopped() and !is_jumping:
		self.jump()




func _on_terrain_detector_terrain_entered(ter: int):
	# set current terrain from terrain_detector area signal
	self.current_terrain = ter
	# Check for wall bounce collisions / sound
	if self.current_terrain == 1 or self.current_terrain == 2:
		if right_cast.is_colliding() or left_cast.is_colliding():
			Audio.get_node("wallhit").play()
	# do the thing
	self.do_terrain_action()
	

# regular movement
func move():
	direction = Input.get_axis("ui_left", "ui_right")
	if direction: # true if vector is non-zero (-1 or 1)
		velocity.x = (direction * SPEED)
		if direction > 0:
			actionable_finder.scale = Vector2(1,1)
		else:
			actionable_finder.scale = Vector2(-1,-1)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)


func do_terrain_action():
	match self.current_terrain:
		0: # NONE / AIR
			move()
		1: # REVERSE
			velocity.x = move_toward(velocity.x, -1*SPEED, SPEED)
		2: # FAST
			velocity.x = move_toward(velocity.x, 1*SPEED, SPEED)
		3: # SPIKE
			Audio.get_node("player_death").play()
			Game.death_counter += 1
			Game.resetLevel()


func _on_gravity_flip_body_entered():
	# print("grav")
	Audio.get_node("gravity").play()
	# update game vars
	Game.gravity = -1 * Game.gravity
	Game.crate_gravity = sign(Game.gravity) * 9
	# update player vars
	if Game.gravity > 0:
		$crate_detector.position.y = -32
	else:
		$crate_detector.position.y = 0
	gravity = Game.gravity
	up_direction = -1 * up_direction
	JUMP_VELOCITY = -1 * JUMP_VELOCITY
	up_cast.target_position = -1 * up_cast.target_position
	down_cast.target_position = -1 * down_cast.target_position
	# floor_max_angle = PI - floor_max_angle
	
	
func _on_door_body_entered(_body):
	Game.nextLevel()
	





func _on_crate_detector_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is RigidBody2D:
		body.set_collision_layer_value(1, false)
		# print(body)


func _on_crate_detector_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is RigidBody2D:
		body.set_collision_layer_value(1, true)
		# print(body)
