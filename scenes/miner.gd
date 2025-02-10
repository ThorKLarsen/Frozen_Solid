extends CharacterBody2D

@onready var sound_mine: AudioStreamPlayer2D = $MineSound

@export var sprite: AnimatedSprite2D
@export var attack_hitbox: Area2D

const SPEED = 300.0
const MAX_SPEED = 500.0
const JUMP_VELOCITY = -700.0

var mining_speed: float:
	get():
		return GameData.mining_speed
var attack_damage = 1

var is_mining = false
var mining_states = [
	AnimationState.MINE,
	AnimationState.MINE_DOWN,
	AnimationState.MINE_WALL_CLIMB,
	AnimationState.MINE_WIND_DOWN,
	AnimationState.MINE_DOWN_WIND_DOWN
]
var is_wall_climbing: bool = false
var mining_direction: Vector2i = Vector2i(0, 0)
var mine_timer = 0

signal mine_block(pos: Vector2, dir: Vector2i)

func _ready():
	attack_hitbox.monitoring = false
	sprite.animation = "idle"
	sprite.play()
	name = "Miner"


func _physics_process(delta):
	
	# Update non-input related changes to the velocity
	update_velocity(delta)
	
	var wall_check = check_walls()
	is_wall_climbing = is_on_wall() and (Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right'))
	
	if Input.is_action_pressed("mine") and not (state in mining_states):
		if is_on_floor():
			if Input.is_action_pressed("ui_down"):
				set_animation_state(AnimationState.MINE_DOWN)
				mining_direction = Vector2i(0, 1)
			elif Input.is_action_pressed("ui_up"):
				set_animation_state(AnimationState.MINE)
				mining_direction = Vector2i(0, -1)
			else:
				set_animation_state(AnimationState.MINE)
				mining_direction = Vector2i(sprite.scale.x, 0)
		elif is_wall_climbing:
			if Input.is_action_pressed("ui_up"):
				set_animation_state(AnimationState.MINE_WALL_CLIMB)
				mining_direction = Vector2i(0, -1)
			else:
				set_animation_state(AnimationState.MINE_WALL_CLIMB)
				mining_direction = Vector2i(-sprite.scale.x, 0)
		
	
	if Input.is_action_pressed('ui_left'):
		if is_on_floor():
			velocity.x = move_toward(velocity.x, -MAX_SPEED, SPEED)
		else:
			velocity.x = move_toward(velocity.x, -MAX_SPEED, SPEED * delta * 15)
		if wall_check == -1:
			velocity.y = 0
	elif Input.is_action_pressed('ui_right'):
		if is_on_floor():
			velocity.x = move_toward(velocity.x, MAX_SPEED, SPEED)
		else:
			velocity.x = move_toward(velocity.x, MAX_SPEED, SPEED * delta * 15)
		if wall_check == 1:
			velocity.y = 0
	
	if Input.is_action_just_pressed("ui_accept") and not (state in mining_states):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		elif check_walls() != 0:
			velocity.y = JUMP_VELOCITY
			velocity.x = SPEED * -check_walls()
	
	if is_on_floor() and not (state in mining_states):
		if Input.is_action_pressed('ui_left') or Input.is_action_pressed('ui_right'):
			set_animation_state(AnimationState.WALK)
		else:
			set_animation_state(AnimationState.IDLE)
	elif not (state in mining_states):
		if is_wall_climbing:
			set_animation_state(AnimationState.WALL_CLIMB)
		else:
			set_animation_state(AnimationState.FALL)
	
	turn_sprite()
	move_and_slide()


func update_velocity(delta):
	if is_on_floor():
		if is_on_ice(): #If there is Ie directly below.
			velocity.x -= velocity.x * 0.3 * delta
		else:
			velocity.x = 0
	if abs(velocity.x) <= 50:
			velocity.x = 0
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y > 50:
			velocity += get_gravity() * delta * min((velocity.y/200), 2)

func is_on_ice():
	return $IceColliderLeft.is_colliding() or $IceColliderRight.is_colliding()

# Returns 1 if there is a wall immediately in positive x direction. -1 if there is a wall in negative
# x, and returns 0 if there are no walls.
func check_walls() -> int:
	if not is_on_wall():
		return 0
	else:
		if $RightWallChecker.is_colliding():
			return 1
		if $LeftWallChecker.is_colliding():
			return -1
		return 0

func turn_sprite():
	if velocity.x > 0:
		sprite.scale = Vector2(1, 1)
		sprite.position.x = 2
	elif velocity.x < 0:
		sprite.scale = Vector2(-1, 1)
		sprite.position.x = -2

enum AnimationState{
	IDLE = 0,
	WALK = 1,
	JUMP = 2,
	FALL = 3,
	MINE = 4,
	MINE_DOWN = 5,
	MINE_WIND_DOWN = 6,
	MINE_DOWN_WIND_DOWN = 7,
	WALL_CLIMB = 8,
	MINE_WALL_CLIMB = 9
}
var state = AnimationState.IDLE

func set_animation_state(new_state: AnimationState):
	if new_state == state:
		return
	state = new_state
	match(state):
		AnimationState.IDLE: 
			sprite.play("idle")
		AnimationState.WALK:
			sprite.play('walk')
		AnimationState.JUMP:
			sprite.play('jump')
		AnimationState.FALL:
			sprite.play('fall')
		AnimationState.MINE:
			sprite.play('mine', mining_speed)
			is_mining = true
		AnimationState.MINE_DOWN:
			sprite.play('mine_down', mining_speed)
			is_mining = true
		AnimationState.MINE_WALL_CLIMB:
			sprite.play("mine_wall_climb", mining_speed)
			is_mining = true
		AnimationState.WALL_CLIMB:
			sprite.play('wall_climb')
		AnimationState.MINE_WIND_DOWN:
			sprite.play('mine_wind_down', mining_speed)
		AnimationState.MINE_DOWN_WIND_DOWN:
			sprite.play('mine_down_wind_down', mining_speed)

func attack():
	attack_hitbox.monitoring = true
	for body in attack_hitbox.get_overlapping_bodies():
		attempt_attack_body(body)

func _attack_end():
	attack_hitbox.monitoring = false
	attack_hitbox.scale.x = 1

func attempt_attack_body(body: Node2D):
	if body.is_in_group('enemy'):
		body.damage(attack_damage, self)

func damage(value: float, source: Node2D):
	GameData.damage_health(value)


func place_torch(coords: Vector2i):
	pass


## === SIGNAL CATCHERS ===

func _on_animated_sprite_2d_animation_finished():
	if is_mining:
		_attack_end()
		mine_block.emit(position, mining_direction)
		if state == AnimationState.MINE:
			set_animation_state(AnimationState.MINE_WIND_DOWN)
		elif state == AnimationState.MINE_DOWN:
			set_animation_state(AnimationState.MINE_DOWN_WIND_DOWN)
		elif state == AnimationState.MINE_WALL_CLIMB:
			set_animation_state(AnimationState.WALL_CLIMB)
		
		is_mining = false	
		mining_direction = Vector2i(0, 0)
	else:
		if is_wall_climbing:
			set_animation_state(AnimationState.WALL_CLIMB)
		else:
			set_animation_state(AnimationState.IDLE)


func _on_area_2d_body_entered(body):
	attempt_attack_body(body)


func _on_animated_sprite_2d_frame_changed():
	if state in mining_states and sprite.frame == 1:
		attack()
		if state == AnimationState.MINE_WALL_CLIMB:
			attack_hitbox.scale.x = -1
		
		if state != AnimationState.MINE_WIND_DOWN and state != AnimationState.MINE_DOWN_WIND_DOWN:
			sound_mine.play()
