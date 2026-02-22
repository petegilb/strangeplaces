extends DialogicSubsystem

## Describe the subsystems purpose here.


#region STATE
####################################################################################################

func clear_game_state(clear_flag:=Dialogic.ClearFlags.FULL_CLEAR) -> void:
	pass

func load_game_state(load_flag:=LoadFlags.FULL_LOAD) -> void:
	pass

#endregion


#region MAIN METHODS
####################################################################################################

func modifier_yokai_translator(text:String) -> String:
	if text.contains("[ENG]"):
		return text.substr(5)
	var font_path: String = "res://assets/fonts/stray.ttf"
	var regex = RegEx.new()
	
	var global = Engine.get_main_loop().root.get_node_or_null("Global")
	var player_dicts: Array[int] = global.get_dictionaries()
	
	var dictionary1 = "EZCTJMAQ"
	var dictionary2 = "OFXYKNWVP"
	var dictionary3 = "IGBRSHDLU"
	
	for element in player_dicts:
		if element == 1:
			dictionary1 = ""
		if element == 2:
			dictionary2 = ""
		if element == 3:
			dictionary3 = ""
	
	# TODO check if the player has the dictionaries
	var letters_to_change = dictionary1 + dictionary2 + dictionary3
	
	# This pattern matches any of your target letters (case-insensitive) 
	# ONLY if they are not followed by a closing bracket ']' 
	# before an opening bracket '[' is seen.
	# Basically: "Is this letter NOT inside a BBCode tag?"
	regex.compile("(?i)([" + letters_to_change + "])(?![^[]*])")
	
	# $1 refers to the captured letter (keeping its original casing)
	var replacement: String = "[font=" + font_path + "]$1[/font]"
	
	return regex.sub(text, replacement, true)

#endregion
