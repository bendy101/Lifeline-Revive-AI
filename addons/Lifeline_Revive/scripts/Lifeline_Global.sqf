diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "========================================== _Global.sqf ================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 

// function to check revive pair and cancel the medic if needed
Lifeline_exit_travel = {
	params ["_incap","_medic","_diagtext","_linenumber"];

	_pairtimeoutbaby = (_incap getVariable ["LifelinePairTimeOut",0]);
	_incapTL = (_incap getVariable ["LifelineBleedOutTime",0]);
	_distcalc = _medic distance2D _incap;
	_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); 
	_exit = false;

	_ifACEdragged = false;
	if (Lifeline_RevMethod == 3) then {
		// if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
		if ([_incap] call Lifeline_check_carried_dragged) then {
		_ifACEdragged = true;
		};
	};

	if ((_pairtimeoutbaby > 0 && time > _pairtimeoutbaby && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3)) 
		|| _pairtimeoutbaby == 0 || _ifACEdragged == true || (lifestate _incap != "INCAPACITATED") || (lifestate _medic == "INCAPACITATED") 
		|| !(alive _medic) || (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != "") 
		|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
		|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")
		|| (!(_medic in _AssignedMedic) && count _AssignedMedic > 0 )
		|| _AssignedMedic isEqualTo []
		|| _medic getVariable ["Lifeline_ExitTravel", false] == true
		|| (_pairtimeoutbaby - time) < 0 //might not need
		// || assignedVehicleRole _medic isNotEqualTo [] //added 2025
		) then {
			_exit = true;
			_medic setVariable ["Lifeline_ExitTravel", true, true];
		};
_exit
};

Lifeline_format_name = {
	params ["_unit","_format","_opfor"];

	if (isNull _unit) exitWith {false};

	_name = name _unit;
	_surname = "";
	_unitnumber = "";
	_group = "";
	_result = "";

	if (_format == 1) then {
		_result = _name;
	};

	if (_format in [2,3,4,6]) then {
		_surname = (_name splitString " ") select ((count (_name splitString " ")) - 1);
	};
	if (_format in [3,5,6,7]) then {
		_unitnumber = str (groupId _unit);
	};
	if (_format in [4,5,6,7]) then {
		_group = (groupId group _unit);
		// if (isNil "_group" || _group == "") then {
		// 	[_unit,"_group is nil"] call serverSide_unitstate;
		// 	playsound "siren_1";
		// 	};		
	};

	if (_format == 2) then {
		_result = _surname;
	};
	if (_format == 3) then {
		_result = _unitnumber + ". " + _surname;
	};	
	if (_format == 4) then {
		_result = _surname;
	};
	if (_format == 5) then {
		//_result = _group + " : " + _unitnumber;
		_result = _unitnumber + " • ";
	};	
	if (_format == 6) then {
		_result =  "<t valign='bottom'>"+_unitnumber + ".</t> " + _surname;
	};		
	if (_format == 7) then {
		_result =  "<t valign='bottom'>"+_unitnumber + ".</t> " + _name;
	};	
	[_result,_group]
};

Lifeline_incap_list_HUD = {
params ["_x","_diag_text"];

		// _diag_text = "";
		_underline = "";
		_underline2 = "";
		// _colur =  "#EEEEEE"; //whiteish
		// _colur2 = "#EEEEEE"; //whiteish
		_colur =  "#faefde"; //whiteish
		_colur2 = "#faefde"; //whiteish
		_colur3 = "#f1948a"; //skin colour for group
		_colur3 = "#FBA399"; //skin colour for group
		// _colur3 = "#FFB2A8"; //skin colour for group
		_joiner = " ";
		_no = "   ";
		_medics = "";
		_tme = "";
		_distcalc = "";
		_incap = _x;
		_opfor = false;

		_size1 = "0.4";
		_sizesm = "0.3";

		if (side group _x != Lifeline_Side) then {
			_opfor = true;
		};

		// _samegroupneat = false; // do this later. If same group only display group name once.

		if (lifestate _x == "INCAPACITATED") then {
				_colur = "#FFBFA7"; //pinkish
				if (Lifeline_RevMethod == 2) then {
					if (Lifeline_BandageLimit > 1 && Lifeline_HUD_names in [2,4]) then {
						_bandges = (_x getVariable ["num_bandages",0]);
						if (_bandges != 0) then {
							_no = "<t size='"+ _sizesm + "'> "+str _bandges+" </t>";
						} else {
							_no = "  "; 
						};
					};	
				};
		};
		if (isPlayer _x) then {_underline = "underline='1'";};

		// if (_x getVariable ["ReviveInProgress",0] == 0) then {
		if (_x getVariable ["ReviveInProgress",0] == 0 && lifestate _x == "INCAPACITATED") then {
			// _colur = "#EE5F09";
			// _colur = "#EE2809"; //red
			_colur = "#FFBFA7"; //pinkish

				//temp for debug opfor
				if (_opfor) then {_colur = "#af7ac5";}; //remove later

			_nameformat = [_x,Lifeline_HUD_nameformat] call Lifeline_format_name;
			_name = _nameformat select 0;
			_group = _nameformat select 1;
			// _diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + _name + "</t>   <br />";
			// _diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + _name + " <t color='#f1948a'>"+_group+" </t>  </t>   <br />";
			_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + _name + " <t color='"+_colur3+"'>"+_group+" </t>  </t>   <br />";
		};

		if (_opfor) then {_colur = "#af7ac5";};

		if (_x getVariable ["ReviveInProgress",0] == 3) then {
			_medic = (_x getVariable ["Lifeline_AssignedMedic", []]);
			{
				if (Lifeline_Revive_debug && isServer && Lifeline_HUD_names_pairtime) then {
					// _tme = str round ((_incap getVariable ["LifelinePairTimeOut",0]) - time);
					_tme = str round ((_incap getVariable ["LifelinePairTimeOut",0]) - time) + " ";
				};
				if (Lifeline_HUD_names in [2,3]) then {
					// _distcalc = "" + str round (_incap distance2D _x) + "m ";
					_distcalc = "" + str round (_incap distance2D _x) + "m 〉";
				};

				_joiner = _distcalc + _tme;

				if (_x getVariable ["ReviveInProgress",0] == 2) then {
					// _colur2 = "#58D68D"; //GREEN
					_colur = "#58D68D";// GREEN  COMMENT THIS OUT TO HAVE DIFF COLOURED INCAP / MEDIC PAIRS WHEN ACTUAL REVIVE
					_colur3 = "#23b45e";
					if (_opfor) then {_colur = "#f105f1";};
					_tme = "";
					_distcalc = "";
					 _joiner = " ↑	 ";
				};
				if (_x getVariable ["Lifeline_selfheal_progss",false] == true) then {					
					// _colur2 = "#faefde"; // yellowy
					// _colur2 = "#f0ebd7"; // yellowy
					_colur2 = "#fadbd8"; // pink brown
				};
				if (isPlayer _x) then {_underline2 = "underline='1'";};
				// _medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) + _name + " " + _distcalc + _tme + "</t>   ";
				_medicnameformat = [_x,Lifeline_HUD_nameformat,_opfor] call Lifeline_format_name;
				_medicname = _medicnameformat select 0;
				_groupmedic = _medicnameformat select 1;
				_medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) + _medicname + " " + "<t color='#bfc9ca'>"+_groupmedic+" </t></t>";
				//_medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) +  "<t size='0.3'>" +_distcalc + _tme + "</t>" + _medicname + " </t>";
			} foreach _medic;

			_nameformat = [_x,Lifeline_HUD_nameformat,_opfor] call Lifeline_format_name;
			_name = _nameformat select 0;
			_group = _nameformat select 1;
			_name = _name + " <t color='"+_colur3+"'>"+_group+"</t>";

			_diag_text = _diag_text + _medics + "<t size='" + _sizesm + "'>" + _joiner + " </t>" + (format ["<t color='%1' %2>", _colur,_underline]) + _name +_no + "</t><br />"; // ORIG 
			// _diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + _no + " " + _name + "</t> - "  + _medics + "<br />";			
		};
_diag_text
};

Lifeline_Smoke = {
	params ["_incap", "_medic"];
	_reldir = 0;
	_relpos = [];
	_col = "";
	_EnemyCloseBy = [_medic] call Lifeline_EnemyCloseBy;
	if (getPosATL _incap select 2 <1) then {
		if (!isNull _EnemyCloseBy && alive _EnemyCloseBy && _EnemyCloseBy isKindOf "CAManbase") then {
				_reldir = _incap getdir _EnemyCloseBy;
		} else {
			_reldir = _incap getdir _medic;
		};
		_relpos = _incap getPos [10, _reldir]; // 10 metres away
		// _relpos = (_incap getPos [10, _reldir]) vectorAdd [0,0,0.5]; // 10 metres away, 0.5m above ground
		_colors= ["yellow","red","purple","orange","green","white"];
		if (Lifeline_SmokeColour == "random") then {
			_col = selectRandom _colors;
		} else {
			_col = Lifeline_SmokeColour;
		};
		_percentchance = 0; _random = 0;
		if (isNull _EnemyCloseBy) then {_percentchance = Lifeline_SmokePerc; } else {_percentchance = Lifeline_EnemySmokePerc;  };
		if (_percentchance == 0) exitWith { };
		if (_percentchance != 100) then {  
			_random = [1,100] call BIS_fnc_randomInt; 
		};
		if (_percentchance == 100 OR _random <= _percentchance) then {
			if (_col=="white") then {_col = ""}; 
			_GrenadeSmokeCol = "SmokeShell"+_col;
			_smoke = createVehicle [_GrenadeSmokeCol, _relpos, [], 0, "NONE"];
			_smoke setPosATL [_relpos select 0, _relpos select 1, 0];
			_randomAngle = random 360;
			_smoke setVectorDirAndUp [[sin _randomAngle, cos _randomAngle, 0], [-cos _randomAngle, sin _randomAngle, 0]]; // Random direction while lying flat
		};	
	};
	true
};

Lifeline_EnemyCloseBy = {
	params ["_unit"];
	_EnemyCloseBy = objNull;
	_select = Lifeline_EnemyCloseByType;
	if (Lifeline_EnemyCloseByType == 3) then {
		_select = selectRandom [1,2];
	};
	if (_select == 1) then {
			_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBySimple;
	} else {
		_EnemyCloseBy = [_unit] call Lifeline_KnowsAboutEnemy;
	};
	_EnemyCloseBy
};

Lifeline_EnemyCloseBySimple = {
	params ["_unit"];
	_EnemiesCloseBy = [];
	_EnemyCloseBy = objNull;
	_EnemySides = (Lifeline_Side call BIS_fnc_enemySides);
	_EnemyUnits = allunits select {side _x in _EnemySides};
	_EnemiesCloseBy = _EnemyUnits select {_x distance _unit <500 && simulationEnabled _x};
	if (count _EnemiesCloseBy >0) then {
		_EnemyCloseBy = _EnemiesCloseBy select 0;
	} else {
		_EnemyCloseBy = objNull;
	};
	_EnemyCloseBy
};

Lifeline_KnowsAboutEnemy = {
    params ["_unit"];
    private _EnemiesKnownBy = [];
    private _EnemyKnownBy = objNull;
    private _knowsAboutThreshold = 1.5; // Fixed threshold value
    // Get enemy sides
    private _EnemySides = ((side group _unit) call BIS_fnc_enemySides);
    // Get all enemy units
    private _EnemyUnits = allunits select {side _x in _EnemySides};
	_EnemiesKnownBy = _EnemyUnits select {
		((group _unit) knowsAbout _x > _knowsAboutThreshold || 
		_unit knowsAbout _x > _knowsAboutThreshold) && 
		simulationEnabled _x &&
		_x distance _unit < 500 &&
		alive _x
	};

	 // check line of sight to enemy, but one metre above the incapciated unit, in case he is lying behind low cover (like sandbags) but not
	 // version one, simple check, just incaps eyes to enemy
	_EnemiesKnownBy = _EnemiesKnownBy select {
		private _elevatedUnitPosEye = eyePos _unit;
		_elevatedUnitPosEye set [2, (_elevatedUnitPosEye select 2) + 1]; // Add 1 meter to the unit's eye height
		!(lineIntersects [_elevatedUnitPosEye, eyePos _x, _unit, _x]) 
	};
    // Return the first enemy that knows about unit or objNull
    if (count _EnemiesKnownBy > 0) then {
		_EnemiesKnownBy = [_EnemiesKnownBy, [], {_unit distance _x}, "ASCEND"] call BIS_fnc_sortBy; //sort by distance, closest first
        _EnemyKnownBy = _EnemiesKnownBy select 0;
    } else {
        _EnemyKnownBy = objNull;
    };
    _EnemyKnownBy
};

//tactical crouch
Lifeline_AutoCrouch = {
	params ["_x","_crouchtrig"];
	// _crouchtrig = _x getVariable ["Lifeline_crouchtrig",false];
	// if (speed _x <= Lifeline_Idle_Crouch_Speed && stance _x == "STAND" && _crouchtrig == false && behaviour _x == "AWARE" && _x getVariable ["ReviveInProgress",0] == 0) then {
	if (speed _x <= Lifeline_Idle_Crouch_Speed && stance _x != "PRONE" && _crouchtrig == false && behaviour _x == "AWARE" && _x getVariable ["ReviveInProgress",0] == 0) then {
		_crouchtrig = true; 
		if (stance _x != "CROUCH") then {
			_x setUnitPos "MIDDLE";
		};
	};
	if ((speed _x > Lifeline_Idle_Crouch_Speed && _crouchtrig == true) || behaviour _x != "AWARE") then {
		_crouchtrig = false;						
		if (unitPos _x != "DOWN") then {
			_x setUnitPos "AUTO";
		};
	}; 
	if (speed _x == 0 && _crouchtrig == true && (behaviour _x == "COMBAT" || behaviour _x == "STEALTH" || (isPlayer (leader group _x) && stance (leader group _x) == "PRONE" && behaviour _x == "AWARE"))) then {
		_crouchtrig = false;
		_x setUnitPos "DOWN";
		_x setUnitPos "AUTO";  
	};
	_x setVariable ["Lifeline_crouchtrig",_crouchtrig, true];
};

Lifeline_POSnexttoincap = {
params ["_incap", "_medic", "_distnextto"];	
	// Step 1: Get the positions of the units
	_posA = getPos _incap;
	_posB = getPos _medic;
	// _posA = getPosASL _incap;
	// _posB = getPosASL _medic;
	// Step 2: Calculate the direction vector from _unitA to _unitB
	_directionVector = _posB vectorDiff _posA;
	// Step 3: Normalize the direction vector
	_directionVectorNormalized = vectorNormalized _directionVector;
	// Step 4: Scale the direction vector by _distnextto meters
	_scaledDirectionVector = _directionVectorNormalized vectorMultiply _distnextto; //_distnextto = metres
	// Step 5: Calculate the new position _distnextto meters from _unitA in the direction of _unitB
	_newPosition = _posA vectorAdd _scaledDirectionVector;
	// testing, choose position that is safe
	// _newPosition = [_newPosition, 1, 5, 5, 0, 20, 0] call BIS_fnc_findSafePos; //experimental
	_newPosition
};

Lifeline_delYelMark = {
	params ["_unit"];
	if !(Lifeline_yellowmarker) exitWith {};
		_yelmark = _unit getVariable ["ymarker1", nil]; 
	if (!isNil "_yelmark") then {
		deleteVehicle _yelmark;
	};
	// _ymrkrs = nearestObjects [_unit,["Sign_Arrow_Yellow_F"], 2];
	// {deleteVehicle _x} foreach _ymrkrs;
};

