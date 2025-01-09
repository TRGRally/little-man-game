extends Node2D

@export var PUSH_DIRECTION: Vector2 = Vector2(0,-1)
@export var PUSH_SPEED: float = 1000.0

@onready var collisionShape: CollisionShape2D = $CollisionShape2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	self.gravity_direction = PUSH_DIRECTION
	self.gravity = PUSH_SPEED
