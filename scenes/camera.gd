extends Camera2D

var player : CharacterBody2D
@export var player_one: Node2D
@export var min_zoom: float = 1.0
@export var max_zoom: float = 0.5
@export var follow_speed: float = 5.0
@export var min_x : float = 0.0
@export var max_x : float = 3500.0
@export var min_y : float = -350.0
@export var max_y : float = 750.0

func _ready() -> void:
	var players = get_tree().get_nodes_in_group("Player")
	if players.size() > 0:
		player = players[0]
		if not player_one:
			player_one = players[0]

func _process(delta: float) -> void:
	if not player_one:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player_one = players[0]
	
	if not player_one:
		return
			
	var target_position: Vector2 = player_one.global_position
	var target_zoom_value: float = min_zoom
		
	target_position.x = clampf(target_position.x, min_x, max_x)
	target_position.y = clampf(target_position.y, min_y, max_y)
		
	global_position = global_position.lerp(target_position, follow_speed * delta)
	zoom = zoom.lerp(Vector2(target_zoom_value, target_zoom_value), follow_speed * delta)
