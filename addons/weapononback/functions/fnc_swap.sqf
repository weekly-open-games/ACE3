#include "../script_component.hpp"
/*
 * Author: BaerMitUmlaut
 * Swaps primary and weapon on back. Can handle no primary or no weapon on back.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Public: No
 */

private _loadout = getUnitLoadout ACE_player;
private _oldPrimary = _loadout#0;
private _newPrimary = [ACE_player] call FUNC(get);

// Save scope adjustment
private _adjustments = ACE_player getVariable [QEGVAR(scopes,adjustment), [[0, 0, 0], [0, 0, 0], [0, 0, 0]]];
private _oldAdjustment = _adjustments#0;
private _newAdjustement = ACE_player getVariable [QGVAR(scopeAdjustment), [0, 0, 0]];
EGVAR(scopes,guns) set [0, ""];

// Заменяем слот основного оружия в массиве снаряжения (если за спиной пусто, ставим [])
_loadout set [0, _newPrimary];
ACE_player setUnitLoadout _loadout;

if (_newPrimary isNotEqualTo []) then {
    _newPrimary params ["_weapon"];
    ACE_player selectWeapon _weapon;

    // Restore scope adjustment
    [{
        EGVAR(scopes,guns)#0 != ""
    }, {
        params ["_oldAdjustment", "_newAdjustement"];

        if (_newAdjustement isNotEqualTo [0, 0, 0]) then {
            private _scopeAdjustmentParams = [ACE_player];
            _scopeAdjustmentParams append _newAdjustement;
            _scopeAdjustmentParams call EFUNC(scopes,applyScopeAdjustment);
        };

        ACE_player setVariable [QGVAR(scopeAdjustment), _oldAdjustment];
    }, [_oldAdjustment, _newAdjustement]] call CBA_fnc_waitUntilAndExecute;
};

if (_oldPrimary isEqualTo []) then {
    [ACE_player] call FUNC(remove);
} else {
    [ACE_player, _oldPrimary] call FUNC(add);
};