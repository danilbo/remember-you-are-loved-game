extends Node2D

@onready var dealingCardsPlayer = $DealingCardsPlayer
@onready var drawingCardPlayer = $DrawingCardPlayer
@onready var menuClickPlayer = $MenuClickPlayer
@onready var putDownCardPlayer = $PutDownCardPlayer
@onready var putDownCard2Player = $PutDownCard2Player
@onready var ruffleShufflePlayer = $RuffleShufflePlayer
@onready var takeACardPlayer = $TakeACardPlayer

func play_dealing_cards(pitch_scale: float = 1.0):
	dealingCardsPlayer.pitch_scale = pitch_scale
	dealingCardsPlayer.play()

func play_drawing_card(pitch_scale: float = 1.0):
	drawingCardPlayer.pitch_scale = pitch_scale
	drawingCardPlayer.play()

func play_menu_click(pitch_scale: float = 1.0):
	menuClickPlayer.pitch_scale = pitch_scale
	menuClickPlayer.play()

func play_put_down_card(pitch_scale: float = 1.0):
	putDownCardPlayer.pitch_scale = pitch_scale
	putDownCardPlayer.play()

func play_put_down_card2(pitch_scale: float = 1.0):
	putDownCard2Player.pitch_scale = pitch_scale
	putDownCard2Player.play()

func play_ruffle_shuffle(pitch_scale: float = 1.0):
	ruffleShufflePlayer.pitch_scale = pitch_scale
	ruffleShufflePlayer.play()

func play_take_a_card(pitch_scale: float = 1.0):
	takeACardPlayer.pitch_scale = pitch_scale
	takeACardPlayer.play()
