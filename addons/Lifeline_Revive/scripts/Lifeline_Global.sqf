diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "========================================== Lifeline_Global.sqf ================================================='"; 
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
		if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
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
		) then {
			_exit = true;
			_medic setVariable ["Lifeline_ExitTravel", true, true];
	};
_exit
};




// List of all incapped units and assigned medics in HUD. Needs to be used with "foreach"
Lifeline_incap_list_HUD = {
params ["_x","_diag_text"];

		// _diag_text = "";
		_underline = "";
		_underline2 = "";
		_colur =  "#EEEEEE"; //whiteish
		_colur2 = "#EEEEEE"; //whiteish
		_no = "";
		_medics = "";
		_tme = "";
		_distcalc = "";
		_incap = _x;

		if (lifestate _x == "INCAPACITATED" || !(alive _x)) then {
				_colur = "#FFBFA7"; //pinkish
				if (Lifeline_RevMethod == 2) then {
					if (Lifeline_BandageLimit > 1 && Lifeline_HUD_names in [2,4]) then {
						_bandges = (_x getVariable ["num_bandages",0]);
						if (_bandges != 0) then {
							// _no = " (" + str _bandges + ")";
							// _no = "<t size='0.3'> ("+str _bandges+")</t>";
							// _no = "  " + str _bandges;
							_no = "<t size='0.3'>  "+str _bandges+" </t>";
							// _no = "<t color='#ffffff'> ("+str _bandges+")</t>";
							 // _no = "<t color='#ffffff' size='0.3'> ("+str _bandges+")</t>";
						} else {
							_no = " "; 
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
			_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + "</t>   <br />";
		};

		if (_x getVariable ["ReviveInProgress",0] == 3) then {
			_medic = (_x getVariable ["Lifeline_AssignedMedic", []]);
			{
				if (Lifeline_Revive_debug && isServer && Lifeline_HUD_names_pairtime) then {
					_tme = str round ((_incap getVariable ["LifelinePairTimeOut",0]) - time);
				};
				if (Lifeline_HUD_names in [2,3]) then {
					_distcalc = str round (_incap distance2D _x) + "m ";
				};
				if (_x getVariable ["ReviveInProgress",0] == 2) then {
					_colur2 = "#58D68D";
					_colur = "#58D68D";// COMMENT THIS OUT TO HAVE DIFF COLOURED INCAP / MEDIC PAIRS WHEN ACTUAL REVIVE
					_tme = "";
					_distcalc = "";
				};
				if (isPlayer _x) then {_underline2 = "underline='1'";};
				// _medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) + name _x + " " + _distcalc + _tme + "</t>   ";
				_medics = _medics + (format ["<t color='%1' %2>", _colur2,_underline2]) + name _x + " " + "<t size='0.3'>" +_distcalc + _tme + "</t></t>   ";
			} foreach _medic;

			_diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + name _x + _no + "</t> - "  + _medics + "<br />";
			// _diag_text = _diag_text + (format ["<t color='%1' %2>", _colur,_underline]) + _no + " " + name _x + "</t> - "  + _medics + "<br />";
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
			createVehicle [_GrenadeSmokeCol, _relpos, [], (random 6), "CAN_COLLIDE"];
		};	
	};
	true
};



Lifeline_EnemyCloseBy = {
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

			_x setVariable ["ReviveInProgress",0,true];	
			_x setVariable ["Lifeline_AssignedMedic", [], true];
			_x setvariable ["LifelinePairTimeOut",0,true];
			// _x setVariable ["Lifeline_ExitTravel", false, true];

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
			[_x] joinSilent _x;
			_x assignTeam _teamcolour;

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
				if !(local _x) then {
					[_x, true] remoteExec ["allowDamage",_x];
					[_x, false] remoteExec ["setCaptive",_x];
				} else {
					_x allowDamage true;
					_x setCaptive false; 
				};		
			};	
		};	//if (alive _x) then 
	} forEach _units;


	true
};



