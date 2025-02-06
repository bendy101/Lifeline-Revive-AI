diag_log "                                                                                   		   	               '"; 
diag_log "                                                                                   			               '"; 
diag_log "============================================================================================================='";
diag_log "============================================================================================================='";
diag_log "========================================== Lifeline_ReviveEngine.sqf ==========================================='";
diag_log format ["========================================== %1     %2 ==========================================='", Lifeline_Version, Lifeline_Version_no];
diag_log "============================================================================================================='";

if (Lifeline_Voices == 1) then { Lifeline_UnitVoices = ["Adam", "Antoni", "Arnold", "Bill", "Callum", "Charlie", "Clyde", "Daniel", "Dave", "A006", "Alistair", "Allen", "Hugh", "Philemon","Bruce"]; };
if (Lifeline_Voices == 2) then { Lifeline_UnitVoices = ["A006", "Alistair", "Allen", "Bruce", "Charlie", "Daniel", "Dave", "Hugh", "Philemon"]; };
if (Lifeline_Voices == 3) then { Lifeline_UnitVoices = ["Adam", "Antoni", "Arnold", "Bill", "Callum", "Clyde"]; };

if (Lifeline_RevProtect == 1) then {dmg_trig=false; cptv_trig=true};
if (Lifeline_RevProtect == 2) then {dmg_trig=true; cptv_trig=true};
if (Lifeline_RevProtect == 3) then {dmg_trig=true; cptv_trig=true};//changed for antistasi

if (Lifeline_Revive_debug) then {
	[] call serverSide_MissionSettings;//just diaglogs
};

//this forces Lifeline_RevMethod to value of 3 if ACE is loaded. Double checked.
if (!isNil "oldAce") then {
	Lifeline_RevMethod = 3;
};

publicVariable "Lifeline_Scope";
Lifeline_incapacitated = [];
publicVariable "Lifeline_incapacitated";
Lifeline_Process = [];
publicVariable "Lifeline_Process";
Lifeline_medics = [];
Lifeline_LimitDist = 1000;
Lifeline_textsize = str 1.5;
Lifeline_players_autorev = [];
Lifeline_UnitVoices = Lifeline_UnitVoices call BIS_fnc_arrayShuffle;
Lifeline_UnitVoicesCount = count Lifeline_UnitVoices;
Lifeline_mascas = false;

// RadioPartA = ["_hangtight1","_greetA1","_greetA2","_greetA3","_greetB2","_greetB3","_hanginthere1","_staybuddy1"];
RadioPartA = ["_hangtight1"];
RadioPartB = ["_coming1","_comingtogetyou1","_onmyway1","_theresoon1"];

if (Lifeline_Revive_debug) then {{[_x, 100000] remoteExec ["addRating", _x]} foreach allplayers;};

// wait for players 
waitUntil {count (allPlayers - entities "HeadlessClient_F") >0};

_players = allPlayers - entities "HeadlessClient_F";
Lifeline_Side = side (_players select 0);

// if a teamswitch mission
if (BI_RespawnDetected in [4,5]) then {

	addMissionEventHandler ["TeamSwitch", {
		params ["_previousUnit", "_newUnit"];
		onTeamSwitch { 
		_previousUnit enableAI "TeamSwitch";
		};
		_newUnit addEventHandler ["Respawn", {
			params ["_unit", "_corpse"];
		}];
	}];

	//change font colour in teamswitch pop-up for incap units
	fnc_teamSwitch = { 
	  disableSerialization; 
	  params ["_type","_ctrlDispl"]; 
	  private _idc = ctrlIDC (_ctrlDispl select 0); 
	  private _selectedIndex = _ctrlDispl param [1]; 
	  _displ = findDisplay 632; 
	  _ctrl101 = _displ displayCtrl 101; 
	  _cnt = (lbsize 101) -1; 
	  for "_i" from 0 to _cnt do { 
		_selectedUnit = switchableUnits param [_i,objNull]; 
		_unit = vehicle _selectedUnit; 
		/* if (lifeState _unit == "incapacitated") then { 
		  //lbSetText [_idc,_i,"unconscious unit"]; 
		  //lbSetTooltip [_idc, _i, "unconscious unit"]; 
		  lbSetColor [_idc, _i,[1,0,0,1]];	// CHANGE COLOR HERE (R,G,B,A) 
		};  */
		if (_unit getVariable ["ReviveInProgress",0] == 0 && lifestate _unit == "INCAPACITATED") then {
			// lbSetColor [_idc, _i,[255,191,167,1]];	// CHANGE COLOR HERE (R,G,B,A) 
			lbSetColor [_idc, _i,[1,0,0,1]];	// CHANGE COLOR HERE (R,G,B,A) //RED
		};		
		if (_unit getVariable ["ReviveInProgress",0] == 3 && lifestate _unit == "INCAPACITATED") then {
			_medic = (_unit getVariable ["Lifeline_AssignedMedic", []]) select 0;
			if (_medic getVariable ["ReviveInProgress",0] == 1) then {
				// lbSetColor [_idc, _i,[0.98, 0.67, 0.23, 1]];	// CHANGE COLOR HERE (R,G,B,A) //ORANGE
				lbSetColor [_idc, _i,[0.996, 0.48, 0.48, 1]];	// CHANGE COLOR HERE (R,G,B,A) //LIGHT RED
			};			
			if (_medic getVariable ["ReviveInProgress",0] == 2) then {
				lbSetColor [_idc, _i,[0.98, 0.67, 0.23, 1]];	// CHANGE COLOR HERE (R,G,B,A) //ORANGE
				// lbSetColor [_idc, _i,[0.99, 0.84, 0.63, 1]];	// CHANGE COLOR HERE (R,G,B,A) //LIGHT ORANGE
			};
		};
		if (_unit getVariable ["ReviveInProgress",0] == 1) then {
		  lbSetColor [_idc, _i,[0.71, 1, 0.34, 1]];	// CHANGE COLOR HERE (R,G,B,A) // LIGHT GREEN
		}; 		
		if (_unit getVariable ["ReviveInProgress",0] == 2) then {
		  // lbSetColor [_idc, _i,[0.39, 1, 0.43, 1]];	// CHANGE COLOR HERE (R,G,B,A) // GREEN
		  lbSetColor [_idc, _i,[0.13, 0.76, 0.24, 1]];	// CHANGE COLOR HERE (R,G,B,A) // GREEN
		}; 
	  }; 
	  if (_type == 1) then {true}; 
	  //this turns of the button to switch into unit
	  /* if (lifeState (vehicle (switchableUnits param [_selectedIndex,objNull])) == "incapacitated") then { 
		(_displ displayCtrl 1) ctrlShow false 
	  } else { 
		(_displ displayCtrl 1) ctrlShow true 
	  }  */
	}; 

	[] spawn { 
	  while {true} do { 
		waituntil {sleep 0.2; !isnull findDisplay 632}; 
		(findDisplay 632 displayCtrl 101) ctrlAddEventHandler ["LBSelChanged", 
		  "[0,_this] call fnc_teamSwitch" 
		]; 
		(findDisplay 632 displayCtrl 101) ctrlsetEventHandler ["LBDblClick", 
		  "[1,_this] call fnc_teamSwitch" 
		]; 
		waitUntil {sleep 0.2; isNull findDisplay 632}; 
	  }; 
	};

}; // if (BI_RespawnDetected in [4,5]) then {

