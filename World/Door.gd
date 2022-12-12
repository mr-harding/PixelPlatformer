extends Area2D

#exports a string which is a path to a tscn file(to identify target level)
export(String, FILE, "*.tscn") var target_level_path = ""


func _on_Door_body_entered(body):
	if not body is Player: return #exit case, ends function if not player
	if target_level_path.empty(): return #prevents errors if not path set
	get_tree().change_scene(target_level_path)