Lifeline_SelfHeal = {
	params ["_unit"];

	_unit setVariable ["Lifeline_selfheal_progss",true,true];
	if (_unit getVariable ["ReviveInProgress",0] == 0) then {
		sleep 3;
		sleep (random 2); // this must be BEFORE cheching incapacitated. Otherwise in these 5 secs it can happen, and bugs animation.
	};

	if (alive _unit && lifeState _unit != "INCAPACITATED" && Lifeline_RevMethod != 3 && (damage _unit > 0.2 || _unit getHitPointDamage "hitlegs" >= 0.5) && (isnull (objectParent _unit))) then {

		_EnemyCloseBy = [_unit] call Lifeline_EnemyCloseBy;

		if (_unit getVariable ["ReviveInProgress",0] in [1,2]) then {
			_unit setVariable ["LifelinePairTimeOut", (_unit getvariable "LifelinePairTimeOut") + 5, true];  
		}; // add 5 secs to timeout

		// if (isnull _EnemyCloseBy or _unit distance _EnemyCloseBy >100) then {
		// if (isnull _EnemyCloseBy) then {
		if ((stance _unit == "STAND" || stance _unit == "CROUCH") && stance _unit != "UNDEFINED") then {
			[_unit,"AinvPknlMstpSlayWrflDnon_medic"] remoteExec ["playMoveNow", _unit];
			sleep 6;
		} else {
			[_unit,"ainvppnemstpslaywrfldnon_medic"] remoteExec ["playMoveNow",_unit];
			sleep 7;
		};

		if (lifeState _unit != "INCAPACITATED") then { //added again
			_unit setdamage 0;
		};		
	};

	if (alive _unit && lifeState _unit != "INCAPACITATED" && Lifeline_RevMethod == 3 && (isnull (objectParent _unit))) then {
		[_unit] call Lifeline_SelfHeal_ACE;
	};
	_unit setVariable ["Lifeline_selfheal_progss",false,true];

	true
};