// === NON-ACE FUNCTIONS
if (Lifeline_RevMethod != 3) then {  
	[] execvm "Lifeline_Revive\scripts\non_ace\Lifeline_Functions.sqf";
}; 
// === ACE FUNCTIONS
if (Lifeline_RevMethod == 3) then {  
	[] execvm "Lifeline_Revive\scripts\ace\Lifeline_ACE_Functions.sqf";
}; 	

// Add data to all units in scope - Damage Handler for non-ace version and settings for both

if (isServer) then {

	Lifeline_All_Units = [];
	publicVariable "Lifeline_All_Units";
	Lifelinecompletedinit = 1; //just for the hint showing units initializing
	Lifelineunitscount_pre = 0;

	Lifeline_DH_update = {

		if (Lifelinecompletedinit > 1) then {	
			Lifelineunitscount_pre = (count Lifeline_All_Units);
		};

		// GROUP
		if (Lifeline_Scope == 1 && isDedicated) then {_groupsWPlayers = allGroups select {{isPlayer _x} count (units _x) > 0 }; Lifeline_All_Units = allunits select {(group _x) in _groupsWPlayers && simulationEnabled _x && rating _x > -2000}};
		if (Lifeline_Scope == 1 && !isDedicated) then {Lifeline_All_Units = allunits select {group _x == group player && simulationEnabled _x && rating _x > -2000}};

		// SIDE	
		if (Lifeline_Scope == 2) then {Lifeline_All_Units = allunits select {(side (group _x) == Lifeline_Side) && simulationEnabled _x && rating _x > -2000}};
		// if (Lifeline_Scope == 2) then {Lifeline_All_Units = allunits select {(side (group _x) == Lifeline_Side) && simulationEnabled _x && rating _x > -2000 && ((captive _x == false && _x getVariable ["ReviveInProgress",0] == 0) || (_x getVariable ["ReviveInProgress",0] in [1,2,3]))}};
		// if (Lifeline_Scope == 2) then {Lifeline_All_Units = allunits select {simulationEnabled _x && rating _x > -2000}}; // TEST FOR OPFOR

		// ALL PLAYABLE (SLOTS)
		if (Lifeline_Scope == 3) then {Lifeline_All_Units = allunits select {(side (group _x) == Lifeline_Side) && simulationEnabled _x  && (_x in playableUnits) && rating _x > -2000}};

		publicVariable "Lifeline_All_Units";
		waitUntil {count Lifeline_All_Units >0};
		Lifelineunitscount = (count Lifeline_All_Units); // added to indicate with a hint when all units are processed below	

		if (Lifelineunitscount != Lifelineunitscount_pre) then {
			Lifelinecompletedinit = Lifelineunitscount_pre + 1;
		};

		// Add needed settings to each unit.
		{
			if !(_x getVariable ["LifelineDHadded",false]) then {
					[format ["Lifeline Revive Units %1 of %2", Lifelinecompletedinit, Lifelineunitscount]] remoteExec ["hintsilent", allPlayers];
					Lifelinecompletedinit = Lifelinecompletedinit + 1;

					// add voice identifiers (the orignal voiceover artists name)	
					if ((teamSwitchEnabled == false && !(isPlayer _x)) || teamSwitchEnabled == true) then {
						_x setVariable ["Lifeline_Voice", Lifeline_UnitVoices select (Lifeline_UnitVoicesCount - 1), true];
							if (Lifeline_UnitVoicesCount == 0) then {
							Lifeline_UnitVoicesCount = count Lifeline_UnitVoices;
							};
						Lifeline_UnitVoicesCount = Lifeline_UnitVoicesCount - 1;
					};				

				//set skill for your AI Units	
				if (Lifeline_AI_skill > 0) then {
					_x setSkill Lifeline_AI_skill;
				};

				//set Fatigue for all units. Bypass if 0
				if (Lifeline_Fatigue > 0) then {
					if (Lifeline_Fatigue == 2) then {
						if (local _x) then {_x enableFatigue false;} else {[_x, false] remoteExec ["enableFatigue", _x];};
					} else {
						if (local _x) then {_x enableFatigue true;} else {[_x, true] remoteExec ["enableFatigue", _x];};
					};				
				};

				//make units "explosivespecialists" trait. Its annoying not being able to unset a bomb when accidently set. 
				if (Lifeline_ExplSpec) then {
					if (local _x) then {
						_x setUnitTrait ["ExplosiveSpecialist", true];
					} else {
						[_x, ["ExplosiveSpecialist", true]] remoteExec ["setUnitTrait", _x]}
				};

				if (Lifeline_RevMethod == 2) then { 
					_x setVariable ["Lifeline_allowdeath",false,true];
				};

				// add Damage Handler for non-ace version
				if (Lifeline_RevMethod == 2) then {  
					[_x] execvm "Lifeline_Revive\scripts\non_ace\Lifeline_DamageHandler.sqf";
				}; 

				// add groups 
				if ((_x getVariable ["Lifeline_Grp",""]) == "") then {
					_goup = group _x;
					_x setVariable ["Lifeline_Grp", _goup, true];
					_x setVariable ["LifelinePairTimeOut",0,true];
				};

				// Add vehicle to Lifeline_All_Units
				if !(assignedvehicle _x isEqualTo (_x getVariable ["AssignedVeh", objNull])) then {
					_vehicle = assignedvehicle _x;
					_x setVariable ["AssignedVeh", _vehicle, true];
				};

				// add death event handler for debugging
				if (Lifeline_Revive_debug) then {
					_x addMPEventHandler ["MPKilled", {
							params ["_unit", "_killer", "_instigator", "_useEffects"];	
								if (Lifeline_RevProtect == 1) then {
									if (Lifeline_debug_soundalert) then {["siren1"] remoteExec ["playSound",2];[selectRandom["memberdied1","memberdied2","memberdied3","memberdied4","memberdied5"]] remoteExec ["playSound",2];};
								};
								if (isNull (findDisplay 49)) then {
									[_unit,"KILLED"] remoteExec ["serverSide_unitstate", 2];
									["KILLED"] remoteExec ["serverSide_Globals", 2]
								};
					}];
				};

				// set "added" trigger 
				_x setVariable ["LifelineDHadded",true,true];

				sleep 0.5;

			}; // end (_x getVariable ["LifelineDHadded",false]

		} foreach Lifeline_All_Units;

		publicVariable "Lifeline_All_Units";

		Lifeline_All_Units

	}; // end Lifeline_DH_update

	[] call Lifeline_DH_update; 

}; // end isserver

