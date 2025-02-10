extends CharacterBody2D

signal killed()

@export var player: CharacterBody2D
@export var ray_los: RayCast2D

const SPEED = 200.0

const detection_distance = 28

var health = 3
var attack_damage = 5

var is_idle = true
var is_stunned = false
var stun_timer = 0
var idle_timer: float = 5.0
var idle_wait: float = 5.0

func _physics_process(delta):
	check_los()
	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			is_stunned = false
		velocity = velocity.move_toward(Vector2(0, 0), SPEED/10)
		
	elif is_idle:
		idle_timer += delta
		if idle_timer >= idle_wait:
			idle_timer -= idle_wait
			if velocity.length() == 0:
				velocity = Vector2(1, 0)
			velocity = velocity.project(Vector2(1, 0))
			velocity = velocity.normalized() * SPEED/5
		if is_on_wall():
			velocity *= -1
			
	else:
		var desired_vel = position.direction_to(player.position) * SPEED
		velocity = velocity.move_toward(desired_vel, SPEED)
		
		#velocity = velocity.limit_length(SPEED)
	
	move_and_slide()

func check_los():
	ray_los.target_position = position.direction_to(player.position) * position.distance_to(player.position)
	var distance = position.distance_to(player.position)
	if distance <= detection_distance and (not ray_los.is_colliding()):
		is_idle = false
	else:
		is_idle = true

func damage(value: float, source: Node2D):
	health -= value
	if health <= 0:
		kill()
	
	#knockback on hit
	var direction = sign(position.direction_to(source.position).x)
	velocity = Vector2(4*SPEED * -direction, -SPEED)
	stun()

func stun(time: float = 0.5):
	is_stunned = true
	stun_timer = time

func kill():
	killed.emit()
	queue_free()


func _on_area_2d_body_entered(body):
	if body == player:
		player.damage(attack_damage, self)
