extends CanvasLayer

#Atributos
var life : int = 1000
var tween : Tween = create_tween()

#Instancias
@onready var life_bar = $life/life_bar
@onready var pursuer_defeathed = $Pursuer_defeated

func _on_pursuer_defeated() -> void:
	pursuer_defeathed.show()
	pursuer_defeathed.modulate.a = 0
	tween.tween_property(pursuer_defeathed, "modulate:a", 0.5, 2.0)
	tween.tween_property(life_bar, "modulate:a", 0, 2.0)
	tween.tween_property(pursuer_defeathed, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(pursuer_defeathed, "modulate:a", 0.5, 2.0)
	tween.tween_property(pursuer_defeathed, "modulate:a", 0.0, 1.0)
	await tween.finished
	pursuer_defeathed.hide()


func _on_pursuer_damage_taked(damage: int) -> void:
	if tween:
		tween.kill()
	tween = create_tween()
	life = clampi(life - damage, 0, life_bar.max_value)
	tween.tween_property(life_bar, "value", life, 2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