Lifeline_delIncapMrk = {
	params ["_unit"];
	_allmarkers = allMapMarkers select {markerType _x == "loc_heal"};
	{
		_txt = markerText _x;
		if (alive _unit && (name _unit) in _txt) then {
			deleteMarker _x;
			_unit setVariable ["Lifeline_IncapMark","",true];
		};
	} foreach _allmarkers;
	true
};

Lifeline_reset2 = {
	params ["_units","_lineno"];
	{
		if (alive _x) then {
			[_x] spawn {
				params ["_unit"];
				sleep 2;
				_unit setVariable ["Lifeline_ExitTravel", false, true];
			};		

/* 			_veh = _x getVariable ["AssignedVeh", objNull];
			if (!isNull _veh && !isPlayer _x) then {
				_x setVariable ["Lifeline_back2vehicle",true,true];
				// Add the vehicle to the group's known vehicles
				(group _x) addVehicle _veh;			
				// Allow the unit to get in and assign them to the vehicle
				[_x] allowGetIn true;
				_x assignAsCargo _veh;
				[_x] orderGetIn true;
				[_x] spawn {
					params ["_unit"];
					waitUntil {
						sleep 0.5;
						(vehicle _unit != _unit) || (!alive _unit) || lifestate _unit == "INCAPACITATED"
					};
					_unit setVariable ["Lifeline_back2vehicle",false,true];
				};
			};	 */

			_x setVariable ["ReviveInProgress",0,true];	
			_x setVariable ["Lifeline_AssignedMedic", [], true];
			_x setvariable ["LifelinePairTimeOut",0,true];
			// _x setVariable ["Lifeline_ExitTravel", false, true];
			// these two variables below are just for SOG AI to avoid clashes. 

		    _x setVariable ["isInjured",false,true]; 
			_x setVariable ["isMedic",false,true]; 
            // -------------------- 

			if (_x in Lifeline_Process) then {
				Lifeline_Process = Lifeline_Process - [_x];
				publicVariable "Lifeline_Process";
			};

			// _x enableAI "ANIM";
			_x enableAI "MOVE";
			_x enableAI "AUTOTARGET";
			_x enableAI "AUTOCOMBAT";
			_x enableAI "SUPPRESSION";
			_x enableAI "TARGET";
			group _x setSpeedMode "NORMAL";
			_x limitSpeed 100;
			_x doWatch objNull;
			doStop _x; //ADDED 
			// joinSilent deletes Teamcolour, so workaround here.
			_teamcolour = assignedTeam _x;
			[_x] joinSilent _x; // also makes units get back in assigned vehicles
			_x assignTeam _teamcolour;
			_veh = _x getVariable ["AssignedVeh", objNull];
			if (!isNull _veh && !isPlayer _x) then {
				_x setVariable ["Lifeline_back2vehicle",true,true]; 
				// Add the vehicle to the group's known vehicles
				(group _x) addVehicle _veh; 
				// Allow the unit to get in and assign them to the vehicle
				[_x] allowGetIn true;
				_x assignAsCargo _veh;
				[_x] orderGetIn true;
				[_x,_veh] spawn {
					params ["_unit","_veh"];
					waitUntil {
						sleep 0.5;
						(vehicle _unit != _unit) || (!alive _unit) || lifestate _unit == "INCAPACITATED" ||
						((_veh isKindOf "Air") && !isTouchingGround _veh)
					};
					_unit setVariable ["Lifeline_back2vehicle",false,true];
				};
			} else {
				_x setVariable ["Lifeline_back2vehicle",false,true];
			};
			if (alive leader _x && lifestate leader _x != "incapacitated") then {
				_x doFollow leader _x;
			};

			// _x setvariable ["LifelineBleedOutTime",0,true]; // must be OFF. Its called at end of revive loop even when 15 sec pair is cancelled.
			if (!isNull (_x getVariable ["AssignedVeh", objNull]) && !isPlayer leader _x && isNull assignedVehicle _x) then {
				(group _x) addVehicle (_x getVariable "AssignedVeh"); 
			};
			if (isplayer _x && alive _x && lifestate _x != "INCAPACITATED") then {
				[group _x, _x] remoteExec ["selectLeader", groupOwner group _x];
				{_teamcolour = assignedTeam _x;[_x] joinSilent group _x;_x assignTeam _teamcolour;} foreach units group _x; // joinSilent deletes Teamcolour, so workaround here.
			};	

			// fix animation if animation if incap but unit is healthy
			if (lifestate _x != "INCAPACITATED" && alive _x && (animationState _x find "unconscious" == 0 && animationState _x != "unconsciousrevivedefault" && animationState _x != "unconsciousoutprone")) then {
					[_x, "unconsciousrevivedefault"] remoteExec ["SwitchMove", 0];
			};

			//this should be completely turned off. 
			if (lifestate _x != "INCAPACITATED") then { 
               //spawn for delay
			//    [_x] spawn {
				// params ["_x"];
				// sleep 5;
				_captive = _x getVariable ["Lifeline_Captive", false];
				// if !(local _x) then {
					_timestamp = time;
					_x allowDamage true;					
					_x setCaptive _captive; 
					[_x, true] remoteExec ["allowDamage",0];
					[_x, _captive] remoteExec ["setCaptive",0];
				//  } else {
					// _x allowDamage true;
					// _x setCaptive false; 
					// _x setCaptive _captive; 
				// };	 
			//    }; //endspawn
					/* [_x,_captive] spawn {
						params ["_unit","_captive"];	
						_unit setVariable ["Lifeline_Captive_Delay",true,true];
						sleep 5;
						if (_unit getVariable ["ReviveInProgress",0] != 2) then { 
							_unit setCaptive _captive; 
							[_unit, _captive] remoteExec ["setCaptive",0];	 
							_unit setVariable ["Lifeline_Captive_Delay",false,true];
						};
					}; */
			};	
		};	//if (alive _x) then 
	} forEach _units;

	true
};

