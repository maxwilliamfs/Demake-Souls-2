extends CharacterBody2D

#Enuns
enum state {idle,pursue,attack,cooldown}
enum diretional {left,right}

#Declaracoes de Enuns
var actual_state : state = state.idle
var actual_diretional : diretional

#Atributos
var damage : int = 30
var player : CharacterBody2D
var _velocity : int = 100
var attack_trigger : bool = false
var direction_trigger
var player_in_range : bool = false

#Pre Processamento
@export var initial_diretional : diretional

#Instacias
@onready var sprite_animation = $AnimatedSprite2D
@onready var combat_pivot = $Pivot
@onready var cooldown_timer = $CooldownTimer
@onready var range_2d = $Pivot/Range2D

func _ready() -> void:
	actual_diretional = initial_diretional
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = 2
	if initial_diretional == diretional.right:
		combat_pivot.scale.x = -1
	diretional_animation("idle_right","idle_left")

func _physics_process(delta: float) -> void:
	match actual_state:
		state.pursue:
			pursue()
		state.attack:
			attack()
		state.cooldown:
			velocity = Vector2.ZERO
			move_and_slide()

func attack() -> void:
	if !attack_trigger:
		diretional_animation("attack_right","attack_left")
		direction_trigger = global_position.direction_to(player.global_position)
		attack_trigger = true
	
	velocity = (_velocity + 70) * direction_trigger
	move_and_slide()

func pursue() -> void:
	var direction = global_position.direction_to(player.global_position)
	
	if direction.x > 0:
		actual_diretional = diretional.right
		combat_pivot.scale.x = -1
	else:
		actual_diretional = diretional.left
		combat_pivot.scale.x = 1
	diretional_animation("walk_right","walk_left")
	
	velocity = _velocity * direction
	move_and_slide()

func diretional_animation(animation1 : String, animation2 : String) -> void:
	if actual_diretional == diretional.right:
			sprite_animation.play(animation1)
	else:
			sprite_animation.play(animation2)

func _on_vision_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		if actual_state == state.idle:
			actual_state = state.pursue

func _on_range_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		if actual_state == state.pursue:
			actual_state = state.attack

func _on_animated_sprite_2d_animation_finished() -> void:
	var anim_atual = sprite_animation.animation
	if anim_atual in ["attack_right", "attack_left"] and actual_state == state.attack:
		diretional_animation("idle_right","idle_left")
		actual_state = state.cooldown
		cooldown_timer.start()

func _on_range_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

func _on_cooldown_timer_timeout() -> void:
	if actual_state != state.cooldown:
		return
	attack_trigger = false
	var player_still_in_area = false
	for corpse in range_2d.get_overlapping_bodies():
		if corpse.is_in_group("Player"):
			player_still_in_area = true
			break
	if player_still_in_area or player_in_range:
		actual_state = state.attack
	else:
		actual_state = state.pursue

func _on_hitbox_2d_area_shape_entered(area_rid: RID, area: Area2D, area_shape_index: int, local_shape_index: int) -> void:
	if area.is_in_group("player_hurtbox"):
		player = area.owner
		if player and player.has_method("take_damage"):
			player.take_damage(damage,global_position)
