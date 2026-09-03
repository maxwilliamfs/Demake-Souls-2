extends CanvasLayer

#Atributos
var Estus : int = 3
var tween: Tween

#Instancias
@onready var life_bar = $Control/Base_Life/Life
@onready var stamina_bar = $Control/Base_Life/Stamina

#Signals
func _on_solair_damage_taken(damage: int) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	var new_life : int = (life_bar.value - damage)
	tween.tween_property(life_bar, "value", new_life, 3).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _on_solair_estus() -> void:
	pass # Replace with function body.
