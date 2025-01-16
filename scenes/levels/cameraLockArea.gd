extends Area2D

@export var anchor: Vector2 = Vector2(-1236,636)
@export var transitionLockState: bool = true

var collisionShape: CollisionShape2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collisionShape = $CollisionShape2D


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
