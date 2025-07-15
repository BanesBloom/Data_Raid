extends HBoxContainer
class_name ScoreEntry

func initialize(player, level, score):
	$EntryName.text = "%s"%player
	$EntryLevel.text = "%s"%level
	$EntryScore.text = "%s"%score
