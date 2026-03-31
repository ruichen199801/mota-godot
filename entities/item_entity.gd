class_name ItemEntity
extends TileEntity

@export var data: ItemData
@onready var sprite: Sprite2D = $Sprite2D
@onready var anim_sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	if data == null:
		return
	
	if data.frames:
		sprite.visible = false
		anim_sprite.visible = true
		anim_sprite.sprite_frames = data.frames
		anim_sprite.play("default")
	else:
		sprite.visible = true
		anim_sprite.visible = false
		if data.icon:
			sprite.texture = data.icon


func is_blocking(_player_data: PlayerData) -> bool:
	return false


func on_enter(pd: PlayerData) -> void:
	match data.item_type:
		ItemData.ItemType.INSTANT:
			print("Applied instant item %s: %s" % [data.item_name, data.description])
			data.apply(pd)
			if data.item_id.ends_with("sword") and pd.sword_hit_frames:
				pd.hit_frames = pd.sword_hit_frames
				
		ItemData.ItemType.CONSUMABLE:
			print("Obtained consumable item %s: %s" % [data.item_name, data.description])
			pd.add_to_inventory(data, data.max_uses)
			
		ItemData.ItemType.PERMANENT:
			print("Obtained permanent item %s: %s" % [data.item_name, data.description])
			pd.add_to_inventory(data)
			
	remove_from_grid()
