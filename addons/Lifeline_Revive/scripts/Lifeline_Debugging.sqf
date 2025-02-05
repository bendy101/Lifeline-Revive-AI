diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "=========================================== Lifeline_Debugging.sqf ============================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 

// to individually turn off bug detectors
Debug_Lifeline_downequalstrue = true;	
Debug_unconsciouswithouthandler = true;
Debug_overtheshold = true;	
Debug_Zeusorthirdparty = true;	
Debug_invincible_or_captive = true;
Debug_LifelineBleedOutTime_not_zero = true;
Debug_reviveinprogresserror = true;
Debug_reviveinprogress1dmgfalse = true;

// if (isServer) then {group _medic setSpeedMode "LIMITED";

	serverSide_unitstate = {
		params ["_unit","_line"];
		diag_log format ["%2 | %1 !!!!!!!!SERV | ==================================================================================================='",_line, name _unit];
		diag_log format ["%2 | %1 !!!!!!!!SERV | dmg: %3 | state: %4 | dmg_allwd: %5 | Captive: %6 | Rating: %7 | GroupSpeed: %8'",_line, name _unit, damage _unit, lifestate _unit, isDamageAllowed _unit, captive _unit, rating _unit, speedMode (group _unit)];
		diag_log format ["%2 | %1 !!!!!!!!SERV | Unit Side: %3 | Group Side: %7 | Lifeline_Down: %4 | Lifeline_allowdeath: %5 | ReviveInProgress: %6'",_line, name _unit, side _unit, (_unit getVariable ["Lifeline_Down","NONE"]), (_unit getVariable ["Lifeline_allowdeath","NONE"]), (_unit getVariable ["ReviveInProgress",0]), side (group _unit)];
		diag_log format ["%2 | %1 !!!!!!!!SERV | Lifeline_All_Units: %3 | Lifeline_Process: %6 | Lifeline_incapacitated: %4 | Lifeline_medics: %5'",_line, name _unit, (_unit in Lifeline_All_Units), (_unit in Lifeline_incapacitated), (_unit in Lifeline_medics), (_unit in Lifeline_Process)];
		diag_log format ["%2 | %1 !!!!!!!!SERV | Lifeline_countdown_start: %3 | Lifeline_canceltimer: %4 | unitPos stance: %5'",_line, name _unit, (_unit getVariable ["Lifeline_countdown_start","NONE"]), (_unit getVariable ["Lifeline_canceltimer","NONE"]), UnitPos _unit];
		diag_log format ["%2 | %1 !!!!!!!!SERV | Lifeline_AssignedMedic:%4 | AnimationState:%3 | Lifeline_selfheal_progss:%5'",_line, name _unit, animationstate _unit, name (_unit getVariable ["Lifeline_AssignedMedic",[]] select 0), _unit getVariable ["Lifeline_selfheal_progss",false]];

		_bleedout = (_unit getVariable ["LifelineBleedOutTime",0]);
		_pairtime = (_unit getVariable ["LifelinePairTimeOut",0]);
		if (_bleedout != 0) then {_bleedout = _bleedout - time};
		if (_pairtime != 0) then {_pairtime = _pairtime - time};	
		diag_log format ["%2 | %1 !!!!!!!!SERV | Lifeline_reset_trig: %6 | AutoRevive: %3 | Bleedout %4 | Pair Time %5'",_line, name _unit, _unit getVariable ["Lifeline_autoRecover","NONE"],_bleedout,_pairtime,_unit getVariable ["Lifeline_reset_trig",false]];
		if (Lifeline_RevMethod == 2) then {
			diag_log format ["%2 | %1 !!!!!!!!SERV | unitwounds: %3'",_line, name _unit, _unit getVariable ["unitwounds","NONE"]];
			diag_log format ["%2 | %1 !!!!!!!!SERV | _actionId: %3 | num_bandages: %4'",_line, name _unit, _unit getVariable ["Lifeline_ActionMenuWounds","NONE"],_unit getVariable ["num_bandages","NONE"]];
		};
		_text1="";_text2="";_text3="";_text4="";_text5="";_text6="";_text7="";_text8="";_text9="";_text10="";_text11=""; 
		_text12="";_text13="";_text14="";_text15="";_text16="";_text17="";_text18=""; 
		_type = "AUTOTARGET"; 	if !(_unit checkAIFeature _type) then {_text1 = _type + " "}; 
		_type = "MOVE";			if !(_unit checkAIFeature _type) then {_text2 = _type + " "}; 
		_type = "TARGET";		if !(_unit checkAIFeature _type) then {_text3 = _type + " "}; 
		_type = "TEAMSWITCH";	if !(_unit checkAIFeature _type) then {_text4 = _type + " "}; 
		_type = "WEAPONAIM";  	if !(_unit checkAIFeature _type) then {_text5 = _type + " "}; 
		_type = "ANIM";   		if !(_unit checkAIFeature _type) then {_text6 = _type + " "}; 
		_type = "FSM";			if !(_unit checkAIFeature _type) then {_text7 = _type + " "}; 
		_type = "AIMINGERROR";  if !(_unit checkAIFeature _type) then {_text8 = _type + " "}; 
		_type = "SUPPRESSION";  if !(_unit checkAIFeature _type) then {_text9 = _type + " "}; 
		_type = "CHECKVISIBLE"; if !(_unit checkAIFeature _type) then {_text10 = _type + " "}; 
		_type = "AUTOCOMBAT";  	if !(_unit checkAIFeature _type) then {_text11 = _type + " "}; 
		_type = "COVER";   		if !(_unit checkAIFeature _type) then {_text12 = _type + " "}; 
		_type = "PATH";   		if !(_unit checkAIFeature _type) then {_text13 = _type + " "}; 
		_type = "MINEDETECTION";if !(_unit checkAIFeature _type) then {_text14 = _type + " "}; 
		_type = "LIGHTS";   	if !(_unit checkAIFeature _type) then {_text15 = _type + " "}; 
		_type = "NVG";			if !(_unit checkAIFeature _type) then {_text16 = _type + " "}; 
		_type = "RADIOPROTOCOL";if !(_unit checkAIFeature _type) then {_text17 = _type + " "}; 
		//_type = "FIREWEAPON";  if (_unit checkAIFeature _type) then {_text18 = _type + " "}; 
		_alltext = _text1+_text2+_text3+_text4+_text5+_text6+_text7+_text8+_text9+_text10+_text11+_text12+_text13+_text14+_text15+_text16+_text17+_text18;  
		diag_log format ["%2 | %1 !!!!!!!!SERV | Fleeing: %4 | Supprssion: %5 | moveToCompleted: %6 | Behaviour: %7 | CombatMode: %8 | AI feat missing: %3 '",_line, name _unit, _alltext, fleeing _unit, getSuppression _unit, moveToCompleted _unit, behaviour _unit, combatMode (group _unit)];
		diag_log format ["%2 | %1 !!!!!!!!SERV | ==================================================================================================='",_line, name _unit];
	};

	serverSide_Globals = {
		params ["_line"];
		diag_log format ["!!!!!!!!SERVGLOBAL %1 | ==================================================================================================='", _line];	
		_diag_array = ""; {_diag_array = _diag_array + name _x + ", "} foreach Lifeline_All_Units; diag_log format ["!!!!!!!!SERVGLOBAL %1 Lifeline_All_Units: %2'", _line, _diag_array];
		_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_incaps2choose; diag_log format ["!!!!!!!!SERVGLOBAL %1 Lifeline_incaps2choose: %2'", _line, _diag_array];
		_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_medics2choose; diag_log format ["!!!!!!!!SERVGLOBAL %1 Lifeline_medics2choose: %2'", _line, _diag_array];
		_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_healthy_units; diag_log format ["!!!!!!!!SERVGLOBAL %1 Lifeline_healthy_units: %2'", _line, _diag_array];
		_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_medics; diag_log format ["!!!!!!!!SERVGLOBAL %1 Lifeline_medics: %2'", _line, _diag_array];
		_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_incapacitated; diag_log format ["!!!!!!!!SERVGLOBAL %1 Lifeline_incapacitated: %2'", _line, _diag_array];
		_diag_array = ""; {_diag_array = _diag_array + name _x + ", " } foreach Lifeline_Process; diag_log format ["!!!!!!!!SERVGLOBAL %1 Lifeline_Process: %2'", _line, _diag_array];
		diag_log format ["!!!!!!!!SERVGLOBAL %1 | ==================================================================================================='", _line];
	};

	serverSide_MissionSettings = { 
		diag_log format ["!!!! Lifeline_Scope | %1 !!!!'", Lifeline_Scope];
		diag_log format ["!!!! Lifeline_RevProtect | %1 !!!!'", Lifeline_RevProtect];
		if (Lifeline_ACEcheck_ == false) then {
			diag_log format ["!!!! Lifeline_BandageLimit | %1 !!!!'", Lifeline_BandageLimit];
			diag_log format ["!!!! Lifeline_BleedOutTime | %1 !!!!'", Lifeline_BleedOutTime];
			diag_log format ["!!!! Lifeline_InstantDeath | %1 !!!!'", Lifeline_InstantDeath];
			diag_log format ["!!!! Lifeline_autoRecover | %1 !!!!'", Lifeline_autoRecover];
			diag_log format ["!!!! Lifeline_CPR_likelihood | %1 !!!!'", Lifeline_CPR_likelihood];
			diag_log format ["!!!! Lifeline_CPR_less_bleedouttime | %1 !!!!'", Lifeline_CPR_less_bleedouttime];
			diag_log format ["!!!! Lifeline_IncapThres | %1 !!!!'", Lifeline_IncapThres];
		};
		diag_log format ["!!!! Lifeline_SmokeColour | %1 !!!!'", Lifeline_SmokeColour];
		diag_log format ["!!!! Lifeline_radio | %1 !!!!'", Lifeline_radio];
		diag_log format ["!!!! Lifeline_MedicComments | %1 !!!!'", Lifeline_MedicComments];
		diag_log format ["!!!! Lifeline_Voices | %1 !!!!'", Lifeline_Voices];
		diag_log format ["!!!! Lifeline_HUD_distance | %1 !!!!'", Lifeline_HUD_distance];
		diag_log format ["!!!! Lifeline_HUD_medical | %1 !!!!'", Lifeline_HUD_medical];
		diag_log format ["!!!! Lifeline_HUD_names | %1 !!!!'", Lifeline_HUD_names];
		diag_log format ["!!!! Lifeline_Map_mark | %1 !!!!'", Lifeline_Map_mark];
		if (Lifeline_ACEcheck_ == true) then {
			diag_log format ["!!!! Lifeline_ACE_Bandage_Method | %1 !!!!'", Lifeline_ACE_Bandage_Method];
			diag_log format ["!!!! Lifeline_ACE_Blackout | %1 !!!!'", Lifeline_ACE_Blackout];
		};
		diag_log format ["!!!! Lifeline_Revive_debug | %1 !!!!'", Lifeline_Revive_debug];
		diag_log format ["!!!! Lifeline_ACE_Bandage_Method | %1 !!!!'", Lifeline_ACE_Bandage_Method];
		diag_log format ["!!!! Lifeline_Idle_Medic_Stop | %1 !!!!'", Lifeline_Idle_Medic_Stop];
		diag_log format ["!!!! Lifeline_RevMethod | %1 !!!!'", Lifeline_RevMethod];
	};