Lifeline_SelfHeal = {
	params ["_unit"];

    // Fix this later. A medic should be able to stop healing an incap to heal himself between incap heal animation

	if (_unit getVariable ["ReviveInProgress",0] == 2 || lifestate _unit == "INCAPACITATED") exitWith {// update
	};

	_unit setVariable ["Lifeline_selfheal_progss",true,true];
	if (_unit getVariable ["ReviveInProgress",0] == 0) then {
		sleep 3;
		sleep (random 2); // this must be BEFORE cheching incapacitated. Otherwise in these 5 secs it can happen, and bugs animation.
	};

	_bypass = false;

	// if the SelfHeal Condition Setting is set to 2, then we need to check if there is an enemy within 100m. (line of sight). No self heal then, return fire more important.
	if (Lifeline_SelfHeal_Cond == 2) then {
		_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;
		if (!isnull _EnemyCloseBy && _unit distance _EnemyCloseBy < 100) then {
			_bypass = true;
		};
	};

	if (_bypass == false && alive _unit && lifeState _unit != "INCAPACITATED" && (isnull (objectParent _unit))) then {

		// if (alive _unit && lifeState _unit != "INCAPACITATED" && Lifeline_RevMethod != 3 && (damage _unit > 0.2 || _unit getHitPointDamage "hitlegs" >= 0.5) && (isnull (objectParent _unit))) then {
		if (Lifeline_RevMethod != 3 && (damage _unit > 0.2 || _unit getHitPointDamage "hitlegs" >= 0.5)) then {

			_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;

			// if (_unit getVariable ["ReviveInProgress",0] in [1,2]) then { // original to revert to if need be
			if (_unit getVariable ["ReviveInProgress",0] == 1) then { //update 14/04/2025
				_unit setVariable ["LifelinePairTimeOut", (_unit getvariable "LifelinePairTimeOut") + 5, true];  
			}; // add 5 secs to timeout

			// if (isnull _EnemyCloseBy or _unit distance _EnemyCloseBy >100) then {
			// if (isnull _EnemyCloseBy) then {
			if ((stance _unit == "STAND" || stance _unit == "CROUCH") && stance _unit != "UNDEFINED") then {
				[_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow", 0];
				sleep 6;
			} else {
				[_unit,"ainvppnemstpslaywrfldnon_medic"] remoteExec ["playMoveNow",0];
				sleep 7;
			};

			if (lifeState _unit != "INCAPACITATED") then { //added again
				_unit setdamage 0;
			};		
		};		

		// if (alive _unit && lifeState _unit != "INCAPACITATED" && Lifeline_RevMethod == 3 && (isnull (objectParent _unit))) then {
		if (Lifeline_RevMethod == 3) then {
			[_unit] call Lifeline_SelfHeal_ACE;
		};

	}; //end bypass
	_unit setVariable ["Lifeline_selfheal_progss",false,true];

	true
};

//========================== MAIN FUNCTION LOOP TO CHECK INCAP / MEDIC PAIR
Lifeline_PairLoop = {
	params ["_medic","_incap"];

	// if (Lifeline_Revive_debug && Lifeline_hintsilent) then {[format ["Incap: %1\nMedic: %2", name _incap, name _medic]] remoteExec ["hintsilent", 2]};
	if (Lifeline_Revive_debug && Lifeline_hintsilent) then {[format ["Incap: %1\nMedic: %2", name _incap, name _medic]] remoteExec ["diag_log", 0]};

	_poscheck = getpos _medic; // for checking idle medic
	_idleMlimit = 7; // number of seconds an idle medic before resetting
	_repeatcount = _idleMlimit; // for checking idle medic
	_exit = false; // for exiting loop without using getVariable
	_idlemedic = false;
	_closermedic = false;

	while {alive _medic && lifestate _incap == "INCAPACITATED" && (_incap getVariable ["LifelinePairTimeOut",0])>0} do {

		// check time limit
		_elapsedTimeToRevive = (_incap getVariable ["LifelinePairTimeOut",0]);
		_incapTL = (_incap getVariable ["LifelineBleedOutTime",0]);

		if (isNil "_incapTL" && Lifeline_Revive_debug) then {
			[_incap,"_incapTL ISSUE"] remoteExec ["serverSide_unitstate", 2];
			["_incapTL ISSUE"] remoteExec ["serverSide_Globals", 2];
		};

		_distcalc = _medic distance2D _incap;
		if (animationstate _medic in ["aidlpercmstpsraswrfldnon_g01","aidlpercmstpsraswrfldnon_g02","aidlpercmstpsraswrfldnon_g03",
				"aidlpercmstpsraswrfldnon_g04","amovpknlmstpslowwrfldnon","aidlpercmstpsraswrfldnon_ai"]) then {
		};

		// THIS IS TO STOP IDLE MEDICS. SOMETIMES HAPPENS.
		// if (Lifeline_Idle_Medic_Stop && (animationstate _medic in ["aidlpercmstpsraswrfldnon_g01","aidlpercmstpsraswrfldnon_g02","aidlpercmstpsraswrfldnon_g03","aidlpercmstpsraswrfldnon_g04","amovpknlmstpslowwrfldnon","aidlpercmstpsraswrfldnon_ai"] || _repeatcount != 6)) then { 
		if (Lifeline_Idle_Medic_Stop && (speed _medic == 0 || _repeatcount != 6) && (_medic getVariable ["ReviveInProgress",0] == 1) && _distcalc > 6 && _medic getVariable ["Lifeline_selfheal_progss",false] == false) then { 
			if (_repeatcount < 4) then { // just beep for debugging
				if (Lifeline_Revive_debug) then {
					if (Lifeline_hintsilent) then {hintsilent format ["%1 IDLE MEDIC %2", name _medic, _repeatcount]}; 
					if (Lifeline_debug_soundalert) then {["beep_hi_1"] remoteExec ["playsound",2]};
				};
			};
		   if (_repeatcount == _idleMlimit) then { _poscheck = getpos _medic; }; 
		   if (_repeatcount == 0 && _poscheck isEqualTo getpos _medic) exitWith { 
				if (Lifeline_Revive_debug) then {
				   if (Lifeline_debug_soundalert) then {["stop_idle_medic"] remoteExec ["playSound",2]}; 
				   if (Lifeline_hintsilent) then {hintsilent format ["%1 STOPPED IDLE MEDIC", name _medic]}; 
			   };
			   _repeatcount = _idleMlimit; 
			   // _incap setVariable ["LifelinePairTimeOut", 0,true]; 
			   _exit = true; 
			   _idlemedic = true;			   
			   if (Lifeline_Revive_debug) then {[_medic,"IDLE MEDIC [0403]"] call serverSide_unitstate};
			   _medic call reset_idle_medics;			   
		   }; 
		   // if (_poscheck isEqualTo getpos _medic) then {_repeatcount = _repeatcount - 1}; 
		   _repeatcount = _repeatcount - 1;
		   if (_repeatcount < 0 || _poscheck isNotEqualTo getpos _medic) then {_repeatcount = _idleMlimit; if (Lifeline_hintsilent) then {hintsilent ""};}; 
		};

		 //check for closer medic
		 _closermedic_dist = 100;
		 _medic_under_limit = true;
		 _medics2chooseCloser = [];

		 // VERSION 1
/* 		if (_distcalc > _closermedic_dist ) then {

			 Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;
			 sleep 0.1;
			 // new code 
			 _medics2chooseCloser = (Lifeline_healthy_units select {[_x, _incap] call Lifeline_check_available_medic});
			//  _medics2chooseCloser = (_Lifeline_healthy_units_side select {[_x, _incap] call Lifeline_check_available_medic});

			 _closermedic = false;
			 {
				  _dis = _x distance2D _incap;
				 if (_dis < _closermedic_dist) then {
					 _closermedic = true;
				 };		 
			 } foreach _medics2chooseCloser;

			 if (count _medics2chooseCloser > 0 && _closermedic == true) then {
				if (Lifeline_Revive_debug) then {
					if (Lifeline_debug_soundalert) then {["closermedic"] remoteExec ["playSound",2]}; 
					if (Lifeline_hintsilent) then {hintsilent format ["%1  CLOSER MEDIC ", name _medic]}; 
				 };
				  _exit = true;
				  _medic setVariable ["Lifeline_ExitTravel", true, true];
			  };
		};		*/
		 // VERSION 2
		 if (_distcalc > _closermedic_dist ) then {

			 Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;
			 sleep 0.1;
			 // new code 
			 _medic_under_limit = [_incap,true] call Lifeline_Medic_Num_Limit;
			 if (_medic_under_limit) then {
			    _medics2chooseCloser = (Lifeline_healthy_units select {[_x, _incap] call Lifeline_check_available_medic});
				//  _medics2chooseCloser = (_Lifeline_healthy_units_side select {[_x, _incap] call Lifeline_check_available_medic});
				_closermedic = false;
				{
					_dis = _x distance2D _incap;
					if (_dis < _closermedic_dist) then {
						_closermedic = true;
					};		 
				} foreach _medics2chooseCloser;

				if (count _medics2chooseCloser > 0 && _closermedic == true) then {
					if (Lifeline_Revive_debug) then {
						if (Lifeline_debug_soundalert) then {["closermedic"] remoteExec ["playSound",2]}; 
						if (Lifeline_hintsilent) then {hintsilent format ["%1  CLOSER MEDIC ", name _medic]}; 
					};
					_exit = true;
					_medic setVariable ["Lifeline_ExitTravel", true, true];
				};
			 };
		};	

		//JUST DEBUGGING
		_formatedReviveTime = round(_elapsedTimeToRevive - time);
		if (Lifeline_RevMethod == 2 && Lifeline_Revive_debug) then {
			// diag_log format [" %3 | %4 |xxxxxxxxxxxxxxxxxxx REVIVETIME %2 BLEEDOUT %5 DISTANCE %6 ReviveInProgress %7 autoRecover %8 |'", 0, if (_formatedReviveTime < 10) then {"0"+(str _formatedReviveTime)} else {_formatedReviveTime}, name _incap, name _medic, round(_incapTL - time), _distcalc toFixed 0, _medic getVariable ["ReviveInProgress",0], _incap getVariable ["Lifeline_autoRecover",false] ];
		};
		if (Lifeline_RevMethod == 3 && Lifeline_Revive_debug) then {
			// diag_log format [" %3 | %4 |xxxxxxxxxxxxxxxxxxx REVIVETIME %2 DISTANCE %5 ReviveInProgress %6 |'", 0, if (_formatedReviveTime < 10) then {"0"+(str _formatedReviveTime)} else {_formatedReviveTime}, name _incap, name _medic, _distcalc toFixed 0, _medic getVariable ["ReviveInProgress",0] ];
		};
		// };		

		_ifACEdragged = false;
		if (Lifeline_RevMethod == 3) then {
			// if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
			if ([_incap] call Lifeline_check_carried_dragged) then {
			_ifACEdragged = true;
			};
		};

		if ((_elapsedTimeToRevive > 0 && time > _elapsedTimeToRevive && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3)) 
			|| _elapsedTimeToRevive == 0 || _ifACEdragged == true || (lifestate _incap != "INCAPACITATED") || (lifestate _medic == "INCAPACITATED") 
			|| !(alive _medic) || (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != "") 
			|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
			|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")	
			|| _exit == true) then {

				_medic setVariable ["Lifeline_ExitTravel", true, true];

				if (Lifeline_Revive_debug) then {
					diag_log format ["%3|%4| '", _incap, _medic,name _incap,name _medic];
					if (_elapsedTimeToRevive > 0 && time > _elapsedTimeToRevive && (Lifeline_RevMethod == 2 && time < _incapTL || Lifeline_RevMethod == 3))  then {
					if (Lifeline_hintsilent) then {["Medic reset\nTaking too long"] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0495] MEDIC RESET TAKING TOO LONG'", _incap, _medic,name _incap,name _medic];
					};
					if ((lifestate _medic == "INCAPACITATED") || (lifestate _medic == "DEAD") || (lifestate _medic == "DEAD-RESPAWN") || (lifestate _medic == "DEAD-SWITCHING")) then {
					if (Lifeline_hintsilent) then {[format ["Medic DOWN\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0499] MEDIC DOWN!!!'", _incap, _medic,name _incap,name _medic];
					};
					if (_closermedic == true && _exit == true) then {
					if (Lifeline_hintsilent) then {[format ["Medic Closer\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0503] CLOSER MEDIC !!!'", _incap, _medic,name _incap,name _medic];
					};				
					if (_idlemedic == true && _exit == true) then {
					if (Lifeline_hintsilent) then {[format ["Medic Idle\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0507] IDLE MEDIC !!!'", _incap, _medic,name _incap,name _medic];
					};
					if (lifestate _incap != "INCAPACITATED") then {
					if (Lifeline_hintsilent) then {[format ["Medic WOKE UP\n%1", name _medic]] remoteExec ["hintsilent", 2]};
					diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0511] INCAP WOKE UP!!!'", _incap, _medic,name _incap,name _medic];
					};
					if (currentWeapon _medic == secondaryWeapon _medic && currentWeapon _medic != ""
						|| (((assignedTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "") //check unit did not get order to hunt tank
						|| (((getAttackTarget _medic) isKindOf "Tank") && secondaryWeapon _medic != "")					
					) then {
						if (Lifeline_debug_soundalert) then {["medichaslauncher"] remoteExec ["playSound",2]};
						if (Lifeline_hintsilent) then {[format ["Medic w Launcher\n%1", name _medic]] remoteExec ["hintsilent", 2]};
						diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0516] MEDIC HAS LAUNCHER!!!'", _incap, _medic,name _incap,name _medic];				
					};
					diag_log format ["%3|%4| '", _incap, _medic,name _incap,name _medic];
					_incap call Lifeline_delYelMark;
				};

				_exit = false;

				_teamcolour = assignedTeam _medic; // joinSilent deletes Teamcolour, so workaround here.
				[_medic] joinSilent _medic; 
				_medic assignTeam _teamcolour; // joinSilent deletes Teamcolour, so workaround here.
				_medic = objNull;

		}; // end time > _LifelinePairTimeOut 

		//if the medic switches to launcher, it means a tank needs to be taken out. Cancel medic then, more important is tank. - Lifeline
		if ((_incap getVariable ["LifelinePairTimeOut", 0]) == 0) exitWith {};
		if ((_medic getVariable ["Lifeline_ExitTravel", false]) == true) exitWith {};

		sleep 1;
	}; // end while

}; // END Fnc spawn recovery, recycle or death func

//========================== MAIN REVIVE FUNCTION STARTING MEDIC TRAVEL
Lifeline_StartRevive = {
	params ["_medic", "_incap"];

	_dmg_trig = dmg_trig;
	_cptv_trig = false;
	_opforpve = false;

	if (Lifeline_RevProtect in [1,2]) then {
		_cptv_trig = cptv_trig;
	};

	// if its only PVE and not PVP, and OPFOR is included, then turn off indestructible for OPFOR while reviving.
	if (Lifeline_Include_OPFOR && Lifeline_PVPstatus == false && (side group _medic) in Lifeline_OPFOR_Sides) then {
		_dmg_trig = true;
		_cptv_trig = true;
		_opforpve = true;
	};

	[_medic,["COURAGE", 1]] remoteExec ["setSkill",0];
	[_medic,"AUTOTARGET"] remoteExec ["disableAI",0];
	[_medic,"AUTOCOMBAT"] remoteExec ["disableAI",0];
	[_medic,"SUPPRESSION"] remoteExec ["disableAI",0];
	[_medic,"TARGET"] remoteExec ["disableAI",0];
	[_medic,0.2] remoteExec ["allowFleeing",0];
	[_medic,"TARGET"] remoteExec ["disableAI",0];

	_linenumber = "0744";
	_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;

	_voice = _medic getVariable "Lifeline_Voice";
	_B = "";
	_EnemyCloseBy = objNull;	
	_yelmark = objNull;	
	_goup = group _medic;	// check group 4 medic
	_revivePos = [];
	_distnextto = 0;
	_dir = 0;
	_revtime = time;
	_shortorigdist = false;
	_shortorigdist6 = false;
	_stance = UnitPos _medic;

	if !(_exit) then {
		_linenumber = "0757";
		_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;
	};	
	if (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {

		//if original distance is short, the medic overshoots the incap (goes too far). This var for adjusting anim.
		if ((_medic distance2D _incap) <= 10) then {
			_shortorigdist = true;
			// _medic limitSpeed 2;
			// sleep 4;			
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "shortdistance"};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 SHORT DISTANCE ", name _medic]};
		};

		//TEMP NEW
		if ((_medic distance2D _incap) <= 6)  then {
			_shortorigdist6 = true;
			if (stance _medic == "STAND") then {
				_medic setUnitPos "MIDDLE";
			};
		};

		// unassign vehicle if lost group status
		if (!isplayer (leader group _medic) && isPlayer _incap) then {
			{if (!isplayer _x) then {_x leaveVehicle (assignedVehicle _x)}} foreach (units leader _incap);
		};

		//check if bleeding. both for ACE and non-ACE
		_isbleeding = false;
		if (Lifeline_RevMethod == 3) then {
			_isbleeding = [_medic] call ace_medical_blood_fnc_isBleeding;
		} else {
			if (damage _medic >=0.2 || _medic getHitPointDamage "hitlegs" >= 0.5) then { 
			_isbleeding = true;
			};
		};
		if (!isPlayer _medic && !(lifestate _medic == "INCAPACITATED") && alive _medic && _isbleeding == true 
			&& _medic getVariable ["Lifeline_selfheal_progss",false] == false && Lifeline_SelfHeal_Cond > 0 //update 2025-05-11
		) then {
			_medic call Lifeline_SelfHeal;
		};

		// ========== Start travel ===========

		// update this later. bad method for making sure animation works when not having primary weapon. 
		if (alive _medic && primaryWeapon _medic == "") then {_medic addWeapon "arifle_MX_F"};
		if (alive _medic && currentWeapon _medic != (primaryWeapon _medic)) then {_medic selectWeapon (primaryWeapon _medic)};

		// _EnemyCloseBy = [_medic] call Lifeline_EnemyCloseBy;
		_EnemyCloseBy = [_incap] call Lifeline_EnemyCloseBy; // we should use incap because that is where the revive happens
		_cpr = false;
		if (Lifeline_RevMethod == 3) then {
				_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
		};

		// calc position depending on enemy proximity
		// if (!isnull _EnemyCloseBy) then {
		if (!isnull _EnemyCloseBy && _cpr == false) then {
			_distnextto = 1.5;
		} else {
			_distnextto = 0.8;
		};

		_revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
		// _revivePos set [2,0]; // Set height. Maybe turn this off
		//TEMP // maybe this whole block should move as a waitUntil {_medic distance2D _revivePos < 10} further down this function
		[_incap,_medic,_revivePos,_EnemyCloseBy] spawn {
			params ["_incap","_medic","_revivePos","_EnemyCloseBy"];

			// sleep 4;
			_revivePosCheck = "";
			_cpr = false;
			_medicpos = getPos _medic;
			_medicpos2 = [];
			_directioncount = 3; //re-align direction only 3 times, to prevent a loop of constant direction glitch
			_checkdegrees = 0;
			_teleptrig = false; //this is to make sure teleport is only triggered once. Teleport is a micro teleport of under 5 metres to make sure medic is in right spot.
			_telepcheck = nil; // this var is to check medic position against revive position for potential teleport

			while {alive _medic && alive _incap && _medic getVariable ["ReviveInProgress",0] in [1,2] && lifestate _incap == "INCAPACITATED"} do {
				if (_medic distance2D _revivePos < 10) then { 

					if (Lifeline_RevMethod == 3) then {
						_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
					};
				// if (!isnull _EnemyCloseBy && _cpr == false) then {
				// 		_revivePosCheck = [_incap, _medic, 1.5] call Lifeline_POSnexttoincap;
				// 	} else {
				// 		_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap; 
				// 	}; 
					if (!isnull _EnemyCloseBy && _cpr == false) then {
							// _revivePosCheck = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
							_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap;
					} else {
						// _revivePosCheck  = _incap;				
							// _revivePosCheck  = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;			
							_revivePosCheck  = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;			
					};

					if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {

						//============== MARKERS ======
						_incap call Lifeline_delYelMark;
						_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
						_incap setVariable ["ymarker1", _yelmark, true]; 							
						//================================
					};

					_telepcheck = _revivePos;

					// if (_revivePos isNotEqualTo _revivePosCheck) then {
					if (_revivePos distance2D _revivePosCheck > 0.2 && _medic distance2D _incap > 4) then {
					// if (_revivePos distance2D _revivePosCheck > 0.5) then {	

						_revivePos = _revivePosCheck; // commenting out this line, gets diff results. Test/											
						_incap setVariable ["Lifeline_RevPosX",_revivePos,true];

						if (_medic getVariable ["ReviveInProgress",0] == 1) then {
							//_teamcolour = assignedTeam _medic;[_medic] joinSilent _medic;_medic assignTeam _teamcolour; // joinSilent deletes Teamcolour, so workaround here.
							_medic domove position _medic;
							_medic moveto position _medic;
							_medic domove _revivePos;
							_medic moveto _revivePos;
							if (Lifeline_Revive_debug) then {
								if (Lifeline_debug_soundalert) then {playsound "beep_hi_1"};
								if (Lifeline_hintsilent) then {hint format ["%1 DOMOVE MEDIC", name _medic]};
							};
						};

						if (Lifeline_yellowmarker && Lifeline_Revive_debug) then {
							_incap call Lifeline_delYelMark;
							_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
							_incap setVariable ["ymarker1", _yelmark, true]; 	
						};
					};
					// make sure medic is facing right direction. Only for ACE at the moment
					if (Lifeline_RevMethod == 3) then {
						// if (_directioncount > 0) then {_checkdegrees = [_incap,_medic,30] call Lifeline_checkdegrees;};
						_checkdegrees = [_incap,_medic,20] call Lifeline_checkdegrees;
						if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false && _directioncount > 0) then {
							// if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false) then {
							if (Lifeline_Revive_debug) then {
								if (Lifeline_debug_soundalert) then {["forcedirection"] remoteExec ["playSound", 0]};
								if (Lifeline_hintsilent) then {hint format ["%1 FORCE DIRECTION", name _medic]};
							};
							_direction = _medic getDir _incap;
							// _medic setDir _direction;
							[_medic, _direction] remoteExec ["setDir", 0];
							// _directioncount = _directioncount - 1;
						};
					};
				}; //if (_medic distance2D _revivePos < 10) then { 

				sleep 2;
				_medicpos2 = getPos _medic;

			}; // end WHILE

			_incap setVariable ["Lifeline_RevPosX",nil,true];
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = _medic getVariable ["_greenmark1", nil]; 
				if (!isNil "_greenmark") then {deleteVehicle _greenmark};				
				_greenmark = _medic getVariable ["_greenmark2", nil]; 
				if (!isNil "_greenmark") then {deleteVehicle _greenmark};
			};
		};

		// [center, minDist, maxDist, objDist, waterMode, maxGrad, shoreMode, blacklistPos, defaultPos] call BIS_fnc_findSafePos

	}; // END IF (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {

	if !(_exit) then {
		_linenumber = "0817";
		_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;
	};

	if (Lifeline_Revive_debug) then {
		if (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
				diag_log format ["|%1|%2|++++ YELLOW MARKER ++++ [0632] '", name _incap,name _medic];
				if (Lifeline_yellowmarker) then {
					_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
					_incap setVariable ["ymarker1", _yelmark, true]; 	
				};
		} else {
				diag_log format ["|%1|%2|++++ BYPASS YELLOW MARKER ++++ [0640] '", name _incap,name _medic];
		};
	};

	_waypoint = [];

	if (alive _medic && alive _incap && (lifestate _incap == "INCAPACITATED") && (lifestate _medic != "INCAPACITATED") && _medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
			_revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			_teamcolour = assignedTeam _medic;// joinSilent deletes Teamcolour, so workaround here.

			// good for getting confused in buildings - confirm later
			// [_medic] joinSilent _medic; // THIS AFFECTS SPEED. FUCKS UP UNITS THAT LEAVE TURRENTS AND ALREADY PART OF GROUP WITH MULTPLE
			_medic assignTeam _teamcolour;// joinSilent deletes Teamcolour, so workaround here.
			if (_shortorigdist6) then {
				_medic limitSpeed 2;
				// group _medic setSpeedMode "LIMITED";
				// playsound "testC";
			};

			//remoteExec version. Even though documentation says doMove and MoveTo is global, was getting errors, so remoteExec seemed to fix it. 
			[_medic, position _medic] remoteExec ["moveTo", 0];
			[_medic, position _medic] remoteExec ["doMove", 0];
			[_medic, _revivePos] remoteExec ["moveTo", 0];
			[_medic, _revivePos] remoteExec ["doMove", 0];

			_linenumber = "0868";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};
			waitUntil {
				sleep 0.1;
				(_medic distance2D _revivePos <=100 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0882";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			if (_medic distance2D _revivePos > 97 && Lifeline_radio && lifeState _medic != "INCAPACITATED" && lifeState _incap == "INCAPACITATED" && _exit == false 
			&& _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 && _incap getvariable ["LifelinePairTimeOut",0] !=0 
			) then {
					if (isPlayer _incap) then {
					[_incap, [_voice+"_100m1", 50, 1, true]] remoteExec ["say3D", _incap];
					};
			};	

			_linenumber = "0896";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			waitUntil {
				sleep 0.1;
				(_medic distance2D _revivePos <=50 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0909";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			if (_medic distance2D _revivePos > 47 && Lifeline_radio && lifeState _medic != "INCAPACITATED" && lifeState _incap == "INCAPACITATED" && _exit == false 
				&& _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 && _incap getvariable ["LifelinePairTimeOut",0] !=0 
			) then {
					if (isPlayer _incap) then {
						[_incap, [_voice+"_50m1", 50, 1, true]] remoteExec ["say3D", _incap];
					};
			};		

			_linenumber = "0923";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;

			// DISTANCE RADIUS <=10 || 	// DISTANCE RADIUS <=15

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			waitUntil {
				sleep 0.1;
				((_medic distance2D _revivePos <=10 && speed _medic < 14) || (_medic distance2D _revivePos <=15 && speed _medic >= 14) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// ((_medic distance2D _revivePos <=10 && speed _medic < 17) || (_medic distance2D _revivePos <=15 && speed _medic > 17) || (_shortorigdist == true) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0953";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;

			// DISTANCE RADIUS <=8 || 	// DISTANCE RADIUS <=15

			waitUntil {
				sleep 0.1;
				(((_medic distance2D _incap <=8 && speed _medic < 14) || (_medic distance2D _incap <=15 && speed _medic >= 14)) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true  || _shortorigdist == true
				// (((_medic distance2D _incap <=6 && speed _medic < 17) || (_medic distance2D _incap <=15 && speed _medic > 17)) || (_shortorigdist == true) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true		
				)
			};

			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
				_pairtimebaby = "LifelinePairTimeOut";
				_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
				_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true];
				if (lifestate _medic != "INCAPACITATED" && !(_medic getVariable ["Lifeline_Captive_Delay",false])) then {
					_medic setVariable ["Lifeline_Captive",(captive _medic),true]; //2025
				};

				// if (Lifeline_RevProtect != 3) then {
					// if !(local _medic) then {

					[_medic,_dmg_trig] remoteExec ["allowDamage",0];
				if (Lifeline_RevProtect in [1,2]) then {	
					[_medic,_cptv_trig] remoteExec ["setCaptive",0];
				};

				// };							
			};

			_linenumber = "0978";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			_unblockwtime = time;

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			// some medics were getting stuck waiting for this. Added a timer to unblock.
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;

			// DISTANCE RADIUS <=6 || 	// DISTANCE RADIUS <=8

			waitUntil {
				_medic domove _revivePos;
				sleep 0.7;
				// ((_medic distance2D _revivePos <=2.5 && speed _medic < 14) || (_medic distance2D _revivePos <= 8 && speed _medic >= 14) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				((_medic distance2D _revivePos <=6 && speed _medic < 14) || (_medic distance2D _revivePos <= 8 && speed _medic >= 14) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				) 
			};			

			// group _medic setspeedMode "FULL";

			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
				_pairtimebaby = "LifelinePairTimeOut";
				_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
				_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
			};

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;			

			_animMove = "";
			_animStop = "";
			_dist = _medic distance _revivePos;
			_timer = time;
			_newrevpos = nil; //distance of yellow marker from incap
			_posture = nil;

			if (!isnull _EnemyCloseBy) then {
				// commando crawl
				// _revivePos = [_incap, _medic, 1.9] call Lifeline_POSnexttoincap;
				_animMove = "amovppnemsprslowwrfldf"; // move
				_animStop = "amovppnemstpsraswrfldnon"; // stop
				_newrevpos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
				_posture = "DOWN";
			} else {
				// crouch
				// _revivePos = [_incap, _medic, 0.9] call Lifeline_POSnexttoincap;
				_animMove = "amovpknlmwlkslowwrfldf"; //"amovpknlmwlkslowwrfldf"; "amovpknlmrunslowwrfldf" "amovpercmrunsraswrfldf"
				_animStop = "amovpknlmstpslowwrfldnon";
				// _newrevpos = _incap;
				_newrevpos = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;				
				_posture = "MIDDLE";
			};

			// GREEN MARKER BEFORE ANIM CHANGE
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = createVehicle ["Sign_Arrow_green_F", getPos _medic,[],0,"can_collide"];
				_medic setVariable ["_greenmark1", _greenmark, true]; 
			};

			//this is vital and must be kept, otherwise anim stands up
			if (alive _medic && !(lifestate _medic == "INCAPACITATED")) then {
			// check the do watch turn here, they walk wrong direction sometimes. Might be remoteExec issue. (temp changed to nonRemoteExec)
				_medic lookAt _newrevpos;
				// [_medic, _newrevpos] remoteExec ["lookAt", 0];
				// _medic doWatch _newrevpos;
				_timechc = time;
				_checkdegrees = [_newrevpos,_medic,15] call Lifeline_checkdegrees;
				if (_checkdegrees == false) then {	
					if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
					if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};			
					waitUntil {						
						_medic lookAt _newrevpos;
						// [_medic, _newrevpos] remoteExec ["lookAt", 0];
						_checkdegrees = [_newrevpos,_medic,30] call Lifeline_checkdegrees;
						if (time - _timechc > 5) then {
							_medic lookAt _newrevpos;
							// [_medic, _newrevpos] remoteExec ["lookAt", 0];
							_medic disableAI "ANIM";
							// [_medic, "ANIM"] remoteExec ["disableAI", 0]; 
							_medic setDir (_medic getDir _newrevpos);
							// [_medic, (_medic getDir _newrevpos)] remoteExec ["setDir", 0];
						};
						(_checkdegrees == true)				
						// (_checkdegrees == true || time - _timechc > 5)				
					};

					// [_medic, _newrevpos] call Lifeline_align_dir;

				};
				if (Lifeline_travel_meth == 0) then {
					_medic disableAI "ANIM"; //TEMP
					[_medic, "ANIM"] remoteExec ["disableAI", 0];
					_medic playMoveNow _animMove;					[_medic,_animMove] remoteExec ["playMoveNow",0];
				};
				if (Lifeline_travel_meth == 1) then {
					// _medic setUnitPos _posture; //posture
					[_medic, _posture] remoteExec ["setUnitPos", 0];
				};				
			};

			_rposDist = _revivePos distance2D _incap;

			_linenumber = "1031";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};			
			_unblockwtime = time;
			_selfheal_trig = false; //one time trigger to stop repeated spamming of the check to see if self-revive is active, in the "waitUntil" below
			_trig1 = false;
			_trig2 = false;
			_diag_texty2 = ""; //only for diag_log

			//check its right direction 
			// [_medic,_newrevpos] call Lifeline_align_dir;

			// DISTANCE RADIUS <=4

			waitUntil {
				// sleep 0.1;
				sleep 0.2;
				if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						sleep 2;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1 && [_medic, _incap] call Lifeline_check_available_medic) then { 

							// _medic disableAI "ANIM";
							// _medic enableAI "ANIM";							// _medic setPos _newrevpos;
							_medic disableAI "ANIM";
							[_medic, "ANIM"] remoteExec ["disableAI", 0];
							// _medic setDir (_medic getDir _incap);
							[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							[_medic,_animMove] remoteExec ["playMoveNow",0];
							_trig1 = false;
						};
					};
				};

				if (_medic distance2D _newrevpos > 8 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig2 == false) then { 
					_trig2 = true;

					if (!isnull _EnemyCloseBy) then {_newrevpos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
						} else {_newrevpos = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;};
					 [_medic,_newrevpos] call Lifeline_align_dir;
					if !([_newrevpos,_medic,20] call Lifeline_checkdegrees) then {
						_medic disableAI "ANIM";
						[_medic, "ANIM"] remoteExec ["disableAI", 0];
						[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];
						if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
						if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
						[_medic,_animMove] remoteExec ["playMoveNow",0];
					 };

					// [_medic,_animMove] remoteExec ["playMoveNow",0];					
				}; 

				if (_medic getVariable ["Lifeline_selfheal_progss",false] == true && _selfheal_trig == false) then {
					_selfheal_trig = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						waitUntil {
							(_medic getVariable ["Lifeline_selfheal_progss",false] == false)
						};
						// _medic playMoveNow _animMove;
						[_medic,_animMove] remoteExec ["playMoveNow",0];
						// _medic setdir (_medic getDir _newrevpos);	
						// _medic lookAt _incap;						
						[_medic, _incap] remoteExec ["lookAt", 0];						
					};
				};

				(_medic distance2D _revivePos <= 4 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || time - _unblockwtime > 8
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};	

			// GREEN MARKER FOR APPROACH GREETING
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = createVehicle ["Sign_Arrow_green_F", getPos _medic,[],0,"can_collide"];
				_medic setVariable ["_greenmark2", _greenmark, true]; 
			};

			// remove collision //moved
			if (alive _incap && alive _medic) then {
				[_medic, _incap] remoteExecCall ["disableCollisionWith", 0, _medic];
			};

			// randomized greeting as medic approaches incap
			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) 
				&& (_incap getvariable ["LifelinePairTimeOut",0] != 0) && _exit == false && _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 
				) then {
					_pairtimebaby = "LifelinePairTimeOut";
					_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
					_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true];
				if (Lifeline_MedicComments && !_opforpve) then {
					_A = str ([1, 3] call BIS_fnc_randomInt);
					_B = str ([1, 6] call BIS_fnc_randomInt);
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetA"+_A, 20, 1, true]] remoteExec ["say3D", 0]};
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetB"+_B, 20, 1, true]] remoteExec ["say3D", 0]};		
				};
			};

			//check its right direction 

			// _checkdegrees = [_revivepos,_medic,25] call Lifeline_checkdegrees;
			_checkdegrees = [_newrevpos,_medic,15] call Lifeline_checkdegrees;
			if (_checkdegrees == false) then {
				[_medic,_newrevpos] call Lifeline_align_dir;
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "adjust_direction"};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 ADJUST DIRECTION ", name _medic]};
			};

			_selfheal_trig = false;			
			_unblockwtime = time;
			_trig1 = false;
			_trig2 = false;
			_diag_texty2 = "";
			_two = 2;
			_waitcount = 5; // 5 seconds, 25 times 0.2

			// DISTANCE RADIUS <=2

			waitUntil {
				// _medic playMoveNow _animMove;
				// [_medic,_animMove] remoteExec ["playMoveNow",_medic];
				sleep 0.2;
				_medic doWatch _newrevpos;

				if (_medic distance2D _newrevpos > 6 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig2 == false) then { 
					_trig2 = true;

					if (!isnull _EnemyCloseBy) then {_newrevpos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
						} else {_newrevpos = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;};
					 [_medic,_newrevpos] call Lifeline_align_dir;
					 if !([_newrevpos,_medic,20] call Lifeline_checkdegrees) then {
						_medic disableAI "ANIM";
						[_medic, "ANIM"] remoteExec ["disableAI", 0];
						[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];
						if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
						if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
						[_medic,_animMove] remoteExec ["playMoveNow",0];
					 };

					// [_medic,_animMove] remoteExec ["playMoveNow",0];					
				}; 

				if (_trig1) then {
					_waitcount = _waitcount - 1;
					if (_waitcount < 0) then {
						_trig1 = false;
					};
				};

				if (speed _medic <= 0.3 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 2 /* && _medic distance2D _newrevpos < 4 */ && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					// [_incap,_medic,_newrevpos,_animMove] spawn {
						// params ["_incap","_medic","_newrevpos","_animMove"];
						// sleep 2;
						if (_waitcount < 0 && speed _medic <= 0.3 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 2 /* && _medic distance2D _newrevpos < 4 */ && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							// METHOD 1
							if (_medic distance2D _newrevpos >= 4) then {
								_medic disableAI "ANIM";
								[_medic, "ANIM"] remoteExec ["disableAI", 0];
								[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];
								if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
								if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
								[_medic,_animMove] remoteExec ["playMoveNow",0];
								// _trig1 = false;
							};
							// METHOD 2
							_two = (_medic distance2D _newrevpos) + 0.1; 
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["unblock_medic"] remoteExec ["playSound", 0]};
							_waitcount = 5;
							_trig1 = false;
						};
					// };
				};

				((_medic distance2D _newrevpos <= _two ) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true) 
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true				
				)
			};	

			if (Lifeline_travel_meth == 1) then {
				[_medic,_animMove] remoteExec ["playMoveNow",0];
			};

			//TEMP ADD BELOW (lookAt)
			// if (_medic distance2D _incap > 0.5) then { // don't force force direction if medic is already standing over the incap
				_medic disableAI "ANIM";
				[_medic, "ANIM"] remoteExec ["disableAI", 0];
				// _medic setDir (_medic getDir _incap);
				[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
				[_medic,_animMove] remoteExec ["playMoveNow",0];
			// };

			_unblockwtime = time;
			_trig1 = false; // this switch is so that the gate for stuck medics only triggers ever 3 seconds below
			_trig2 = false;
			_one = 1;
			_waitcount = 5; 

			// DISTANCE RADIUS <=1	

			waitUntil {
				sleep 0.2;
				// sleep 0.05;

				if (_trig1) then {
					_waitcount = _waitcount - 1;
					if (_waitcount < 0) then {
						_trig1 = false;
					};
				};

				if (speed _medic <= 0.3 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 /* && _medic distance2D _newrevpos < 4 */ && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					// [_incap,_medic,_newrevpos,_animMove] spawn {
						// params ["_incap","_medic","_newrevpos","_animMove"];
						// sleep 2;
						if (_waitcount < 0 && speed _medic <= 0.3 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 /* && _medic distance2D _newrevpos < 4 */ && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							if (!isnull _EnemyCloseBy) then {_newrevpos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
							} else {_newrevpos = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;};
							// METHOD 1
							if (_medic distance2D _newrevpos >= 2) then {
								_medic disableAI "ANIM";
								[_medic, "ANIM"] remoteExec ["disableAI", 0];
								[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];
								if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
								if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
								[_medic,_animMove] remoteExec ["playMoveNow",0];
								// _trig1 = false;
							};
							// METHOD 2
							_one = (_medic distance2D _newrevpos) + 0.1; 
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["unblock_medic"] remoteExec ["playSound", 0]};
							_waitcount = 5;
							_trig1 = false;
						};
					// };
				};

				 // if (time - _unblockwtime > 4 && _medic distance2D _newrevpos > 1 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
				 if (_medic distance2D _newrevpos > 3 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig2 == false) then { 
					_trig2 = true;
					if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
					if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIRECTION dist: %2", name _medic, _medic distance2d _newrevpos]};
					if (!isnull _EnemyCloseBy) then {_newrevpos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
						} else {_newrevpos = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;};
						[_medic,_newrevpos] call Lifeline_align_dir;
						if !([_newrevpos,_medic,20] call Lifeline_checkdegrees) then {
							_medic disableAI "ANIM";
							[_medic, "ANIM"] remoteExec ["disableAI", 0];
							[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							[_medic,_animMove] remoteExec ["playMoveNow",0];
						};
					// _medic setDir (_medic getDir _incap);
					// [_medic,_animMove] remoteExec ["playMoveNow",_medic];
					// [_medic,_animMove] remoteExec ["playMoveNow",0];					
				}; 
				((_medic distance2D _newrevpos <= _one) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true) 
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true				
				)

			}; // end waitUntil

			// if (alive _medic && !(lifestate _medic == "INCAPACITATED")) then {
			if (alive _medic && !(lifestate _medic == "INCAPACITATED") && (_exit == false && _medic getVariable ["Lifeline_ExitTravel", false] == false)) then {
				// _medic doWatch _incap;
				_medic playMoveNow _animStop;
				[_medic,_animStop] remoteExec ["playMoveNow",0];
			};

			_linenumber = "1056";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			//wait until fully stopped forward momentum and wait until finished self-healing
			waitUntil {
				(speed _medic == 0) || (_medic getVariable ["Lifeline_selfheal_progss",false] == false || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};			

	};		// end (alive _medic && (lifestate _incap == "incapacitated")

	//======= END IF  end (alive _medic && (lifestate _incap == "incapacitated")

	sleep 0.2;

	if (alive _incap && alive _medic && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && _exit == false && _medic getVariable ["Lifeline_ExitTravel", false] == false ) then {

		// if (Lifeline_travel_meth == 1) then {
			_medic disableAI "ANIM";
			[_medic, "ANIM"] remoteExec ["disableAI", 0];
		// };

		// convert all vanilla FAKs to ACE medical items for AI units (ACE only does players) 2025. FOR LATER when I add function to take items when bandaged.
		/* if (Lifeline_RevMethod == 3 && !isPlayer _x) then {  
			[_x] call ace_common_fnc_replaceRegisteredItems;
		}; */

		_medic setVariable ["ReviveInProgress",2,true];

		_incap setVariable ["Lifeline_canceltimer",true,true]; // if showing, cancel it.

		// smoke
		[_incap, _medic] spawn Lifeline_Smoke; 

		_medic dowatch objNull;

		if (lifestate _medic != "INCAPACITATED" && alive _medic) then {[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];};

		_exitanim = false;

		//call animations and medic hands-on revive
		if (Lifeline_RevMethod != 3) then {
			_exitanim = [_incap,_medic,_EnemyCloseBy,_voice,_B] call Lifeline_Medic_Anim_and_Revive; 
		};

		if (Lifeline_RevMethod == 3) then {
			[_incap,_medic,_EnemyCloseBy,_voice,_B] call Lifeline_ACE_Revive;
		};

		//explaination of variables. _voice is the voice actor. _B is the randomized second half of greeting. We pass this variable to avoid repeated samples.

		if (_exitanim == true) exitWith {
		};

		// ========= WAKE UP (IF)
		if (lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap) then {

			_incap setdamage 0;	
			[_incap, 0] remoteExec ["setDamage", 0];

			// if !(local _incap) then {
				[_incap, false] remoteExec ["setUnconscious",0,true]; //remoteexec version
			// } else {
			// 	_incap setUnconscious false; // non remote exec version
			// };			

			waitUntil {
				(lifestate _incap != "INCAPACITATED") //Cannot go past until awake. Needed for slower remoteExec delay		
			};
		};		

	}; // END IF alive medic and incap unit and lifestate incap == "incapacitated" 

	//=====================================================================================================
	//========= EITHER WAKE UP OR BYPASS ==================================================================
	//=====================================================================================================

	// Debug get total revive time and remove debug path marker
	if (Lifeline_Revive_debug) then {
		_incap call Lifeline_delYelMark;
		if (lifestate _incap != "incapacitated" && alive _incap && _exit == false) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ SUCCESS REVIVED // [0952] revive completed'", _incap, _medic,name _incap,name _medic];
		};
		if (lifestate _incap == "incapacitated" && lifestate _medic != "incapacitated" && alive _incap) then {
			// if (Lifeline_hintsilent) then {["Incap not revived"] remoteExec ["hintsilent",2]};
			diag_log format ["%1|%2|++++ DELETE YELLOW MARKER ++++ FAILED TRAVEL // [0958] Incap not revived | LifelinePairTimeOut %3 | '", name _incap,name _medic,((_medic getvariable "LifelinePairTimeOut") - time)];
		};
		if (lifestate _medic == "incapacitated" || !alive _medic ) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ FAILED TRAVEL // [0963] MEDIC DOWN'", _incap, _medic,name _incap,name _medic];
			if (Lifeline_hintsilent) then {[format ["MEDIC DOWN: %1", name _medic]] remoteExec ["hintsilent",2]};
		};
		if !(alive _incap) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ INCAP DEAD // [0969]'", _incap, _medic,name _incap,name _medic];
		};
		if (lifestate _incap != "INCAPACITATED" && alive _incap && (_exit == true)) then {
			if (Lifeline_hintsilent) then {[format ["Medic WOKE UP\n%1", name _medic]] remoteExec ["hintsilent", 2]};
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0975] INCAP WOKE UP!!!'", _incap, _medic,name _incap,name _medic];
		};
	};

	//back to original stance
	if (Lifeline_travel_meth == 1) then {
		// _medic setUnitPos _stance;
		_medic setUnitPos "AUTO";
	};
	_medic limitSpeed 100;
	_medic dofollow leader _medic;

	// Bleedout timer reset
	if (lifestate _incap != "INCAPACITATED") then {
		_incap doFollow leader _incap;
		_incap setVariable ["LifelineBleedOutTime", 0, true];
		_incap setVariable ["Lifeline_selfheal_progss",false,true];
	};

	// clear wayppoints for medic
	// for "_i" from 0 to (count waypoints _goup - 1) do {deleteWaypoint [_goup, 0]};

	if (lifestate _medic != "INCAPACITATED") then { //added this conditional. if the medic gets downed, then we dont want to reset these

		_captive = _medic getVariable ["Lifeline_Captive", false];
		// if !(local _medic) then {
				[_medic,true] remoteExec ["allowDamage",0];
				// [_medic,false] remoteExec ["setCaptive",_medic];
				[_medic,_captive] remoteExec ["setCaptive",0];
			/* } else {
				_medic allowDamage true;
				// _medic setCaptive false;
				_medic setCaptive _captive;
			}; */
		[_medic, objNull] remoteExec ["doWatch",0];
	};

	if (Lifeline_Revive_debug && Lifeline_hintsilent && alive _medic && !alive _incap) then {[format ["Incap dead: %1",name _incap]] remoteExec ["hintsilent", 2]};

	// Delete Incap marker
	if !(_incap getVariable ["Lifeline_IncapMark",""] == "") then {
		deleteMarker (_incap getVariable "Lifeline_IncapMark");
		_incap setVariable ["Lifeline_IncapMark","",true];
	};

	// turn on collision
	[_medic, _incap] remoteExecCall ["enableCollisionWith", 0, _medic];

	// Player control group
	if (isplayer _incap && alive _incap && lifestate _incap != "INCAPACITATED") then {
		[group _incap, _incap] remoteExec ["selectLeader", groupOwner group _incap];//checkthis
	}; 

	_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); 

	// if ( !(_medic getVariable ["Lifeline_reset_trig",false]) 
	if (_incap getVariable ["ReviveInProgress",0] == 3 || _AssignedMedic isEqualTo [] || _medic getVariable ["Lifeline_ExitTravel", false] == true ) then {
			// _medic setVariable ["Lifeline_reset_trig", true, true]; 
		 [[_incap,_medic],"1232 VERY END TRAVEL"] call Lifeline_reset2;	
	};	
	sleep 5; //delay enableing "ANIM" for 5 secs to stop unit spinning on the ground
	_medic enableAI "ANIM";
	[_medic, "ANIM"] remoteExec ["enableAI", 0];

}; // End AIReviveUnits Fnc

