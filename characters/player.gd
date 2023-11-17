extends CharacterBody2D

# constants
const preload_gun = preload("res://scenes/items/gun.tscn")

# movement and jump
const SPEED := 300.0
var JUMP_VELOCITY := -325.0
var gravity = Game.gravity
var current_terrain: int = 0
var is_jumping = false
var big_fall = false

var direction = Input.get_axis("ui_left", "ui_right")
@onready var coyote_timer = $CoyoteTimer
@onready var jump_buffer = $JumpBuffer

# raycasts
@onready var right_cast = $RightCast
@onready var left_cast = $LeftCast
@onready var up_cast = $UpCast
@onready var down_cast = $DownCast

# actionable finder
@onready var actionable_finder: Area2D = $Direction/ActionableFinder

# nocturne
signal nocturne
var tween_started = false


func _ready():
	if Audio.get_node("nocturne").playing:
		print("stop")
		Audio.get_node("nocturne").stop()

	Game.has_gun_signal.connect(_on_Game_has_gun_signal)
	if Game.has_gun == true:
		self.spawn_gun()


func _unhandled_input(_event: InputEvent) -> void:
	# Handle dialogue input
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			var dstart = actionables[0].get_parent().get_dialogue_start()
			actionables[0].action({"start" = dstart})
			direction = Vector2.ZERO
			return
	
	# Handle jump input
	if Input.is_action_just_pressed("ui_up"):
		if is_on_floor() or !coyote_timer.is_stopped():
			self.jump()
		else:
			jump_buffer.start()
	if Input.is_action_just_released("ui_up"):
		self.jump_cut()
	
	# Handle movement input
	direction = Input.get_axis("ui_left", "ui_right")


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


func _on_music_tween_completed():
	print("end tween")
	# stop the music -- otherwise it continues to run at silent volume
	Audio.get_node("background_music").stop()
	Audio.get_node("background_music").volume_db = -10 # reset volume
	# play
	Audio.get_node("nocturne").play()
	nocturne.emit()
	
	
func _physics_process(delta):

	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	if velocity.y >= 0:
		is_jumping = false
	
	# Check for big fall
	if abs(velocity.y) > 500:
		big_fall = true
	
	# Check for nocturne
	if get_tree().get_current_scene().name == "Level_1":
		if self.global_position.y > 10000:
			if !Audio.get_node("nocturne").playing:
				if !tween_started:
					print("start tween")
					# Game.gravity = 0.0
					# gravity = Game.gravity
					var tween = get_tree().create_tween()
					tween.tween_property(Audio.get_node("background_music"), "volume_db", -80, 3.00)
					tween.tween_callback(_on_music_tween_completed)
					tween_started = true

	
	# Reset position
	if self.global_position.y > 900000:
		self.global_position.y = 10000
	
	# Perform movement and other inputs based on terrain type
	# Also perform this when changing terrain?
	match self.current_terrain:
		0: # NONE / AIR
			if direction: # true if vector is non-zero (-1 or 1)
				velocity.x = (direction * SPEED)
				if direction > 0:
					actionable_finder.scale = Vector2(1,1)
				else:
					actionable_finder.scale = Vector2(-1,-1)
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
		1: # REVERSE
			velocity.x = move_toward(velocity.x, -1*SPEED, SPEED)
		2: # FAST
			velocity.x = move_toward(velocity.x, 1*SPEED, SPEED)
		3: # SPIKE
			Audio.get_node("player_death").play()
			Game.death_counter += 1
			Game.resetLevel()
		_: # OTHER
			print("invalid terrain")
	
	# move and slide
	var was_on_floor = is_on_floor()
	move_and_slide()
	
	# move crates
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
	
func _on_door_body_entered(_body):
	Game.nextLevel()

func _on_crate_detector_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is RigidBody2D:
		body.set_collision_layer_value(1, false)
		body.set_collision_layer_value(5, false)

func _on_crate_detector_body_shape_exited(_body_rid, body, _body_shape_index, _local_shape_index):
	if body is RigidBody2D:
		body.set_collision_layer_value(1, true)
		body.set_collision_layer_value(5, true)
		
func _on_Game_has_gun_signal() -> void:
	if Game.has_gun == true:
		self.spawn_gun()
	else:
		self.remove_gun()
		
func spawn_gun() -> void:
	var gun = preload_gun.instantiate()
	self.add_child(gun)
	gun.position.y = -16

func remove_gun() -> void:
	var gun = $gun
	self.remove_child(gun)
	
