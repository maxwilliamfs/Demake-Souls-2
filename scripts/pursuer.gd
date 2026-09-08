extends CharacterBody2D
#Enuns
enum state {idle,pursue,attack,cooldown,death}
enum diretional {left,right}

#Declaracoes de Enuns
var actual_state : state = state.pursue
var actual_diretional : diretional

#Atributos
var amplitude_float: float = 1.0
var speed_float: float = 5.0 
var time: float = 0.0
var life : int = 1000
var damage : int = 40
var player : CharacterBody2D
var _velocity : int = 150
var attack_trigger : bool = false
var direction_trigger
var attack_num : int
var souls_dropped : int = 10000
var attack_finisheds : int = 0
var player_in_range : bool = false
var actual_attack : int
var attack_dash : int = 550

#Pre Processamento
const SOUL_SCENE = preload("res://scenes/soul.tscn")
@export var initial_diretional : diretional

#Signals
signal damage_taked(damage : int)
signal defeated

#Instacias
@onready var sprite_animation = $AnimatedSprite2D
@onready var combat_pivot = $Pivot
@onready var cooldown_timer = $CooldownTimer
@onready var range_2d = $Pivot/Range2D
@onready var hitbox1 = $Pivot/Hitbox1
@onready var hitbox2 = $Pivot/Hitbox2
@onready var hitbox3 = $Pivot/Hitbox3

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	player = players[0]
	actual_diretional = initial_diretional
	cooldown_timer.one_shot = true
	cooldown_timer.wait_time = 3
	if initial_diretional == diretional.right:
		combat_pivot.scale.x = -1
	diretional_animation("idle_right","idle_left")

func _physics_process(delta: float) -> void:
	#Flutuacao
	time += delta * speed_float
	position.y += sin(time) * amplitude_float
	
	if actual_state == state.death:
		return
	if life <= 0:
		actual_state = state.death
	match actual_state:
		state.pursue:
			hitboxs_monitoring(false)
			pursue()
		state.attack:
			if attack_num == 1:
				attack1()
			elif attack_num == 2:
				attack2()
			else:
				attack3()
		state.cooldown:
			hitboxs_monitoring(false)
			velocity = Vector2.ZERO
			move_and_slide()
		state.death:
			hitboxs_monitoring(false)
			diretional_animation("death_right","death_left")
			velocity = Vector2.ZERO
			actual_state = state.death

func take_damage(damage : int,attack_position : Vector2) -> void:
	if actual_state == state.death:
		return
	life -= damage
	damage_taked.emit(damage)
	attack_trigger = false
	sprite_animation.modulate = Color(5, 5, 5, 1)
	await get_tree().create_timer(0.2).timeout
	sprite_animation.modulate = Color(1, 1, 1, 1)

func hitboxs_monitoring(mode : bool) -> void:
	hitbox1.monitoring = mode
	hitbox2.monitoring = mode
	hitbox3.monitoring = mode

func attack1() -> void:
	if !attack_trigger:
		diretional_animation("attack1_right","attack1_left")
		direction_trigger = global_position.direction_to(player.global_position)
		actualize_directio(direction_trigger)
		attack_trigger = true
		velocity = direction_trigger * attack_dash
		attack_finisheds -= 1
	velocity = velocity.lerp(Vector2.ZERO, 0.03)
	move_and_slide()

func attack2() -> void:
	if !attack_trigger:
		direction_trigger = global_position.direction_to(player.global_position)
		actualize_directio(direction_trigger)
		if attack_finisheds == 2:
			diretional_animation("attack1_right", "attack1_left")
		elif attack_finisheds == 1:
			diretional_animation("attack2_right", "attack2_left") 
		attack_trigger = true
		attack_finisheds -= 1
		velocity = direction_trigger * attack_dash
	
	velocity = velocity.lerp(Vector2.ZERO, 0.03)
	move_and_slide()

func attack3() -> void:
	if !attack_trigger:
		direction_trigger = global_position.direction_to(player.global_position)
		actualize_directio(direction_trigger)
		if attack_finisheds == 3:
			diretional_animation("attack1_right", "attack1_left")
		elif attack_finisheds == 2:
			diretional_animation("attack2_right", "attack2_left") 
		elif attack_finisheds == 1:
			diretional_animation("attack3_right", "attack3_left") 
		attack_trigger = true
		attack_finisheds -= 1
		velocity = direction_trigger * attack_dash
	
	velocity = velocity.lerp(Vector2.ZERO, 0.03)
	move_and_slide()

func actualize_directio(vector : Vector2) -> void:
	if vector.x > 0:
		actual_diretional = diretional.right
		combat_pivot.scale.x = -1
	else:
		actual_diretional = diretional.left
		combat_pivot.scale.x = 1

func pursue() -> void:
	var direction = global_position.direction_to(player.global_position)
	actualize_directio(direction)
	diretional_animation("walk_right","walk_left")
	
	velocity = _velocity * direction
	move_and_slide()

func diretional_animation(animation1 : String, animation2 : String) -> void:
	if actual_diretional == diretional.right:
			sprite_animation.play(animation1)
	else:
			sprite_animation.play(animation2)

func _on_range_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = true
		if actual_state == state.pursue:
			attack_num = randi_range(1,3)
			attack_finisheds = attack_num
			actual_state = state.attack

func _on_animated_sprite_2d_animation_finished() -> void:
	var anim_atual = sprite_animation.animation
	if actual_state == state.attack:
		if attack_finisheds <= 0:
			diretional_animation("idle_right","idle_left")
			actual_state = state.cooldown
			cooldown_timer.start()
		else:
			attack_trigger = false
	elif actual_state == state.death:
		drop_soul()
		queue_free()

func drop_soul() -> void:
	defeated.emit()
	var soul_instance = SOUL_SCENE.instantiate()
	soul_instance.souls_value = souls_dropped
	soul_instance.global_position = global_position
	soul_instance.modulate.a = 0
	get_parent().add_child(soul_instance)
	var tween = create_tween().bind_node(soul_instance)
	tween.tween_property(soul_instance,"modulate:a",1,3)
	await tween.finished

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
		attack_num = randi_range(1, 3)
		attack_finisheds = attack_num
	else:
		actual_state = state.pursue

func _on_hitbox_1_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		player = area.owner
		if player and player.has_method("take_damage"):
			player.take_damage(damage,global_position)

func _on_hitbox_2_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		player = area.owner
		if player and player.has_method("take_damage"):
			player.take_damage(damage,global_position)

func _on_hitbox_3_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_hurtbox"):
		player = area.owner
		if player and player.has_method("take_damage"):
			player.take_damage(damage,global_position)

func _on_animated_sprite_2d_frame_changed() -> void:
	var anim_atual = sprite_animation.animation
	var actual_frame = sprite_animation.frame
	if anim_atual in ["attack1_right","attack1_left"]:
		if actual_frame == 11:
			hitbox1.monitoring = true
		elif actual_frame == 14:
			hitbox1.monitoring = false
	if anim_atual in ["attack2_right","attack2_left"]:
		if actual_frame == 2:
			hitbox1.monitoring = true
		elif actual_frame == 5:
			hitbox1.monitoring = false
	if anim_atual in ["attack3_right","attack3_left"]:
		if actual_frame == 4:
			hitbox1.monitoring = true
		elif actual_frame == 7:
			hitbox1.monitoring = false
