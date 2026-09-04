extends CharacterBody2D

#Atributos
var amplitude_float: float = 6.0
var speed_float: float = 3.0 
var time: float = 0.0

#Instancias
@onready var animated_sprite = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	#Flutuacao
	time += delta * speed_float
	position.y = sin(time) * amplitude_float
	
	animated_sprite.play("idle_front")
