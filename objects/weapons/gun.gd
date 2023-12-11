extends Node2D

const bulletPath = preload("res://objects/projectiles/bullet.tscn")
var canShoot = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	look_at(get_global_mouse_position())
	if Input.is_action_just_pressed("shoot"):
		if canShoot == true:
			canShoot = false
			shoot()

func createBullet():
	var bullet = bulletPath.instantiate()
	get_parent().get_parent().add_child(bullet)
	bullet.global_position = $Marker2D.global_position
	bullet.direction = (get_global_mouse_position() - self.global_position).normalized()
	bullet.velocity = bullet.direction * bullet.SPEED
	# add opposing velocity to player
	self.get_parent().velocity.x = -1 * bullet.direction.x * bullet.PSPEEDX
	self.get_parent().velocity.y = -1 * bullet.direction.y * bullet.PSPEEDY
	Audio.get_node("shoot").play()
	
func shoot():
	$ShootTimer.start()
	$Sprite2D.position.x -= 5
	$Sprite2D.rotation_degrees -= 5
	createBullet()

func _on_shoot_timer_timeout():
	$Sprite2D.position.x += 5
	$Sprite2D.rotation_degrees += 5
	canShoot = true
