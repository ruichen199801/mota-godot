class_name NpcMerchantData
extends Resource

enum CurrencyType { GOLD, XP }

@export var description: String
@export var currency: CurrencyType
@export var options: Array[ShopOptionData] = []
