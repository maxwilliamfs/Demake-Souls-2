extends CharacterBody2D

#Enuns
enum state {free,heal,heavyatk,lightatk,damage}
enum diretional {left,right}

#Declaraçoes de Enuns
var actual_state : state = state.free
var actual_diretional : diretional

#Atributos
var vector_diretional : Vector2 = Vector2(0,0)
var velocity_ : int = 200
var knockback_vector : Vector2
var knockback_force : int = 400
var estus_taked : bool = false
var estus_qtd : int = 3

#Signals
signal damage_taken(damage : int)
signal estus

#Instancias
@onready var sprite_animation = $AnimatedSprite2D

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
		state.damage:
			diretional_animation("damage_right","damage_left")
			velocity = knockback_vector
			move_and_slide()

func processing_free() -> void:
	if Input.is_action_just_pressed("heal"):
		if estus_qtd <= 0:
			return
		actual_state = state.heal
	elif Input.is_action_just_pressed("heavy_attack"):
		actual_state = state.heavyatk
	##elif Input.is_action_just_pressed("light_attack"):
		##actual_state = state.lightatk
		##return
	
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
		sprite_animation.play("run_right")
	elif vector_diretional.x < 0:
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
			

#Signals Emiteds

func take_damage(damage : int, attacker_position : Vector2) -> void:
	actual_state = state.damage
	damage_taken.emit(damage)
	var knockback_direction: Vector2 = (global_position - attacker_position).normalized()
	knockback_vector = knockback_direction * knockback_force

#Signals Reciveds

func _on_animated_sprite_2d_animation_finished() -> void:
	actual_state = state.free
