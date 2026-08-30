extends CharacterBody2D

#Enuns
enum state {idle,walk,attack}
enum diretional {left,right}

#Declaracoes de Enuns
var actual_state : state = state.idle
var actual_diretional : diretional

#Atributos
var player : CharacterBody2D

#Pre Processamento
@export var initial_diretional : diretional

#Instacias
@onready var sprite_animation = $AnimatedSprite2D

func _ready() -> void:
	actual_diretional = initial_diretional
	diretional_animation("idle_right","idle_left")

func _physics_process(delta: float) -> void:
	match actual_state:
		state.idle:
			pass
		state.walk:
			pass

func diretional_animation(animation1 : String, animation2 : String) -> void:
	if actual_diretional == diretional.right:
			sprite_animation.play(animation1)
	else:
			sprite_animation.play(animation2)

func _on_vision_2d_body_entered(body: Node2D) -> void:
	player = body
	if player.is_in_group("Player"):
		actual_state = state.walk
