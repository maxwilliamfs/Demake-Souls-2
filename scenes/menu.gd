extends Control

#Enuns
enum state {initial,start,controls}

#Atributos
var menu_state : state = state.initial
var new_game : bool = true

#Instancias
@onready var initial = $Initial
@onready var initial_S = $Initial/Label3
@onready var start = $Start
@onready var new_game_l = $Start/new_game
@onready var exit_l = $Start/exit
@onready var controls = $Controls

func _ready() -> void:
	initial.modulate.a = 0
	var tween : Tween = create_tween()
	tween.tween_property(initial,"modulate:a",0.2,1)
	tween.tween_property(initial,"modulate:a",1,2)
	await tween.finished
	new_game_l.self_modulate = Color("#ffffff")     
	exit_l.self_modulate = Color("#515151") 


func _process(_delta: float) -> void:
	if menu_state == state.initial:
		if Input.is_action_pressed("Enter"):
			var tween : Tween = create_tween()
			start.show()
			start.modulate.a = 0
			tween.set_parallel(true)
			tween.tween_property(initial_S,"modulate:a",0,0.3)
			tween.tween_property(start,"modulate:a",1,0.5)
			await tween.finished
			initial_S.hide()
			menu_state = state.start
	elif menu_state == state.start:
		if Input.is_action_just_pressed("mov_down") and new_game:
			print("Indo para Sair")
			new_game_l.self_modulate = Color("#515151") 
			exit_l.self_modulate = Color("#ffffff")     
			new_game = false
			
		if Input.is_action_just_pressed("mov_up") and !new_game:
			new_game_l.self_modulate = Color("#ffffff")     
			exit_l.self_modulate = Color("#515151") 
			new_game = true
		if Input.is_action_just_pressed("Enter"):
			if new_game:
				var tween : Tween = create_tween()
				controls.show()
				controls.modulate.a = 0
				initial.hide()
				tween.set_parallel(true)
				tween.tween_property(start,"modulate:a",0,0.3)
				tween.tween_property(controls,"modulate:a",1,0.5)
				await tween.finished
				menu_state = state.controls
			else:
				get_tree().quit()
	elif menu_state == state.controls:
		if Input.is_action_just_pressed("Enter"):
			get_tree().change_scene_to_file("res://scenes/fases/florest.tscn")
