extends CanvasLayer

#Instancias
@onready var pursuer_defeathed = $Pursuer_defeated

func _on_pursuer_defeated() -> void:
	pursuer_defeathed.show()
	pursuer_defeathed.modulate.a = 0
	var tween : Tween = create_tween()
	tween.tween_property(pursuer_defeathed, "modulate:a", 0.5, 2.0)
	tween.tween_property(pursuer_defeathed, "modulate:a", 1.0, 1.0)
	tween.tween_interval(1.0)
	tween.tween_property(pursuer_defeathed, "modulate:a", 0.5, 2.0)
	tween.tween_property(pursuer_defeathed, "modulate:a", 0.0, 1.0)
	await tween.finished
	pursuer_defeathed.hide()
