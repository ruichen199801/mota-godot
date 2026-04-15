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


func is_async() -> bool:
	return true


func on_block(pd: PlayerData) -> void:
	data.give_to(pd)
			
	visible = false
	EventBus.item_pickup_show.emit(data)
	await EventBus.item_pickup_dismissed
	remove_from_grid()
