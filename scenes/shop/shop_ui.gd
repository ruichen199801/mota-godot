class_name ShopUI
extends Control

@onready var title_label: Label = %TitleLabel
@onready var avatar_sprite: AnimatedSprite2D = %AvatarSprite
@onready var description_label: RichTextLabel = %DescriptionLabel

@onready var arrows: Array[TextureRect] = [%Arrow1]
@onready var cost_hint_1: Label = %CostHint1


@onready var options_container: VBoxContainer = %OptionsContainer
