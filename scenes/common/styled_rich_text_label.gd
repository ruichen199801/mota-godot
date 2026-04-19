## Label that auto-styles latin letters and numbers with system font.
##
## USAGE: Attach this script to RichTextLabel in editor, then 
##        use set_content() instead of .text in code to apply styling.
##
## NOTE: Styling is only visible at runtime, not in the scene editor.
## 		 During development, we still need to write bbcode manually to preview styling change.
class_name StyledRichTextLabel
extends RichTextLabel

const NUM_FONT := "res://assets/fonts/OpenSans-SemiBold.ttf"

@export var styled_font_size: int = 14

var _regex := RegEx.create_from_string("(\\$?[a-zA-Z0-9()]+)")


func _ready() -> void:
	bbcode_enabled = true
	fit_content = true
	scroll_active = false


func set_content(value: String) -> void:
	text = _regex.sub(value, 
		   "[font=%s][font_size=%d]$1[/font_size][/font]" % [NUM_FONT, styled_font_size], true)
