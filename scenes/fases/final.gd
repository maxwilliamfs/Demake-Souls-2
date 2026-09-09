extends Node2D

@onready var final = $Sprite2D
var tween : Tween

func _on_bonfire_bonfire() -> void:
	get_tree().change_scene_to_file("res://scenes/fases/tank.tscn")
