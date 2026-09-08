extends CanvasLayer

@onready var death_label = $Death_label
@onready var death_timer = $DeathTimer
@onready var death_audio = $Death_audio



func _on_hud_death() -> void:
	death_audio.play()
	death_timer.start()

func _on_death_timer_timeout() -> void:
	death_label.show()
	death_label.modulate.a = 0.0 
	var tween = create_tween()
	tween.tween_property(death_label, "modulate:a", 1.0, 2.5)