// for games with huge numbers of units, this function sorts the incapacitated units 
//by priority. Otherwise the queue will mean players will wait longer for revive.
Lifeline_sort_order_incapacitated = {
	params ["_filter"];

	// Filter out any dead units from Lifeline_incapacitated first. They sometimes sneak into the list.
	Lifeline_incapacitated = Lifeline_incapacitated select {alive _x && lifeState _x != "DEAD"};

	// 1) Players (highest priority)
	_Lifeline_incap_players = Lifeline_incapacitated select {isPlayer _x}; 

	// 2) AI units (subtract players from total)
	_Lifeline_incap_AI = Lifeline_incapacitated - _Lifeline_incap_players;

	if (_filter == 1) then { // players only
		Lifeline_incapacitated = _Lifeline_incap_players + _Lifeline_incap_AI;
	};

	if (_filter == 2) then { // players and player groups

		// 3) AI in player groups - simplified select approach
		_playerGroups = [];
		{_playerGroups pushBackUnique (group _x);} forEach allPlayers;
		_Lifeline_incap_PG = _Lifeline_incap_AI select {(group _x) in _playerGroups}; 

		// 4) AI not in player groups (remaining AI)
		_Lifeline_incap_nonPG = _Lifeline_incap_AI - _Lifeline_incap_PG;

		Lifeline_incapacitated = _Lifeline_incap_players + _Lifeline_incap_PG + _Lifeline_incap_nonPG;
	};

	if (_filter == 3) then { // all players, then player groups, then AI according to PVP status
		_playerGroups = [];
		{_playerGroups pushBackUnique (group _x);} forEach allPlayers;
		_Lifeline_incap_PG = _Lifeline_incap_AI select {(group _x) in _playerGroups}; 
		// 4) AI not in player groups (remaining AI)
		_Lifeline_incap_nonPG = _Lifeline_incap_AI - _Lifeline_incap_PG;

		if (!Lifeline_PVPstatus && Lifeline_Include_OPFOR) then {

			// 5) BLUFOR units from non-player group AI
			_Lifeline_incap_blufor = _Lifeline_incap_nonPG select {side group _x == Lifeline_Side};

			// 6) OPFOR units from non-player group AI
			_Lifeline_incap_opfor = _Lifeline_incap_nonPG select {side group _x in Lifeline_OPFOR_Sides};

			// Combine in priority order while preserving original order within groups
			Lifeline_incapacitated = _Lifeline_incap_players + _Lifeline_incap_PG + _Lifeline_incap_blufor + _Lifeline_incap_opfor;

		};
		if (Lifeline_PVPstatus || (!Lifeline_PVPstatus && !Lifeline_Include_OPFOR)) then {
			Lifeline_incapacitated = _Lifeline_incap_players + _Lifeline_incap_PG + _Lifeline_incap_nonPG;
		};	
	};

	if  (_filter == 4) then { // simpler: all players, then according to PVP status, split AI into BLUFOR and OPFOR
		if (!Lifeline_PVPstatus && Lifeline_Include_OPFOR) then {
			// 5) BLUFOR units from non-player group AI
			_Lifeline_incap_blufor = _Lifeline_incap_AI select {side group _x == Lifeline_Side};

			// 6) OPFOR units from non-player group AI
			_Lifeline_incap_opfor = _Lifeline_incap_AI select {side group _x in Lifeline_OPFOR_Sides};

			Lifeline_incapacitated = _Lifeline_incap_players + _Lifeline_incap_blufor + _Lifeline_incap_opfor;
		};
		if (Lifeline_PVPstatus || (!Lifeline_PVPstatus && !Lifeline_Include_OPFOR)) then {
			Lifeline_incapacitated = _Lifeline_incap_players + _Lifeline_incap_AI;
		};
	};	
	if  (_filter == 5) then { // stagger list, one from each group
		if (!Lifeline_PVPstatus && Lifeline_Include_OPFOR) then {

			_Lifeline_incap_AI = _Lifeline_incap_players + _Lifeline_incap_AI;

			// Extract all groups from Lifeline_incapacitated into an array
			Lifeline_incap_groups = [];
			{
				_unitGroup = group _x;
				if (!isNull _unitGroup) then {
					Lifeline_incap_groups pushBackUnique _unitGroup;
				};
			} forEach (_Lifeline_incap_AI);
			// Make the array available to all clients
			publicVariable "Lifeline_incap_groups";

			if (Lifeline_Revive_debug) then {
				_diag_array = ""; 
				{_diag_array = _diag_array + str _x + ", "} forEach Lifeline_incap_groups; 
			};

			// Create a staggered array with players first
			// _staggered_incaps = +_Lifeline_incap_players;
			// _staggered_incaps = +_Lifeline_incap_AI;
			_staggered_incaps = [];
			// Keep going until we've processed all units
			_remaining_units = +_Lifeline_incap_AI;

			while {count _remaining_units > 0} do {
				// Go through each group and take one unit
				{
					_current_group = _x;
					// Find first unit in this group from remaining units
					_group_units_index = _remaining_units findIf {group _x == _current_group};
					// If we found a unit from this group
					if (_group_units_index != -1) then {
						// Add it to staggered array
						_unit = _remaining_units select _group_units_index;
						_staggered_incaps pushBack _unit;
						// Remove from remaining units
						_remaining_units deleteAt _group_units_index;
					};
				} forEach Lifeline_incap_groups;
			};

			// Update the main array with staggered results
			Lifeline_incapacitated = _staggered_incaps;
			if (Lifeline_Revive_debug) then {
				_diag_array = ""; 
				{_diag_array = _diag_array + name _x + ", "} forEach Lifeline_incapacitated; 
			};
		};
		if (Lifeline_PVPstatus || (!Lifeline_PVPstatus && !Lifeline_Include_OPFOR)) then {
			Lifeline_incapacitated = _Lifeline_incap_players + _Lifeline_incap_AI;
		};
	};
	if (_filter == 6) then { // sort with groups in alphabetical order, units remain in original order
		// Combine players and AI
		// _Lifeline_incap_all = _Lifeline_incap_players + _Lifeline_incap_AI;
		// Extract all groups
		_all_groups = [];
		{
			_unitGroup = group _x;
			if (!isNull _unitGroup) then {
				_all_groups pushBackUnique _unitGroup;
			};
		} forEach _Lifeline_incap_AI;
		// Sort the groups alphabetically by group ID
		_all_groups = [_all_groups, [], {groupID _x}, "ASCEND"] call BIS_fnc_sortBy;
		// Create sorted array
		_sorted_by_group = [];
		{
			_current_group = _x;
			// Get all units in this group while maintaining their original order
			_units_in_group = _Lifeline_incap_AI select {group _x == _current_group};
			// Add all units from this group to the result array (without sorting)
			_sorted_by_group append _units_in_group;
		} forEach _all_groups;
		// Update the main array with sorted results
		Lifeline_incapacitated = _Lifeline_incap_players + _sorted_by_group;
	};
	publicVariable "Lifeline_incapacitated";

};

