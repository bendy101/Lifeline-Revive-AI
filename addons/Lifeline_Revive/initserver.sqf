diag_log "                                                                                   			               '"; 
diag_log "============================================================================================================='";
diag_log "==================================================== MOD ===================================================='";
diag_log "=============================================== initserver.sqf =============================================='";
diag_log "============================================================================================================='";
diag_log "============================================================================================================='";

// Stop AI respawning when killed
{
	_x addMPEventHandler ["MPRespawn", {
		params ["_unit"];
		if (!isPlayer _unit) exitWith {
			deleteVehicle _unit
		};
		// Lifeline_All_Units = Lifeline_All_Units + [_unit];
		Lifeline_All_Units pushBackUnique _unit;
		// Lifeline_incapacitated = Lifeline_incapacitated - [_unit];
		_unit setVariable ["LifelinePairTimeOut", 0, true];
		_unit setVariable ["LifelineBleedOutTime", 0, true];
		_unit setVariable ["bledout", false, true];
		_unit setVariable ["Lifeline_Down",false,true];
		_unit setVariable ["Lifeline_autoRecover",false,true];		
		_unit setVariable ["Lifeline_canceltimer",false,true]; // if showing, cancel it.
		_unit setVariable ["Lifeline_countdown_start",false,true]; // if showing, cancel it.		
		_unit setVariable ["Lifeline_allowdeath",false,true];
		_unit setVariable ["Lifeline_bullethits",0,true];
		_unit setVariable ["ReviveInProgress",0,true];
		_unit setVariable ["num_bandages",nil,true]; // just for debug text . Instead of "(0)" have "(?)" at first.
		_unit setVariable ["Lifeline_selfheal_progss",false,true]; //to stop double firing of the selfheal
		//remove wounds action ID
		if (Lifeline_RevMethod == 2) then {
			_actionId = _unit getVariable ["Lifeline_ActionMenuWounds",false]; 
			[_unit,_actionId] remoteExec ["removeAction",_unit];
			_unit setVariable ["Lifeline_RevActionAdded",false,true];
		};

			Lifeline_Process = Lifeline_Process - [_unit];
	publicVariable "Lifeline_Process";
	}]
} forEach playableUnits;

// ORIGINAL
/* {
	_x addMPEventHandler ["MPRespawn", {
		params ["_unit"];
		if (!isPlayer _unit) exitWith {
			deleteVehicle _unit
		}
	}]
} forEach playableUnits; */

