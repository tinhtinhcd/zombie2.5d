extends Node
class_name SceneRouter

const HOME_SCENE_PATH := "res://scenes/ui/home_screen.tscn"
const GAME_SCENE_PATH := "res://scenes/core/game.tscn"

func change_scene(scene_path: String) -> void:
    var error := get_tree().change_scene_to_file(scene_path)
    if error != OK:
        push_error("Failed to change scene to %s (error %d)." % [scene_path, error])

func go_to_home() -> void:
    change_scene(HOME_SCENE_PATH)

func go_to_game() -> void:
    change_scene(GAME_SCENE_PATH)
