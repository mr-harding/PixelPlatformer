extends Area2D

#exports a string which is a path to a tscn file(to identify target level)
export(String, FILE, "*.tscn") var target_level_path = ""

var player = false

func go_to_next_room():
	Transitions.play_exit_transition()
	get_tree().paused = true
	yield(Transitions, "transition_completed") 
	#using yield in this way will wait till the function is completed before executing next line
	Transitions.play_enter_transition()
	get_tree().paused = false
	get_tree().change_scene(target_level_path)
	
func _process(delta):
	if not player: return
	if not player.is_on_floor(): return
	if Input.is_action_just_pressed("ui_accept"):
		if target_level_path.empty(): return
		go_to_next_room()
	
func _on_Door_body_entered(body):
	if not body is Player: return #exit case, ends function if not player
	player = body
	if target_level_path.empty(): return #prevents errors if not path set


func _on_Door_body_exited(body):
	if not body is Player: return
	player = null
