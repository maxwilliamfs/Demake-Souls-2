extends StaticBody2D

#Enuns
enum diretional {left,right}

#Declaracoes de Enuns
@export var actual_diretional : diretional

#Atributos
var player_in_range : bool = false
var player : CharacterBody2D
var dialoging : bool = false

#Instancias
@onready var animated_sprite = $AnimatedSprite2D

#Signals
signal talk

func _ready() -> void:
	diretional_animation("idle_right","idle_left")

func _process(delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("heal") and !dialoging:
		talk.emit()
		player.dialogue()
		dialoging = true

func _on_interect_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		player_in_range = true

func _on_interect_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player_in_range = false

func _on_dialogue_cancel(finished : bool) -> void:
	player.cancel_dialogue()
	if !finished:
		dialoging = false

func diretional_animation(animation1 : String, animation2 : String) -> void:
	if actual_diretional == diretional.right:
			animated_sprite.play(animation1)
	else:
			animated_sprite.play(animation2)

func _on_dialogue_change_animation(animation: String) -> void:
	if animation == "estus":
		diretional_animation("estus_right","estus_left")
	else:
		diretional_animation("idle_right","idle_left")
