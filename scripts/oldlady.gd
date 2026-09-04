extends StaticBody2D

#Instancias
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	animated_sprite.play("idle_right")
