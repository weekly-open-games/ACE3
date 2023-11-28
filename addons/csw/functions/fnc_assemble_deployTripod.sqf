#include "..\script_component.hpp"
/*
 * Author:tcvm
 * Deploys the tripod
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * [player] call ace_csw_fnc_assemble_deployTripod
 *
 * Public: No
 */

[{
    params ["_player"];
    TRACE_1("assemble_deployTripod",_player);

    // Remove the tripod from the launcher slot
    private _secondaryWeaponClassname = secondaryWeapon _player;
    // handle loaded launchers which can become csw like CUP Metis
    private _secondaryWeaponMagazine = secondaryWeaponMagazine _player param [0, ""];
    _player removeWeaponGlobal (secondaryWeapon _player);

    private _onFinish = {
        params ["_args"];
        _args params ["_player", "_secondaryWeaponClassname", "_secondaryWeaponMagazine"];
        TRACE_3("deployTripod finish",_player,_secondaryWeaponClassname,_secondaryWeaponMagazine);

        private _tripodClassname = getText(configFile >> "CfgWeapons" >> _secondaryWeaponClassname >> QUOTE(ADDON) >> "deploy");

        // Create a tripod
        private _cswTripod = createVehicle [_tripodClassname, [0, 0, 0], [], 0, "NONE"];
        // Because the tripod can be a "full weapon" we disable any data that will allow it to be loaded
        _cswTripod setVariable [QGVAR(assemblyMode), 2, true]; // Explicitly set enabled&unload assembly mode and broadcast
        if (_secondaryWeaponMagazine isNotEqualTo "") then {
            _cswTripod setVariable [QGVAR(secondaryWeaponMagazine), _secondaryWeaponMagazine];
        };
        if (!GVAR(defaultAssemblyMode)) then {
            TRACE_1("global disableVanillaAssembly event",_cswTripod); // handles it being assembled when setting is disabled
            [QGVAR(disableVanillaAssembly), [_cswTripod]] call CBA_fnc_globalEvent;
        };

        private _posATL = _player getRelPos [2, 0];
        _posATL set [2, ((getPosATL _player) select 2) + 0.5];

        _cswTripod setDir (direction _player);
        _cswTripod setCenterOfMass ((getCenterOfMass _cswTripod) vectorAdd [0,0,-0.3]);
        _cswTripod setPosATL _posATL;
        _cswTripod setVectorUp (surfaceNormal _posATL);

        [_player, "PutDown"] call EFUNC(common,doGesture);

        // drag after deploying
        if ((missionNamespace getVariable [QGVAR(dragAfterDeploy), false]) && {["ACE_dragging"] call EFUNC(common,isModLoaded)}) then {
            if ([_player, _cswTripod] call EFUNC(dragging,canCarry)) then {
                TRACE_1("starting carry",_cswTripod);
                [_player, _cswTripod] call EFUNC(dragging,startCarry);
            } else {
                TRACE_1("cannot carry",_cswTripod);
            };
        };
    };

    private _onFailure = {
        params ["_args"];
        _args params ["_player", "_secondaryWeaponClassname", "_secondaryWeaponMagazine"];
        TRACE_3("deployTripod failure",_player,_secondaryWeaponClassname,_secondaryWeaponMagazine);

        _player addWeaponGlobal _secondaryWeaponClassname;
        if (_secondaryWeaponMagazine isNotEqualTo "") then {
            _player addWeaponItem [_secondaryWeaponClassname, _secondaryWeaponMagazine, true];
        };
    };

    private _deployTime = getNumber(configFile >> "CfgWeapons" >> _secondaryWeaponClassname >> QUOTE(ADDON) >> "deployTime");
    [TIME_PROGRESSBAR(_deployTime), [_player, _secondaryWeaponClassname, _secondaryWeaponMagazine], _onFinish, _onFailure, localize LSTRING(PlaceTripod_progressBar)] call EFUNC(common,progressBar);
}, _this] call CBA_fnc_execNextFrame;
