#include "..\script_component.hpp"
/*
 * Author: ACE-Team
 * Dev things
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call ace_frag_fnc_dev_trackTrace
 *
 * Public: No
 */

params ["_args", "_pfhID"];
_args params ["_tracerObj", "_index"];

if (alive _tracerObj && {GVAR(traces) isNotEqualTo []}) then {
    private _data = GVAR(traces) select _index;
    private _positions = _data select 4;
    _positions pushBack [getPos _tracerObj, vectorMagnitude (velocity _tracerObj)];
} else {
    [_pfhID] call CBA_fnc_removePerFrameHandler;
};
