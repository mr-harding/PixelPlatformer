extends Node2D

const PlayerScene = preload("res://Player/Player.tscn") #instancing a scene

var player_spawn_location = Vector2.ZERO

onready var camera: = $Camera2D
onready var player: = $Player
onready var timer: = $Timer

func _ready():
	VisualServer.set_default_clear_color(Color.lightblue)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.connect("player_died", self, "_on_player_died")
	Events.connect("hit_checkpoint", self, "_on_hit_checkpoint")
	
func _on_player_died():
	timer.start(1.0)
	yield(timer, "timeout")
	var player = PlayerScene.instance()
	add_child(player)
	player.position = player_spawn_location
	player.connect_camera(camera) #need to reconnect camera as this is an entirely new player instance
	
func _on_hit_checkpoint(checkpoint_position):
	checkpoint_position.y -= 30
	player_spawn_location = checkpoint_position
