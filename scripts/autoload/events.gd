extends Node

signal on_player_hurt(damage: int, fatal:bool, source: StringName)
signal on_player_hp_changed(new_hp: int)
signal on_player_dead()
signal on_crumbs_changed(new_count:int)
signal on_toggle_build_mode(is_enabled:bool)
signal on_game_mode_changed(mode:StringName)
