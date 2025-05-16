	// PLAYER REVIVE OTHERS ACTION

	params ["_player","_actionId"];

	if (captive _player && !(_player getVariable ["Lifeline_Captive_Delay",false])) then {_player setVariable ["Lifeline_Captive",true,true]} else {_player setVariable ["Lifeline_Captive",false,true]}; //2025

	_exit = false;
	_Lifeline_AssignedMedic_AI = objNull;
	_timestamp = time;
	_incap = cursorObject;
	_bandages = 1; 		  //only appearing in debugging if RevMethod = 1
	_damagesubtract = 1;  //only appearing in debugging if RevMethod = 1
	_unitwounds = [];
	[_incap, _player] remoteExecCall ["disableCollisionWith", 0, _incap];
	_vcrew = [];

	if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
		_damagesubtract = _incap getVariable ["damagesubstr",0];
		_bandages = _incap getVariable ["num_bandages",0];
		_unitwounds =  _incap getVariable ["unitwounds",[]]; // important for deleting from array
	};

	_captive = _player getVariable ["Lifeline_Captive", false];//2025

	if (_bandages == 0) exitWith {		
		[_player, true] remoteExec ["allowDamage",0];
		// [_player, false] remoteExec ["setCaptive",_player]; 
		[_player, _captive] remoteExec ["setCaptive",0]; 
		// _player setcaptive false;_player allowDamage true; 
	};

	if (Lifeline_RevMethod == 2 && !(_incap getVariable ["Lifeline_Down",false])) exitWith {
		[_player, true] remoteExec ["allowDamage",0];
		// [_player, false] remoteExec ["setCaptive",_player]; 
		[_player, _captive] remoteExec ["setCaptive",0]; 
		// _player setcaptive false;_player allowDamage true; 
	};

	if (_bandages == 0 or (lifestate _incap !="INCAPACITATED")) exitWith {
		[_player, true] remoteExec ["allowDamage",0];
		// [_player, false] remoteExec ["setCaptive",_player]; 
		[_player, _captive] remoteExec ["setCaptive",0]; 
		// _player setcaptive false;_player allowDamage true; 
	};

	_incap setVariable ["Lifeline_canceltimer",true,true]; 

	//ADD MORE TIMER. added to increase revive time limit on each loop pass (made to also work with old versions)
	_bleedoutincap = (_incap getvariable "LifelineBleedOutTime");
	_incap setVariable ["LifelineBleedOutTime", _bleedoutincap + 30, true];

	_player setVariable ["ReviveInProgress",2,true]; 
	// _player setcaptive true;
	// _player allowDamage dmg_trig; 
	if (Lifeline_RevProtect != 3) then {
		[_player, dmg_trig] remoteExec ["allowDamage",0];
		[_player, true] remoteExec ["setCaptive",0]; 	
	};

	//temporarily clear action menu while reviving	
	if (Lifeline_RevMethod == 2) then {
	// if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
		[[_incap,_actionId],{params ["_incap","_actionId"];_incap setUserActionText [_actionId, ""];}] remoteExec ["call", _incap, true];
	};

	// Unassign vehicle crew to prevent them getting back in after revive (reset fnc will conditionally reassign veh and allow getin)
	if (!isnull assignedVehicle _incap) then {
		_vehicle =  (assignedVehicle _incap);
		{_vcrew pushBack _x} foreach (Lifeline_All_Units select {assignedvehicle _x == _vehicle});
		// Unassign vehicle crew to prevent them getting back in after revive (reset fnc will conditionally reassign veh and allow getin)
		{unassignVehicle _x; [_x] allowGetIn false;} forEach _vcrew;
	};

	if (lifestate _incap == "INCAPACITATED") then {
		// {Lifeline_Process pushback _x} foreach [_incap, _player];
		// {Lifeline_Process pushBackUnique _x} foreach [_incap, _player];
		Lifeline_Process pushBackUnique _player; 
		// Lifeline_Process pushBackUnique _incap; 
		publicVariable "Lifeline_Process"; 
		// new text system for proc pairs
		_Lifeline_AssignedMedic = _incap getVariable ["Lifeline_AssignedMedic",[]];
		_Lifeline_AssignedMedic_AI = _Lifeline_AssignedMedic select 0; //this is the other AI medic already on its way. This needs to be cancelled.
		_Lifeline_AssignedMedic pushBackUnique _player;
		_incap setVariable ["Lifeline_AssignedMedic", _Lifeline_AssignedMedic, true];	

		waitUntil {_player distance _incap <2 or !alive _player};

		_EnemyCloseBy = _player findNearestEnemy _player;

		_waituntilHack = false;
		// if (_incap distance _EnemyCloseBy < 100 ||  animationState _player find "ppn" == 4 ) then {
		if (animationState _player find "ppn" == 4 ) then {
			_waituntilHack = true;	
			[_player,"ainvppnemstpslaywrfldnon_medicother"] remoteExec ["playMove", 0]; // ORIGINAL
			if (_bandages == 1) then {
				sleep 8;
			};
		} else { 
			_player setAnimSpeedCoef 1.5;
			[_player,"AinvPknlMstpSnonWnonDnon_medic4"] remoteExec ["playMoveNow", 0]; //ORIGINAL
			sleep 8.6; // HERE
		};

		waitUntil {
				sleep 0.1;
				(
				(animationState _player == "amovpknlmstpsraswrfldnon" || _waituntilHack == true || (time - _timestamp) >= 10)
				// (animationState _player == "amovpknlmstpsraswrfldnon" || animationState _player == "ainvppnemstpslaywrfldnon_medicdummyend" || (time - _timestamp) >= 10)
				)
		};
		_player setAnimSpeedCoef 1;
		sleep 1;

		if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
			_colour = "";
			_text = "";
			_damagesubtract = _incap getVariable ["damagesubstr",0];		
			_bandages = _incap getVariable ["num_bandages",0];

			//remotecheck
			if (_bandages == 0 or (lifestate _incap !="INCAPACITATED")) exitWith {
				// _player setcaptive false;  
				_player setcaptive _captive;  
				_player allowDamage true; 
				_exit = true;
			};
			_newdamage = damage _incap - _damagesubtract; // added a 0.000001 just to make sure 
			_bandages = _bandages - 1;
			_text = _incap getVariable "unitwounds" select (_bandages -1) select 0;
			_colour = _incap getVariable "unitwounds" select (_bandages -1) select 1;		
			//add new text to action menu each bandage
			_incap setVariable ["num_bandages",_bandages,true];

			_unitwounds deleteAt _bandages;
			_incap setVariable ["unitwounds",_unitwounds,true];
			_actionId = _incap getVariable ["Lifeline_ActionMenuWounds",-1];

			//setUserActionText
			[[_incap,_actionId,_colour,_bandages, _text],
					{params ["_incap", "_actionId", "_colour","_bandages","_text"];
					_incap setUserActionText [_actionId, format ["<t size='%4' color='#%1'>%3       ..%2</t>",_colour,_bandages,_text, Lifeline_textsize]];}
			] remoteExec ["call", 0, true];
			//BIS_fnc_dynamicText
			if (isPlayer _incap && Lifeline_HUD_medical) then {
				// [format ["<t align='right' size='%4' color='#%1'>%3	  ..%2</t>",_colour,_bandages,_text, 0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
				_textright = format ["<t align='right' size='%4' color='#%1'>%3	  ..%2</t>",_colour,_bandages,_text, 0.7];
				[_textright,1.3,5,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright",_incap];				
			};
			//ADD MORE TIMER. added to increase revive time limit on each loop pass (made to also work with old versions)
			_bleedoutincap = (_incap getvariable "LifelineBleedOutTime");
			_incap setVariable ["LifelineBleedOutTime", _bleedoutincap + 30, true];

			_incap setDamage _newdamage;
		};
		if (_exit == true) exitWith {
			if (_incap getVariable ["ReviveInProgress",0] == 3) then {; 
				[[_incap], format ["%1|%2| PLAYERREVIVE [259]",name _incap,name _player]] remoteExec ["Lifeline_reset2", _incap];
			};
		};

		if (_bandages > 1) then {
			// _player setcaptive false; 
			_player setcaptive _captive; 
		};
		// ============ WAKE UP, FINISHED
		// if (damage _incap <= 0.2) then { 
		if (_bandages <= 0 || Lifeline_BandageLimit == 1) then { 

			_incap setVariable ["damagesubstr", nil, true]; //added
			if !((_incap getVariable ["Lifeline_IncapMark",""]) == "") then {
				deleteMarker (_incap getVariable "Lifeline_IncapMark");
				_incap setVariable ["Lifeline_IncapMark","",true];
			};
			_goupI = (_incap getVariable ["Lifeline_Grp",(group _incap)]);
			_teamcolour = assignedTeam _incap;
			[_incap] joinSilent _goupI;
			_incap assignTeam _teamcolour;
			[_incap, (leader _goupI)] remoteExec ["doFollow", 0];
			[_incap, false] remoteExec ["setUnconscious",0];
			// Reset bleedout time var
			_incap setVariable ["LifelineBleedOutTime", 0, true];
			[_incap] spawn {
			params ["_incap"];	
				_incap setVariable ["Lifeline_Captive_Delay",true,true];
				sleep 5;
				_captivei = _incap getVariable ["Lifeline_Captive", false];
				// _incap setCaptive false;	
				// _incap allowdamage true; 
				[_incap, true] remoteExec ["allowDamage",0];
				// [_incap, false] remoteExec ["setCaptive",_incap]; 	
				[_incap, _captivei] remoteExec ["setCaptive",0]; 	
				_incap setVariable ["Lifeline_Captive_Delay",false,true];
			};

			//newline
			 [_incap, _player] remoteExecCall ["enableCollisionWith", 0, _incap];

			//these vars gotten again to prevent timing issues (such as change of medic during player medic animation
			_Lifeline_AssignedMedic = _incap getVariable ["Lifeline_AssignedMedic",[]];
			_Lifeline_AssignedMedic_AI = _Lifeline_AssignedMedic select 0; //this is the other AI medic already on its way. This needs to be cancelled.
			if (_Lifeline_AssignedMedic_AI isNotEqualTo []) then {
			};
			if (_incap getVariable ["ReviveInProgress",0] == 3) then { 
				[[_incap], format ["%1|%2| PLAYERREVIVE [315]",name _incap,name _player]] remoteExec ["Lifeline_reset2", _incap];
			};
			if (_Lifeline_AssignedMedic_AI isNotEqualTo []) then {
				// if !(_Lifeline_AssignedMedic_AI getVariable ["Lifeline_reset_trig",false]) then { 
					// _Lifeline_AssignedMedic_AI setVariable ["Lifeline_reset_trig", true, true];  // to stop double reset.
				if (_Lifeline_AssignedMedic_AI getVariable ["ReviveInProgress",0] in [1,2]) then {
					[[_Lifeline_AssignedMedic_AI],format ["%1|%2| AssignedMedic_AI: %3 PLAYERREVIVE [322]",name _incap,name _player,name _Lifeline_AssignedMedic_AI]] remoteExec ["Lifeline_reset2", _Lifeline_AssignedMedic_AI];
				};
			};
		};	
	}; // end lifestate incap == "INCAPACITATED"

	// if (damage _incap <= 0.2) then {
	if (_bandages <= 0  || Lifeline_RevMethod == 1 ||  Lifeline_BandageLimit == 1) then { 

		// just in case another AI is reviving at same time, this will prevent double firing of wake up animation
		if (alive _incap && ((animationState _incap find "unconscious" == 0 && animationState _incap != "unconsciousrevivedefault" && animationState _incap != "unconsciousoutprone") || animationState _incap == "unconsciousrevivedefault")) then {
			[_incap, "unconsciousrevivedefault"] remoteExec ["SwitchMove", 0];
		};

		// Not sure if this is needed. 
		if (rating _player <0) then {_player addrating ((abs rating _player)+1)};

		//Incap Markers
		if !((_incap getVariable ["Lifeline_IncapMark",""]) == "") then {
			deleteMarker (_incap getVariable "Lifeline_IncapMark");
			_incap setVariable ["Lifeline_IncapMark","",true];
		};
		// _incap setVariable ["Lifeline_RevActionAdded",false,true];
		_incap setVariable ["Lifeline_Down",false,true];// for Revive Method 3
		_incap setVariable ["Lifeline_allowdeath",false,true];
		_incap setVariable ["Lifeline_bullethits",0,true];
		_incap setVariable ["Lifeline_canceltimer",false,true]; // if showing, cancel it.
		_incap setVariable ["Lifeline_countdown_start",false,true]; // if showing, cancel it.
		_incap doFollow leader _incap;		
		_incap setDamage 0;
		_incap setVariable ["ReviveInProgress",0,true]; //added
		// Lifeline_Process = Lifeline_Process - [_incap]; // TEMPUNCOMMENT
		// publicVariable "Lifeline_Process";// TEMPUNCOMMENT

		_actionId = _incap getVariable "Lifeline_ActionMenuWounds";
		if (!isNil "_actionId") then {
		// if (!isNil "_actionId" && Lifeline_BandageLimit > 1) then {
				[[_incap,_actionId],{params ["_incap","_actionId"];_incap setUserActionText [_actionId, ""];}] remoteExec ["call", 0, true];
		};
		// Remove yellow marker
		if (Lifeline_Revive_debug) then {
			_incap call Lifeline_delYelMark;
		};
	};	

	Lifeline_Process = Lifeline_Process - [_player]; 
	publicVariable "Lifeline_Process"; 

	// _player allowDamage true;

	//regain control of group.
	[(group _player), _player] remoteExec ["selectLeader", _player];
	{
		if (alive _player && !(lifestate _player == "incapacitated")) then {		
			[(group _player), _player] remoteExec ["selectLeader", _player];
			_teamcolour = assignedTeam _x; // team colour deleted with JoinSilent. This fixes.
			[_x] joinSilent group _player;
			_x assignTeam _teamcolour;		// team colour deleted with JoinSilent. This fixes.
		};
	} foreach units group _player;

	[_player,_incap,_captive] spawn {
		params ["_player","_incap","_captive"];	
		_player setVariable ["Lifeline_Captive_Delay",true,true];
		sleep 5;
		if (_player getVariable ["ReviveInProgress",0] != 2) then { 
		// _player allowdamage true; 
		// _player setCaptive false; 
		[_player, true] remoteExec ["allowDamage",0]; 
		// [_player, false] remoteExec ["setCaptive",_player];	 
		[_player, _captive] remoteExec ["setCaptive",0];	 
		_player setVariable ["Lifeline_Captive_Delay",false,true];
		};
	};

	//split Lifeline_Process up now

	Lifeline_Process = Lifeline_Process - [_player]; 
	publicVariable "Lifeline_Process"; 
	// new text system for proc pairs
	_Lifeline_AssignedMedic = _incap getVariable ["Lifeline_AssignedMedic",[]];
	_Lifeline_AssignedMedic = _Lifeline_AssignedMedic - [_player];
	_incap setVariable ["Lifeline_AssignedMedic", _Lifeline_AssignedMedic, true];	

	_player setVariable ["ReviveInProgress",0,true]; 
	// _player removeEventHandler ["AnimDone", _animdoneID];
	// _player removeEventHandler ["AnimStateChanged", _AnimStateChangedID];

