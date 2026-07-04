extends Node2D

@onready var dealingCardsPlayer = $DealingCardsPlayer
@onready var drawingCardPlayer = $DrawingCardPlayer
@onready var menuClickPlayer = $MenuClickPlayer
@onready var putDownCardPlayer = $PutDownCardPlayer
@onready var putDownCard2Player = $PutDownCard2Player
@onready var ruffleShufflePlayer = $RuffleShufflePlayer
@onready var takeACardPlayer = $TakeACardPlayer

func play_dealing_cards(vol_db: float = GlobalVariables.music_volume, pitch_scale: float = 1.0):
	dealingCardsPlayer.volume_db = vol_db
	dealingCardsPlayer.pitch_scale = pitch_scale
	dealingCardsPlayer.play()

func play_drawing_card(vol_db: float = GlobalVariables.music_volume, pitch_scale: float = 1.0):
	drawingCardPlayer.volume_db = vol_db
	drawingCardPlayer.pitch_scale = pitch_scale
	drawingCardPlayer.play()

func play_menu_click(vol_db: float = GlobalVariables.music_volume, pitch_scale: float = 1.0):
	menuClickPlayer.volume_db = vol_db
	menuClickPlayer.pitch_scale = pitch_scale
	menuClickPlayer.play()

func play_put_down_card(vol_db: float = GlobalVariables.music_volume, pitch_scale: float = 1.0):
	putDownCardPlayer.volume_db = vol_db
	putDownCardPlayer.pitch_scale = pitch_scale
	putDownCardPlayer.play()

func play_put_down_card2(vol_db: float = GlobalVariables.music_volume, pitch_scale: float = 1.0):
	putDownCard2Player.volume_db = vol_db
	putDownCard2Player.pitch_scale = pitch_scale
	putDownCard2Player.play()

func play_ruffle_shuffle(vol_db: float = GlobalVariables.music_volume, pitch_scale: float = 1.0):
	ruffleShufflePlayer.volume_db = vol_db
	ruffleShufflePlayer.pitch_scale = pitch_scale
	ruffleShufflePlayer.play()

func play_take_a_card(vol_db: float = GlobalVariables.music_volume, pitch_scale: float = 1.0):
	takeACardPlayer.volume_db = vol_db
	takeACardPlayer.pitch_scale = pitch_scale
	takeACardPlayer.play()