//=================================================================================================================
//============================== LOOPS ============================================================================
//=================================================================================================================

if (isServer) then {
	[] spawn {
		while {true} do {
			_alldown = true;
			_autorevive = false;
			_crouchtrig = false;
			_incappos = nil;

			{
				if (Lifeline_Idle_Crouch) then {
					_crouchtrig = _x getVariable ["Lifeline_crouchtrig",false];
				};
				//check if bleeding. both for ACE and non-ACE
				_isbleeding = false;
				if (Lifeline_RevMethod == 3) then {
					_isbleeding = [_x] call ace_medical_blood_fnc_isBleeding;
				} else {
					if (damage _x >=0.2 || _x getHitPointDamage "hitlegs" >= 0.5) then { 
						_isbleeding = true;
					};
				};

				// Self heal for AI
				if (!isPlayer _x && !(lifestate _x == "INCAPACITATED") && alive _x && _isbleeding == true 
					&& _x getVariable ["Lifeline_selfheal_progss",false] == false
				) then {
					_x spawn Lifeline_SelfHeal;
				};

				// Add Player incap to incap array
				if (lifeState _x == "INCAPACITATED" &&  !(_x in Lifeline_incapacitated)) then {
					Lifeline_incapacitated pushBackUnique _x;
					publicVariable "Lifeline_incapacitated";
					/* if (_x in Lifeline_Process) then {
						Lifeline_Process = Lifeline_Process - [_x];
						publicVariable "Lifeline_Process";
					}; */
				};

				// Still in incap array - lifestate not incap = remove
				if (!(lifeState _x == "INCAPACITATED") && (_x in Lifeline_incapacitated)) then {
					Lifeline_incapacitated = Lifeline_incapacitated - [_x];
					publicVariable "Lifeline_incapacitated";
					Lifeline_Process = Lifeline_Process - [_x];
					publicVariable "Lifeline_Process";
				};

				// Clear processing if no incap
				if (count Lifeline_incapacitated == 0 && count Lifeline_Process >0) then {
					Lifeline_Process = [];
					publicVariable "Lifeline_Process";
				};

				// NON-ACE: These fixes are for when damage is applied but it hasnt gone through the damage event handler. (such as scripted damage)
				if (Lifeline_RevMethod == 2) then {
					if (Debug_unconsciouswithouthandler && lifestate _x == "INCAPACITATED" && alive _x && !(_x in Lifeline_incapacitated) && !(_x getVariable ["Lifeline_Down",false])) then {
						_damage = damage _x;
						diag_log format ["%1 | !!!!!!!!!!!!!! UNCONSC WITHOUT DAMAGE HANDLER !!!!!!!!!!!!!!!! TOTDMG %2'", name _x, _damage];
						if (Lifeline_Revive_debug) then {["unconsciouswithouthandler"] remoteExec ["playSound",2];
							if (Lifeline_hintsilent) then {hintsilent format ["%1 UNCONSC WITHOUT DAMAGE HANDLER", name _x]};
						};
							[_x,_damage,true] call Lifeline_Incapped; 
					};

					if (Debug_overtheshold && lifestate _x != "INCAPACITATED" && alive _x && damage _x > Lifeline_IncapThres && !(_x in Lifeline_incapacitated) && !(_x getVariable ["Lifeline_Down",false])) then {
						[_x] spawn {
							params ["_x"];
							// sleep 5;
							sleep 3;
							if (Debug_overtheshold && lifestate _x != "INCAPACITATED" && alive _x && damage _x > Lifeline_IncapThres && !(_x in Lifeline_incapacitated) && !(_x getVariable ["Lifeline_Down",false])) then {
								_damage = damage _x;
								diag_log format ["%1 | !!!!!!!!!!!!!! DAMAGE OVER THRESH WITHOUT HANDLER !!!!!!!!!!!!!!!! TOTDMG %2'", name _x, _damage];
								if (Lifeline_Revive_debug) then {
									if (Lifeline_debug_soundalert) then {["overtheshold"] remoteExec ["playSound",2]};
									if (Lifeline_hintsilent) then {hintsilent format ["%1 DAMAGE OVER THRESH WITHOUT HANDLER", name _x]};
								};
								[_x,_damage,true] call Lifeline_Incapped; 
							}; // if
						}; //spawn
					};
				};		

				//HEALED OUTSIDE SCRIPT - setUnconscious method:. this is to cover for 3rd party script healing - such as mission code or revived in debug console. It will reset whats needed.
				if (Debug_Lifeline_downequalstrue && lifestate _x != "INCAPACITATED" && alive _x && (_x in Lifeline_incapacitated || Lifeline_RevMethod == 2 && _x getVariable ["Lifeline_Down",false])) then {
						[_x] spawn {
						params ["_x"];
						sleep 5;
						if (Debug_Lifeline_downequalstrue && lifestate _x != "INCAPACITATED" && alive _x && (_x in Lifeline_incapacitated || Lifeline_RevMethod == 2 && _x getVariable ["Lifeline_Down",false])) then {
							diag_log format ["%1 | !!!!!!!!!!!!!! NOT DOWN, but Lifeline_Down = true (incincible) FIX !!!!!!!!!!!!!!!! TOTDMG %2'", name _x, damage _x];
							if (Lifeline_Revive_debug) then {
								if (Lifeline_debug_soundalert) then {["Lifeline_downequalstrue"] remoteExec ["playSound",2]};
								if (Lifeline_hintsilent) then {hintsilent format ["%1 NOT DOWN, but Lifeline_Down = true", name _x]};
							};
								_x setVariable ["Lifeline_Down",false,true];
								// _x allowDamage true; 
								// _x setCaptive false; 
								// [_x, true] remoteExec ["allowDamage",_x];
								// [_x, false] remoteExec ["setCaptive",_x];
								_captive = _x getVariable ["Lifeline_Captive", false];
								if !(local _x) then {
									[_x, true] remoteExec ["allowDamage",_x];
									// [_x, false] remoteExec ["setCaptive",_x];
									[_x, _captive] remoteExec ["setCaptive",_x];
								} else {
									_x allowDamage true; 
									// _x setCaptive false; 								
									_x setCaptive _captive; 								
								};
						}; // if
					}; //spawn
				};					

				//HEALED OUTSIDE SCRIPT - Damage = 0 method. Zeus healing, or 3rd party script healing. If damage = 0 but the unit is unconcious, then revive.
				if (Debug_Zeusorthirdparty && (lifestate _x == "INCAPACITATED" && damage _x == 0) && ((Lifeline_RevMethod == 2 && (_x getVariable ["Lifeline_Down",false])) || Lifeline_RevMethod == 1 )) then {
					[_x] spawn {
						params ["_x"];
						sleep 3;
						if (Debug_Zeusorthirdparty && (lifestate _x == "INCAPACITATED" && damage _x == 0) && ((Lifeline_RevMethod == 2 && (_x getVariable ["Lifeline_Down",false])) || Lifeline_RevMethod == 1 )) then {
								// var dump
								_diagtext = "ZEUS, CONSOLE or SCRIPT HEAL [2]"; 
								if (Lifeline_Revive_debug) then {if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;}};
							diag_log format ["%1!!!!!!!!!!!!! ZEUS, CONSOLE or 3RD PARTY SCRIPT HEAL !!!!!!!!!!!!!!!!!!'", name _x];
							if (Lifeline_Revive_debug) then {
								["Zeusorthirdparty"] remoteExec ["playSound",2];
								hintsilent format ["%1\n%2", name _x,_diagtext];
							};							
							[_x, false] remoteExec ["setUnconscious",_x];
							[_x, "unconsciousoutprone"] remoteExec ["SwitchMove", 0];
							_x setVariable ["LifelineBleedOutTime", 0, true];
							_x call Lifeline_reset_variables;
									if (_x getVariable ["ReviveInProgress",0] == 3) then {
									// if !(_x getVariable ["Lifeline_reset_trig",false]) then {
											// _x setVariable ["Lifeline_reset_trig", true, true];  // to stop double reset.			
										[[_x],"373"] call Lifeline_reset2;														
									};	
						}; // if ((
					}; //spawn
				};

				// this is a backup to force unit out of unconcious animation if unit is healthy / revived. Although this switchmove already executes when medic revives, some missions in the workshop have custom scripts to revive without the medic (e.g. radiation heal etc etc). So this is backup to prevent stuck in unconcious anim. 
				if (lifestate _x != "INCAPACITATED" && alive _x && ((animationState _x find "unconscious" == 0 && animationState _x != "unconsciousrevivedefault" && animationState _x != "unconsciousoutprone") || animationState _x == "unconsciousrevivedefault")) then {
						[_x] spawn {
						params ["_x"];
							sleep 5;
							if (lifestate _x != "INCAPACITATED" && alive _x && ((animationState _x find "unconscious" == 0 && animationState _x != "unconsciousrevivedefault" && animationState _x != "unconsciousoutprone") || animationState _x == "unconsciousrevivedefault")) then {
								[_x, "unconsciousoutprone"] remoteExec ["SwitchMove", 0];
							}; // if
						}; //spawn
				};	

				if (Lifeline_Map_mark) then {[_x] call Lifeline_Map};

				// ONLY ACE . Some missions have a script that inflicts vanilla damage that bypasses ACE medical, such as radiation. 
				// This means with ACE medical you cannot heal and are stuck limping.  This will give option to fix.
				/* 	if (Lifeline_RevMethod == 3 && isPlayer _x && (_x getHit "legs") >= 0.5 && !(_x in Lifeline_incapacitated)) then { 
					if  (!(_x getVariable ["fixdamagebug",false]) || count (actionIDs _x) == 0) then {
							_x setVariable ["fixdamagebug",true,true];
							_x addAction ["<t color='#00FF0A'>vanilla damage fix</t>", {params ["_x"]; _x setVariable ["fixdamagebug",nil,true]; _x setDamage 0; _x removeAction (_this select 2)}, nil, 1, false];
					};
				};	 */

				if (Lifeline_Revive_debug) then {				
					[_x] call Lifeline_debug_unit_states;
				}; 

				// ========================= CROUCH SCRIPT. MAKE UNIT CROUCH WHEN STANDING AND IDLE. MORE IMMERSIVE. (ONLY IN "AWARE" BEHAVIOUR MODE) ============================

				if (Lifeline_Idle_Crouch) then {
					if (speed _x <= Lifeline_Idle_Crouch_Speed && stance _x == "STAND" && _crouchtrig == false && behaviour _x == "AWARE" && _x getVariable ["ReviveInProgress",0] == 0) then {
						_crouchtrig = true; 
					   _x setUnitPos "MIDDLE";
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

				// ========================= HACK FIX ====================== 
				// these are hacks to fix variables that sometimes dont get set, due to network errors etc.

				if (Lifeline_Revive_debug == false) then {

					_captive = _x getVariable ["Lifeline_Captive", true];//changed to true for testing
					// if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
					if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
						// if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};
						// [_x,true] remoteExec ["setCaptive", _x]; 
						_x setCaptive true; 				
					};

					// if ((isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" &&  _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process) // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
					if ((isDamageAllowed _x == false || (captive _x == true && _captive == false)) && alive _x && lifestate _x != "INCAPACITATED" &&  _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process) // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
						&& (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)) then {
						[_x] spawn {
							params ["_x"];
							sleep 7;
							_captive = _x getVariable ["Lifeline_Captive", false];
							// if ((isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" && !(_x getVariable ["Lifeline_Down",false]) && _x getVariable ["ReviveInProgress",0] == 0 && (_x getVariable ["LifelineBleedOutTime",0]) == 0 && !(_x in Lifeline_Process)
							if ((isDamageAllowed _x == false || (captive _x == true && _captive == false)) && alive _x && lifestate _x != "INCAPACITATED" && !(_x getVariable ["Lifeline_Down",false]) && _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process)  // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
								&& (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)) then {
									// if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};									
									if !(local _x) then {
										[_x, true] remoteExec ["allowDamage",_x];
										// [_x, false] remoteExec ["setCaptive",_x];	
										[_x, _captive] remoteExec ["setCaptive",_x];	
									} else {
										_x allowDamage true;
										// _x setCaptive false;		
										_x setCaptive _captive;		
									};			
							};									
						};
					};					

					if (lifestate _x != "INCAPACITATED" && alive _x && (_x getVariable ["LifelineBleedOutTime",0]) != 0 && !(_x in Lifeline_Process)) then {
						[_x] spawn {
							params ["_x"];
							sleep 7;
							if (lifestate _x != "INCAPACITATED" && alive _x && (_x getVariable ["LifelineBleedOutTime",0]) != 0 && !(_x in Lifeline_Process) ) then {
								// if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};							
								_x setVariable ["LifelineBleedOutTime",0,true];									
							};
						};
					};	
					// Captive state not staying true when down. 				
					if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
						[_x] spawn {
								params ["_x"];
								sleep 5;
								if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
									//hackfix here...
									if (isDedicated) then {
									 [_x,true] remoteExec ["setCaptive", _x]; 
									};								
								};
						};
					};	
				}; // END if (Lifeline_Revive_debug == false) then {

				//========================= END Hack fixes ==================

				//========================== MASCAS =========================	

				//check if all units are incapacitated or dead for the hint text "MASCAS / MASCAL allunits are down"
				if (lifestate _x != "INCAPACITATED" && lifestate _x != "DEAD" && lifestate _x != "DEAD-RESPAWN" && lifestate _x != "DEAD-SWITCHING") then {
					_alldown = false;
				};	
				if (lifestate _x == "INCAPACITATED" && (_x getVariable ["Lifeline_autoRecover",false])) then {
					_autorevive = true;
					if (isPlayer _x) then {
						Lifeline_players_autorev pushBackUnique _x;
					};
				};	

			} foreach Lifeline_All_Units;

			// MASCAS Hint text for when all units are down.
			if (_alldown == false) then {
				Lifeline_mascastxt_trig = false;
				Lifeline_mascastxt_timer = 0;
				Lifeline_players_autorev = [];
				if (Lifeline_mascas == true) then {
					Lifeline_mascas = false;
				};
			};
			if (_alldown == true) then {
					Lifeline_mascas = true;
					_bottomtext = "all units down";
					_bottomtext2 = "all units down";
					//if one of units have luck of autorevive, after 60 seconds display message of hope....
					if (_autorevive == true) then {
						if (Lifeline_mascastxt_trig == false) then {
								Lifeline_mascastxt_timer = time + 60;
								Lifeline_mascastxt_trig = true;
							};
						if (time >= Lifeline_mascastxt_timer) then {					
						 _bottomtext = "SOME LUCK:<br />a unit will regain consciousness";
						 _bottomtext2 = "SOME LUCK:<br />you will regain consciousness";
						//_bottomtext = "luck: a unit will regain consciousness";
						//_bottomtext2 = "luck: you will regain consciousness";
						};
					};				
				//===METHOD FOR CALCULATING RIGHT ALIGN SENDING IN REMOTEEXEC TO BIS_fnc_dynamicText
				_colour = "EF5736"; 
				// _colour = "B61717"; 
					if (count allPlayers > count Lifeline_players_autorev) then {
						// [format ["<t align='right' size='%3' color='#%1'>MASCAS / MASCAL</t><br /><t align='right' size='%4' color='#%1'>%2</t>",_colour,_bottomtext, 0.7,0.5],((safeZoneW - 1) * 0.48),1.15,5,0,0,Lifelinetxt1Layer] remoteExec ["BIS_fnc_dynamicText",allPlayers - Lifeline_players_autorev]
						_textright = format ["<t align='right' size='%3' color='#%1'>MASCAS / MASCAL</t><br /><t align='right' size='%4' color='#%1'>%2</t>",_colour,_bottomtext, 0.7,0.5];
						[_textright,1.15,5] remoteExec ["Lifeline_display_textright2",allPlayers - Lifeline_players_autorev];
					};
					if (count Lifeline_players_autorev > 0) then {
						// [format ["<t align='right' size='%3' color='#%1'>MASCAS / MASCAL</t><br /><t align='right' size='%4' color='#%1'>%2</t>",_colour,_bottomtext2, 0.7,0.5],((safeZoneW - 1) * 0.48),1.15,5,0,0,Lifelinetxt1Layer] remoteExec ["BIS_fnc_dynamicText",Lifeline_players_autorev]
						_textright = format ["<t align='right' size='%3' color='#%1'>MASCAS / MASCAL</t><br /><t align='right' size='%4' color='#%1'>%2</t>",_colour,_bottomtext2, 0.7,0.5];
						[_textright,1.15,5] remoteExec ["Lifeline_display_textright2",Lifeline_players_autorev];
					};
				// };
			};

			sleep 2;
		}; // end while
	}; // end spawn

	//=== ACE ONLY, LIMIT BLEEDOUT FOR OPFOR WHEN PVE MISSION, IF MISSION NOT DESIGNED FOR ACE.
	/* Workshop missions often require certain number of enemies killed to 
	complete a task or trigger a script. If you have ACE loaded and 
	the mission is not designed for ACE, you have to wait sometimes ages 
	for enemies to bleedout before the task is triggered.
	This setting limits bleedout time for enemy with ACE medical.
	Set to zero to disable.
	If the mission is PVP, this is bypassed.*/
	if (Lifeline_RevMethod == 3) then {
		[] spawn { 
			while {Lifeline_ACE_OPFORlimitbleedtime != 0} do {  
				playerSide1 = side group player;//this needs to be updated for dedicated servers.
				// Filter allUnits to only include enemies
				if (Lifeline_ACE_CIVILIANlimitbleedtime == false) then {
					enemyUnitsJa = allUnits select {
						[playerSide1, side group _x] call BIS_fnc_sideIsEnemy
					};
				} else {
					enemyUnitsJa = allUnits select {
						[playerSide1, side group _x] call BIS_fnc_sideIsEnemy || side group _x == CIVILIAN 
					};
				};
				pve = true; 
				{  
					if (isPlayer _x) then {
						pve = false;
					};
					// Check if unit is incapacitated  
					if (lifeState _x == "INCAPACITATED" && pve == true) then {  
						[_x] spawn { 
							params ["_x"];
							// hint "trigger";
							sleep (random (Lifeline_ACE_OPFORlimitbleedtime - 60)); 
							// if (alive _x && lifeState _x == "INCAPACITATED") then {
							if (alive _x && lifeState _x == "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] != 3) then {
								[_x, "LifeLine Revive Timer", _x, _x] call ace_common_fnc_setDead;
							};
						};  
					};  
				} forEach enemyUnitsJa;  
				sleep 60;  
			}; 
		};
	};

	[] spawn {
		_freq = 1; //frequency counter. Some functions we want less frequent than others
		while {true} do {		

				_diag_text = "";

						// timer for bleedout or autorecover
						{	

							if (Lifeline_RevMethod != 3) then {

								if ((_x getVariable ["LifelineBleedOutTime",0])>0) then {

										_bleedout = ""; // this is just for diag_log
										// _bleedouttime = _x getVariable "LifelineBleedOutTime";
										_bleedouttime = (_x getVariable "LifelineBleedOutTime") + 1; // with extra second so happens on 0
										_autoRecover = _x getVariable ["Lifeline_autoRecover",false];	
										_bleedout_half = Lifeline_BleedOutTime / 2; //auto revover half way through bleedout.								

										if ((time > _bleedouttime && _autoRecover == false || time > (_bleedouttime - _bleedout_half) && _autoRecover == true ) && lifeState _x == "INCAPACITATED") then {
											// _autoRecover = _x getVariable "Lifeline_autoRecover";
											// DIES
											// if !(Lifeline_autoRecover) then {
											if (_autoRecover == false) then {
												_x setDamage 1; 
												if (Lifeline_Revive_debug && Lifeline_hintsilent) then {[format ["%1 bled out. Dead.", name _x]] remoteExec ["hintSilent",2]};
												if (Lifeline_Revive_debug && Lifeline_hintsilent) then {[selectRandom["diedbleedout1","diedbleedout2","diedbleedout3","diedbleedout4","diedbleedout5"]] remoteExec ["playSound",2]};
												diag_log format ["[0496] !!!!!!!!!!!! %1 BLED OUT !!!!!!!!!!!!!!'", name _x];
											} else {
											// AUTORECOVERS	
												// _x setUnconscious false;
												[_x, false] remoteExec ["setUnconscious",_x];
												_x setVariable ["Lifeline_Down",false,true];  		// for Revive Method 2

												if (isMultiplayer && isPlayer _x) then {
													["#rev", 1, _x] remoteExecCall ["BIS_fnc_reviveOnState", _x];																		
												};

												diag_log format ["%1 [0515] !!!!!!!!!!! AUTO RECOVER !!!!!!!!!!!!!!'", name _x];
												//remove wounds action ID
												if (Lifeline_RevMethod == 2) then {
													_actionId = _x getVariable "Lifeline_ActionMenuWounds"; 
													if (!isNil "_actionId") then {
															[[_x,_actionId],{params ["_unit","_actionId"];_unit setUserActionText [_actionId, ""];}] remoteExec ["call", 0, true];
													};
												};

												_captive = _x getVariable ["Lifeline_Captive", false];
												[_x, true] remoteExec ["allowDamage",_x]; //added 
												// [_x, false] remoteExec ["setCaptive",_x]; 
												[_x, _captive] remoteExec ["setCaptive",_x]; 
												//_x allowDamage true; //added 

												//added
												// _x setVariable ["Lifeline_Down",false,true];  		// for Revive Method 2
												_x setVariable ["Lifeline_allowdeath",false,true]; 	// for Revive Method 2
												_x setVariable ["Lifeline_bullethits",0,true];			// for Revive Method 2
												// _x setVariable ["Lifeline_autoRecover",false,true];
												// _x setdamage 0;
												_x setdamage 0.5; 
												[_x] remoteExec ["Lifeline_reset", _x]; 
												_x addItemToBackpack "Medikit";
												_x setVariable ["LifelinePairTimeOut", 0, true];
												_x setVariable ["LifelineBleedOutTime", 0, true];
												_x setVariable ["Lifeline_selfheal_progss",false,true];

												if (Lifeline_hintsilent && Lifeline_Revive_debug) then {[format ["%1\nRecovered,", name _x]] remoteExec ["hintSilent",2]};
												if (alive leader _x && lifestate leader _x != "incapacitated") then {
													[_x] joinsilent _x;
													_x doFollow leader group _x;
												};
												_bleedout = "AUTO RECOVER";
											};

											Lifeline_incapacitated = Lifeline_incapacitated - [_x];
											publicVariable "Lifeline_incapacitated";
											Lifeline_Process = Lifeline_Process - [_x];
											publicVariable "Lifeline_Process";

											if (Lifeline_Revive_debug) then {_x call Lifeline_delYelMark;
											};
											_x setVariable ["ReviveInProgress",0,true]; 
											_x setVariable ["Lifeline_AssignedMedic", [], true]; // added
										};
									// }; //if (Lifeline_RevMethod != 3) then {

								} else {
										if (lifeState _x == "INCAPACITATED") then {
											_BleedOut = (time + Lifeline_BleedOutTime); 
											if (Lifeline_RevMethod == 2 && _x getVariable ["LifelineBleedOutTime",0] == 0) then {
												_x setVariable ["LifelineBleedOutTime", _BleedOut, true];
											}; //adjusted for ace
											_Lifeline_Down = (_x getVariable ["Lifeline_Down",false]);
											_allowdeath = (_x getVariable ["Lifeline_allowdeath",false]);
											_bullethits = (_x getVariable ["Lifeline_bullethits",0]);
											_countdowntimer = (_x getVariable ["countdowntimer",false]);
											_ReviveInProgress = (_x getVariable ["ReviveInProgress",0]);
										};
								};
							}; // if (Lifeline_RevMethod != 3) then {	

							// list of incaps and medics in realtime on HUD
							if (Lifeline_HUD_names > 0) then {
								_diag_text = [_x,_diag_text] call Lifeline_incap_list_HUD;
							};

						} foreach Lifeline_incapacitated;

			[format ["<t align='right' size='0.4'>%1</t>",_diag_text],((safeZoneW - 1) * 0.48),-0.03,3,0,0,LifelinetxtdebugLayer1] spawn BIS_fnc_dynamicText;	

			//adds units to Lifeline_DH_update
			if (_freq == 1) then {
				[] call Lifeline_DH_update; 
				// allows proximity for revive when vehicles there
				Lifeline_deadVehicle = [];
				{if (damage _x == 1 && simulationEnabled _x && isTouchingGround _x) then {Lifeline_deadVehicle pushBackUnique _x}} forEach vehicles;
			};

			if (_freq == 3) then {_freq = 1} else {_freq = _freq +1};	

			sleep 2;

		}; // end while

	}; // end spawn - Update INCAPACITATED and Incap Time up - die or autorecover

}; // Isserver

