extends Node

signal on_player_hurt(damage: int, fatal:bool, source: StringName)
signal on_player_hp_changed(new_hp: int)
signal on_player_dead()
signal on_crumbs_changed(new_count:int)
signal on_game_mode_changed(mode:StringName)
signal on_level_loaded(level: Level, is_reset: bool)
signal on_level_reset()
signal on_honeyed();
signal on_honey_dried();
signal on_new_game();
signal on_platform_built(length:int);
signal on_crumbs_earnt(amount:int);
