extends Camera2D

#Atributos
@export var player_one: Node2D
@export var player_two: Node2D
@export var min_zoom: float = 1.0
@export var max_zoom: float = 0.5
@export var min_distance: float = 300.0
@export var max_distance: float = 900.0
@export var follow_speed: float = 5.0

func _physics_process(delta: float) -> void:
	if not player_one:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 0:
			player_one = players[0]
	
	if not player_one:
		return
	
	if not player_two:
		var players = get_tree().get_nodes_in_group("Player")
		if players.size() > 1:
			player_two = players[1] 
	var target_position: Vector2
	var target_zoom_value: float = min_zoom

	if player_two and is_instance_valid(player_two):
		target_position = (player_one.global_position + player_two.global_position) / 2.0
		
		var current_distance = player_one.global_position.distance_to(player_two.global_position)
		var zoom_factor = inverse_lerp(min_distance, max_distance, current_distance)
		zoom_factor = clamp(zoom_factor, 0.0, 1.0)
		target_zoom_value = lerp(min_zoom, max_zoom, zoom_factor)
	else:
		target_position = player_one.global_position
		target_zoom_value = min_zoom 
		
	global_position = global_position.lerp(target_position, follow_speed * delta)
	zoom = zoom.lerp(Vector2(target_zoom_value, target_zoom_value), follow_speed * delta)