// these medic filters now turned into a function. Returns true if medic is available. 
Lifeline_check_available_medic = {
	params ["_unit","_incap"];
		if (side (group _unit) != side (group _incap)) exitWith {false};
		// (side (group _unit) == side (group _incap)) // TEST FOR OPFOR
	 	!(side group _unit == civilian) 
		&& alive _unit
		&& !isPlayer _unit 
		&& !([_unit, _incap] call Lifeline_Blacklist_Check)
		&& !(_unit in Lifeline_Process) 
		&& ((_unit distance _incap) < Lifeline_LimitDist) 
		&& !(currentWeapon _unit == secondaryWeapon _unit && currentWeapon _unit != "") //make sure unit is not about to fire launcher. This comes first.
		&& !(((assignedTarget _unit) isKindOf "Tank") && secondaryWeapon _unit != "") //check unit did not get order to hunt tank
		&& !(((getAttackTarget _unit) isKindOf "Tank") && secondaryWeapon _unit != "") //check unit is not hunting a tank
		&& (_unit getVariable ["ReviveInProgress",0]) == 0 
		&& _unit getVariable ["Lifeline_AssignedMedic",[]] isEqualTo []
		&& (_unit getVariable ["LifelinePairTimeOut", 0]) == 0
		&& (lifestate _unit != "INCAPACITATED")
		&& _unit getVariable ["Lifeline_ExitTravel", false] == false
		&& _unit getVariable ["Lifeline_back2vehicle", false] == false //check unit is not heading back to vehicle
		&& (if (Lifeline_ASmission) then {if (_unit == Petros) then {false} else {true}} else {true}) //exclude Antistasi AI commander if exists
};

Lifeline_count_group_medics = {
    params ["_group"];
    private _count = 0;
    {
        if (_x getVariable ["ReviveInProgress", 0] in [1,2]) then {
            _count = _count + 1;
        };
    } forEach units _group;
    _count
};

Lifeline_count_group_medics2 = {
    params ["_group"];
    private _count = 0;
    {
        if (_x getVariable ["ReviveInProgress", 0] in [1,2] && !(_x getUnitTrait "medic")) then {
            _count = _count + 1;
        };
    } forEach units _group;
    _count
};

