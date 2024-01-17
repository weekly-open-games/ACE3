#include "..\script_component.hpp"
/*
 * Author: PabstMirror
 * Gets all magazines inside of a vehicle.
 *
 * Arguments:
 * 0: Vehicle <Object>
 *
 * Return Value:
 * 0: Ammo Array <ARRAY>
 * - 0: Magazine Classname <STRING>
 * - 1: Ammo Count <NUMBER>
 * 1: Total Ammo Count <NUMBER>
 *
 * Example:
 * [vehicle player] call ace_cookoff_fnc_getVehicleAmmo
 *
 * Public: No
 */

params ["_vehicle"];
TRACE_1("getVehicleAmmo",_vehicle);

private _ammoToDetonate = [];
private _totalAmmo = 0;

// Get ammo from turrets
{
    _x params ["_mag", "_turret", "_count"];
    // if the turret is an FFV seat, it takes magazines from the soldier
    if (_count > 0) then {
        if (_mag call FUNC(isMagazineFlare)) then {continue};
        private _ammo = getText (configFile >> "CfgMagazines" >> _mag >> "ammo");
        private _model = getText (configFile >> "CfgAmmo" >> _ammo >> "model");
        if (_model == "\A3\weapons_f\empty") exitWith {TRACE_3("skipping",_mag,_ammo,_model);};
        _ammoToDetonate pushBack [_mag, _count];
        _totalAmmo = _totalAmmo + _count;
    };
} forEach (magazinesAllTurrets [_vehicle, true]);

// Get ammo from cargo space
{
    _x params ["_mag", "_count"];
    if (_count > 0) then {
        if (_mag call FUNC(isMagazineFlare)) then {continue};
        _ammoToDetonate pushBack [_mag, _count];
        _totalAmmo = _totalAmmo + _count;
    };
} forEach (magazinesAmmoCargo _vehicle);

// Get ammo from transportAmmo / ace_rearm
private _vehCfg = configOf _vehicle;

private _configSupply = (getNumber (_vehCfg >> "transportAmmo")) max (getNumber (_vehCfg >> QEGVAR(rearm,defaultSupply)));
if (_vehicle getVariable [QEGVAR(rearm,isSupplyVehicle), (_configSupply > 0)]) then {
    TRACE_1("transportAmmo vehicle - adding virtual ammo",typeOf _vehicle);

    _ammoToDetonate pushBack ["2000Rnd_65x39_belt", 2000];
    _totalAmmo = _totalAmmo + 2000;
    _ammoToDetonate pushBack ["20Rnd_105mm_HEAT_MP", 6];
    _totalAmmo = _totalAmmo + 6;
    _ammoToDetonate pushBack ["SatchelCharge_Remote_Mag", 3];
    _totalAmmo = _totalAmmo + 3;
};

[_ammoToDetonate, _totalAmmo]
