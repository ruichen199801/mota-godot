class_name ItemData
extends Resource

enum ItemType { INSTANT, CONSUMABLE, PERMANENT }

@export var item_id: String
@export var item_name: String
@export var description: String
@export var icon: Texture2D # optional
@export var frames: SpriteFrames # optional, for animated items
@export var item_type: ItemType
@export var max_uses: int = 1 # only meaningful for consumable items
@export var effect: EffectData # null for permanent items


func apply(player_data: PlayerData) -> void:
	if effect:
		effect.apply(player_data)
