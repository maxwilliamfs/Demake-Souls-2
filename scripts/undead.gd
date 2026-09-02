extends CharacterBody2D

#Enuns
enum state {idle,pursue,attack}
enum diretional {left,right}

#Declaracoes de Enuns
var actual_state : state = state.idle
var actual_diretional : diretional

#Atributos
var player : CharacterBody2D
var _velocity : int = 100

#Pre Processamento
@export var initial_diretional : diretional

#Instacias
@onready var sprite_animation = $AnimatedSprite2D
@onready var combat_pivot = $Pivot

func _ready() -> void:
	actual_diretional = initial_diretional
	diretional_animation("idle_right","idle_left")

func _physics_process(delta: float) -> void:
	match actual_state:
		state.pursue:
			pursue()

func pursue() -> void:
	var direcao = global_position.direction_to(player.global_position)
	
	if direcao.x > 0:
		actual_diretional = diretional.right
	else:
		actual_diretional = diretional.left
	diretional_animation("walk_right","walk_left")
	
	velocity = _velocity * direcao
	move_and_slide()

func diretional_animation(animation1 : String, animation2 : String) -> void:
	if actual_diretional == diretional.right:
			sprite_animation.play(animation1)
	else:
			sprite_animation.play(animation2)

func _on_vision_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		player = body
		actual_state = state.pursue

func _on_range_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.

func _on_hitbox_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
