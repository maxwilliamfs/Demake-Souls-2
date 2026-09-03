extends Area2D

#Atributo
var souls_value : int
var tween : Tween

#Instancias
@onready var soul = $"."
@onready var animated_sprite = $AnimatedSprite2D

func _process(delta: float) -> void:
	animated_sprite.play("idle")

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.take_souls(souls_value)
		tween = create_tween()
		tween.tween_property(soul,"modulate:a",0,1)
		await tween.finished
		queue_free()