// ===== FOR NON-HOSTING PLAYERS (hoster don't need this, already in a loop) 
// list of incaps and medics in realtime on HUD.
if (!isServer) then {	
	[] spawn {
		while {true} do {
			_diag_textp = "";
			if (Lifeline_HUD_names != 0) then {
				{
					_diag_textp = [_x,_diag_textp] call Lifeline_incap_list_HUD;
				} foreach Lifeline_incapacitated;			
				[format ["<t align='right' size='0.4'>%1</t>",_diag_textp],((safeZoneW - 1) * 0.48),-0.03,3,0,0,LifelinetxtdebugLayer3] spawn BIS_fnc_dynamicText;
			};
			sleep 2;
		}; 
	};
};

// ===== SELECTION LOOP ==============================================================

if (isServer) then {

	_unitbaby = "";
	if (isDedicated) then {
		_unitbaby == "DEDICATED"
	} else {
		_unitbaby == name player;
	};

	_diag_textbaby = format [">>>>>>>[0821]>>>>>>>>>>>>>>> Lifeline Revive initialized. HOST: %1 SCRIPT VERSION: %2 >>>>>>>>>>>>>>>>>>>>>>> ", _unitbaby, _version];
	[_diag_textbaby] remoteExec ["diag_log", 2];

	Lifeline_incaps2choose = [];
	Lifeline_medics2choose = [];

	["Lifeline Revive initialized"] remoteExec ["hintsilent", allplayers];

	while {true} do {

		scopeName "main";

		Lifeline_incaps2choose = [];
		Lifeline_medics2choose = [];
		Lifeline_healthy_units = [];
		Lifeline_medics = [];
		_incap = objNull;
		_medic = objNull;

		Lifeline_incaps2choose = Lifeline_incapacitated select {!(_x in Lifeline_Process) && (lifestate _x == "INCAPACITATED") && (rating _x > -2000)};

		if (count Lifeline_incaps2choose > 0 ) then {

			// ======================== SELECT INCAP UNIT ==========================
			_incap = (Lifeline_incaps2choose select 0);

			if (Lifeline_Revive_debug) then {[_incap,"SELECTED INCAP"] call serverSide_unitstate};
			// _incap setVariable ["ReviveInProgress",3,true]; // added
			moveOut _incap; //added, dunno why, but needed in this version

			// ======================== SELECT MEDIC UNIT ==========================
			Lifeline_healthy_units = Lifeline_All_Units - Lifeline_incapacitated;
			sleep 0.2;

			_AssignedMedic = (_incap getVariable ["Lifeline_AssignedMedic",[]]);
			// CONDITIONS FOR CHOOSING MEDIC:
			{
				if (
					!(side group _x == civilian) 
					&& !isPlayer _x 
					&& !(_x in Lifeline_Process) 
					&& ((_x distance _incap) < Lifeline_LimitDist) 
					&& !(currentWeapon _x == secondaryWeapon _x && currentWeapon _x != "") //make sure unit is not about to fire launcher. This comes first.
					&& !(((assignedTarget _x) isKindOf "Tank") && secondaryWeapon _x != "") //check unit did not get order to hunt tank
					&& !(((getAttackTarget _x) isKindOf "Tank") && secondaryWeapon _x != "") //check unit is not hunting a tank
					&& (_x getVariable ["ReviveInProgress",0]) == 0 
					&& _x getVariable ["Lifeline_AssignedMedic",[]] isEqualTo []
					&& (_x getVariable ["LifelinePairTimeOut", 0]) == 0
					&& (lifestate _x != "INCAPACITATED")
					&& _x getVariable ["Lifeline_ExitTravel", false] == false
					&& (side (group _x) == side (group _incap)) // TEST FOR OPFOR
				) then {
					Lifeline_medics2choose pushBackUnique _x;
				};
			} foreach Lifeline_healthy_units;
			_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_medics2choose; 

			_voice = "";

			if (alive _incap && count Lifeline_medics2choose >0) then {

				Lifeline_medics = [Lifeline_medics2choose, [], {_incap distance _x}, "ASCEND"] call BIS_fnc_sortBy;
				_arraynum = 0;
				_numMedics = count Lifeline_medics;
				_arraynum = [0]; // MAKE IT ALWAYS CLOSEST
				_medic = Lifeline_medics select (selectRandom _arraynum);
				sleep 0.2;

				if (Lifeline_Revive_debug) then {[_medic,"SELECTED MEDIC"] call serverSide_unitstate};

				_medic setVariable ["Lifeline_ExitTravel", false, true];

				sleep 0.5;				

				_voice = _medic getVariable "Lifeline_Voice";

			} else {
				_incap setVariable ["ReviveInProgress",0,true];
				_medic = objNull;
			};

			// medic leave vehicle
			if (alive _incap && alive _medic && !(isNull objectParent _medic) && isTouchingGround (vehicle _medic)) then {
				_vehicle = objectParent _medic;
				if (_medic distance2D _incap < 200) then {
					_medic setVariable ["AssignedVeh", _vehicle, true];
					unassignVehicle _medic;
					moveOut _medic;
					[_medic] allowGetIn false;
				} else {
					if (_vehicle isKindOf "car") exitWith {
						_pos = [_incap, 10, 20, 5, 0, 20, 0] call BIS_fnc_findSafePos;
						_vehicle domove _pos;
						// _medic setVariable ["Lifeline_ExitTravel", true, true];
						// breakTo "main";
					};
				};
			};

			// Medic group position
			if (alive _incap && alive _medic && count units group _medic ==1) then {
				if (_medic getVariable ["Lifeline_medicOrigPos",[]] isEqualTo []) then {
					_pos = (getPosATL _medic);
					_dir = (getdir _medic);
					_medic setVariable ["Lifeline_medicOrigPos", _pos, true];
					_medic setVariable ["Lifeline_medicOrigDir", _dir, true];
				};
			};

			// Dispatch medic
			if (alive _incap && alive _medic && !(_medic in Lifeline_Process) && !(_incap in Lifeline_Process)) then {

				_pairloopsetting = 25;
				// _pairloopsetting = 15;
				_dist = (_medic distance2D _incap);
				_pairloopsetting = _pairloopsetting + (_dist/4);
				_pairlooptimeout = (time + _pairloopsetting);
				_incap setVariable ["LifelinePairTimeOut", _pairlooptimeout, true]; 
				_medic setVariable ["LifelinePairTimeOut", _pairlooptimeout, true]; 

				//original version
				if (Lifeline_radio && _medic distance2D _incap > 55 && _medic getVariable ["Lifeline_ExitTravel", false] == false && _medic getVariable ["ReviveInProgress",0] != 0 && alive _medic && alive _incap && lifestate _medic != "INCAPACITATED"
					&& lifestate _incap == "INCAPACITATED"
				) then {
					[_incap,_voice,_medic] spawn {
						params ["_incap","_voice","_medic"];
						sleep 1;
						if (isPlayer _incap && _medic getVariable ["ReviveInProgress",0] != 0) then {
						[_incap, [_voice+"_hangtight1", 50, 1, true]] remoteExec ["say3D", _incap];
						};
					};
				};

				Lifeline_Process pushBackUnique _incap;
				Lifeline_Process pushBackUnique _medic;
				publicVariable "Lifeline_Process";
				_incap setVariable ["ReviveInProgress",3,true]; 
				_medic setVariable ["ReviveInProgress",1,true]; 
				// _medic setVariable ["Lifeline_reset_trig",false,true]; 
				_incap setVariable ["Lifeline_AssignedMedic", [_medic], true];				

				// Call Functions. Start revive travel and incap / medic pair monitoring loop
				[_medic, _incap] spawn Lifeline_PairLoop; 
				[_medic, _incap] spawn Lifeline_StartRevive; 

			}; // end if alive && !(_medic in Lifeline_Process) && !(_incap in Lifeline_Process)

		}; // end count Lifeline_incaps2choose >0 && count Lifeline_healthy_units >0

		sleep 3;

	}; // end while

}; // isserver

//=======================================================================================================================================