// };

//this function uses an audio vocal sample to alert of bug. Less annoying.
Lifeline_debug_unit_states = {
params ["_x"];

					if (alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 1 && (_x getVariable ["LifelinePairTimeOut",0]) == 0) then {
						diag_log format ["%1====== TEMP MINUS ========'", name _x];
						if (Lifeline_hintsilent) then {hintsilent format ["%1==TEMP MINUS=='", name _x]};
							playsound "beep_hi_1";
					};

					// if ((isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" && !(_x getVariable ["Lifeline_Down",false]) && _x getVariable ["ReviveInProgress",0] == 0 && (_x getVariable ["LifelineBleedOutTime",0]) == 0 && !(_x in Lifeline_Process)
					if (Debug_invincible_or_captive && (isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" &&  _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process) // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
						&& (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)
					) then {
						diag_log format ["%1 is invincible or captive uuuuuuuuuu BUG GATE uuuuuuuuuu ReviveInProgress:%2'", name _x, (_x getVariable ["ReviveInProgress",false])];
						[_x] spawn {
							params ["_x"];
							sleep 7;
							// if ((isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" && !(_x getVariable ["Lifeline_Down",false]) && _x getVariable ["ReviveInProgress",0] == 0 && (_x getVariable ["LifelineBleedOutTime",0]) == 0 && !(_x in Lifeline_Process)
							if (Debug_invincible_or_captive && (isDamageAllowed _x == false || captive _x == true) && alive _x && lifestate _x != "INCAPACITATED" && !(_x getVariable ["Lifeline_Down",false]) && _x getVariable ["ReviveInProgress",0] == 0 && !(_x in Lifeline_Process)  // deleted _x getVariable ["LifelineBleedOutTime",0] (unlike line above)
								&& (isNull findDisplay 60492) && (isNull findDisplay 47) && (isNull findDisplay 48) && (isNull findDisplay 50) && (isNull findDisplay 51) && (isNull findDisplay 58) && (isNull findDisplay 61) && (isNull findDisplay 312) && (isNull findDisplay 314)
								) then {			
								_txtj = ""; 
								if (isDamageAllowed _x == false) then {
									if (captive _x == false) then {_txtj = "DAMAGE = FALSE";} else {_txtj = "DAMAGE = FALSE & CAPTIVE = TRUE";};};
									if (isDamageAllowed _x == true && captive _x == true) then {_txtj = "CAPTIVE = TRUE";};
								diag_log format ["%1 is invincible or captive uuuuuuuuuu BUG uuuuuuuuuu  %2  ReviveInProgress:%3'", name _x, _txtj, (_x getVariable ["ReviveInProgress",false])];
								diag_log format ["%1 is invincible or captive uuuuuuuuuu BUG uuuuuuuuuu  %2  ReviveInProgress:%3'", name _x, _txtj, (_x getVariable ["ReviveInProgress",false])];
								diag_log format ["%1 is invincible or captive uuuuuuuuuu BUG uuuuuuuuuu  %2  ReviveInProgress:%3'", name _x, _txtj, (_x getVariable ["ReviveInProgress",false])];
								//var dump
								_diagtext = "BUG invincible or captive"; if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};

								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["invincible_or_captive"] remoteExec ["playSound",Debug_to];
								// = HACKFIX 
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
								if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};	
							};
						};
					};
					if (Debug_LifelineBleedOutTime_not_zero && Lifeline_RevMethod == 2 && lifestate _x != "INCAPACITATED" && alive _x && (_x getVariable ["LifelineBleedOutTime",0]) != 0 && !(_x in Lifeline_Process) 
					) then {
						diag_log format ["%1 LifelineBleedOutTime NOT ZERO uuuuuuuuuu BUG GATE uuuuuuuuuu damage:%2 captive:%3 LifelineBleedOutTime:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelineBleedOutTime",0])];
						Debug_LifelineBleedOutTime_not_zero = false;
						[_x] spawn {
							params ["_x"];
							sleep 7;
							Debug_LifelineBleedOutTime_not_zero = true;
							if (lifestate _x != "INCAPACITATED" && alive _x && (_x getVariable ["LifelineBleedOutTime",0]) != 0 && !(_x in Lifeline_Process) 
								) then {
								diag_log format ["%1 BleedOutTime NOT ZERO uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelineBleedOutTime:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelineBleedOutTime",0])];
								diag_log format ["%1 BleedOutTime NOT ZERO uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelineBleedOutTime:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelineBleedOutTime",0])];
								diag_log format ["%1 BleedOutTime NOT ZERO uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelineBleedOutTime:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelineBleedOutTime",0])];
								//var dump
								_diagtext = "BleedOutTime NOT ZERO"; if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};
								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["BleedOutTime_not_zero"] remoteExec ["playSound",Debug_to];
								// = HACKFIX 
								_x setVariable ["LifelineBleedOutTime",0,true];
								if (Lifeline_debug_soundalert) then {["hackfix"] remoteExec ["playSound",2]};	
							};
						};
					};	
					// this will create problems with selecting future medics 
					if (Debug_reviveinprogresserror && alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] != 0 && !(_x in Lifeline_Process)) then {
						diag_log format ["%1 ReviveInProgress ERROR. Not in Lifeline_Process uuuuuuuuuu BUG GATE uuuuuuuuuu damage:%2 captive:%3 LifelineBleedOutTime:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelineBleedOutTime",0])];
						[_x] spawn {
								params ["_x"];
								sleep 10;
								if (Debug_reviveinprogresserror && alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] != 0 && !(_x in Lifeline_Process)) then {
								diag_log format ["%1 ReviveInProgress ERROR. Not in Lifeline_Process uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelineBleedOutTime:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelineBleedOutTime",0])];
								diag_log format ["%1 ReviveInProgress ERROR. Not in Lifeline_Process uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelineBleedOutTime:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelineBleedOutTime",0])];
								diag_log format ["%1 ReviveInProgress ERROR. Not in Lifeline_Process uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelineBleedOutTime:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelineBleedOutTime",0])];
								_diagtext = "ReviveInProgress ERROR. Not in Lifeline_Process"; if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};
								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["reviveinprogresserror"] remoteExec ["playSound",Debug_to];
								};
						};
					};		
					if (alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 1 && ((_x getVariable ["LifelinePairTimeOut",0]) - time) < 0) then {
						diag_log format ["%1 REVIVE PAIR TIMELIMIT ERROR. ITS BELOW ZERO uuuuuuuuuu BUG GATE uuuuuuuuuu damage:%2 captive:%3 LifelinePairTimeOut:%4 '", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelinePairTimeOut",0])];
						[_x] spawn {
								params ["_x"];
								sleep 2;
								if (alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 1 && ((_x getVariable ["LifelinePairTimeOut",0]) - time) < 0) then {
								_secs = (_x getVariable ["LifelinePairTimeOut",0]) - time;
								diag_log format ["%1 REVIVE PAIR TIMELIMIT ERROR. ITS BELOW ZERO uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelinePairTimeOut:%4, secs: %5'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs];
								diag_log format ["%1 REVIVE PAIR TIMELIMIT ERROR. ITS BELOW ZERO uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelinePairTimeOut:%4, secs: %5'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs];
								diag_log format ["%1 REVIVE PAIR TIMELIMIT ERROR. ITS BELOW ZERO uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelinePairTimeOut:%4, secs: %5'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs];
								_diagtext = "REVIVE PAIR TIMELIMIT ERROR. ITS BELOW ZERO"; if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};
								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["revivetimeminus"] remoteExec ["playSound",Debug_to];
								};
						};
					};						
					if (alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 1 && _x getVariable ["LifelinePairTimeOut",0] == 0) then {
						diag_log format ["%1 ReviveInProgress STUCK AT 1 w  LifelinePairTimeOut ZERO uuuuuuuuuu BUG GATE uuuuuuuuuu LifelinePairTimeOut:%2, ReviveInProgress %3'", name _x, (_x getVariable ["LifelinePairTimeOut",0]), (_x getVariable ["ReviveInProgress",0])];
						[_x] spawn {
								params ["_x"];
								sleep 2;
								if (alive _x && lifestate _x != "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 1 && _x getVariable ["LifelinePairTimeOut",0] == 0) then {
								_secs = (_x getVariable ["LifelinePairTimeOut",0]) - time;
								diag_log format ["%1 ReviveInProgress STUCK AT 1 w  LifelinePairTimeOut ZERO uuuuuuuuuu BUG uuuuuuuuuu LifelinePairTimeOut:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs, (_x getVariable ["ReviveInProgress",0])];
								diag_log format ["%1 ReviveInProgress STUCK AT 1 w  LifelinePairTimeOut ZERO uuuuuuuuuu BUG uuuuuuuuuu LifelinePairTimeOut:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs, (_x getVariable ["ReviveInProgress",0])];
								diag_log format ["%1 ReviveInProgress STUCK AT 1 w  LifelinePairTimeOut ZERO uuuuuuuuuu BUG uuuuuuuuuu LifelinePairTimeOut:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs, (_x getVariable ["ReviveInProgress",0])];
								_diagtext = "ReviveInProgress STUCK AT 1 w LifelinePairTimeOut ZERO "; if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};
								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["revivetimeminus"] remoteExec ["playSound",Debug_to];
								};
						};
					};	
					//stuck, can't be chosen by medic					
					if (alive _x && _x getVariable ["ReviveInProgress",0] == 0 && _x in Lifeline_Process)  then {
						diag_log format ["%1 UNIT in Lifeline_Process & ReviveInProgress = 0 uuuuuuuuuu BUG GATE uuuuuuuuuu damage:%2 captive:%3 LifelinePairTimeOut:%4'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelinePairTimeOut",0])];
						[_x] spawn {
								params ["_x"];
								sleep 5;
								if (alive _x && _x getVariable ["ReviveInProgress",0] == 0 && _x in Lifeline_Process)  then {
								_secs = (_x getVariable ["LifelinePairTimeOut",0]) - time;
								diag_log format ["%1 UNIT in Lifeline_Process & ReviveInProgress = 0 uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelinePairTimeOut:%4, secs: %5'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs];
								diag_log format ["%1 UNIT in Lifeline_Process & ReviveInProgress = 0 uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelinePairTimeOut:%4, secs: %5'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs];
								diag_log format ["%1 UNIT in Lifeline_Process & ReviveInProgress = 0 uuuuuuuuuu BUG uuuuuuuuuu damage:%2 captive:%3 LifelinePairTimeOut:%4, secs: %5'", name _x, isDamageAllowed _x, captive _x, (_x getVariable ["LifelinePairTimeOut",0]), _secs];
								_diagtext = "UNIT in Lifeline_Process & ReviveInProgress = 0"; if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};
								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["siren1"] remoteExec ["playSound",Debug_to];
								};
						};
					};		
					//assigned medic missing and ReviveInProgress = 3 				
					if (alive _x && lifestate _x == "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 3 && _x in Lifeline_Process && (_x getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo [])  then {
						diag_log format ["%1 MISSING AssignedMedic & ReviveInProgress=3 uuuuuuuuuu BUG GATE uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %3'", name _x, (_x getVariable ["AssignedMedic",[]]),(_x getVariable ["ReviveInProgress",0])];
						[_x] spawn {
								params ["_x"];
								sleep 5;
								if (alive _x && lifestate _x == "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 3 && _x in Lifeline_Process && (_x getVariable ["Lifeline_AssignedMedic",[]]) isEqualTo [])  then {
								_secs = (_x getVariable ["LifelinePairTimeOut",0]) - time;
								diag_log format ["%1 MISSING AssignedMedic & ReviveInProgress=3 uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["AssignedMedic",[]]), _secs, (_x getVariable ["ReviveInProgress",0])];
								diag_log format ["%1 MISSING AssignedMedic & ReviveInProgress=3 uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["AssignedMedic",[]]), _secs, (_x getVariable ["ReviveInProgress",0])];
								diag_log format ["%1 MISSING AssignedMedic & ReviveInProgress=3 uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["AssignedMedic",[]]), _secs, (_x getVariable ["ReviveInProgress",0])];
								_diagtext = "MISSING AssignedMedic & ReviveInProgress=3"; if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};
								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["siren1"] remoteExec ["playSound",Debug_to];
								};
						};
					};		
					// AssignedMedic has LifelinePairTimeOut=0 				
					if (alive _x && lifestate _x == "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 3 && _x in Lifeline_Process 
					&& ((_x getVariable ["Lifeline_AssignedMedic",[]] select 0) getVariable ["LifelinePairTimeOut",0] == 0 || lifestate (_x getVariable ["Lifeline_AssignedMedic",[]] select 0) == "INCAPACITATED")) then {
					diag_log format ["%1 AssignedMedic has LifelinePairTimeOut=0 uuuuuuuuuu BUG GATE uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %3'", name _x, (_x getVariable ["Lifeline_AssignedMedic",[]] select 0), (_x getVariable ["ReviveInProgress",0])];
						[_x] spawn {
								params ["_x"];
								sleep 5;
								if (alive _x && lifestate _x == "INCAPACITATED" && _x getVariable ["ReviveInProgress",0] == 3 && _x in Lifeline_Process 
								&& ((_x getVariable ["Lifeline_AssignedMedic",[]] select 0) getVariable ["LifelinePairTimeOut",0] == 0 || lifestate (_x getVariable ["Lifeline_AssignedMedic",[]] select 0) == "INCAPACITATED")) then {
								_secs = (_x getVariable ["LifelinePairTimeOut",0]) - time;
								diag_log format ["%1 AssignedMedic has LifelinePairTimeOut=0 uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["Lifeline_AssignedMedic",[]] select 0), _secs, (_x getVariable ["ReviveInProgress",0])];
								diag_log format ["%1 AssignedMedic has LifelinePairTimeOut=0 uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["Lifeline_AssignedMedic",[]] select 0), _secs, (_x getVariable ["ReviveInProgress",0])];
								diag_log format ["%1 AssignedMedic has LifelinePairTimeOut=0 uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["Lifeline_AssignedMedic",[]] select 0), _secs, (_x getVariable ["ReviveInProgress",0])];
								_diagtext = "AssignedMedic has LifelinePairTimeOut=0"; if !(local _x) then {[_x,_diagtext] remoteExec ["serverSide_unitstate", 2];[_diagtext] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};
								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["siren1"] remoteExec ["playSound",Debug_to];
								};
						};
					};						
					// Captive state not staying true when down. 				
					if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
					diag_log format ["%1 Captive turned off when down uuuuuuuuuu BUG GATE uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %3'", name _x, (_x getVariable ["Lifeline_AssignedMedic",[]] select 0), (_x getVariable ["ReviveInProgress",0])];
						[_x] spawn {
								params ["_x"];
								sleep 5;
								if (alive _x && lifestate _x == "INCAPACITATED" && captive _x == false && Lifeline_RevProtect != 3) then {
								//hackfix here...
								if (isDedicated) then {
								 [_x,true] remoteExec ["setCaptive", _x]; 
								};
								_secs = (_x getVariable ["LifelinePairTimeOut",0]) - time;
								diag_log format ["%1 Captive turned off when down uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["Lifeline_AssignedMedic",[]] select 0), _secs, (_x getVariable ["ReviveInProgress",0])];
								diag_log format ["%1 Captive turned off when down uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["Lifeline_AssignedMedic",[]] select 0), _secs, (_x getVariable ["ReviveInProgress",0])];
								diag_log format ["%1 Captive turned off when down uuuuuuuuuu BUG uuuuuuuuuu AssignedMedic:%2, ReviveInProgress %4, secs: %3'", name _x, (_x getVariable ["Lifeline_AssignedMedic",[]] select 0), _secs, (_x getVariable ["ReviveInProgress",0])];
								_diagtext = "Captive turned off when down"; if !(local _x) then {[_x,_diagtext+" remoteexec"] remoteExec ["serverSide_unitstate", 2];[_diagtext+" remoteexec"] remoteExec ["serverSide_Globals", 2];
								} else {[_x,_diagtext] call serverSide_unitstate;[_diagtext] call serverSide_Globals;};
								if (Lifeline_hintsilent) then {hintsilent format ["BUG %1\n%2", name _x,_diagtext]};
								["siren1"] remoteExec ["playSound",Debug_to];
								};
						};
					};	
};

LifelineSpeedMarker = {
	params ["_medic","_line"];
	if (speed _medic < 0.1) then {
		_largecyanmark = _medic getVariable ["cyanmarker1", nil]; 
		if (!isNil "_largecyanmark") then {deleteVehicle _largecyanmark};				
		_largecyanmark = createVehicle ["Sign_Arrow_Large_Cyan_F", getPos _medic,[],0,"can_collide"];
		_medic setVariable ["cyanmarker1", _largecyanmark, true]; 
	};
};

// TEMP
/* [] spawn {
sleep 5;
	while {true} do {
		{
		if (lifestate _x == "INCAPACITATED" && captive _x == false) then {
		};
	} foreach Lifeline_All_Units;
	sleep 0.1;
	};
}; */