extends Node

@export var snakeScene: PackedScene

var score: int = 0
var isGameStarted: bool = false

var startingPosition: Vector2 = Vector2(9, 9)
var moveDirection: Vector2 = Vector2(0, -1)
var canMove: bool = false

var cells: int = 20
var cellSize: int = 50

var oldSnakeData: Array = []
var snakeData: Array = []
var snake: Array = []

var directionInputs = {
	"moveUp": Vector2(0, -1),
	"moveDown": Vector2(0, 1),
	"moveLeft": Vector2(-1, 0),
	"moveRight": Vector2(1, 0)
}

var foodPosition: Vector2
var regenerateFood: bool = true

func _ready() -> void:
	initializeGame()
	
func _process(delta: float) -> void:
	moveSnake()
	
func _on_game_over_menu_restart() -> void:
	initializeGame()
	
func _on_move_timer_timeout() -> void:
	canMove = true
	oldSnakeData = snakeData.duplicate(true)
	snakeData[0] += moveDirection
	for i in range(1, snakeData.size()):
		snakeData[i] = oldSnakeData[i - 1]
	for i in range(snakeData.size()):
		snake[i].position = snakeData[i] * cellSize + Vector2(cellSize / 2, cellSize / 2)
	checkGameConditions()

func initializeGame() -> void:
	setDefaultValues()
	updateScore()
	generateSnake()
	generateFood()

func setDefaultValues() -> void:
	$GameOverMenu.hide()
	get_tree().paused = false
	get_tree().call_group("segments", "queue_free")
	score = 0
	moveDirection = Vector2(0, -1)
	canMove = true

func generateSnake() -> void:
	oldSnakeData.clear()
	snakeData.clear()
	snake.clear()
	for i in range(3):
		addSegment(startingPosition + Vector2(0, i))
		
func generateFood() -> void:
	while true:
		foodPosition = Vector2(randi() % cells, randi() % cells)
		if not foodPosition in snakeData:
			break
	$Food.position = foodPosition * cellSize + Vector2(cellSize / 2, cellSize / 2)

func addSegment(position: Vector2) -> void:
	snakeData.append(position)
	var snakeSegment = snakeScene.instantiate()
	snakeSegment.position = position * cellSize + Vector2(cellSize / 2, cellSize / 2)
	add_child(snakeSegment)
	snake.append(snakeSegment)

func moveSnake() -> void:
	if canMove:
		handleInput()

func handleInput() -> void:
	for inputEvent in directionInputs.keys():
		if Input.is_action_just_pressed(inputEvent) and moveDirection != -directionInputs[inputEvent]:
			moveDirection = directionInputs[inputEvent]
			canMove = false
			if not isGameStarted:
				startGame()
			return

func startGame() -> void:
	isGameStarted = true
	$MoveTimer.start()

func checkGameConditions() -> void:
	checkOutOfBounds()
	checkSelfCollision()
	checkFoodCollision()

func checkOutOfBounds() -> void:
	var headPosition = snakeData[0]
	if headPosition.x < 0 or headPosition.x >= cells or headPosition.y < 0 or headPosition.y >= cells:
		endGame()

func checkSelfCollision() -> void:
	var headPosition = snakeData[0]
	if headPosition in snakeData.slice(1, snakeData.size()):
		endGame()

func checkFoodCollision() -> void:
	if snakeData[0] == foodPosition:
		score += 1
		updateScore()
		addSegment(oldSnakeData[-1])
		generateFood()

func endGame() -> void:
	$GameOverMenu.show()
	$MoveTimer.stop()
	isGameStarted = false
	get_tree().paused = true

func updateScore() -> void:
	$Hud.get_node("ScoreLabel").text = "SCORE: %d" % score
