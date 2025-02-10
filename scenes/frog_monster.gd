extends CharacterBody2D

signal killed()

@export var player: CharacterBody2D
@export var ray_los: RayCast2D
@export var sprite: AnimatedSprite2D

const SPEED = 200.0
const JUMP_SPEED = 600

const detection_distance = 50

var health = 5
var attack_damage = 10

var is_idle = true
var is_stunned = false
var stun_timer = 0
var idle_timer: float = 5.0
var idle_wait: float = 5.0

var jump_timer: float = 0.0
var jump_wait: float = 2.0

func _physics_process(delta):
	check_los()
	
	if is_on_floor():
		jump_timer += delta
		if sprite.animation == 'jump':
			sprite.play('land')
		velocity = Vector2(0, 0)
		if jump_timer >= jump_wait:
			jump_timer -= jump_wait
			if is_idle:
				jump(delta)
			else:
				var dist = position.direction_to(player.position)* position.distance_to(player.position)
				jump(delta, dist.x)
	else:
		velocity += get_gravity() * delta
	
	move_and_slide()

func jump(delta, dist = null):
	sprite.play('jump')
	if dist == null:
		velocity += Vector2(randf_range(-1, 1) * JUMP_SPEED/8, -JUMP_SPEED)
	else:
		var t = 2 * (JUMP_SPEED/get_gravity().length())
		velocity += Vector2(dist*Constants.game_scale/(t), -JUMP_SPEED)

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
	velocity += Vector2(JUMP_SPEED/2 * -direction, -JUMP_SPEED)
	move_and_slide()
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
