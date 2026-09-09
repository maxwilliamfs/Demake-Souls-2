extends CanvasLayer

#Atributos
var estus : int = 3
var estus_health : int = 40
var tween: Tween
var life : int = 100
var stamina : float = 100
var life_tween: Tween
var stamina_tween: Tween
var is_dead : bool = false
var souls : int = 0
var roll_stamina : int = 40
var stamina_velocity : float = 12
var estus_unlock : bool = false
var pause_time_stamina : float = 0

#Instancias
@onready var life_bar = $Control/Base_Life/Life
@onready var stamina_bar = $Control/Base_Life/Stamina
@onready var estus_animation = $Control/Invetory/Estus
@onready var souls_label = $Control/Souls_Label
@onready var estus_audio = $Control/Invetory/estus_audio

#Signals
signal death

#Funcoes Proprias
func _process(delta: float) -> void:
	if pause_time_stamina > 0:
		pause_time_stamina -= delta 
	else:
		if stamina < stamina_bar.max_value:
			stamina += stamina_velocity * delta 
			stamina_bar.value = stamina 
	souls_label.text = str(souls)
	if life <= 0 and !is_dead:
		death.emit()
		is_dead = true
	if is_dead:
		if Input.is_action_pressed("heal"):
			get_tree().reload_current_scene()


#Funcoes
func use_estus() -> void:
	if !estus_unlock:
		return
	if estus <= 0 or is_dead:
		return
	estus_audio.play()
	estus -= 1
	match estus:
		0:
			estus_animation.play("Zero")
		1:
			estus_animation.play("One")
		2:
			estus_animation.play("Two")
		3:
			estus_animation.play("Three")
	tween = create_tween()
	life = clampi(life + estus_health, 0, life_bar.max_value)
	tween.tween_property(life_bar, "value", life, 3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

#Signals
func _on_solair_damage_taken(damage: int) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	life = clampi(life - damage, 0, life_bar.max_value)
	tween.tween_property(life_bar, "value", life, 3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_solair_estus() -> void:
	use_estus()

func _on_solair_souls(value: int) -> void:
	souls += value

func _on_dialogue_estus_unlocked() -> void:
	estus_unlock = true
	estus_animation.show()

func _on_solair_stamina_s(value: int) -> void:
	if stamina < value:
		return
	if stamina_tween:
		stamina_tween.kill()
	stamina_tween = create_tween()
	stamina = clampf(stamina - value, 0, stamina_bar.max_value) 
	pause_time_stamina = 1.0
	stamina_tween.tween_property(stamina_bar, "value", stamina, pause_time_stamina).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
