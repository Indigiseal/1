# WordSelection.gd
# A global singleton for tracking word learning progress
extends Node

# Words the player is currently practicing
static var selected_words: Array = []
# All available words from JSON
static var all_words: Array = []
# All mastered words across batches
static var mastered_words: Array = []
# Tracks what batch the player is on (starts at 1)
static var current_batch_index: int = 1

# Call this once when the game loads to set the full word list
static func initialize_word_pool(all_available_words: Array) -> void:
	all_words = all_available_words.duplicate()
	mastered_words.clear()
	current_batch_index = 1
	selected_words = get_next_batch(12)

# Returns the next batch of unmastered words
# 🔧 FIX: Don't increment batch index here - do it only when actually advancing
static func get_next_batch(batch_size: int) -> Array:
	var next_words: Array = []
	for word in all_words:
		if not mastered_words.has(word):
			next_words.append(word)
		if next_words.size() == batch_size:
			break
	
	# 🔧 REMOVED: current_batch_index += 1
	# The batch index should only increment when we actually advance to the next batch
	# This will be handled in the game script when transitioning
	
	return next_words

# 🔧 NEW: Separate function to advance to next batch
static func advance_to_next_batch(batch_size: int) -> Array:
	current_batch_index += 1
	return get_next_batch(batch_size)

# 🔧 NEW: Helper function to check if current batch is complete
static func is_current_batch_complete() -> bool:
	for word in selected_words:
		if not mastered_words.has(word):
			return false
	return true

# 🔧 NEW: Debug function to print current state
static func print_debug_info() -> void:
	print("🔍 WordSelection Debug:")
	print("  - current_batch_index:", current_batch_index)
	print("  - selected_words:", selected_words)
	print("  - mastered_words:", mastered_words)
	print("  - total words:", all_words.size())
	print("  - batch complete:", is_current_batch_complete())
