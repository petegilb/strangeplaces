@tool
extends DialogicIndexer

func _get_events() -> Array:
	return [this_folder.path_join('event_yokai.gd')]

func _get_subsystems() -> Array:
	return [{'name':'Yokai', 'script':this_folder.path_join('subsystem_yokai.gd')}]
	
func _get_text_modifiers() -> Array[Dictionary]:
	return [
		{'subsystem':'Yokai', 'method':"modifier_yokai_translator"},
	]
