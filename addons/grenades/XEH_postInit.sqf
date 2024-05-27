// by commy2

#include "script_component.hpp"

["ace_flashbangExploded", LINKFUNC(flashbangExplosionEH)] call CBA_fnc_addEventHandler;

// Register fired event handlers
["ace_firedPlayer", LINKFUNC(throwGrenade)] call CBA_fnc_addEventHandler;
["ace_firedPlayerNonLocal", LINKFUNC(throwGrenade)] call CBA_fnc_addEventHandler;
["ace_firedNonPlayer", LINKFUNC(throwGrenade)] call CBA_fnc_addEventHandler;

if (!hasInterface) exitWith {};

GVAR(flashbangPPEffectCC) = ppEffectCreate ["ColorCorrections", 4265];
GVAR(flashbangPPEffectCC) ppEffectForceInNVG true;

// Add keybinds
["ACE3 Weapons", QGVAR(switchGrenadeMode), localize LSTRING(SwitchGrenadeMode), {
    // Conditions: canInteract
    if !([ACE_player, objNull, ["isNotEscorting", "isNotInside"]] call EFUNC(common,canInteractWith)) exitWith {false};
    // Conditions: specific
    if (!([ACE_player] call CBA_fnc_canUseWeapon)) exitWith {false};
    // Don't change mode or show hint if advanced throwing is active
    if (ACE_player getVariable [QEGVAR(advanced_throwing,inHand), false]) exitWith {false};

    // Statement
    [] call FUNC(nextMode);
}, {false}, [9, [false, false, false]], false] call CBA_fnc_addKeybind; //8 Key

["CBA_settingsInitialized", {
    if (GVAR(convertExplosives)) then {
        [] call FUNC(addChangeFuseItemContextMenuOptions);
    };
}] call CBA_fnc_addEventHandler;
