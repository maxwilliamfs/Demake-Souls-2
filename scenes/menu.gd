extends Control

#Atributos
var firt_menu : bool = true
var new_game : bool = true

#Instancias
@onready var initial = $Initial
@onready var initial_S = $Initial/Label3
@onready var start = $Start
@onready var new_game_l = $Start/new_game
@onready var exit_l = $Start/exit

func _ready() -> void:
	initial.modulate.a = 0
	var tween : Tween = create_tween()
	tween.tween_property(initial,"modulate:a",0.2,1)
	tween.tween_property(initial,"modulate:a",1,2)
	await tween.finished
	new_game_l.self_modulate = Color("#ffffff")     
	exit_l.self_modulate = Color("#515151") 


func _process(_delta: float) -> void:
	if firt_menu:
		if Input.is_action_pressed("heal"):
			var tween : Tween = create_tween()
			start.show()
			start.modulate.a = 0
			tween.set_parallel(true)
			tween.tween_property(initial_S,"modulate:a",0,2)
			tween.tween_property(start,"modulate:a",1,2)
			await tween.finished
			initial_S.hide()
			firt_menu = false
	else:
		if Input.is_action_just_pressed("mov_down") and new_game:
			print("Indo para Sair")
			new_game_l.self_modulate = Color("#515151") 
			exit_l.self_modulate = Color("#ffffff")     
			new_game = false
			
		if Input.is_action_just_pressed("mov_up") and !new_game:
			print("Indo para Novo Jogo")
			new_game_l.self_modulate = Color("#ffffff")     
			exit_l.self_modulate = Color("#515151") 
			new_game = true
		if Input.is_action_just_pressed("heal"):
			if new_game:
				get_tree().change_scene_to_file("res://scenes/tutorial.tscn")
			else:
				get_tree().quit()
