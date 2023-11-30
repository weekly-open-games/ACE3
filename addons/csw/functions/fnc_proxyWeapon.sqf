#include "..\script_component.hpp"
/*
 * Author: tcvm, PabstMirror
 * Handles the use of proxy weapons to fix engine-reload times
 *
 * Arguments:
 * 0: CSW <OBJECT>
 * 1: Turret <ARRAY>
 * 2: Proxy weapon needed <BOOL>
 * 2: Weapon should be emptied <BOOL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [weapon, [0], true, false] call ace_csw_fnc_proxyWeapon
 *
 * Public: No
 */

params ["_vehicle", "_turret", "_needed", "_emptyWeapon"];
TRACE_4("proxyWeapon",_vehicle,_turret,_needed,_emptyWeapon);

if (_vehicle getVariable [format [QGVAR(proxyHandled_%1), _turret], false]) exitWith { TRACE_1("already handled",typeOf _vehicle); };

private _proxyWeapon = getText (configOf _vehicle >> "ace_csw" >> "proxyWeapon");

TRACE_2("",typeOf _vehicle,_proxyWeapon);
if (_proxyWeapon isEqualTo "") exitWith {};

private _currentWeapon = (_vehicle weaponsTurret [0]) param [0, "#none"];
if ((missionNamespace getVariable [_proxyWeapon, objNull]) isEqualType {}) then { // check if string is a function
    TRACE_1("Calling proxyWeapon function",_proxyWeapon);
    // This function may replace magazines or do other things to the static weapon
    _proxyWeapon = [_vehicle, _turret, _currentWeapon, _needed, _emptyWeapon] call (missionNamespace getVariable _proxyWeapon);
    _needed = _proxyWeapon isNotEqualTo "" && {_proxyWeapon isNotEqualTo _currentWeapon};
};
if (!_needed) exitWith { TRACE_2("not needed",_needed,_proxyWeapon); };

// Rearm compatibility, prevent reloading entire static and breaking CSW
_staticWeapon setVariable [QEGVAR(rearm,scriptedLoadout), true, true];

// Config case for hashmap key
_proxyWeapon = configName (configFile >> "CfgWeapons" >> _proxyWeapon);
if (_proxyWeapon isEqualTo "") exitWith {ERROR_1("proxy weapon non-existent for [%1]", _currentWeapon)};

// Cache compatible magazines
if !(_proxyWeapon in GVAR(compatibleMagsCache)) then {
    private _compatibleMagazines = compatibleMagazines _proxyWeapon;
    GVAR(compatibleVehicleMagsCache) set [_proxyWeapon, _compatibleMagazines];
    GVAR(compatibleMagsCache) set [_proxyWeapon, (_compatibleMagazines apply {_x call FUNC(getCarryMagazine)}) createHashMapFromArray []];
};

TRACE_2("swapping to proxy weapon",_currentWeapon,_proxyWeapon);
_vehicle removeWeaponTurret [_currentWeapon, _turret];
_vehicle addWeaponTurret [_proxyWeapon, _turret];
_vehicle setVariable [format [QGVAR(proxyHandled_%1), _turret], true, true];
