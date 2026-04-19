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
@export var effect: EffectData # only needed by instant items


func apply(player_data: PlayerData) -> void:
	if effect:
		effect.apply(player_data)


func give_to(player_data: PlayerData) -> void:
	match item_type:
		ItemType.INSTANT:
			print("Applied instant item %s: %s" % [item_name, description])
			apply(player_data)
			if item_id.ends_with("sword") and player_data.sword_hit_frames:
				player_data.hit_frames = player_data.sword_hit_frames
				
		ItemType.CONSUMABLE:
			print("Obtained consumable item %s: %s" % [item_name, description])
			player_data.add_to_inventory(self, max_uses)
			
		ItemType.PERMANENT:
			print("Obtained permanent item %s: %s" % [item_name, description])
			player_data.add_to_inventory(self)