Lifeline_check_dedimedic = {
    params ["_group"];
    _dedi_in_action = false;
    _dedi_medic_available = false;
    {
        if (_x getVariable ["ReviveInProgress", 0] in [1,2] && (_x getUnitTrait "medic")) then {
            _dedi_in_action = true;
        };
		if (_x getUnitTrait "medic" && lifestate _x != "INCAPACITATED") then {
            _dedi_medic_available = true;
        };
    } forEach units _group;
    [_dedi_in_action,_dedi_medic_available]
};

Lifeline_count_group_healthy = {
    params ["_group"];
    private _count = 0;
    {
        if (lifestate _x != "INCAPACITATED" && alive _x) then {
            _count = _count + 1;
        };
    } forEach units _group;
    _count
};

Lifeline_check_medics_MASCAL = {
	params ["_unit","_incap"];
		!(side group _unit == civilian) 
		&& !([_unit,_incap] call Lifeline_Blacklist_Check)
		&& ((_unit distance _incap) < Lifeline_LimitDist) 
		&& (lifestate _unit != "INCAPACITATED")
		&& (side (group _unit) == side (group _incap)) // TEST FOR OPFOR
};

Lifeline_Map = {
	params ["_unit"];
	// Add marker
	if (lifestate _unit == "INCAPACITATED" && isTouchingGround _unit && vehicle _unit == _unit) then {
		if ((_unit getVariable ["Lifeline_IncapMark",""]) == "") then {
			_markerName = "Marker" + (name _unit);
			_marker = createMarker [_markerName, position _unit];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "loc_heal";
			_marker setmarkerText (name _unit);
			_marker setMarkerColor "ColorRed";
			// _marker setMarkerSize [0.5,0.5];
			// _marker setMarkerSize [0.8,0.8];
			_marker setMarkerSize [1,1];
			_unit setVariable ["Lifeline_IncapMark",_markerName,true];
		};
	};

	// Remove marker
	if (alive _unit && lifestate _unit != "INCAPACITATED") then {
		if !(_unit getVariable ["Lifeline_IncapMark",""] == "") then {
			deleteMarker (_unit getVariable "Lifeline_IncapMark");
			_unit setVariable ["Lifeline_IncapMark","",true];
		};
	};

	// Add dead marker
	if (lifeState _unit == "DEAD" || lifeState _unit == "DEAD-RESPAWN" || lifeState _unit == "DEAD-SWITCHING") then {
		if ((_unit getVariable ["Lifeline_IncapMark",""]) != "Dead") then {
			_markerName = "Dead";
			_marker = createMarker [_markerName, position _unit];
			_marker setMarkerShape "ICON";
			_marker setMarkerType "KIA";
			_marker setmarkerText (name _unit);
			_marker setMarkerColor "ColorBlack";
			// _marker setMarkerSize [0.5,0.5];
			// _marker setMarkerSize [0.8,0.8];
			_marker setMarkerSize [0.7,0.7];
			_unit setVariable ["Lifeline_IncapMark",_markerName,true];
		};
	};
};

Lifeline_checkdegrees = {
	params ["_incap", "_medic","_range"];

	_direction1 = _medic getDir _incap;
	_direction2 = getDir _medic;

	// Calculate the absolute difference
	_difference = abs(_direction1 - _direction2);

	// Adjust for circular nature
	if (_difference > 180) then {
		_difference = 360 - _difference;
	};

	// Check if the difference is within the range
	_isWithinRange = _difference <= _range;
	_isWithinRange
	};

Lifeline_align_dir = {
params ["_unit","_revivepos"];
	//check its right direction 
	_checkdegrees = [_revivepos,_medic,15] call Lifeline_checkdegrees;	if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false) then {
		if (Lifeline_Revive_debug) then {
			if (Lifeline_debug_soundalert) then {playsound "adjust_direction"};
			if (Lifeline_hintsilent) then {hint format ["%1 DIRECTION MEDIC", name _medic]};
		};
		// _direction = _medic getDir _revivepos;
		// _medic setDir _direction;
		_medic enableAI "ANIM";
		_medic lookAt _revivepos;
		_timechk = time;
		waitUntil {
			_checkdegrees = [_revivepos,_medic,5] call Lifeline_checkdegrees;
			(_checkdegrees == true || (time - _timechk) > 5)				
		};
	};
};

Lifeline_Blacklist_Check = {
	params ["_unit","_incap"];

	// if (side (group _unit) != side (group _incap)) exitWith {true;};

			//Blacklist mounted weapons, armour, air, drivers
			_blacklist = false;	
			_Lifeline_Blacklist_Mounted_Weapons = Lifeline_Blacklist_Mounted_Weapons;
			_Lifeline_Blacklist_Drivers = Lifeline_Blacklist_Drivers;
			_Lifeline_Blacklist_Armour = Lifeline_Blacklist_Armour;
			_Lifeline_Blacklist_Air = Lifeline_Blacklist_Air;
			_Lifeline_Blacklist_Car = Lifeline_Blacklist_Car;

			if (group _incap in Lifeline_Group_Mascal) then {
				_Lifeline_Blacklist_Mounted_Weapons = false;
				_Lifeline_Blacklist_Drivers = false;
				_Lifeline_Blacklist_Armour = false;
				// _Lifeline_Blacklist_Air = false;
				_Lifeline_Blacklist_Car = false;
			};

			if (!Lifeline_Blacklist_Mounted_Weapons && !Lifeline_Blacklist_Drivers && !Lifeline_Blacklist_Armour && !Lifeline_Blacklist_Air && !Lifeline_Blacklist_Car) exitWith {
				false;
			};

			_vehrole = assignedVehicleRole _unit select 0;
			_veh = vehicle _unit;
			_isInVehicle = _veh != _unit;

			if (!isNil "_vehrole" && _isInVehicle) then {	
				if (_Lifeline_Blacklist_Mounted_Weapons && _vehrole == "turret") then {
					_blacklist = true;
				};
				if (_Lifeline_Blacklist_Drivers && _vehrole == "driver") then {
					_blacklist = true;
				};

				if (_Lifeline_Blacklist_Armour && (_veh isKindOf "Tank" || _veh isKindOf "Tracked_APC_F" || _veh isKindOf "Wheeled_APC_F")) then {
					_blacklist = true;
				};
				if (_Lifeline_Blacklist_Air && _veh isKindOf "Air") then {
					_blacklist = true;
				};				
				if (_Lifeline_Blacklist_Car && _veh isKindOf "Car" && !(_veh isKindOf "Wheeled_APC_F")) then {
					_blacklist = true;
				};

			};
_blacklist
};

//just testing
reset_idle_medics = {
    params ["_unit"];
	// _unit setSkill ["courage", 1];
    // Reset behaviour
    _unit setBehaviour "AWARE";
    _unit setCombatMode "YELLOW";
    _unit setSpeedMode "NORMAL";
    // Full reset of AI capabilities
    _unit disableAI "ALL";
	// sleep 0.1;
    _unit enableAI "ALL";
	// sleep 0.1;
    // Force the unit to stand and clear any ongoing tasks
    // _unit doWatch objNull;
    // doStop _unit;
    // _unit doFollow (leader (group _unit));
    // Reset unit stance
    _unit setUnitPos "AUTO";
    // Clear any target the unit might be focused on
    _unit forgetTarget (leader (group _unit));

    // Reset pathfinding
    _unit allowFleeing 0;
    _unit enableAttack true;
    // Clear animation if stuck in one
    // if (animationState _unit in ["amovppnemstpsraswrfldnon","amovpercmstpsraswrfldnon"]) then {
        // _unit switchMove "";
        _unit playMoveNow "";
    // };
    // Reset unit's knowledge - helps with unit awareness
    { 
        _unit forgetTarget _x;
        _unit reveal [_x, 0]; // Reset knowsAbout to 0
    } forEach (_unit targets [true, 0]);
    // Full reset of AI capabilities
    _unit disableAI "ALL";
    // sleep 0.1;
    _unit enableAI "ALL";
    // sleep 0.1;
    // Force the unit to stand and clear any ongoing tasks
    _unit doWatch objNull;
    doStop _unit;
    _unit doFollow (leader (group _unit));
    // Reset courage
    _unit setSkill ["courage", 1];
    if (Lifeline_Revive_debug) then {
        [_unit,"IDLE MEDIC reset_idle_medics [_Global.sqf]"] call serverSide_unitstate;
    };
};

//========================== OLD VERSION FOR TESTINGMAIN REVIVE FUNCTION STARTING MEDIC TRAVEL

