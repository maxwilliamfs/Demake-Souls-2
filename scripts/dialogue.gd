extends CanvasLayer

#Enuns
enum dialogue {talk_1,talk_2,talk_3,talk_4,estus,question_yes,question_no,nothing,boss}

#Declaracaop de enuns
var actual_dialogue : dialogue = dialogue.nothing
var count : bool = true

#signals
signal cancel(finished : bool)
signal estus_unlocked
signal change_animation(animation : String)

#Instancias
@onready var talk_1 = $OldLady/Talk_1
@onready var talk_2 = $OldLady/Talk_2
@onready var talk_3 = $OldLady/Talk_3
@onready var talk_4 = $OldLady/Talk_4
@onready var estus = $OldLady/Estus
@onready var question_yes = $OldLady/Question_YES
@onready var question_no = $OldLady/Question_NO
@onready var travel = $travel

func _process(_delta: float) -> void:
	if actual_dialogue == dialogue.question_yes and Input.is_action_just_pressed("mov_right"):
		actual_dialogue = dialogue.question_no
	elif actual_dialogue == dialogue.question_no and Input.is_action_just_pressed("mov_left"):
		actual_dialogue = dialogue.question_yes
	elif Input.is_action_just_pressed("heal"):
		match actual_dialogue:
			dialogue.talk_1:
				actual_dialogue = dialogue.talk_2
			dialogue.talk_2:
				actual_dialogue = dialogue.talk_3
				change_animation.emit("estus")
			dialogue.talk_3:
				actual_dialogue = dialogue.estus
			dialogue.talk_4:
				cancel.emit(true)
				actual_dialogue = dialogue.nothing
			dialogue.estus:
				actual_dialogue = dialogue.talk_4
				change_animation.emit("idle")
				estus_unlocked.emit()
			dialogue.question_yes:
				actual_dialogue = dialogue.talk_1
			dialogue.question_no:
				cancel.emit(false)
				actual_dialogue = dialogue.nothing
			dialogue.boss:
				travel.show()
				if count:
					await get_tree().process_frame
					count = false
				if Input.is_action_just_pressed("heal"):
					get_tree().change_scene_to_file("res://scenes/fases/boss_fight.tscn")
	choose_dialogue()



func _on_oldlady_talk() -> void:
	await get_tree().process_frame
	actual_dialogue = dialogue.question_yes
	choose_dialogue()

func choose_dialogue():
	talk_1.hide()
	talk_2.hide()
	talk_3.hide()
	talk_4.hide()
	estus.hide()
	question_no.hide()
	question_yes.hide()
	match actual_dialogue:
		dialogue.talk_1:
			talk_1.show()
		dialogue.talk_2:
			talk_2.show()
		dialogue.talk_3:
			talk_3.show()
		dialogue.talk_4:
			talk_4.show()
		dialogue.estus:
			estus.show()
		dialogue.question_yes:
			question_yes.show()
		dialogue.question_no:
			question_no.show()


func _on_bonfire_boss_fight() -> void:
	actual_dialogue = dialogue.boss
