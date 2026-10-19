extends Node
## The single source of truth for game progress. Autoloaded as "GameState",
## so any script can read it, e.g. GameState.day.
## For now it only tracks the calendar; money, reputation, inventory etc. come later.

signal time_changed

## [CONFIRM] slot names in CLAUDE.md section 5.5.
const TIME_SLOTS := ["Morning", "Afternoon", "Evening"]

var day := 1
var time_slot_index := 0


func get_time_slot() -> String:
	return TIME_SLOTS[time_slot_index]


## Moves to the next time slot, and to the next day after the last slot.
## Nothing calls this yet: walking around and entering buildings never uses up time.
func advance_time() -> void:
	time_slot_index += 1
	if time_slot_index >= TIME_SLOTS.size():
		time_slot_index = 0
		day += 1
	time_changed.emit()