Lifeline_StartReviveOLD = {
	params ["_medic", "_incap"];

	_dmg_trig = dmg_trig;
	_cptv_trig = false;
	_opforpve = false;

	if (Lifeline_RevProtect in [1,2]) then {
		_cptv_trig = cptv_trig;
	};

	// if its only PVE and not PVP, and OPFOR is included, then turn off indestructible for OPFOR while reviving.
	if (Lifeline_Include_OPFOR && Lifeline_PVPstatus == false && (side group _medic) in Lifeline_OPFOR_Sides) then {
		_dmg_trig = true;
		_cptv_trig = true;
		_opforpve = true;
	};

	[_medic,["COURAGE", 1]] remoteExec ["setSkill",0];
	[_medic,"AUTOTARGET"] remoteExec ["disableAI",0];
	[_medic,"AUTOCOMBAT"] remoteExec ["disableAI",0];
	[_medic,"SUPPRESSION"] remoteExec ["disableAI",0];
	[_medic,"TARGET"] remoteExec ["disableAI",0];
	[_medic,0.2] remoteExec ["allowFleeing",0];
	[_medic,"TARGET"] remoteExec ["disableAI",0];

	_linenumber = "0744";
	_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;

	// _voice = _medic getVariable "Lifeline_Voice";
	_voice = _medic getVariable ["Lifeline_Voice", selectRandom Lifeline_UnitVoices]; 
	_B = "";
	_EnemyCloseBy = objNull;	
	_yelmark = objNull;	
	_goup = group _medic;	// check group 4 medic
	_revivePos = [];
	_distnextto = 0;
	_dir = 0;
	_revtime = time;
	_shortorigdist = false;
	_shortorigdist6 = false;
	_stance = UnitPos _medic;

	if !(_exit) then {
		_linenumber = "0757";
		_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;
	};	
	if (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {

		//if original distance is short, the medic overshoots the incap (goes too far). This var for adjusting anim.
		if ((_medic distance2D _incap) <= 10) then {
			_shortorigdist = true;
			// _medic limitSpeed 2;
			// sleep 4;			
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "shortdistance"};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 SHORT DISTANCE ", name _medic]};
		};

		//TEMP NEW
		if ((_medic distance2D _incap) <= 6)  then {
			_shortorigdist6 = true;
			if (stance _medic == "STAND") then {
				_medic setUnitPos "MIDDLE";
			};
		};

		// unassign vehicle if lost group status
		if (!isplayer (leader group _medic) && isPlayer _incap) then {
			{if (!isplayer _x) then {_x leaveVehicle (assignedVehicle _x)}} foreach (units leader _incap);
		};

		//check if bleeding. both for ACE and non-ACE
		_isbleeding = false;
		if (Lifeline_RevMethod == 3) then {
			_isbleeding = [_medic] call ace_medical_blood_fnc_isBleeding;
		} else {
			if (damage _medic >=0.2 || _medic getHitPointDamage "hitlegs" >= 0.5) then { 
			_isbleeding = true;
			};
		};
		if (!isPlayer _medic && !(lifestate _medic == "INCAPACITATED") && alive _medic && _isbleeding == true 
			&& _medic getVariable ["Lifeline_selfheal_progss",false] == false && Lifeline_SelfHeal_Cond > 0 //update 2025-05-11	
		) then {
			_medic call Lifeline_SelfHeal;
		};

		// ========== Start travel ===========

		// update this later. bad method for making sure animation works when not having primary weapon. 
		if (alive _medic && primaryWeapon _medic == "") then {_medic addWeapon "arifle_MX_F"};
		if (alive _medic && currentWeapon _medic != (primaryWeapon _medic)) then {_medic selectWeapon (primaryWeapon _medic)};

		// _EnemyCloseBy = [_medic] call Lifeline_EnemyCloseBy;
		_EnemyCloseBy = [_incap] call Lifeline_EnemyCloseBy; // we should use incap because that is where the revive happens
		_cpr = false;
		if (Lifeline_RevMethod == 3) then {
				_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
		};

		// calc position depending on enemy proximity
		// if (!isnull _EnemyCloseBy) then {
		if (!isnull _EnemyCloseBy && _cpr == false) then {
			_distnextto = 1.5;
		} else {
			_distnextto = 0.8;
		};

		_revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
		// _revivePos set [2,0]; // Set height. Maybe turn this off
		//TEMP // maybe this whole block should move as a waitUntil {_medic distance2D _revivePos < 10} further down this function
		[_incap,_medic,_revivePos,_EnemyCloseBy] spawn {
			params ["_incap","_medic","_revivePos","_EnemyCloseBy"];

			// sleep 4;
			_revivePosCheck = "";
			_cpr = false;
			_medicpos = getPos _medic;
			_medicpos2 = [];
			_directioncount = 3; //re-align direction only 3 times, to prevent a loop of constant direction glitch
			_checkdegrees = 0;
			_teleptrig = false; //this is to make sure teleport is only triggered once. Teleport is a micro teleport of under 5 metres to make sure medic is in right spot.
			_telepcheck = nil; // this var is to check medic position against revive position for potential teleport

			while {alive _medic && alive _incap && _medic getVariable ["ReviveInProgress",0] in [1,2] && lifestate _incap == "INCAPACITATED"} do {
				if (_medic distance2D _revivePos < 10) then { 

					if (Lifeline_RevMethod == 3) then {
						_cpr = [_medic, _incap] call ace_medical_treatment_fnc_canCPR;
					};
					if (!isnull _EnemyCloseBy && _cpr == false) then {
							// _revivePosCheck = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
							_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap;
					} else {
						// _revivePosCheck  = _incap;				
							// _revivePosCheck  = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;			
							_revivePosCheck  = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;			
					};

					if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {

						//============== MARKERS ======
						_incap call Lifeline_delYelMark;
						_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
						_incap setVariable ["ymarker1", _yelmark, true]; 							
						//================================
					};

					_telepcheck = _revivePos;

					// if (_revivePos isNotEqualTo _revivePosCheck) then {
					if (_revivePos distance2D _revivePosCheck > 0.2 && _medic distance2D _incap > 4) then {
					// if (_revivePos distance2D _revivePosCheck > 0.5) then {	

						_revivePos = _revivePosCheck; // commenting out this line, gets diff results. Test/											
						_incap setVariable ["Lifeline_RevPosX",_revivePos,true];

						if (_medic getVariable ["ReviveInProgress",0] == 1) then {
							//_teamcolour = assignedTeam _medic;[_medic] joinSilent _medic;_medic assignTeam _teamcolour; // joinSilent deletes Teamcolour, so workaround here.
							_medic domove position _medic;
							_medic moveto position _medic;
							_medic domove _revivePos;
							_medic moveto _revivePos;
							if (Lifeline_Revive_debug) then {
								if (Lifeline_debug_soundalert) then {playsound "beep_hi_1"};
								if (Lifeline_hintsilent) then {hint format ["%1 DOMOVE MEDIC", name _medic]};
							};
						};

						if (Lifeline_yellowmarker && Lifeline_Revive_debug) then {
							_incap call Lifeline_delYelMark;
							_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
							_incap setVariable ["ymarker1", _yelmark, true]; 	
						};
					};
					// make sure medic is facing right direction. Only for ACE at the moment
					if (Lifeline_RevMethod == 3) then {
						// if (_directioncount > 0) then {_checkdegrees = [_incap,_medic,30] call Lifeline_checkdegrees;};
						_checkdegrees = [_incap,_medic,20] call Lifeline_checkdegrees;
						if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false && _directioncount > 0) then {
							// if (_medic getVariable ["ReviveInProgress",0] == 2 && _checkdegrees == false) then {
							if (Lifeline_Revive_debug) then {
								if (Lifeline_debug_soundalert) then {["forcedirection"] remoteExec ["playSound", 0]};
								if (Lifeline_hintsilent) then {hint format ["%1 FORCE DIRECTION", name _medic]};
							};
							_direction = _medic getDir _incap;
							// _medic setDir _direction;
							[_medic, _direction] remoteExec ["setDir", 0];
							// _directioncount = _directioncount - 1;
						};
					};
				}; //if (_medic distance2D _revivePos < 10) then { 

				sleep 2;
				_medicpos2 = getPos _medic;

			}; // end WHILE

			_incap setVariable ["Lifeline_RevPosX",nil,true];
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = _medic getVariable ["_greenmark1", nil]; 
				if (!isNil "_greenmark") then {deleteVehicle _greenmark};				
				_greenmark = _medic getVariable ["_greenmark2", nil]; 
				if (!isNil "_greenmark") then {deleteVehicle _greenmark};
			};
		};

		// [center, minDist, maxDist, objDist, waterMode, maxGrad, shoreMode, blacklistPos, defaultPos] call BIS_fnc_findSafePos

	}; // END IF (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {

	if !(_exit) then {
		_linenumber = "0817";
		_exit = [_incap,_medic,"EXIT REVIVE TRAVEL [root]",_linenumber] call Lifeline_exit_travel;
	};

	if (Lifeline_Revive_debug) then {
		if (_medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
				diag_log format ["|%1|%2|++++ YELLOW MARKER ++++ [0632] '", name _incap,name _medic];
				if (Lifeline_yellowmarker) then {
					_yelmark = createVehicle ["Sign_Arrow_Yellow_F", _revivePos,[],0,"can_collide"];
					_incap setVariable ["ymarker1", _yelmark, true]; 	
				};
		} else {
				diag_log format ["|%1|%2|++++ BYPASS YELLOW MARKER ++++ [0640] '", name _incap,name _medic];
		};
	};

	_waypoint = [];

	if (alive _medic && alive _incap && (lifestate _incap == "INCAPACITATED") && (lifestate _medic != "INCAPACITATED") && _medic getVariable ["Lifeline_ExitTravel", false] == false && _exit == false) then {
			_revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			_teamcolour = assignedTeam _medic;// joinSilent deletes Teamcolour, so workaround here.

			// good for getting confused in buildings - confirm later
			// [_medic] joinSilent _medic; // // THIS AFFECTS SPEED. FUCKS UP UNITS THAT LEAVE TURRENTS AND ALREADY PART OF GROUP WITH MULTPLE
			_medic assignTeam _teamcolour;// joinSilent deletes Teamcolour, so workaround here.
			if (_shortorigdist6) then {
				_medic limitSpeed 2;
				// group _medic setSpeedMode "LIMITED";
				// playsound "testC";
			};

			//remoteExec version. Even though documentation says doMove and MoveTo is global, was getting errors, so remoteExec seemed to fix it. 
			[_medic, position _medic] remoteExec ["moveTo", 0];
			[_medic, position _medic] remoteExec ["doMove", 0];
			[_medic, _revivePos] remoteExec ["moveTo", 0];
			[_medic, _revivePos] remoteExec ["doMove", 0];

			_linenumber = "0868";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};
			waitUntil {
				sleep 0.1;
				(_medic distance2D _revivePos <=100 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0882";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			if (_medic distance2D _revivePos > 97 && Lifeline_radio && lifeState _medic != "INCAPACITATED" && lifeState _incap == "INCAPACITATED" && _exit == false 
			&& _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 && _incap getvariable ["LifelinePairTimeOut",0] !=0 
			) then {
					if (isPlayer _incap) then {
					[_incap, [_voice+"_100m1", 50, 1, true]] remoteExec ["say3D", _incap];
					};
			};	

			_linenumber = "0896";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			waitUntil {
				sleep 0.1;
				(_medic distance2D _revivePos <=50 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0909";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			if (_medic distance2D _revivePos > 47 && Lifeline_radio && lifeState _medic != "INCAPACITATED" && lifeState _incap == "INCAPACITATED" && _exit == false 
				&& _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 && _incap getvariable ["LifelinePairTimeOut",0] !=0 
			) then {
					if (isPlayer _incap) then {
						[_incap, [_voice+"_50m1", 50, 1, true]] remoteExec ["say3D", _incap];
					};
			};		

			_linenumber = "0923";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;

			// DISTANCE RADIUS <=10 || 	// DISTANCE RADIUS <=15
			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			waitUntil {
				sleep 0.1;
				((_medic distance2D _revivePos <=10 && speed _medic < 14) || (_medic distance2D _revivePos <=15 && speed _medic >= 14) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// ((_medic distance2D _revivePos <=10 && speed _medic < 17) || (_medic distance2D _revivePos <=15 && speed _medic > 17) || (_shortorigdist == true) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};

			_linenumber = "0953";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;

			// DISTANCE RADIUS <=8 || 	// DISTANCE RADIUS <=15

			waitUntil {
				sleep 0.1;
				(((_medic distance2D _incap <=8 && speed _medic < 14) || (_medic distance2D _incap <=15 && speed _medic >= 14)) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true  || _shortorigdist == true
				// (((_medic distance2D _incap <=6 && speed _medic < 17) || (_medic distance2D _incap <=15 && speed _medic > 17)) || (_shortorigdist == true) || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true		
				)
			};

			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
				_pairtimebaby = "LifelinePairTimeOut";
				_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
				_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true];
				if (lifestate _medic != "INCAPACITATED" && !(_medic getVariable ["Lifeline_Captive_Delay",false])) then {
					_medic setVariable ["Lifeline_Captive",(captive _medic),true]; //2025
				};

				// if (Lifeline_RevProtect != 3) then {
					// if !(local _medic) then {

					[_medic,_dmg_trig] remoteExec ["allowDamage",0];
				if (Lifeline_RevProtect in [1,2]) then {	
					[_medic,_cptv_trig] remoteExec ["setCaptive",0];
				};

				// };							
			};

			_linenumber = "0978";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			_unblockwtime = time;

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;	
			// some medics were getting stuck waiting for this. Added a timer to unblock.
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;

			// DISTANCE RADIUS <=6 || 	// DISTANCE RADIUS <=8

			waitUntil {
				_medic domove _revivePos;
				sleep 0.7;
				// ((_medic distance2D _revivePos <=2.5 && speed _medic < 14) || (_medic distance2D _revivePos <= 8 && speed _medic >= 14) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				((_medic distance2D _revivePos <=6 && speed _medic < 14) || (_medic distance2D _revivePos <= 8 && speed _medic >= 14) || !alive _medic || !alive _incap || (time - _unblockwtime > 8) || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || _shortorigdist == true
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				) 
			};			

			// group _medic setspeedMode "FULL";

			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) && (_incap getvariable ["LifelinePairTimeOut",0] != 0)) then {
				_pairtimebaby = "LifelinePairTimeOut";
				_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
				_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
			};

			// _revivePos = [_incap, _medic, _distnextto] call Lifeline_POSnexttoincap;
			_revivePosX = _incap getVariable ["Lifeline_RevPosX",_revivePos];
			_revivePos = _revivePosX;			

			_animMove = "";
			_animStop = "";
			_dist = _medic distance _revivePos;
			_timer = time;
			_newrevpos = nil; //distance of yellow marker from incap
			_posture = nil;

			if (!isnull _EnemyCloseBy) then {
				// commando crawl
				// _revivePos = [_incap, _medic, 1.9] call Lifeline_POSnexttoincap;
				_animMove = "amovppnemsprslowwrfldf"; // move
				_animStop = "amovppnemstpsraswrfldnon"; // stop
				_newrevpos = [_incap, _medic, 0.5] call Lifeline_POSnexttoincap;
				_posture = "DOWN";
			} else {
				// crouch
				// _revivePos = [_incap, _medic, 0.9] call Lifeline_POSnexttoincap;
				_animMove = "amovpknlmwlkslowwrfldf"; //"amovpknlmwlkslowwrfldf"; "amovpknlmrunslowwrfldf" "amovpercmrunsraswrfldf"
				_animStop = "amovpknlmstpslowwrfldnon";
				// _newrevpos = _incap;
				_newrevpos = [_incap, _medic, 0.1] call Lifeline_POSnexttoincap;				
				_posture = "MIDDLE";
			};

			// GREEN MARKER BEFORE ANIM CHANGE
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = createVehicle ["Sign_Arrow_green_F", getPos _medic,[],0,"can_collide"];
				_medic setVariable ["_greenmark1", _greenmark, true]; 
			};

			//this is vital and must be kept, otherwise anim stands up
			if (alive _medic && !(lifestate _medic == "INCAPACITATED")) then {
			// check the do watch turn here, they walk wrong direction sometimes. Might be remoteExec issue. (temp changed to nonRemoteExec)
				_medic lookAt _newrevpos;
				// [_medic, _newrevpos] remoteExec ["lookAt", 0];
				// _medic doWatch _newrevpos;
				_timechc = time;
				_checkdegrees = [_newrevpos,_medic,15] call Lifeline_checkdegrees;
				if (_checkdegrees == false) then {				
					waitUntil {						
						_medic lookAt _newrevpos;
						// [_medic, _newrevpos] remoteExec ["lookAt", 0];
						_checkdegrees = [_newrevpos,_medic,30] call Lifeline_checkdegrees;
						if (time - _timechc > 5) then {
							_medic lookAt _newrevpos;
							// [_medic, _newrevpos] remoteExec ["lookAt", 0];
							_medic disableAI "ANIM";
							// [_medic, "ANIM"] remoteExec ["disableAI", 0]; 
							_medic setDir (_medic getDir _newrevpos);
							// [_medic, (_medic getDir _newrevpos)] remoteExec ["setDir", 0];
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["forcedirection"] remoteExec ["playSound", 0]};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
						};
						(_checkdegrees == true)				
						// (_checkdegrees == true || time - _timechc > 5)				
					};

					// [_medic, _newrevpos] call Lifeline_align_dir;

				};
				if (Lifeline_travel_meth == 0) then {
					_medic disableAI "ANIM"; //TEMP
					[_medic, "ANIM"] remoteExec ["disableAI", 0];
					_medic playMoveNow _animMove;					[_medic,_animMove] remoteExec ["playMoveNow",0];
				};
				if (Lifeline_travel_meth == 1) then {
					// _medic setUnitPos _posture; //posture
					[_medic, _posture] remoteExec ["setUnitPos", 0];
				};				
			};

			_rposDist = _revivePos distance2D _incap;

			_linenumber = "1031";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};			
			_unblockwtime = time;
			_selfheal_trig = false; //one time trigger to stop repeated spamming of the check to see if self-revive is active, in the "waitUntil" below
			_trig1 = false;
			_diag_texty2 = ""; //only for diag_log

			//check its right direction 
			// [_medic,_newrevpos] call Lifeline_align_dir;

			// DISTANCE RADIUS <=4

			waitUntil {
				// sleep 0.1;
				sleep 0.2;
				if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						sleep 2;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 4 && _medic distance2D _newrevpos < 10 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							// _medic setPos _newrevpos;
							_medic disableAI "ANIM";
							_medic setDir (_medic getDir _incap);
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							[_medic,_animMove] remoteExec ["playMoveNow",_medic];
							_trig1 = false;
						};
					};
				};

				if (_medic getVariable ["Lifeline_selfheal_progss",false] == true && _selfheal_trig == false) then {
					_selfheal_trig = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						waitUntil {
							(_medic getVariable ["Lifeline_selfheal_progss",false] == false)
						};
						// _medic playMoveNow _animMove;
						[_medic,_animMove] remoteExec ["playMoveNow",0];
						// _medic setdir (_medic getDir _newrevpos);	
						// _medic lookAt _incap;						
						[_medic, _incap] remoteExec ["lookAt", 0];						
					};
				};

				(_medic distance2D _revivePos <= 4 || !alive _medic || !alive _incap || (_incap getvariable ["LifelinePairTimeOut",0] == 0) || lifestate _incap != "INCAPACITATED" || _exit == true || time - _unblockwtime > 8
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| lifestate _medic == "INCAPACITATED"
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};	

			// GREEN MARKER FOR APPROACH GREETING
			if (Lifeline_Revive_debug && Lifeline_yellowmarker) then {
				_greenmark = createVehicle ["Sign_Arrow_green_F", getPos _medic,[],0,"can_collide"];
				_medic setVariable ["_greenmark2", _greenmark, true]; 
			};

			// remove collision //moved
			if (alive _incap && alive _medic) then {
				[_medic, _incap] remoteExecCall ["disableCollisionWith", 0, _medic];
			};

			// randomized greeting as medic approaches incap
			if (lifestate _medic != "INCAPACITATED" && (alive _medic) && lifestate _incap == "INCAPACITATED" && (alive _incap) 
				&& (_incap getvariable ["LifelinePairTimeOut",0] != 0) && _exit == false && _medic getvariable ["ReviveInProgress",0] == 1 && _incap getvariable ["ReviveInProgress",0] == 3 
				) then {
					_pairtimebaby = "LifelinePairTimeOut";
					_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 5, true]; 
					_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 5, true]; 
				if (Lifeline_MedicComments && !_opforpve) then {
					_A = str ([1, 3] call BIS_fnc_randomInt);
					_B = str ([1, 6] call BIS_fnc_randomInt);
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetA"+_A, 20, 1, true]] remoteExec ["say3D", 0]};
					if (lifestate _medic != "INCAPACITATED" && (alive _medic)) then {[_medic, [_voice+"_greetB"+_B, 20, 1, true]] remoteExec ["say3D", 0]};		
				};
			};

			//check its right direction 
			_checkdegrees = [_revivepos,_medic,25] call Lifeline_checkdegrees;
			if (_checkdegrees == false) then {
				[_medic,_newrevpos] call Lifeline_align_dir;
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "adjust_direction"};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 ADJUST DIRECTION ", name _medic]};
			};

			_selfheal_trig = false;			
			_unblockwtime = time;
			_trig1 = false;
			_diag_texty2 = "";

			// DISTANCE RADIUS <=2

			waitUntil {
				// _medic playMoveNow _animMove;
				// [_medic,_animMove] remoteExec ["playMoveNow",_medic];
				sleep 0.2;
				_medic doWatch _newrevpos;

				if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 2 && _medic distance2D _newrevpos < 4 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						sleep 2;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 2 && _medic distance2D _newrevpos < 4 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							// _medic setPos _newrevpos;
							_medic disableAI "ANIM";
							_medic setDir (_medic getDir _incap);
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							[_medic,_animMove] remoteExec ["playMoveNow",_medic];
							_trig1 = false;
						};
					};
				};

				((_medic distance2D _newrevpos <=2 ) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true) 
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true				
				)
			};	

			if (Lifeline_travel_meth == 1) then {
				[_medic,_animMove] remoteExec ["playMoveNow",_medic];
			};

			//TEMP ADD BELOW
			_medic disableAI "ANIM";
			_medic setDir (_medic getDir _incap);
			if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
			if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
			[_medic,_animMove] remoteExec ["playMoveNow",_medic];
			//check its right direction - updated 2025
			/* _checkdegrees = [_revivepos,_medic,25] call Lifeline_checkdegrees;
			if (_checkdegrees == false) then {
				[_medic,_newrevpos] call Lifeline_align_dir;
				if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "adjust_direction"};
				if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 ADJUST DIRECTION ", name _medic]};
			}; */

			_unblockwtime = time;
			_trig1 = false;

			// DISTANCE RADIUS <=1

			waitUntil {
				sleep 0.2;

				if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 && _medic distance2D _newrevpos < 2 && _medic getVariable ["ReviveInProgress",0] == 1 && _trig1 == false) then { 
					_trig1 = true;
					[_incap,_medic,_newrevpos,_animMove] spawn {
						params ["_incap","_medic","_newrevpos","_animMove"];
						sleep 2;
						if (speed _medic == 0 && _medic getVariable ["Lifeline_selfheal_progss",false] == false && _medic distance2D _newrevpos > 1 && _medic distance2D _newrevpos < 2 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
							// _medic setPos _newrevpos;
							_medic disableAI "ANIM";
							_medic setDir (_medic getDir _incap);
							[_medic,_animMove] remoteExec ["playMoveNow",0];
							_trig1 = false;
						};
					};
				};

				 // if (time - _unblockwtime > 4 && _medic distance2D _newrevpos > 1 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
				 if (_medic distance2D _newrevpos > 3 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
					if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
					if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIRECTION dist: %2", name _medic, _medic distance2d _newrevpos]};
					_medic setDir (_medic getDir _incap);
					[_medic,_animMove] remoteExec ["playMoveNow",0];
					[_medic,_animMove] remoteExec ["playMoveNow",0];					
				}; 
				((_medic distance2D _newrevpos <=1) || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true) 
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true				
				)
			};

			// if (alive _medic && !(lifestate _medic == "INCAPACITATED")) then {
			if (alive _medic && !(lifestate _medic == "INCAPACITATED") && (_exit == false && _medic getVariable ["Lifeline_ExitTravel", false] == false)) then {
				// _medic doWatch _incap;
				_medic playMoveNow _animStop;
				[_medic,_animStop] remoteExec ["playMoveNow",0];
			};

			_linenumber = "1056";
			_exit = [_incap,_medic,"EXIT REVIVE TRAVEL",_linenumber] call Lifeline_exit_travel;
			if (_exit == true) exitWIth {};

			//wait until fully stopped forward momentum and wait until finished self-healing
			waitUntil {
				(speed _medic == 0) || (_medic getVariable ["Lifeline_selfheal_progss",false] == false || (!alive _medic) || (!alive _incap) || (lifestate _medic == "INCAPACITATED") || (lifestate _incap != "INCAPACITATED") || (_exit == true)
				// || (_incap getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo []
				|| _medic getVariable ["Lifeline_ExitTravel", false] == true
				)
			};			

	};		// end (alive _medic && (lifestate _incap == "incapacitated")

	//======= END IF  end (alive _medic && (lifestate _incap == "incapacitated")

	sleep 0.2;

	if (alive _incap && alive _medic && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && _exit == false && _medic getVariable ["Lifeline_ExitTravel", false] == false ) then {

		// if (Lifeline_travel_meth == 1) then {
			_medic disableAI "ANIM";
			[_medic, "ANIM"] remoteExec ["disableAI", 0];
		// };

		// convert all vanilla FAKs to ACE medical items for AI units (ACE only does players) 2025. FOR LATER when I add function to take items when bandaged.
		/* if (Lifeline_RevMethod == 3 && !isPlayer _x) then {  
			[_x] call ace_common_fnc_replaceRegisteredItems;
		}; */

		_medic setVariable ["ReviveInProgress",2,true];

		_incap setVariable ["Lifeline_canceltimer",true,true]; // if showing, cancel it.

		// smoke
		[_incap, _medic] spawn Lifeline_Smoke; 

		_medic dowatch objNull;

		if (lifestate _medic != "INCAPACITATED" && alive _medic) then {[_medic, (_medic getDir _incap)] remoteExec ["setDir", 0];};

		_exitanim = false;

		//call animations and medic hands-on revive
		if (Lifeline_RevMethod != 3) then {
			_exitanim = [_incap,_medic,_EnemyCloseBy,_voice,_B] call Lifeline_Medic_Anim_and_Revive; 
		};

		if (Lifeline_RevMethod == 3) then {
			[_incap,_medic,_EnemyCloseBy,_voice,_B] call Lifeline_ACE_Revive;
		};

		//explaination of variables. _voice is the voice actor. _B is the randomized second half of greeting. We pass this variable to avoid repeated samples.

		if (_exitanim == true) exitWith {
		};

		// ========= WAKE UP (IF)
		if (lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap) then {

			_incap setdamage 0;	
			[_incap, 0] remoteExec ["setDamage", 0];

			// if !(local _incap) then {
				[_incap, false] remoteExec ["setUnconscious",0,true]; //remoteexec version
			// } else {
			// 	_incap setUnconscious false; // non remote exec version
			// };			

			waitUntil {
				(lifestate _incap != "INCAPACITATED") //Cannot go past until awake. Needed for slower remoteExec delay		
			};
		};		

	}; // END IF alive medic and incap unit and lifestate incap == "incapacitated" 

	//=====================================================================================================
	//========= EITHER WAKE UP OR BYPASS ==================================================================
	//=====================================================================================================

	// Debug get total revive time and remove debug path marker
	if (Lifeline_Revive_debug) then {
		_incap call Lifeline_delYelMark;
		if (lifestate _incap != "incapacitated" && alive _incap && _exit == false) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ SUCCESS REVIVED // [0952] revive completed'", _incap, _medic,name _incap,name _medic];
		};
		if (lifestate _incap == "incapacitated" && lifestate _medic != "incapacitated" && alive _incap) then {
			// if (Lifeline_hintsilent) then {["Incap not revived"] remoteExec ["hintsilent",2]};
			diag_log format ["%1|%2|++++ DELETE YELLOW MARKER ++++ FAILED TRAVEL // [0958] Incap not revived | LifelinePairTimeOut %3 | '", name _incap,name _medic,((_medic getvariable "LifelinePairTimeOut") - time)];
		};
		if (lifestate _medic == "incapacitated" || !alive _medic ) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ FAILED TRAVEL // [0963] MEDIC DOWN'", _incap, _medic,name _incap,name _medic];
			if (Lifeline_hintsilent) then {[format ["MEDIC DOWN: %1", name _medic]] remoteExec ["hintsilent",2]};
		};
		if !(alive _incap) then {
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ INCAP DEAD // [0969]'", _incap, _medic,name _incap,name _medic];
		};
		if (lifestate _incap != "INCAPACITATED" && alive _incap && (_exit == true)) then {
			if (Lifeline_hintsilent) then {[format ["Medic WOKE UP\n%1", name _medic]] remoteExec ["hintsilent", 2]};
			diag_log format ["%3|%4|++++ DELETE YELLOW MARKER ++++ [0975] INCAP WOKE UP!!!'", _incap, _medic,name _incap,name _medic];
		};
	};

	//back to original stance
	if (Lifeline_travel_meth == 1) then {
		// _medic setUnitPos _stance;
		_medic setUnitPos "AUTO";
	};
	_medic limitSpeed 100;
	_medic dofollow leader _medic;

	// Bleedout timer reset
	if (lifestate _incap != "INCAPACITATED") then {
		_incap doFollow leader _incap;
		_incap setVariable ["LifelineBleedOutTime", 0, true];
		_incap setVariable ["Lifeline_selfheal_progss",false,true];
	};

	// clear wayppoints for medic
	// for "_i" from 0 to (count waypoints _goup - 1) do {deleteWaypoint [_goup, 0]};

	if (lifestate _medic != "INCAPACITATED") then { //added this conditional. if the medic gets downed, then we dont want to reset these

		_captive = _medic getVariable ["Lifeline_Captive", false];
		// if !(local _medic) then {
				[_medic,true] remoteExec ["allowDamage",0];
				// [_medic,false] remoteExec ["setCaptive",_medic];
				[_medic,_captive] remoteExec ["setCaptive",0];
			/* } else {
				_medic allowDamage true;
				// _medic setCaptive false;
				_medic setCaptive _captive;
			}; */
		[_medic, objNull] remoteExec ["doWatch",0];
	};

	if (Lifeline_Revive_debug && Lifeline_hintsilent && alive _medic && !alive _incap) then {[format ["Incap dead: %1",name _incap]] remoteExec ["hintsilent", 2]};

	// Delete Incap marker
	if !(_incap getVariable ["Lifeline_IncapMark",""] == "") then {
		deleteMarker (_incap getVariable "Lifeline_IncapMark");
		_incap setVariable ["Lifeline_IncapMark","",true];
	};

	// turn on collision
	// [_medic, _incap] remoteExecCall ["enableCollisionWith", 0, _medic];

	// Player control group
	if (isplayer _incap && alive _incap && lifestate _incap != "INCAPACITATED") then {
		[group _incap, _incap] remoteExec ["selectLeader", groupOwner group _incap];//checkthis
	}; 

	_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); 

	// if ( !(_medic getVariable ["Lifeline_reset_trig",false]) 
	if (_incap getVariable ["ReviveInProgress",0] == 3 || _AssignedMedic isEqualTo [] || _medic getVariable ["Lifeline_ExitTravel", false] == true ) then {
			// _medic setVariable ["Lifeline_reset_trig", true, true]; 
		 [[_incap,_medic],"1232 VERY END TRAVEL"] call Lifeline_reset2;	
	};	
	sleep 5; //delay enableing "ANIM" for 5 secs to stop unit spinning on the ground
	_medic enableAI "ANIM";
	[_medic, "ANIM"] remoteExec ["enableAI", 0];

	// turn on collision
	[_medic, _incap] remoteExecCall ["enableCollisionWith", 0, _medic];

}; // End LifeLine_StartReviveOld

