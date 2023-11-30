#include "..\script_component.hpp"
/*
 * Author: PabstMirror
 * Gets sub actions for what the player can unload from the CSW
 *
 * Arguments:
 * 0: CSW <OBJECT>
 * 1: Player <OBJECT>
 *
 * Return Value:
 * Actions <ARRAY>
 *
 * Example:
 * [cursorObject, player] call ace_csw_fnc_reload_actionsUnload
 *
 * Public: No
 */

params ["_vehicle", "_player"];

private _statement = {
    params ["_target", "_player", "_params"];
    _params params ["_vehMag", "_turretPath", "_carryMag"];
    TRACE_5("starting unload",_target,_turretPath,_player,_carryMag,_vehMag);

    private _timeToUnload = 1;
    if (!isNull(configOf _target >> QUOTE(ADDON) >> "ammoUnloadTime")) then {
        _timeToUnload = getNumber(configOf _target >> QUOTE(ADDON) >> "ammoUnloadTime");
    };

    [
    TIME_PROGRESSBAR(_timeToUnload),
    [_target, _turretPath, _player, _carryMag, _vehMag],
    {
        (_this select 0) params ["_target", "_turretPath", "", "_carryMag", "_vehMag"];
        TRACE_5("unload progressBar finish",_target,_turretPath,_carryMag,_vehMag,_player);
        [QGVAR(removeTurretMag), [_target, _turretPath, _carryMag, _vehMag, _player]] call CBA_fnc_globalEvent;
    },
    {TRACE_1("unload progressBar fail",_this);},
    format [localize LSTRING(unloadX), getText (configFile >> "CfgMagazines" >> _carryMag >> "displayName")],
    {(_this select 0) call FUNC(reload_canUnloadMagazine)},
    ["isNotInside"]
    ] call EFUNC(common,progressBar);
};

private _condition = {
    params ["_target", "_player", "_params"];
    _params params ["_vehMag", "_turretPath", "_carryMag"];
    [_target, _turretPath, _player, _carryMag, _vehMag] call FUNC(reload_canUnloadMagazine)
};

private _actions = [];
private _handeledMagTypes = [];

private _cfgMagazines = configFile >> "CfgMagazines";

// Go through magazines on static weapon and check if any are unloadable
{
    _x params ["_xMag", "_xTurret", "_xAmmo"];

    if ((_xAmmo > 0) && {!(_xMag in _handeledMagTypes)}) then {
        _handeledMagTypes pushBack _xMag;
        private _carryMag = _xMag call FUNC(getCarryMagazine);
        if (_carryMag == "") exitWith {};

        private _displayName = getText (_cfgMagazines >> _carryMag >> "displayName");
        private _text = format [LLSTRING(actionUnload), _displayName];
        private _picture = getText (_cfgMagazines >> _carryMag >> "picture");
        private _action = [format ["unload_%1", _forEachIndex], _text, _picture, _statement, _condition, {}, [_xMag, _xTurret, _carryMag]] call EFUNC(interact_menu,createAction);
        _actions pushBack [_action, [], _vehicle];
    };
} forEach (magazinesAllTurrets _vehicle);

TRACE_1("unloadActions",count _actions);
_actions
