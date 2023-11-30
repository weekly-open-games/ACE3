#include "..\script_component.hpp"
/*
 * Author:tcvm
 * Dismounts the weapon from the tripod and drops its backpack beside
 *
 * Arguments:
 * 0: CSW <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [weapon] call ace_csw_fnc_assemble_pickupWeapon
 *
 * Public: No
 */

[{
    params ["_vehicle", "_player"];
    TRACE_2("assemble_pickupWeapon",_vehicle,_player);

    private _onDisassembleFunc = getText(configOf _vehicle >> QUOTE(ADDON) >> "disassembleFunc");
    private _carryWeaponClassname = getText(configOf _vehicle >> QUOTE(ADDON) >> "disassembleWeapon");
    private _turretClassname = getText(configOf _vehicle >> QUOTE(ADDON) >> "disassembleTurret");
    private _pickupTime = getNumber(configFile >> "CfgWeapons" >> _carryWeaponClassname >> QUOTE(ADDON) >> "pickupTime");
    TRACE_4("",typeOf _vehicle,_carryWeaponClassname,_turretClassname,_pickupTime);
    if (!isClass (configFile >> "CfgWeapons" >> _carryWeaponClassname)) exitWith {ERROR_1("bad weapon classname [%1]",_carryWeaponClassname);};
    // Turret classname can equal nothing if the deploy bag is the "whole" weapon. e.g Kornet, Metis, other ATGMs
    if ((_turretClassname isNotEqualTo "") && {!isClass (configFile >> "CfgVehicles" >> _turretClassname)}) exitWith {ERROR_1("bad turret classname [%1]",_turretClassname);};

    private _onFinish = {
        params ["_args"];
        _args params ["_vehicle", "_player", "_carryWeaponClassname", "_turretClassname", "_onDisassembleFunc"];
        TRACE_4("disassemble finish",_vehicle,_player,_carryWeaponClassname,_turretClassname);

        private _weaponPos = getPosATL _vehicle;
        _weaponPos set [2, (_weaponPos select 2) + 0.1];
        private _weaponDir = getDir _vehicle;

        private _carryWeaponMag = "";
        private _carryWeaponMags = getArray (configFile >> "CfgWeapons" >> _carryWeaponClassname >> "magazines") apply {toLower _x};
        LOG("remove ammo");
        {
            _x params ["_xMag", "", "_xAmmo"];
            if (_xAmmo == 0) then {continue};

            private _carryMag = _xMag call FUNC(getCarryMagazine);
            if (_carryWeaponMag isEqualTo "" && {toLower _carryMag in _carryWeaponMags}) then {
                TRACE_3("Adding mag to secondary weapon",_xMag,_xAmmo,_carryMag);
                _carryWeaponMag = _carryMag;
                DEC(_xAmmo);
            };
            if ((_xAmmo > 0) && {_carryMag != ""}) then {
                TRACE_2("Removing ammo",_xMag,_carryMag);
                [_player, _carryMag, _xAmmo] call FUNC(reload_handleReturnAmmo);
            };
        } forEach (magazinesAllTurrets _vehicle);

        if (_turretClassname isNotEqualTo "") then {
            private _cswTripod = createVehicle [_turretClassname, [0, 0, 0], [], 0, "NONE"];
            // Delay a frame so weapon has a chance to be deleted
            [{
                params ["_cswTripod", "_weaponDir", "_weaponPos"];
                _cswTripod setDir _weaponDir;
                _cswTripod setPosATL _weaponPos;
                _cswTripod setVelocity [0, 0, -0.05];
                _cswTripod setVectorUp (surfaceNormal _weaponPos);
            }, [_cswTripod, _weaponDir, _weaponPos]] call CBA_fnc_execNextFrame;
            [_cswTripod, _vehicle] call (missionNamespace getVariable _onDisassembleFunc);
        };

        [{
            params ["_player", "_weaponPos", "_carryWeaponClassname", "_carryWeaponMag"];
            if ((alive _player) && {(secondaryWeapon _player) == ""}) exitWith {
                _player addWeapon _carryWeaponClassname;
                if (_carryWeaponMag isNotEqualTo "") then {
                    _player addWeaponItem [_carryWeaponClassname, _carryWeaponMag, true];
                };
            };
            private _weaponRelPos = _weaponPos getPos RELATIVE_DIRECTION(90);
            private _weaponHolder = createVehicle ["groundWeaponHolder", [0, 0, 0], [], 0, "NONE"];
            _weaponHolder setDir random [0, 180, 360];
            _weaponHolder setPosATL [_weaponRelPos select 0, _weaponRelPos select 1, _weaponPos select 2];
            if (_carryWeaponMag isEqualTo "") then {
                _weaponHolder addWeaponCargoGlobal [_carryWeaponClassname, 1];
            } else {
                _weaponHolder addWeaponWithAttachmentsCargoGlobal [[_carryWeaponClassname, "", "", "", [_carryWeaponMag, 1], [], ""], 1];
            };
        }, [_player, _weaponPos, _carryWeaponClassname, _carryWeaponMag]] call CBA_fnc_execNextFrame;

        LOG("delete weapon");
        deleteVehicle _vehicle;

        LOG("end");
    };

    private _condition = {
        params ["_args"];
        _args params ["_vehicle"];
        ((crew _vehicle) isEqualTo []) && (alive _vehicle)
    };

    [TIME_PROGRESSBAR(_pickupTime), [_vehicle, _player, _carryWeaponClassname, _turretClassname, _onDisassembleFunc], _onFinish, {}, localize LSTRING(DisassembleCSW_progressBar), _condition] call EFUNC(common,progressBar);
}, _this] call CBA_fnc_execNextFrame;