// Function to split a full name into first name and surname
Lifeline_split_name = {
    params ["_fullName"];
    // Split the name by spaces
    _nameParts = _fullName splitString " ";
    // The first element is the first name
    _firstName = _nameParts select 0;
    // Everything else is the last name (joined back together with spaces)
    _lastName = "";
    if (count _nameParts > 1) then {
        _lastNameParts = _nameParts - [_firstName];
        _lastName = _lastNameParts joinString " ";
    };
    // Return as an array [firstName, lastName]
    [_firstName, _lastName]
};

Lifeline_delete_create_unit = {
	params ["_unit"];
	// Store unit's information

_type = typeOf _unit;
_pos = getPosATL _unit;
_dir = getDir _unit;
_group = group _unit;
_name = name _unit;
_face = face _unit;
_speaker = speaker _unit;
_rank = rank _unit;
_skill = skill _unit;
// _value = "";
_colorunit = assignedTeam _unit;

// Store unit's loadout (this captures all weapons, magazines, items)
_loadout = getUnitLoadout _unit;

// Store unit's variables (optional, only needed if you have custom variables)
/* _allVariables = [];
{
    // if (!(_x in ["LifelineDHadded"])) then {
        _allVariables pushBack [_x, _unit getVariable _x];
    // };
} forEach (allVariables _unit); */

// Delete the original unit
deleteVehicle _unit;
// sleep 2;

// Create new unit
_newUnit = _group createUnit [_type, _pos, [], 0, "NONE"];
sleep 0.3;
_newUnit setDir _dir;
_nameArray = [_name] call Lifeline_split_name;
_firstName = _nameArray select 0;  // "Colin"
_lastName = _nameArray select 1;   // "O'Connor"

_newUnit setName [_firstName+" "+_lastName, _firstName, _lastName];
_newUnit setFace _face;
_newUnit setSpeaker _speaker;
_newUnit setRank _rank;
_newUnit setSkill _skill;

// Restore team color
_newUnit assignTeam _colorunit;

// Apply the stored loadout
_newUnit setUnitLoadout _loadout;

// Restore variables (optional)
/* {
    _x params ["_varName", "_varValue"];
    _newUnit setVariable [_varName, _varValue, true];
} forEach _allVariables; */

// Enable all AI features
{_newUnit enableAI _x} forEach ["MOVE", "TARGET", "AUTOTARGET", "WEAPONAIM", "FSM", "CHECKVISIBLE", "COVER", "SUPPRESSION", "AUTOCOMBAT", "PATH"];

// Reset the unit's state
_newUnit setDamage 0;
_newUnit setCaptive false;

[] call Lifeline_DH_update;

};

Lifeline_Medic_Num_Limit = {
	params ["_incap","_closermedic"];

	_medic_under_limit = true;

	// these vars are so we can add 1 because when its  a "closer medic" situation,. We swap unit with medic already on its way. 
	_zero = 0;
	_one = 1;
	_two = 2;

	if (_closermedic) then {
		_zero = 1;
		_one = 2;
		_two = 3;
	};

	// ======= MEDIC NUMERICAL LIMITS LOGIC ======== 
			if (Lifeline_Medic_Limit >= 0 && !(group _incap in Lifeline_Group_Mascal)) then {
			// if !(group _incap in Lifeline_Group_Mascal) then {
				// Subtract both incapacitated units and players from the group
				_incap_group_units = (units group _incap) - Lifeline_incapacitated - (units group _incap select {isPlayer _x || !alive _x || lifeState _x == "DEAD"}); // exclude dead units
				// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach _incap_group_units; 

				if (count _incap_group_units > 0) then {
					Lifeline_healthy_units = _incap_group_units;
				};
				// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; 

				_count_current_medics = [group _incap] call Lifeline_count_group_medics;
				// Standard group limits (1, 2, 3)
				if (Lifeline_Medic_Limit == 1 && _count_current_medics > _zero) then {
					_medic_under_limit = false;	
				};
				if (Lifeline_Medic_Limit == 2 && _count_current_medics > _one) then {
					_medic_under_limit = false;
				};
				if (Lifeline_Medic_Limit == 3 && _count_current_medics > _two) then {
					_medic_under_limit = false;
				};
				// Group limits plus unsuppressed units (4, 5, 6)
				if (Lifeline_Medic_Limit >= 4 && Lifeline_Medic_Limit <= 6) then {
					_limit_per_group = Lifeline_Medic_Limit - 3; // Convert 4->1, 5->2, 6->3
					// Check for the count of medics and if we've reached the base limit
					if (_count_current_medics >= _limit_per_group) then {
						// When we've reached the base limit, we'll only allow unsuppressed units to be medics
						_suppressed_units = Lifeline_healthy_units select {getSuppression _x > 0.1};
						// _suppressed_units = Lifeline_healthy_units select {_x getVariable ["testbaby",true] == true}; // TESTER
						_unsuppressed_units = Lifeline_healthy_units - _suppressed_units;
						if (Lifeline_Revive_debug) then {
						};
						// If there are no unsuppressed units, we'll check if all units are suppressed
						if (count _unsuppressed_units == 0 && count _suppressed_units > 0) then {
							// All units are suppressed, so we'll still use the first setting logic
							if (Lifeline_Revive_debug) then {
							};
							// Match the behavior of settings 1-3
							if (_limit_per_group == 1 && _count_current_medics > _zero) then {
								_medic_under_limit = false;
							};
							if (_limit_per_group == 2 && _count_current_medics > _one) then {
								_medic_under_limit = false;
							};
							if (_limit_per_group == 3 && _count_current_medics > _two) then {
								_medic_under_limit = false;
							};
						} else {
							// We have unsuppressed units available, use those
							Lifeline_healthy_units = _unsuppressed_units;
							// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach _unsuppressed_units; 
						};
					};
				};

			} else {
				Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;
				// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; 
			}; 

			// _diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; 

			// =========================== END OF MEDIC NUMERICAL LIMITS LOGIC ================================
	_medic_under_limit

};

// Check if the group has at least one real medic with the medic trait who is not incapacitated
Lifeline_has_real_medic = {
    params ["_group"];
    private _hasRealMedic = false;
    {
        if (_x getUnitTrait "medic" && lifestate _x != "INCAPACITATED" && alive _x) exitWith {
            _hasRealMedic = true;
        };
    } forEach units _group;
    _hasRealMedic
};
