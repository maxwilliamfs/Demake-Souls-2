extends CharacterBody2D

#Atributos
var vetor_direcao : Vector2 = Vector2(0,0)
var velocidade : int = 400
var ultimo_movimento : String

#Instancias
@onready var sprite_animacao = $AnimatedSprite2D

#Funcoes padroes
func _physics_process(_delta: float) -> void:
	
	#Movimento Horizontal
	if Input.is_action_pressed("mov_direita"):
		vetor_direcao.x = 1
		ultimo_movimento = "direita"
		sprite_animacao.play("run_right")
	elif Input.is_action_pressed("mov_esquerda"):
		vetor_direcao.x = -1
		ultimo_movimento = "esquerda"
		sprite_animacao.play("run_left")
	else:
		vetor_direcao.x = 0
	
	#Movimento Vertical
	if Input.is_action_pressed("mov_baixo"):
		vetor_direcao.y = 1
		ultimo_movimento = "baixo"
		sprite_animacao.play("run_down")
	elif Input.is_action_pressed("mov_cima"):
		vetor_direcao.y = -1
		ultimo_movimento = "cima"
		sprite_animacao.play("run_up")
	else:
		vetor_direcao.y = 0
	
	if vetor_direcao.x == 0 and vetor_direcao.y == 0:
		if ultimo_movimento == "cima":
			sprite_animacao.play("idle_up")
		elif ultimo_movimento == "baixo":
			sprite_animacao.play("idle_down")
		elif ultimo_movimento == "esquerda":
			sprite_animacao.play("idle_left")
		else:
			sprite_animacao.play("idle_right")
	
	#Movimentacao
	velocity = vetor_direcao * velocidade
	move_and_slide()


#Funcoes Proprias
