#define COMPONENT cookoff
#define COMPONENT_BEAUTIFIED Cook off
#include "\z\ace\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_COOKOFF
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_COOKOFF
    #define DEBUG_SETTINGS DEBUG_SETTINGS_COOKOFF
#endif

#include "\z\ace\addons\main\script_macros.hpp"

#define IS_EXPLOSIVE_AMMO(ammo) (getNumber (ammo call CBA_fnc_getObjectConfig >> "explosive") > 0.5)

// Stages of cookoff in order (in seconds)
// Should be no un-synced randomness in these as the effects must be ran on each client
#define IGNITE_TIME 3
#define SMOKE_TIME 10.5
#define COOKOFF_TIME 14 // Cook off time should be 20s at most due to length of sound files
#define COOKOFF_TIME_BOX 82.5 // Cook off time for boxes should be significant to allow time for ammo to burn
#define MIN_TIME_BETWEEN_FLAMES 5
#define MAX_TIME_BETWEEN_FLAMES 15
#define MAX_TIME_BETWEEN_AMMO_DET 35
#define MAX_COOKOFF_INTENSITY 10

#define MIN_AMMO_DETONATION_START_DELAY 1 // Min time to wait before a vehicle's ammo starts to cookoff
#define MAX_AMMO_DETONATION_START_DELAY 6 // Max time to wait before a vehicle's ammo starts to cookoff

// Delay between flame effect for players in a cooking off vehicle
#define FLAME_EFFECT_DELAY 0.4

// Common commander hatch defines for default vehicles
#define DEFAULT_COMMANDER_HATCHES ["osa_poklop_commander", "hatch_commander_axis"]
