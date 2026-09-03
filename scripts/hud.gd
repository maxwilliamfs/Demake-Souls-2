extends CanvasLayer

#Atributos
var estus : int = 3
var estus_health : int = 40
var tween: Tween
var life : int = 100

#Instancias
@onready var life_bar = $Control/Base_Life/Life
@onready var stamina_bar = $Control/Base_Life/Stamina
@onready var estus_animation = $Control/Invetory/Estus

#Signals
signal death

#Funcoes Proprias
func _process(_delta: float) -> void:
	if life <= 0:
		death.emit()

#Funcoes
func use_estus() -> void:
	if estus <= 0:
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
