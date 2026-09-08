extends CanvasLayer

#Atributos
var estus : int = 3
var estus_health : int = 40
var tween: Tween
var life : int = 100
var is_dead : bool = false
var souls : int = 0
var estus_unlock : bool = false

#Instancias
@onready var life_bar = $Control/Base_Life/Life
@onready var stamina_bar = $Control/Base_Life/Stamina
@onready var estus_animation = $Control/Invetory/Estus
@onready var death_timer = $Death/DeathTimer
@onready var death_scene = $Death
@onready var death_audio = $Death/Death_audio
@onready var souls_label = $Control/Souls_Label

#Signals
signal death

#Funcoes Proprias
func _process(_delta: float) -> void:
	souls_label.text = str(souls)
	if life <= 0 and !is_dead:
		death.emit()
		death_timer.start()
		is_dead = true
		death_audio.play()
	
	if is_dead:
		if Input.is_action_pressed("heal"):
			get_tree().reload_current_scene()


#Funcoes
func use_estus() -> void:
	if !estus_unlock:
		return
	if estus <= 0 or is_dead:
		return
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


func _on_death_timer_timeout() -> void:
	death_scene.show()
	death_scene.modulate.a = 0.0 
	var tween = create_tween()
	tween.tween_property(death_scene, "modulate:a", 1.0, 2.5)

func _on_solair_souls(value: int) -> void:
	souls += value