//========================== MAIN FUNCTION LOOP TO CHECK INCAP / MEDIC PAIR
Lifeline_PairLoop = {
	params ["_medic","_incap"];

	// if (Lifeline_Revive_debug && Lifeline_hintsilent) then {[format ["Incap: %1\nMedic: %2", name _incap, name _medic]] remoteExec ["hintsilent", 2]};

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
		if (speed _medic == 0) then {
		};

		// THIS IS TO STOP IDLE MEDICS. SOMETIMES HAPPENS.
		// if (Lifeline_Idle_Medic_Stop && (animationstate _medic in ["aidlpercmstpsraswrfldnon_g01","aidlpercmstpsraswrfldnon_g02","aidlpercmstpsraswrfldnon_g03","aidlpercmstpsraswrfldnon_g04","amovpknlmstpslowwrfldnon","aidlpercmstpsraswrfldnon_ai"] || _repeatcount != 6)) then { 
		if (Lifeline_Idle_Medic_Stop && (speed _medic == 0 || _repeatcount != 6) && (_medic getVariable ["ReviveInProgress",0] == 1) && _distcalc > 6) then { 
			if (_repeatcount < 4) then { // just beep for debugging
				if (Lifeline_Revive_debug) then {
					if (Lifeline_hintsilent) then {hintsilent format ["%1 IDLE MEDIC %2", name _medic, _repeatcount]}; 
					["beep_hi_1"] remoteExec ["playsound",2];
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
		if (_distcalc > _closermedic_dist ) then {

			 Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;
			 // Lifeline_medics2choose = (Lifeline_healthy_units select {!(side _x == civilian) && !isPlayer _x && !(_x in Lifeline_Process) && ((_x distance _incap) < Lifeline_LimitDist) && (currentWeapon _x != secondaryWeapon _x )}); 
			 Lifeline_medics2choose = (Lifeline_healthy_units select {!(side _x == civilian) && !isPlayer _x && !(_x in Lifeline_Process) && ((_x distance _incap) < Lifeline_LimitDist) 
				&& !(currentWeapon _x == secondaryWeapon _x && currentWeapon _x != "")
			 	&& !(((assignedTarget _x) isKindOf "Tank") && secondaryWeapon _x != "") //check unit did not get order to hunt tank
				&& !(((getAttackTarget _x) isKindOf "Tank") && secondaryWeapon _x != "")			 
			 }); 
			 _closermedic = false;
			 {
				  _dis = _x distance2D _incap;
				 if (_dis < _closermedic_dist) then {
					 _closermedic = true;
				 };		 
			 } foreach Lifeline_medics2choose;

			 if (count Lifeline_medics2choose > 0 && _closermedic == true) then {
				if (Lifeline_Revive_debug) then {
					if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {["closermedic"] remoteExec ["playSound",2]}; 
					if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hintsilent format ["%1  CLOSER MEDIC ", name _medic]}; 
				 };
				  _exit = true;
				  _medic setVariable ["Lifeline_ExitTravel", true, true];
			  };
		};

		//JUST DEBUGGING
		_formatedReviveTime = round(_elapsedTimeToRevive - time);
		if (Lifeline_RevMethod == 2 && Lifeline_Revive_debug) then {
			diag_log format [" %3 | %4 |xxxxxxxxxxxxxxxxxxx REVIVETIME %2 BLEEDOUT %5 DISTANCE %6 ReviveInProgress %7 autoRecover %8 |'", 0, if (_formatedReviveTime < 10) then {"0"+(str _formatedReviveTime)} else {_formatedReviveTime}, name _incap, name _medic, round(_incapTL - time), _distcalc toFixed 0, _medic getVariable ["ReviveInProgress",0], _incap getVariable ["Lifeline_autoRecover",false] ];
		};
		if (Lifeline_RevMethod == 3 && Lifeline_Revive_debug) then {
			diag_log format [" %3 | %4 |xxxxxxxxxxxxxxxxxxx REVIVETIME %2 DISTANCE %5 ReviveInProgress %6 |'", 0, if (_formatedReviveTime < 10) then {"0"+(str _formatedReviveTime)} else {_formatedReviveTime}, name _incap, name _medic, _distcalc toFixed 0, _medic getVariable ["ReviveInProgress",0] ];
		};
		// };		


		_ifACEdragged = false;
		if (Lifeline_RevMethod == 3) then {
			if ([_incap] call ace_medical_status_fnc_isBeingDragged || [_incap] call ace_medical_status_fnc_isBeingCarried) then {
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

				// if (lifestate _medic != "INCAPACITATED") then { //added this conditional. sometimes when medic is hit and downed, this needs to stay as is.			
						// [_medic,false] remoteExec ["setCaptive",_medic];
				// }; 
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
			&& _medic getVariable ["Lifeline_selfheal_progss",false] == false
		) then {
			_medic call Lifeline_SelfHeal;
		};

		// ========== Start travel ===========

		// update this later. bad method for making sure animation works when not having primary weapon. 
		if (alive _medic && primaryWeapon _medic == "") then {_medic addWeapon "arifle_MX_F"};
		if (alive _medic && currentWeapon _medic != (primaryWeapon _medic)) then {_medic selectWeapon (primaryWeapon _medic)};

		_EnemyCloseBy = [_medic] call Lifeline_EnemyCloseBy;
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
/* 					if (!isnull _EnemyCloseBy && _cpr == false) then {
						_revivePosCheck = [_incap, _medic, 1.5] call Lifeline_POSnexttoincap;
					} else {
						_revivePosCheck = [_incap, _medic, 0.8] call Lifeline_POSnexttoincap; 
					}; */
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
								if (Lifeline_debug_soundalert) then {playsound "forcedirection"};
								if (Lifeline_hintsilent) then {hint format ["%1 FORCE DIRECTION", name _medic]};
							};
							_direction = _medic getDir _incap;
							_medic setDir _direction;
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
			[_medic] joinSilent _medic; // THIS AFFECTS SPEED
			_medic assignTeam _teamcolour;// joinSilent deletes Teamcolour, so workaround here.
			if (_shortorigdist6) then {
				_medic limitSpeed 2;
				// group _medic setSpeedMode "LIMITED";
				// playsound "testC";
			};

			//remoteExec version. Even though documentation says doMove and MoveTo is global, was getting errors, so remoteExec seemed to fix it. 
			[_medic, position _medic] remoteExec ["moveTo", _medic];
			[_medic, position _medic] remoteExec ["doMove", _medic];
			[_medic, _revivePos] remoteExec ["moveTo", _medic];
			[_medic, _revivePos] remoteExec ["doMove", _medic];

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
				if !(local _medic) then {
					[_medic,dmg_trig] remoteExec ["allowDamage",_medic];
					[_medic,cptv_trig] remoteExec ["setCaptive",_medic];
				} else {
					_medic allowDamage dmg_trig;
					_medic setCaptive cptv_trig;
				};								
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
				_medic lookAt _newrevpos;
				// _medic doWatch _newrevpos;
				_timechc = time;
				_checkdegrees = [_newrevpos,_medic,15] call Lifeline_checkdegrees;
				if (_checkdegrees == false) then {				
					waitUntil {						
						_medic lookAt _newrevpos;
						_checkdegrees = [_newrevpos,_medic,30] call Lifeline_checkdegrees;
						if (time - _timechc > 5) then {
							_medic lookAt _newrevpos;
							_medic disableAI "ANIM"; 
							_medic setDir (_medic getDir _newrevpos);
							if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
							if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIR MEDIC dist: %2", name _medic, _medic distance2d _newrevpos]};
						};
						(_checkdegrees == true)				
						// (_checkdegrees == true || time - _timechc > 5)				
					};
				};
				if (Lifeline_travel_meth == 0) then {
					_medic disableAI "ANIM"; //TEMP
					_medic playMoveNow _animMove;					[_medic,_animMove] remoteExec ["playMoveNow",_medic];
				};
				if (Lifeline_travel_meth == 1) then {
					_medic setUnitPos _posture; //posture
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
						[_medic,_animMove] remoteExec ["playMoveNow",_medic];
						// _medic setdir (_medic getDir _newrevpos);	
						_medic lookAt _incap;						
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
				if (Lifeline_MedicComments) then {
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
							[_medic,_animMove] remoteExec ["playMoveNow",_medic];
							_trig1 = false;
						};
					};
				};

				 // if (time - _unblockwtime > 4 && _medic distance2D _newrevpos > 1 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
				 if (_medic distance2D _newrevpos > 3 && _medic getVariable ["ReviveInProgress",0] == 1) then { 
					if (Lifeline_debug_soundalert && Lifeline_Revive_debug) then {playsound "forcedirection"};
					if (Lifeline_hintsilent && Lifeline_Revive_debug) then {hint format ["%1 FORCE DIRECTION dist: %2", name _medic, _medic distance2d _newrevpos]};
					_medic setDir (_medic getDir _incap);
					[_medic,_animMove] remoteExec ["playMoveNow",_medic];
					[_medic,_animMove] remoteExec ["playMoveNow",_medic];					
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
				[_medic,_animStop] remoteExec ["playMoveNow",_medic];
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
		// };

		_medic setVariable ["ReviveInProgress",2,true];

		_incap setVariable ["Lifeline_canceltimer",true,true]; // if showing, cancel it.

		// smoke
		[_incap, _medic] spawn Lifeline_Smoke; 

		_medic dowatch objNull;

		if (lifestate _medic != "INCAPACITATED" && alive _medic) then {_medic setdir (_medic getDir _incap);};

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

			if !(local _incap) then {
				[_incap, false] remoteExec ["setUnconscious",_incap,true]; //remoteexec version
			} else {
				_incap setUnconscious false; // non remote exec version
			};			

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
	for "_i" from 0 to (count waypoints _goup - 1) do {deleteWaypoint [_goup, 0]};

	if (lifestate _medic != "INCAPACITATED") then { //added this conditional. if the medic gets downed, then we dont want to reset these

		if !(local _medic) then {
				[_medic,true] remoteExec ["allowDamage",_medic];
				[_medic,false] remoteExec ["setCaptive",_medic];
			} else {
				_medic allowDamage true;
				_medic setCaptive false;
			};
		[_medic, objNull] remoteExec ["doWatch",_medic];
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
		[group _incap, _incap] remoteExec ["selectLeader", groupOwner group _incap];
	}; 

	_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]); 

	// if ( !(_medic getVariable ["Lifeline_reset_trig",false]) 
	if (_incap getVariable ["ReviveInProgress",0] == 3 || _AssignedMedic isEqualTo [] || _medic getVariable ["Lifeline_ExitTravel", false] == true ) then {
			// _medic setVariable ["Lifeline_reset_trig", true, true]; 
		 [[_incap,_medic],"1232 VERY END TRAVEL"] call Lifeline_reset2;	
	};	
	sleep 5; //delay enableing "ANIM" for 5 secs to stop unit spinning on the ground
	_medic enableAI "ANIM";


}; // End AIReviveUnits Fnc



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

//just testing
reset_idle_medics = {
    params ["_unit"];

    // Remove all waypoints
    {
        deleteWaypoint _x;
    } forEach waypoints (group _unit);

    // Reset position and direction
    // _unit setPos (position _unit);
    _unit setDir (direction _unit);
	_unit setSkill ["courage", 1];
    // Reset behaviour
    _unit setBehaviour "SAFE";
    _unit setCombatMode "YELLOW";
    _unit setSpeedMode "LIMITED";
    _unit disableAI "ALL";
	sleep 0.1;
    _unit enableAI "ALL";
	sleep 0.1;
	if (Lifeline_Revive_debug) then {[_unit,"IDLE MEDIC reset_idle_medics [Lifeline_Functions.sqf]"] call serverSide_unitstate;};
};



 