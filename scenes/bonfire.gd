extends Area2D

#Enuns
enum diretional {left,right}

#Declaracoes de Enuns
@export var actual_diretional : diretional

#Atributos
var player_in_range : bool = false
var player : CharacterBody2D

#Instancias
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	diretional_animation("idle_right")

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("heal"):
		player.bonfire()

func diretional_animation(animation1 : String) -> void:
		animated_sprite.play(animation1)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false
