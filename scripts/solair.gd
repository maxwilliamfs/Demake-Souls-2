extends CharacterBody2D

#Enuns
enum state {free,heal,heavyatk,lightatk,damage,death}
enum diretional {left,right}

#Declaraçoes de Enuns
var actual_state : state = state.free
var actual_diretional : diretional

#Atributos
var vector_diretional : Vector2 = Vector2(0,0)
var velocity_ : int = 200
var knockback_vector : Vector2
var knockback_force : int = 300
var estus_taked : bool = false
var estus_qtd : int = 3
var heavy_damage : int = 50
var light_damage : int = 30

#Signals
signal damage_taken(damage : int)
signal estus
signal souls(value : int)

#Instancias
@onready var sprite_animation = $AnimatedSprite2D
@onready var pivot = $Pivot
@onready var solair = $"."
@onready var heavy_hitbox = $Pivot/HeavyHitBox2D
@onready var light_hitbox = $Pivot/LightHitBox2D

#Funcoes padroes
func _physics_process(_delta: float) -> void:
	match actual_state:
		state.free:
			estus_taked = false
			processing_free()
		state.heal:
			diretional_animation("healing_right","healing_left")
			if !estus_taked:
				estus.emit()
				estus_qtd -= 1
				estus_taked = true
		state.heavyatk:
			diretional_animation("heavyatk_right","heavyatk_left")
			heavy_hitbox.show()
		state.lightatk:
			diretional_animation("lightatk_right","lightatk_left")
			light_hitbox.show()
		state.damage:
			diretional_animation("damage_right","damage_left")
			velocity = knockback_vector
			move_and_slide()
		state.death:
			velocity = Vector2.ZERO
			move_and_slide()
			pivot.hide()

func processing_free() -> void:
	if Input.is_action_just_pressed("heal"):
		if estus_qtd <= 0:
			return
		actual_state = state.heal
	elif Input.is_action_just_pressed("heavy_attack"):
		actual_state = state.heavyatk
	elif Input.is_action_just_pressed("light_attack"):
		actual_state = state.lightatk
	
	#Movimento Horizontal
	if Input.is_action_pressed("mov_right"):
		vector_diretional.x = 1
		actual_diretional = diretional.right
	elif Input.is_action_pressed("mov_left"):
		vector_diretional.x = -1
		actual_diretional = diretional.left
	else:
		vector_diretional.x = 0
	
	#Movimento Vertical
	if Input.is_action_pressed("mov_up"):
		vector_diretional.y = -1
	elif Input.is_action_pressed("mov_down"):
		vector_diretional.y = 1
	else:
		vector_diretional.y = 0
	
	choose_animation()
	velocity = vector_diretional * velocity_ 
	move_and_slide()

func choose_animation() -> void:
	if vector_diretional.x > 0:
		pivot.scale.x = -1
		sprite_animation.play("run_right")
	elif vector_diretional.x < 0:
		pivot.scale.x = 1
		sprite_animation.play("run_left")
	elif vector_diretional.y != 0:
		diretional_animation("run_right","run_left")
	else:
		diretional_animation("idle_right","idle_left")

func diretional_animation(animation1 : String, animation2 : String) -> void:
	if actual_diretional == diretional.right:
			sprite_animation.play(animation1)
	else:
			sprite_animation.play(animation2)

func take_souls(value : int) -> void:
	souls.emit(value)

#Signals Emiteds
func take_damage(damage : int, attacker_position : Vector2) -> void:
	if actual_state == state.death:
		return
	actual_state = state.damage
	var knockback_direction: Vector2 = (global_position - attacker_position).normalized()
	knockback_vector = knockback_direction * knockback_force
	damage_taken.emit(damage)

#Signals Reciveds
func _on_animated_sprite_2d_animation_finished() -> void:
	if actual_state == state.death:
		solair.hide()
		set_physics_process(false)
		return
	actual_state = state.free

func _on_hud_death() -> void:
	actual_state = state.death
	diretional_animation("death_right","death_left")

func _on_heavy_hit_box_2d_area_entered(area: Area2D) -> void:
	var enemy = area.owner
	if enemy.has_method("take_damage"):
		enemy.take_damage(heavy_damage,global_position)

func _on_light_hit_box_2d_area_entered(area: Area2D) -> void:
	var enemy = area.owner
	if enemy.has_method("take_damage"):
		enemy.take_damage(light_damage,global_position)

func _on_animated_sprite_2d_frame_changed() -> void:
	if actual_state == state.heavyatk:
		match sprite_animation.frame:
			3:
				heavy_hitbox.monitoring = true
			6:
				heavy_hitbox.monitoring = false
				velocity = Vector2.ZERO
	if actual_state == state.lightatk:
		match sprite_animation.frame:
			4:
				light_hitbox.monitoring = true
			11:
				light_hitbox.monitoring = false
				velocity = Vector2.ZERO
