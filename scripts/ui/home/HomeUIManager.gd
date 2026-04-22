extends RefCounted
class_name HomeUIManager

signal panel_changed(panel_id: String)

var _panels: Dictionary = {}
var _history: Array[String] = []
var _active_panel_id: String = ""
var _hub_panel_id: String = ""

func setup(panels: Dictionary, hub_panel_id: String) -> void:
	_panels = panels
	_hub_panel_id = hub_panel_id
	_active_panel_id = hub_panel_id

func open_panel(panel_id: String, add_to_history: bool = true) -> void:
	if not _panels.has(panel_id):
		return

	if add_to_history and panel_id != _active_panel_id and not _active_panel_id.is_empty():
		_history.append(_active_panel_id)

	for current_panel_id in _panels.keys():
		var panel := _panels[current_panel_id] as Control
		if panel != null:
			panel.visible = current_panel_id == panel_id

	_active_panel_id = panel_id
	panel_changed.emit(_active_panel_id)

func go_back() -> void:
	if _history.is_empty():
		open_hub(false)
		return

	var previous_panel_id: String = _history.pop_back()
	open_panel(previous_panel_id, false)

func open_hub(add_to_history: bool = false) -> void:
	open_panel(_hub_panel_id, add_to_history)

func get_active_panel_id() -> String:
	return _active_panel_id
