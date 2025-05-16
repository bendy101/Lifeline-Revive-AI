diag_log "                                                                                                '"; 
diag_log "                                                                                                '"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 
diag_log "========================================= Lifeline_Functions.sqf ==============================================='"; 
diag_log "============================================================================================================='"; 
diag_log "============================================================================================================='"; 

//================================================================================
//==== WHEN UNIT INCAPACITATED

Lifeline_Incapped = {
	params ["_unit","_damage","_non_handler"];
	// _non_handler is a boolean. if true it means incapped function was called NOT through the damage handler.

	_unit setUnconscious true; //MOVED TO TOP OF FUNCTION
	[_unit, true] remoteExec ["setUnconscious",0]; //MOVED TO TOP OF FUNCTION

	// store captive status (for missions with 'undercover' mode). Only if unit is not a medic at ReviveInProgress = 1 or 2 because it will be captive already
	if (_unit getVariable ["ReviveInProgress",0] == 0 && _unit getVariable ["Lifeline_RevProtect",0] != 3 && !(_unit getVariable ["Lifeline_Captive_Delay",false])) then { 
		_unit setVariable ["Lifeline_Captive",(captive _unit),true]; //2025
	};
	// _unit setCaptive true;
	[_unit, true] remoteExec ["setCaptive", 0];	

	Lifeline_incapacitated pushBackUnique _unit;
	publicVariable "Lifeline_incapacitated";

	_unit spawn {
		params ["_unit"];
		moveOut _unit;
		[_unit, "UnconsciousReviveArms_A"] remoteExec ["PlayMoveNow", 0];
		[_unit, "Unconscious"] remoteExec ["PlayMove", 0];
	};

	_randanim = [];

	//bleedout time added here, for latest version
	_BleedOut = (time + Lifeline_BleedOutTime); 
	// [_unit] call Lifeline_autoRecover_check; //roll the dice to see if autorevive should be set to 'true'.

	_unit setVariable ["LifelineBleedOutTime", _BleedOut, true]; 
	_unit setVariable ["Lifeline_Down",true,true];
	// _unit setUnconscious true; //MOVED TO TOP OF FUNCTION
	// [_unit, true] remoteExec ["setUnconscious",0]; //MOVED TO TOP OF FUNCTION
	_unit setVariable ["Lifeline_selfheal_progss",false,true]; //clear var if it was in middle of self healing
	// Lifeline_incapacitated pushBackUnique _unit;
	// publicVariable "Lifeline_incapacitated";

	if (count units group _unit ==1) then {
		if (_unit getVariable ["Lifeline_OrigPos",[]] isEqualTo []) then {
			_pos = (getPosATL _unit);
			_dir = (getdir _unit);
			_unit setVariable ["Lifeline_OrigPos", _pos, true];
			_unit setVariable ["Lifeline_OrigDir", _dir, true];
		};
	};	

		// ONLY FOR either addAction if first time, or setUserActionText if already exist.
		if (Lifeline_BandageLimit == 1) then {	
			_colour = "F69994";	// skin colour
			_text = "REVIVE";		
			if !(_unit getVariable ["Lifeline_RevActionAdded",false]) then { 
				_unit setVariable ["Lifeline_RevActionAdded",true,true];
				[[_unit,_colour,_text],
					{
					params ["_unit","_colour","_text"];
					   _actionId = _unit addAction [format ["<t size='%3' color='#%1'>%2</t>",_colour,_text,1.7],{params ["_target", "_caller", "_actionId", "_arguments"]; [_caller,_actionId] execVM "Lifeline_Revive\scripts\Lifeline_PlayerRevive.sqf" ; },[],8,true,true,"","_target == cursorObject && _this distance cursorObject < 2.2 && lifeState cursorObject == 'INCAPACITATED' && animationstate _this find 'medic' ==-1"];
						_unit setVariable ["Lifeline_ActionMenuWounds",_actionId,true];
				}] remoteExec ["call", 0, true];		
			} else {				
				[[_unit,_colour,_text],
					{
					params ["_unit","_colour","_text"];
					_actionId = _unit getVariable ["Lifeline_ActionMenuWounds",false];
					_colour = "F69994";	// skin colour
					_text = "REVIVE";
					_unit setUserActionText [_actionId, format ["<t size='%3' color='#%1'>%2</t>",_colour,_text,1.7]];
				}] remoteExec ["call", 0, true];
			};	
			[_unit] call Lifeline_autoRecover_check; //roll the dice to see if autorevive should be set to 'true'.

			// moved here, start countdown display, or distance medic.
			if ((Lifeline_HUD_distance == true || Lifeline_cntdwn_disply != 0) && isPlayer _unit) then {
				_seconds = Lifeline_cntdwn_disply;
				// if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false]) && Lifeline_cntdwn_disply != 0 && Lifeline_RevMethod != 3 && Lifeline_HUD_distance == false) then {
				// 	_unit setVariable ["Lifeline_countdown_start",true,true];
				// 	[[_unit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_unit, true];
				// }; 
				if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false])) then {
					_unit setVariable ["Lifeline_countdown_start",true,true];
					[[_unit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_unit, true];
				};
			};	
		}; // end if (Lifeline_BandageLimit == 1) then {	

	// 5 second delay to calculate more damage after initial incapacitation, sometimes miliseconds and volley of bullets or fragments
	[_unit, _damage, _non_handler] spawn {
		params ["_unit","_damage", "_non_handler"];	
		sleep 5; 	

		_randanim = "";

		//=== unconcious anim if Bandage Range is only 1
		if (Lifeline_BandageLimit == 1) then {
			_randanim = selectRandom["Default_A", "Default_B", "Default_C", "Head_A", "Head_B", "Head_C", "Body_A", "Body_B", "Arms_A", "Arms_B", "Arms_C", "Legs_A", "Legs_B"];
			_randanim = "UnconsciousRevive" + _randanim;			
			[_unit, _randanim] remoteExec ["PlayMoveNow", 0];
			[_unit, "UnconsciousFaceUp"] remoteExec ["PlayMove", 0];			
		};		

		//== unconcious anim if Bandage Range is multiple
		if (Lifeline_BandageLimit > 1) then {

			[_unit] call Lifeline_autoRecover_check; //roll the dice to see if autorevive should be set to 'true'.

			//call function to calculate bandages needed according to damage			
			[_unit,_non_handler] call Lifeline_bandage_addAction; 	

			_quadstored = _unit getVariable ["quadstored",false];
			

			_unitwounds = _unit getVariable "unitwounds";
			_bandges = count(_unitwounds);
			_firstwound = _unitwounds select (_bandges -1) select 0;
			

			if (_quadstored <=2) then {
				//anim by most damaged body part
				if ((_firstwound find "Head:") == 0) then {_randanim = selectRandom["UnconsciousReviveHead_A", "UnconsciousReviveHead_B", "UnconsciousReviveHead_C"];};
				if ((_firstwound find "Torso:") == 0) then {_randanim = selectRandom["UnconsciousReviveBody_A", "UnconsciousReviveBody_B"];};
				if ((_firstwound find "Arm:") == 0) then {_randanim = selectRandom["UnconsciousReviveArms_A", "UnconsciousReviveArms_B", "UnconsciousReviveArms_C"];};
				if ((_firstwound find "Leg:") == 0) then {_randanim = selectRandom["UnconsciousReviveLegs_A", "UnconsciousReviveLegs_B"];};								
			} else {
				if ((_firstwound find "CRITICAL") == 0) then {
					_randanim = "UnconsciousReviveDefault_Base";
				} else {
					_randanim = selectRandom["UnconsciousReviveDefault","UnconsciousReviveDefault_A", "UnconsciousReviveDefault_B", "UnconsciousReviveDefault_C"];
				};
			};
		};

		[_unit, _randanim] remoteExec ["PlayMoveNow", 0];							//HERE
		[_unit, "UnconsciousFaceUp"] remoteExec ["PlayMove", 0];
		// added for protection after incap. 

		// new updated 
		_dmg_trig = dmg_trig;
		_opfor_not_pvp = false;
		// if its only PVE and not PVP, and OPFOR is included, then turn off indestructible for OPFOR while reviving.
		if (Lifeline_Include_OPFOR && Lifeline_PVPstatus == false && ((side group _unit) in Lifeline_OPFOR_Sides)) then {
			_dmg_trig = true;
			_opfor_not_pvp = true;
		};

		diag_log format ["%1 | Lifeline_Include_OPFOR %2 Lifeline_PVPstatus %3 Right Side? %5 Lifeline_OPFOR_Sides %6 !!!!!!!!!!!!!!!!!!!!!!!!!!! DMTG TRIG %4 !!!!!!!!!!!!!!!", 
		name _unit, Lifeline_Include_OPFOR, Lifeline_PVPstatus, _dmg_trig, (side group _unit) in Lifeline_OPFOR_Sides, Lifeline_OPFOR_Sides];

		if (Lifeline_RevProtect != 3) then {
			_unit allowDamage dmg_trig;			[_unit, _dmg_trig] remoteExec ["allowDamage", 0];
			// _unit setCaptive true;//TEMPCAPTIVEOFF
		};		
		if (Lifeline_RevProtect != 1 || _opfor_not_pvp) then {
		_unit setVariable ["Lifeline_allowdeath",true,true];
		};
	}; //[_unit, _damage, _non_handler] spawn {		

	// this is just for vanilla blood effect. when you setDamage it makes all body parts same damage, which seems to trigger vanilla blood effect.
	// when reviving, chunks of damage are taken off each bandage, thus lessening the vanilla blood each time.
};

Lifeline_actionID = {
	params ["_unit","_colour","_bandageno","_text"];
	_actionId = _unit addAction [format ["<t size='%4' color='#%1'>%3       ..%2</t>",_colour,_bandageno,_text,Lifeline_textsize],{params ["_target", "_caller", "_actionId", "_arguments"]; [_caller,_actionId] execVM "Lifeline_Revive\scripts\Lifeline_PlayerRevive.sqf" ; },[],8,true,true,"","_this distance cursorObject < 2.2 && lifeState cursorObject == 'INCAPACITATED' && animationstate _this find 'medic' ==-1"];
	_unit setVariable ["Lifeline_ActionMenuWounds",_actionId,true];
};

//================================================================================
//==== BANDAGE NUMBER CALCULATION. PER BODY PART

Lifeline_calcbandages = {
	params ["_unit","_dmg_unit"];

	// for instant death prevention, sometimes the allover damage is not updated.
	if (_dmg_unit <= Lifeline_IncapThres) then {
		// _dmg_unit = selectRandom [0.998,Lifeline_IncapThres + 0.05];
		// _dmg_unit = Lifeline_IncapThres + 0.05;
		_dmg_unit = 0.998;
		
	};

	//get damage from body parts for bandage distribution
	_face = _unit getHitPointDamage "hitface";_neck = _unit getHitPointDamage "hitneck";_head = _unit getHitPointDamage "hithead";_pelvis = _unit getHitPointDamage "hitpelvis";_abdomen = _unit getHitPointDamage "hitabdomen";_diaphrm = _unit getHitPointDamage "hitdiaphragm";_chest = _unit getHitPointDamage "hitchest";_body = _unit getHitPointDamage "hitbody";_arms = _unit getHitPointDamage "hitarms";_hands = _unit getHitPointDamage "hithands";_legs = _unit getHitPointDamage "hitlegs";_incap = _unit getHitPointDamage "incapacitated"; 
	

	_headGHPD = _face max _neck max _head;
	_torsoGHPD = _pelvis max _abdomen max _diaphrm max _chest max _body;
	_armsGHPD = _hands max _arms;
	_legsGHPD = _legs;
	
	// TEMP CALULATION. instead of max calc like above, add similar body parts (ie add _pelvis + _abdomen). Might not be accurate, but might be useful.
	_headGHPDtemp = _face + _neck + _head;
	_torsoGHPDtemp = _pelvis + _abdomen + _diaphrm + _chest + _body;
	_armsGHPDtemp = _hands + _arms;
	_legsGHPDtemp = _legs;
	
	// ========when explosion
	_otherdamage = _unit getVariable ["otherdamage",0];
	// _preventdeath = _unit getVariable ["preventdeath",false];
	_explosion = false;

	if (_torsoGHPD <= Lifeline_IncapThres && _headGHPD <= Lifeline_IncapThres && (_otherdamage > 1 || (_armsGHPD < Lifeline_IncapThres && _legsGHPD < Lifeline_IncapThres))) then {
		_headGHPD = _headGHPD + selectRandom[0,1];
			if (_headGHPD < 1) then {
				_torsoGHPD = 1;
			} else {
				_torsoGHPD = _torsoGHPD + selectRandom[0,1];
			};
		_armsGHPD = _armsGHPD + selectRandom[0,1];
		_legsGHPD = _legsGHPD + selectRandom[0,1];
		_explosion = true;
		
	};

	if (_headGHPD >= .998) then {_headGHPD = 1};
	if (_torsoGHPD >= .998) then {_torsoGHPD = 1};
	if (_armsGHPD >= .998) then {_armsGHPD = 1};
	if (_legsGHPD >= .998) then {_legsGHPD = 1};

	

	//============================================================================================================

	_bullethits = (_unit getVariable ["Lifeline_bullethits",0]); 
	_armlegswitch = false;

	//if only arms and legs are hit then reduce damage
	// if (_headGHPD < 0.4 && _torsoGHPD < 0.4 && _dmg_unit > 0.9) then {
	if (_headGHPD < 0.998 && _torsoGHPD < 0.998 && _dmg_unit > 0.9) then {
		_armlegswitch = true;

		

		// _dmg_unit =  _dmg_unit * selectRandom[0.7,0.75,0.8,0.85]; 
		_dmg_unit = _dmg_unit min ( ((0.998 - Lifeline_IncapThres)/2)+Lifeline_IncapThres); // limit damage to no more than half range above Lifeline_IncapThres
		// _dmg_unit = ( ((0.998 - Lifeline_IncapThres)/3.5)+ Lifeline_IncapThres); // limit damage to no more than half range above Lifeline_IncapThres
		
	};
	//============================================================================================================

	_dmg_uncon = (_dmg_unit - Lifeline_IncapThres); // Creates an unconcious damage score between 0.0 and 0.2, which is the damage difference over 0.8. e.g: if damage _unit = 0.83, then _dmg_uncon = 0.03
	_unc_range = 0.998 - Lifeline_IncapThres; // this is the range for unconcois					  
	_per_bandage = _unc_range / Lifeline_BandageLimit;  //   divides 0.2 up into bandage max number. This creates a per bandage division of 0.2
	// _bandagefull = _dmg_uncon / _per_bandage; // full number including decimal. 

	// CALCULATION METHOD ONE. CEILING - ROUND UP. Ends up with more bandages generally
	// _bandage_no = ceil(_dmg_uncon / _per_bandage); //assign number of bandages
	// if (_bandage_no > Lifeline_BandageLimit) then {_bandage_no = Lifeline_BandageLimit};

	// CALCULATION METHOD TWO. ROUND TO NEAREST WHOLE NUMBER
	_bandage_no = round(_dmg_uncon / _per_bandage); 
	if (_bandage_no == 0) then {_bandage_no = 1};
	if (_bandage_no > Lifeline_BandageLimit) then {_bandage_no = Lifeline_BandageLimit};

	_damagesubstr = (_dmg_unit - _unc_range) / _bandage_no; //this calculates the amount of damage to substract each bandage. incap wakes up at 0.2, so only (current damage minus 0.2) divided by num of bandages
	_damagesubstr = _damagesubstr + 0.000001; //added a tiny fraction - sometimes the calculation is a fraction off due to rounding errors. This fixes it.

	//=========================================================================================
    

	//if only arms / legs are hit and bandages calculated are more than bullet hits then reduce bandages to number of bullet hits.
	if (_headGHPD < 0.998 && _torsoGHPD < 0.998 && _armlegswitch == false && ((_bandage_no > _bullethits && _bullethits > 0)) ) then { // better calculation. e.g. 5 shots sometimes only have 1 bandage, but its still minor damage.
		if (_bullethits > Lifeline_BandageLimit) then {
			_bandage_no = Lifeline_BandageLimit;
			
		} else {
			_bandage_no = _bullethits;
			
		};
	};

	//=====calc bandages across parts

	//damage under 0.1 is just noise, make it zero, for cleaner bandage calculation
	if (_headGHPD <= 0.1) then {_headGHPD = 0}; if (_torsoGHPD <= 0.1) then {_torsoGHPD = 0};
	if (_armsGHPD <= 0.1) then {_armsGHPD = 0}; if (_legsGHPD <= 0.1) then {_legsGHPD = 0};

	//spread bandages across parts according to damage
	_totalGHPD = _headGHPD + _torsoGHPD + _armsGHPD + _legsGHPD;
	_bandg_headGHPD = (_headGHPD/_totalGHPD) * _bandage_no;
	_bandg_torsoGHPD = (_torsoGHPD/_totalGHPD) * _bandage_no;
	_bandg_armsGHPD = (_armsGHPD/_totalGHPD) * _bandage_no;
	_bandg_legsGHPD = (_legsGHPD/_totalGHPD) * _bandage_no;

	//Round to nearest whole number, unless between 0.1 - 0.5, then use 'ceil' instead (round upwards). only add to array if  > 0.1. 
	_bandg_total_array = [];

	_randj = selectRandom [1,2];
	if (_randj == 1) then {
		if (_bandg_headGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_headGHPD < 0.5) then {ceil _bandg_headGHPD} else {round _bandg_headGHPD}, "Head:",_headGHPD]];};
		if (_bandg_torsoGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_torsoGHPD < 0.5) then {ceil _bandg_torsoGHPD} else {round _bandg_torsoGHPD}, "Torso:",_torsoGHPD]];};
	} else {
		if (_bandg_torsoGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_torsoGHPD < 0.5) then {ceil _bandg_torsoGHPD} else {round _bandg_torsoGHPD}, "Torso:",_torsoGHPD]];};
		if (_bandg_headGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_headGHPD < 0.5) then {ceil _bandg_headGHPD} else {round _bandg_headGHPD}, "Head:",_headGHPD]];};
	};
	if (_bandg_armsGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_armsGHPD < 0.5) then {ceil _bandg_armsGHPD} else {round _bandg_armsGHPD}, "Arm:",_armsGHPD]];};
	if (_bandg_legsGHPD > 0.1) then {_bandg_total_array = _bandg_total_array + [[if (_bandg_legsGHPD < 0.5) then {ceil _bandg_legsGHPD} else {round _bandg_legsGHPD}, "Leg:",_legsGHPD]];};

	// _dmg_total_array = [[_headGHPD, "head"], [_torsoGHPD, "tors"], [_armsGHPD, "arms"], [_legsGHPD, "legs"]]; 
	_dmg_total_array = [[_headGHPD, "Head:"], [_torsoGHPD, "Torso:"], [_armsGHPD, "Arm:"], [_legsGHPD, "Leg:"]]; 
	_dmg_total_array sort false;
	

	 // Loop through the array and accumulate the number of bandages
	_bandg_total = 0;
	{_bandg_total = _bandg_total + (_x select 0); } forEach _bandg_total_array;

	//test diff sorting methods
	_bandg_total_array sort false;
	
	// _bandg_total_array = [_bandg_total_array, [], {_x select 2}, "DESCEND"] call BIS_fnc_sortBy;

	//sometimes after distributing bandages, there are fractions and they throw off total number. This checks difference
	_diff = _bandg_total - _bandage_no; 
	
	//this just checks if there are 3 body parts in a row with same number of bandages, or 2 in a row. This is so distributing bandages can be even.
	_threeeven = false; _twoeven = false;
	if (count _bandg_total_array >=2) then {
		if ((_bandg_total_array select 0 select 0) == (_bandg_total_array select 1 select 0) && (_bandg_total_array select 0 select 0) == (_bandg_total_array select 2 select 0)) then {_threeeven = true;	};
		if ((_bandg_total_array select 0 select 0) == (_bandg_total_array select 1 select 0) && (_bandg_total_array select 0 select 0) != (_bandg_total_array select 2 select 0)) then {_twoeven = true;	};
	};

	//add counter for loop
	_count = _diff;
	if (_diff < 0) then {_count = _diff * -1;};

	// this checks to see a pattern - 3 body parts with equal number of bandages or 2 body parts with equal number. For correcting rounding erros later below by adding or subtracting a bandage.
	_countarr = []; _countarr2 = [];
	if (_threeeven == true) then {_countarr = [2,1,0];_countarr2 = [0,1,2]};
	if (_twoeven == true) then {_countarr = [1,0,1];_countarr2 = [0,1,0]};
	if (_threeeven == false && _twoeven == false) then {_countarr = [0,1,0];_countarr2 = [1,0,1]};

	//========= add or subract a bandage/s to fix rounding calucation throwing off total bandages
	//add and subtract version
	if (_diff != 0) then {
		_counter = 0;
		_posneg = 1; //positive or negative - either subtract one or add one
		if (_diff < 0) then {_countarr = _countarr2; _posneg = -1}; 
		while {_counter < _count} do {
			_bandg_total_array set [(_countarr select _counter), [(_bandg_total_array select (_countarr select _counter) select 0) - _posneg, (_bandg_total_array select (_countarr select _counter) select 1), (_bandg_total_array select (_countarr select _counter) select 2)]];
			_counter = _counter + 1;
		};
	};
	//subtract only version
	// if (_diff > 0) then {
		// _counter = 0;
		// while {_counter < _count} do {
			// _bandg_total_array set [(_countarr select _counter), [(_bandg_total_array select (_countarr select _counter) select 0) - 1, (_bandg_total_array select (_countarr select _counter) select 1), (_bandg_total_array select (_countarr select _counter) select 2)]];
			// _counter = _counter + 1;
		// };
	// };

	 // Loop through the array and accumulate the numbers
	if (_diff !=0 ) then {
		_bandg_total = 0;
		{_bandg_total = _bandg_total + (_x select 0);} forEach _bandg_total_array;
		
	};
	//============================================================

	_unit setDamage _dmg_unit; //set total damage to _dmg_unit, to fix any issues if it was under [02:22 16/06/2024]
	_unit setVariable ["otherdamage",0,true];
	_unit setVariable ["lastotherdamage",0,true];

	[_bandg_total,_per_bandage,_damagesubstr,_bandg_total_array]
};

//============================================================================================
//==== INJURY NAMES AND COLOUR, ON SEVERITY SCALE 1-4 (called _quads. 4 is highest damage)

Lifeline_bandage_text = {
	params ["_bandage_no", "_unit", "_bandg_total_array", "_cpr", "_non_handler"];

	
	_pallet04 = ["F94545","F97166","F99E86","F9CAA7"];

	_colour = _pallet04; //just replace variable here

	_unconcious = false;
	_bloodneeded = false;
	_passtrig = false; //triggered when a quadrant, _quad, is passed
	_unitwounds = [];
	_textcolour = "";
	_text = "";
	_part = "";

	//just for calc of anim, a severity of four levels (hence 'quad')
	_quadstored = (4 / Lifeline_BandageLimit) * _bandage_no;
	_quadstored = ceil(_quadstored);
	_unit setVariable ["quadstored",_quadstored,true];

	while {_bandage_no > 0} do {

		_part = _bandg_total_array select 0 select 1;
		_value = _bandg_total_array select 0 select 0;
		_count = count _bandg_total_array;
		if (_count == 0) exitWith {};

		_quad = (4 / Lifeline_BandageLimit) * _bandage_no;
		_quad = ceil(_quad); // _quad is a variable to divide serverity of damage into 4 levels for change of colour of the addaction text and also allocation of injury names by severity.		

		if (_quad == 4) then {	
			_bloodneeded = true;
			_unconcious = true;
			_passtrig = true;
			_textcolour = _colour select 0;
			if !(_non_handler) then {
				if (_cpr == true) exitWith { 
					_text = "CRITICAL: Perform CPR";
					_bandage_no = _bandage_no + 1;
					_value = _value + 1;
					_textcolour = "C70039";
				};
				if (_part == "Head:") exitWith {
					_text = selectRandom[ "Neck Wound", "Neck Wound", "Neck Wound", "Scalp Wound", "Broken Jaw", "Broken Jaw", "Broken Jaw", "Scalp Wound", "Scalp Wound", "Deep Scalp Cut", "Severe Gash", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Concussion", "Concussion", "Fractured Cranium", "Fractured Cranium", "Fractured Cranium", "Severe Gash", "Severe Gash", "Severe Gash"];
				};
				if (_part == "Torso:") exitWith {
					_text = selectRandom[ "Fractured Shoulder", "Fractured Shoulder", "Fractured Shoulder", "Fractured Collarbone", "Fractured Collarbone", "Fractured Sternum", "Severe Puncture", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Fractured Pelvis", "Severe Gash", "Severe Gash", "Severe Gash"];
				};
				_text = selectRandom[ "Severe Puncture", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Severe Gash", "Severe Gash", "Severe Gash"];
			} else {
			_text = "Unknown Injury";
			};
		};

		if (_quad == 3) then {
			_unconcious = true;
			_passtrig = true;
			_textcolour =  _colour select 1;
			if !(_non_handler) then {
				if (_part == "Head:") exitWith {
					_text = selectRandom[ "Broken Nose", "Broken Nose", "Broken Nose", "Broken Nose", "Neck Gash", "Neck Wound", "Neck Wound", "Scalp Wound", "Scalp Wound", "Cheek Wound", "Cheek Wound", "Smashed Teeth", "Smashed Teeth", "Smashed Teeth", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Concussion", "Concussion", "Fractured Scull", "Deep Gash", "Deep Gash", "Deep Gash"];
				};
				if (_part == "Torso:") exitWith {
					_text = selectRandom[ "Fractured Sternum", "Severe Puncture", "Severe Laceration",  "Severe Avulsion", "Severe Laceration", "Severe Avulsion", "Severe Laceration", "Fractured Pelvis", "Deep Gash", "Deep Gash", "Deep Gash"];
				};
				_text = selectRandom["Penetration Wound", "Avulsion", "Deep Laceration", "Deep Puncture", "Moderate Avulsion", "Deep Avulsion","Avulsion", "Fracture", "Deep Laceration", "Compound Fracture", "Deep Puncture", "Severe Burns And Cuts", "Limb Fracture", "Moderate Avulsion", "Deep Avulsion", "Limb Fracture", "Deep Gash", "Deep Gash", "Deep Gash"];	
			} else {
			_text = "Unknown Injury";
			};
		};

		if (_quad == 2) then {
			_passtrig = true;
			_textcolour = _colour select 2;
			if !(_non_handler) then {
				if (_bandage_no == 2 && _bloodneeded == true) exitWith {
					_text = "Inject Blood IV";
				};
				if (_part == "Head:" || _part == "Torso:") exitWith {
					_text = selectRandom["Gash Wound","Gash Wound","Gash Wound","Lacerations", "Moderate Wound", "Moderate Abrasions", "Lacerations", "Moderate", "Moderate Abrasions", "Moderate Gash", "Moderate Gash", "Moderate Gash" ];
				};
					_text = selectRandom["Lacerations", "Moderate Wound", "Moderate Abrasions", "Penetration Wound","Penetration Wound","Penetration Wound","Lacerations", "Moderate Gash", "Limb Fracture", "Limb Fracture", "Moderate Abrasions", "Moderate Gash", "Moderate Gash", "Moderate Gash" ];
			} else {
			_text = "Unknown Injury";
			};
		};	

		if (_quad == 1) then {
			_textcolour =  _colour select 3;
			if !(_non_handler) then {
				if (_bandage_no == 2 && _bloodneeded == true) exitWith {
					_text = "Inject Blood IV";
				};
				if (_bandage_no == 1 && _unconcious == true ) exitWith {
					_text = selectRandom["Inject Epinephrine","Inject Epinephrine","Inject Epinephrine","Inject Morphine"];
				};
				if (_part == "Head:" || _part == "Torso:") exitWith {
					_text = selectRandom["Abrasions", "Avulsions", "Heavy Bruising And Cuts", "Burns And Abrasions", "Contusion", "Inject Morphine", "Inject Morphine", "Moderate Graze", "Moderate Graze", "Moderate Graze"];
				};
				if (_passtrig == false) then {
					_text = selectRandom[ "Abrasions", "Avulsion", "Moderate Graze", "Moderate Graze", "Moderate Graze"]; 
					_passtrig = true;
				} else {
					_text = selectRandom["Sprained Ligament","Abrasions", "Avulsions", "Heavy Bruising And Cuts", "Sprain", "Treat Burns And Abrasions", "Sprained Ligament", "Contusion", "Fix Dislocated Joint", "Inject Morphine", "Inject Morphine", "Moderate Graze", "Moderate Graze", "Moderate Graze"];
				};
			} else {
			_text = "Unknown Injury";
			};
		};
		if (_text != "Inject Blood IV" && _text != "Inject Morphine" && _text != "Inject Epinephrine" && _text != "Treat Shock" && _text != "CRITICAL: Perform CPR") then {
			_text = _part + " " + _text;
		};

		_colourtext = [_text, _textcolour];
		_bandage_no = _bandage_no - 1;
		_unitwounds = [_colourtext] + _unitwounds;
		_value = _value - 1;

		if (_value == 0) then {
			_bandg_total_array deleteAt 0;
		};
		if (_cpr == false && _value != 0) then {
			_bandg_total_array set [0, [_value, (_bandg_total_array select 0) select 1, (_bandg_total_array select 0) select 2]];
		};
		_cpr = false;
	}; // while do

	
	_unit setVariable ["unitwounds", _unitwounds, true];
};

Lifeline_bandage_addAction = {
	params ["_unit","_non_handler"];

	_dmgyo = damage _unit;
	
	_calcbandages = [_unit,_dmgyo] call Lifeline_calcbandages;
	_bandageno = _calcbandages select 0;											
	_damagesubstr = _calcbandages select 2;
	_bandg_total_array = _calcbandages select 3;
	_bandage_no = _bandageno; // this is just temp due to laziness 

	

	_unit setVariable ["damagesubstr", _damagesubstr, true];

	_colour = "";
	_text = "";
	_cpr = false; 
	_randomNumber = 0;

	if (Lifeline_CPR_likelihood == 100) then {
		_randomNumber = 100 //save CPU maybe? probably not lol.
		} else {
		_randomNumber = floor (random 101);
		
	};		
	if (Lifeline_CPR_likelihood > 0) then {
		if ((Lifeline_InstantDeath == 0 && damage _unit >= 0.998 && _randomNumber <= Lifeline_CPR_likelihood) || (Lifeline_InstantDeath == 1 && damage _unit > 0.97 && _randomNumber <= Lifeline_CPR_likelihood) || (Lifeline_InstantDeath == 2 && damage _unit > 0.97 )) then {											
		// if (damage _unit >= 0.998) then {		// for testing									
			_cpr = true;
			//turn of autorevive
			_unit setVariable ["Lifeline_autoRecover",false,true];	
			if (Lifeline_CPR_less_bleedouttime != 100) then {
				_bleedouttime = _unit getVariable ["LifelineBleedOutTime", 0];
				// _bleedouttime = _bleedouttime - (Lifeline_BleedOutTime / 3);
				// _bleedouttime = _bleedouttime - (Lifeline_BleedOutTime * (Lifeline_CPR_less_bleedouttime / 100));
				_bleedouttime = time + (Lifeline_BleedOutTime * (Lifeline_CPR_less_bleedouttime / 100));
				_unit setVariable ["LifelineBleedOutTime", _bleedouttime, true];
			};
		};
	};
	if !(_cpr) then {
		_unit setVariable ["LifelineBleedOutTime", time + Lifeline_BleedOutTime, true]; //add again to start fresh.
	};
	//add marker 
	// if (Lifeline_Map_mark) then {[_unit,_cpr] call Lifeline_Incap_Marker;};

	// moved here, start display
	if ((Lifeline_HUD_distance == true || Lifeline_cntdwn_disply != 0) && isPlayer _unit) then {
		_seconds = Lifeline_cntdwn_disply;
		// if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false]) 
		// 	&& Lifeline_cntdwn_disply != 0 && Lifeline_RevMethod != 3 && Lifeline_HUD_distance == false) then {
		// 	_unit setVariable ["Lifeline_countdown_start",true,true];
		// 	[[_unit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_unit, true];
		// }; 
		if (lifeState _unit == "INCAPACITATED" && !(_unit getVariable ["Lifeline_countdown_start",false])) then {
			_unit setVariable ["Lifeline_countdown_start",true,true];
			[[_unit,_seconds], Lifeline_countdown_timer2] remoteExec ["spawn",_unit, true];
		};
	};

	[_bandageno,_unit,_bandg_total_array,_cpr,_non_handler] call Lifeline_bandage_text;

	[_unit] call Lifeline_text_addAction;

	

};

Lifeline_text_addAction = {
	params["_unit"];

	_unitwounds =  _unit getVariable ["unitwounds",[["Inject Morphine","F9CAA7"]]];
	_bandageno = count _unitwounds;
	_unit setVariable ["num_bandages",_bandageno,true];
	_text = _unit getVariable "unitwounds" select (_bandageno -1) select 0;
	_colour = _unit getVariable "unitwounds" select (_bandageno -1) select 1;
	

	if (_text != "CRITICAL: Perform CPR") then {
	_text = format ["%1       ..%2", _text, _bandageno];
	};

	

		// === OLD METHOD IF. Using "" to replace action menu when not used.
	if !(_unit getVariable ["Lifeline_RevActionAdded",false]) then { 
			_unit setVariable ["Lifeline_RevActionAdded",true,true];	
			[[_unit,_colour,_bandageno,_text],
				{params ["_unit","_colour","_bandageno","_text"];
				   _actionId = _unit addAction [format ["<t size='%3' color='#%1'>%2</t>",_colour,_text,Lifeline_textsize],{params ["_target", "_caller", "_actionId", "_arguments"]; [_caller,_actionId] execVM "Lifeline_Revive\scripts\Lifeline_PlayerRevive.sqf" ; },[],8,true,true,"","_target == cursorObject && _this distance cursorObject < 2.2 && lifeState cursorObject == 'INCAPACITATED' && animationstate _this find 'medic' ==-1"];
					_unit setVariable ["Lifeline_ActionMenuWounds",_actionId,true];
				}] remoteExec ["call", 0, true];
		} else {
			_actionId = _unit getVariable ["Lifeline_ActionMenuWounds",false];
			[[_unit,_actionId,_colour,_bandageno, _text],
				{params ["_unit", "_actionId", "_colour","_bandageno","_text"];
				_unit setUserActionText [_actionId, format ["<t size='%3' color='#%1'>%2</t>",_colour,_text, Lifeline_textsize]];
				}] remoteExec ["call", 0, true];
		};		
};

// this is a powercurve over incap threshold. Can change the curve to affect number of bandages. 
// _powerValue = 1 mean no effect (straight line).  1.1 - 1.9 is recomended range for _powerValue
powerCurve = {
	params ["_damage","_powerValue","_threshold"];
	_processedDamage = 0;
	_normalizedDamage = 0;
	// Define the threshold above which the curve will apply 
	// _threshold = 0.8; 
	// _powerValue = 1.5; // You can adjust this value to control the curve //EDIT now a param
	if (_damage > _threshold) then { 
		_normalizedDamage = (_damage - _threshold) / (1 - _threshold); 
		_processedDamage = _threshold + (1 - _threshold) * _normalizedDamage ^ _powerValue; 
	} else { 
		_processedDamage = _damage; 
	}; 
	_processedDamage
};

Lifeline_Medic_Anim_and_Revive = {
		params ["_incap","_medic","_EnemyCloseBy","_voice","_B"];

		_bleedoutbaby = "LifelineBleedOutTime";
		_pairtimebaby = "LifelinePairTimeOut";			
		_exit = false;		

		// too lazt to make this a passed on param
		_opforpve = false;
		if (Lifeline_PVPstatus == false && Lifeline_Include_OPFOR == true && (side group _medic) in Lifeline_OPFOR_Sides) then {
			_opforpve = true;
		};

		

		if (lifestate _incap == "INCAPACITATED") then {

					if (Lifeline_RevMethod == 1 || Lifeline_BandageLimit == 1) then {
						_incap setVariable ["damagesubstr", damage _incap, true]; // ADDED to be compatible with new bandage anim method. even though its only 1 revive action
						_incap setVariable ["num_bandages",1,true];				// ADDED to be compatible with new bandage anim method. even though its only 1 revive action
					};														

					_bandages = _incap getVariable ["num_bandages",0];

					//usually takes 5 seconds for wound and injury data for incap to be calculated. This prevents medic trying to bandage before then.
					if (_bandages == 0 && Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
						_count = 7;
						while {_count > 0} do {
						
						_incap setVariable [_pairtimebaby, (_incap getvariable _pairtimebaby) + 1, true]; // add 5 seconds to incap revivetimer
						_medic setVariable [_pairtimebaby, (_medic getvariable _pairtimebaby) + 1, true]; // add 5 seconds to medic revivetimer
						_incap setVariable [_bleedoutbaby, (_incap getvariable _bleedoutbaby) + 1, true];  
						_bandages = _incap getVariable ["num_bandages",0];
						if (_bandages != 0 ) exitWith {};
						_count =  _count - 1;
						sleep 1;
						};
						if (_bandages == 0 ) then {_exit = true;};
					};
					if (_exit == true) exitWith {
						// if (Lifeline_debug_soundalert) then {["siren1"] remoteExec ["playSound",2]};
						hintsilent format ["NO BANDAGE DATA: %1\nEXIT BEFORE BANDAGE ANIM", name _incap];
						
					};

					// _damagesubtract = _incap getVariable "damagesubstr"; // IS THIS FUCKING RIGHT? THE DAMAGE TO SUBRACT SHOULD JUST BE TOTAL DAMAGE DIVIDED BY TOTAL BANDAGES
					_damagesubtract = damage _incap / _bandages;
					

					_switch = 0;
					
					_unitwounds =  _incap getVariable ["unitwounds",[]];

					

					//=====================================================================================================

					_switch = 0;
					_againswitch = 1; // this is so the voice sample "and again" alternates samples and not sound robotic

					// _encourage = ["_greetB5", "_greetB2", "_almostthere1"];	//different voices of encouragement
					_encourage = ["_greetB5", "_greetB2", "_almostthere1","_staybuddy1"];	//different voices of encouragement
					_enc_count = 0;											//round-robin counter for above	
					_cprcheck = false;
					_notrepeat = "";
					_colour = "";
					_part_yo = "";
					// _firstpass = true;
					_crouchreviveanim = selectRandom [0,1]; // this is to randomize between two different crouch revive animations.

					// ================= BANDAGE ACTION LOOP ===============================================================
					
					_firstimetrigg = false; // TEMP FOR NEW ANIMATION
					// _tempswitch = false;

					// _textright = "BLEEDOUT CLEAR";
					// [_textright,1.3,5,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright",_incap];

					// while {_bandages > 0 && (lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && alive _medic)} do { 
					while {_bandages > 0 && (lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap)} do { 

						_bandages = _incap getVariable "num_bandages"; //copy of this in loop so updates from other medics reviving at same time works
						//loop for medical actions
						// while {damage _incap > 0.2 && (lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && alive _medic)} do { //loop for medical actions

						if (_bandages <= 0) exitWith {};//backup to exit in case of bandage calulation error (mutiple players reviving same incap, it might happen)

						if (lifestate _medic == "INCAPACITATED" || !(alive _medic)) exitWith {};
						if (lifestate _incap != "INCAPACITATED" || !(alive _incap)) exitWith {};

						

						//============== ADD MORE TIMER. added to increase revive time limit on each loop pass ==============================================================================
						_timelimitincap = (_incap getvariable _pairtimebaby);
						_timelimitmedic = (_medic getvariable _pairtimebaby);
						_incap setVariable [_pairtimebaby, _timelimitincap + 10, true]; 
						_medic setVariable [_pairtimebaby, _timelimitmedic + 10, true]; 
						_bleedoutincap = (_incap getvariable _bleedoutbaby);
						_incap setVariable [_bleedoutbaby, _bleedoutincap + 30, true];
						//======================================================================================================================================================================		

						if (_bandages > 0 && Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {

							_text = _incap getVariable "unitwounds" select (_bandages -1) select 0;
							
							_colour = _incap getVariable "unitwounds" select (_bandages -1) select 1;
							_actionId = _incap getVariable ["Lifeline_ActionMenuWounds",0];
							//new method
							if (_text != "CRITICAL: Perform CPR") then {
								_text = format ["%1       ..%2", _text, _bandages];
							};

							[[_incap,_actionId,_colour,_bandages, _text],
								{params ["_incap", "_actionId", "_colour","_bandages","_text"];
								_incap setUserActionText [_actionId, format ["<t size='%3' color='#%1'>%2</t>",_colour,_text, Lifeline_textsize]];}] remoteExec ["call", 0, true];

							//hint feedback for incap player
							if (isPlayer _incap && Lifeline_HUD_medical) then {
								// [format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
								_textright = format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.7];
								[_textright,1.3,5,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright",_incap];																
							};
							

							if (lifestate _medic != "INCAPACITATED" && lifestate _incap == "INCAPACITATED" && (alive _incap) && (alive _medic) && (Lifeline_MedicComments && !_opforpve)) then {

								

								if (_text == "CRITICAL: Perform CPR") then {
									_part_yo = "CPR";
									if (_part_yo != _notrepeat) then {
										
										[_medic, [_voice+"_CPR1", 20, 1, true]] remoteExec ["say3D", 0];
									};
								};
								if ((_text find "Head:") == 0) then {
									_part_yo = "head";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_head1", 20, 1, true]] remoteExec ["say3D", 0];
										
									};
								};		
								if ((_text find "Torso:") == 0) then {
									_part_yo = "torso";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_torso1", 20, 1, true]] remoteExec ["say3D", 0];
										
									};
								};	
								if ((_text find "Arm:") == 0) then {
									_part_yo = selectRandom["_leftarm1","_rightarm1"];
									if (_part_yo != _notrepeat && (_text find "Fracture") == -1) then {
										[_medic, [_voice+_part_yo, 20, 1, true]] remoteExec ["say3D", 0];
										
									};									
								};
								if ((_text find "Leg:") == 0) then {
									_part_yo = selectRandom["_leftleg1","_rightleg1"];
									if (_part_yo != _notrepeat && (_text find "Fracture") == -1) then {
										[_medic, [_voice+_part_yo, 20, 1, true]] remoteExec ["say3D", 0];
										
									};		
								};
								if ((_text find "Fracture") != -1 && _part_yo != "torso" && _part_yo != "head") then { // only arms and legs
								// if ((_text find "Fracture") != -1 && _part_yo != "head") then { //this version includes fracture shoulders which are part of torso
									_part_yo = "fracture";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_fracture1", 20, 1, true]] remoteExec ["say3D", 0];
										
									};
								};
								if ((_text find "Inject Blood IV") == 0) then {
									_part_yo = "blood";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_giveblood1", 20, 1, true]] remoteExec ["say3D", 0];
										
									};
								};
								if ((_text find "Inject Epinephrine") == 0) then {
									_part_yo = "Epinephrine";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_giveEpinephrine1", 20, 1, true]] remoteExec ["say3D", 0];
										
									};	
								};
								if ((_text find "Inject Morphine") == 0) then {
									_part_yo = "Morphine";
									if (_part_yo != _notrepeat) then {
										[_medic, [_voice+"_morphine1", 20, 1, true]] remoteExec ["say3D", 0];
										
									};	
								};
							}; // end if not incapped

						}; // end if RevMethod == 2

						//encouragment or "and again" voice sample when body part is repeated for Lifeline_RevMethod 2. Repeated audio samples are not cool. 

						
						// if (Lifeline_RevMethod == 2) then {
						if (Lifeline_RevMethod == 2 && (Lifeline_MedicComments && !_opforpve) && Lifeline_BandageLimit > 1) then {
							_repeatrandom = selectRandom[1,2];	
							
							if (_part_yo == _notrepeat && _enc_count < 4 && _repeatrandom == 1) then { 
								[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
								
								if (_enc_count == 3) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
							};
							if (_part_yo == _notrepeat && _repeatrandom == 2) then { 
								
								[_medic, [_voice+"_andagain"+(str _againswitch), 20, 1, true]] remoteExec ["say3D", 0];
								
								if (_againswitch == 1) then { _againswitch = 2; } else { _againswitch = 1; };
							};	
							_notrepeat = _part_yo;
						};

						_sleeptime = 0;
						

						//turning off the random choice between two animations. Hard setting it here:
						_crouchreviveanim = 0;

						if (_part_yo != "CPR") then {
								// Kneeling revive - no near enemy
								// if (isNull _EnemyCloseBy) then {
								if (lifestate _incap == "INCAPACITATED" && isNull _EnemyCloseBy && lifestate _medic != "INCAPACITATED" && alive _medic) then {
									// _medic setdir (_medic getDir _incap)+5;/*  */ //SETDIRTEMP
									if (_crouchreviveanim == 0) then {
										 // [_medic, "AinvPknlMstpSnonWnonDnon_medic4"] remoteExec ["playMoveNow", _medic];
										 [_medic, "AinvPknlMstpSnonWnonDnon_medic4"] remoteExec ["playMoveNow", 0, true];
										 _sleeptime = 4;
									};
								};

								// Prone revive - near enemy. Alternating between two anims to fix an Arma bug
								if (lifestate _incap == "INCAPACITATED" && !isNull _EnemyCloseBy && lifestate _medic != "INCAPACITATED" && alive _medic) then {
									// _medic setdir (_medic getDir _incap)+5;/*  *///SETDIRTEMP
									// [_medic, (_medic getDir _incap)+5] remoteExec ["setdir", _medic];

									if (Lifeline_Anim_Method == 0) then {
											// _switch = 0; // TEMP - force switch for testing.
											if (_switch == 0) then {
												[_medic, "AinvPpneMstpSlayWrflDnon_medicOther"] remoteExec ["playMove", 0, true]; //CURRENT
												
												// [_medic, "ainvppnemstpslaywrfldnon_medicother"] remoteExec ["SwitchMove", _medic];
												_switch = 1;
												// sleep 9;
												_sleeptime = 4.5;
											} else {
												[_medic, "AinvPpneMstpSlayWrflDnon_medicOther"] remoteExec ["SwitchMove", 0, true]; //CURRENT
												
												_sleeptime = 4.75;
												// sleep 9.5;
											}; 
											[_medic, _incap] spawn {
												params ["_medic", "_incap"];
												// _medic setdir (_medic getDir _incap)+10;/*  *///SETDIRTEMP
											};
										};														
										//NEW ANIMATION LOOP, less weapon being pulled out between bandages, faster, but a frame jump in the loop.
										if (Lifeline_Anim_Method == 1) then {
											if (_firstimetrigg == false ) then {
												_randomanimloop = selectrandom[1,2,3,4];
												// _randomanimloop = 1;
												//remote exec the function with the bandage animation loop
												// [_incap,_medic,_randomanimloop,_cprcheck] remoteExec ["Lifeline_Anim_Bandage_new",0,true];
												[_incap,_medic,_randomanimloop,_cprcheck] remoteExec ["Lifeline_Anim_Bandage_new",[_incap,_medic],true];
												// [_incap,_medic,_randomanimloop] spawn Lifeline_Anim_Bandage_new;
												_firstimetrigg = true;
											};
											_sleeptime = 3.75;
										};														
								};	//if (!isNull _EnemyCloseBy) then
						}; // if != CPR

						if (_part_yo == "CPR") then {
							if (lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" && alive _medic) then {
								// _medic setdir (_medic getDir _incap)+5; //SETDIRTEMP
								// [_medic, (_medic getDir _incap)+5] remoteExec ["setdir", _medic];
								// [_medic, "AinvPknlMstpSnonWnonDr_medic0"] remoteExec ["playMoveNow", _medic];
								[_medic, "AinvPknlMstpSnonWnonDr_medic0"] remoteExec ["playMoveNow", 0, true];
								_cprcheck = true;
								
								_sleeptime = 4;
							};
						};

						// does this direction code go before or after animations?
						[_medic, _incap] spawn {
							params ["_medic", "_incap"];
							// _medic setdir (_medic getDir _incap)+10; //SETDIRTEMP
						}; 

						// }; // end if (lifestate _medic != "INCAPACITATED" etc

						sleep _sleeptime;

						

						// random verbal encouragement halfway through playMove, for both Lifeline_RevMethod 1 & 2. There is a sample repeat blocker for Lifeline_RevMethod 1.
						if (Lifeline_MedicComments && !_opforpve) then {	
							_rando = selectRandom[1,2,3,4];
							if (Lifeline_RevMethod == 1 || Lifeline_BandageLimit == 1) then {
								_rando = selectRandom[1,2];
								_enc_count = selectRandom[0,1,2,3];
								
								//this will stop a repeated sample from the greeting (some shared samples in arrival greeting)
								while {(_enc_count == 0 && _B == "5") || (_enc_count == 1 && _B == "2")} do {
									
									_enc_count = selectRandom[0,1,2,3];
								};
								
							};

							
							if (_rando == 1) then { 
								[_medic, [_voice+(_encourage select _enc_count), 20, 1, true]] remoteExec ["say3D", 0];
								
								if (_enc_count == 3) then {_enc_count = 0} else {_enc_count = _enc_count + 1};
								
							};
						};

						sleep _sleeptime;

						

						if (_part_yo == "CPR") then {	
							sleep 4;
							if (Lifeline_MedicComments && !_opforpve) then {	
								
								[_medic, [_voice+"_pulse1", 20, 1, true]] remoteExec ["say3D", 0];
							};							
							// take incap out of CPR animation (dead still)
							[_incap] spawn {
								params ["_incap"];
								sleep 5;
								[_incap, "UnconsciousReviveDefault_C"] remoteExec ["PlayMoveNow", _incap];	   
								[_incap, "UnconsciousFaceUp"] remoteExec ["PlayMove", 0];	
								//local anim 
								// _incap playMoveNow "UnconsciousReviveDefault_C";
								// _incap playMove "UnconsciousFaceUp";
							};
						};

						

						// THIS IS HACKED ON MORPHINE AT END 
						if (_part_yo == "Epinephrine" && _bandages == 1) then {
							[_incap,_medic,_voice,_colour,_opforpve] spawn {
							params ["_incap","_medic","_voice","_colour","_opforpve"];
							sleep 2;
								if (isPlayer _incap && Lifeline_HUD_medical) then {
									_text = "Inject Morphine       ..extra";
									// [format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
									_textright = format ["<t align='right' size='%3' color='#%1'>%2</t>",_colour,_text, 0.7];
									[_textright,1.3,5,Lifelinetxt2Layer] remoteExec ["Lifeline_display_textright",_incap];									
								};
								if (Lifeline_MedicComments && !_opforpve) then {
									[_medic, [_voice+"_morphine1", 20, 1, true]] remoteExec ["say3D", 0];
									
								};
							};	
							sleep 2;
						};

						// }; // end if (lifestate _medic != "INCAPACITATED" etc

						_newdamage = damage _incap - _damagesubtract;
						if (_newdamage < 0.2) then {
							
							// _incap setDamage 0.2;
							_newdamage = 0.2;						
						};

						_incap setDamage _newdamage;
						_bandages = _bandages - 1;
						_incap setVariable ["num_bandages",_bandages,true];	

						// NEW TEST for deleting from array
						
						// _unitwounds = _unitwounds - [(_unitwounds select (_bandages))]; // WRONGGG
						_unitwounds deleteAt _bandages;
						
						_incap setVariable ["unitwounds",_unitwounds,true];

					}; // end while ================================================ END BANDAGE LOOP ========================================

		}; // if lifestate == incapacitated

		//================================================ REMOVE DAMAGE AND WAKE UP OR ABORT ============================

		_tempswitch = true;

		if (lifestate _medic != "INCAPACITATED" && alive _medic && alive _incap && lifestate _incap == "INCAPACITATED" && _exit == false) then {

			// Remove damage and wake up			

			if ((animationState _incap find "unconscious" == 0 && animationState _incap != "unconsciousrevivedefault" && animationState _incap != "unconsciousoutprone") || animationState _incap == "unconsciousrevivedefault") then {
				[_incap, "unconsciousrevivedefault"] remoteExec ["SwitchMove", 0];
			};

			if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
				_actionId = _incap getVariable "Lifeline_ActionMenuWounds";
				if (!isNil "_actionId") then {
						[[_incap,_actionId],{params ["_unit","_actionId"];_unit setUserActionText [_actionId, ""];}] remoteExec ["call", 0, true];
				};
			};
			// _medic setVariable ["Lifeline_reset_trig",false,true]; // THIS AGAIN, SOMETIMES NOT SET AT START
			_incap setVariable ["Lifeline_Down",false,true];// for Revive Method 2
			_incap setVariable ["Lifeline_autoRecover",false,true];
			_incap setVariable ["Lifeline_allowdeath",false,true];
			_incap setVariable ["Lifeline_bullethits",0,true];

			// _medic setVariable ["ReviveInProgress",0,true];
			// Reset health state and zero damage
			[_incap, false] remoteExec ["setUnconscious",_incap];
			// _incap setUnconscious false;
			_incap setdamage 0;		
			_incap setVariable ["unitwounds",[],true]; //added
			//COUNTDOWN TIMERS
			_incap setVariable ["Lifeline_countdown_start",false,true];
			_incap setVariable ["Lifeline_canceltimer",false,true];
			// _unit setVariable ["preventdeath",false,true]; // I dont think this is used. need to check

			_Lifeline_Down = (_incap getVariable ["Lifeline_Down",false]);

				_captive = _incap getVariable ["Lifeline_Captive", false];
				// if !(local _incap) then {
					[_incap, true] remoteExec ["allowDamage",0];
					// [_incap, false] remoteExec ["setCaptive",_incap];	
					[_incap, _captive] remoteExec ["setCaptive",0];	
				/* } else {
					_incap allowDamage true;
					// _incap setCaptive false;		
					_incap setCaptive _captive;		
				}; */

		};
		// waitUntil {lifestate _incap != "INCAPACITATED"}; // if incap is remote player, sometimes there is a delay. Wait until data catches up. // DO NOT USE. 
_exit
};

//new animation for bandage loop without pulling out weapon after each animation
Lifeline_Anim_Bandage_new = {
	params ["_incap","_medic","_randomanimloop","_cprcheck"];
	//AinvPpneMstpSlayWnonDnon_medicOther  for use later. For no weapon characters.

	if (_randomanimloop == 1) then {		
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};
		_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 10;
		_medic playmovenow "AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon";
		sleep 2;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 7;
			_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOtherOut";
			sleep 0.2;
		};
	};														

	if (_randomanimloop == 2) then {	
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};		
		_medic playmovenow "AinvPpneMstpSlayWpstDnon_medicOther";
		sleep 7;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 7;
			_medic playmoveNow "AinvPpneMstpSlayWpstDnon_medicOtherOut";
			sleep 0.2;
		};
	};

	if (_randomanimloop == 3) then {
		if (_cprcheck == true) then {  // to smooth animation if CPR animation was prevously
			_medic playmovenow "amovppnemstpsraswrfldnon"; sleep 4;
		};
		// _medic setAnimSpeedCoef 1.9;
		 _medic playmove "AmovPpneMstpSrasWrflDnon_AmovPpneMstpSrasWpstDnon"; 
		// _medic setAnimSpeedCoef 1;
		sleep 2;
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "AinvPpneMstpSlayWpstDnon_medicOther";
			sleep 4;
		};
	};

	if (_randomanimloop == 4) then {
		_medic playmovenow "amovppnemstpsraswrfldnon"; 
		while {_incap getVariable "num_bandages" > 0 && lifestate _incap == "INCAPACITATED" && lifestate _medic != "INCAPACITATED" &&  alive _incap} do {
			_medic switchmove "ainvppnemstpslaywrfldnon_medicother"; 
			sleep 7.607; 
		};
	_medic playmovenow "amovppnemstpsraswrfldnon_amovpercmstpsraswrfldnon"; 
	};														
};

Lifeline_autoRecover_check = {
	params ["_unit"];				
	_percentchance = Lifeline_autoRecover;
	//do this later
	// if (Lifeline_RevMethod ==2) then {
	// _quadstored = _unit getVariable ["quadstored",false];
	// };
	_randm = [1,100] call BIS_fnc_randomInt; 
	if (_percentchance == 100 OR _randm <= _percentchance) then {
		_unit setVariable ["Lifeline_autoRecover",true,true];
		true
	} else {
		_unit setVariable ["Lifeline_autoRecover",false,true];
		false
	};
};

Lifeline_countdown_timer2 = {
	params ["_unit","_seconds"];

	_bleedout = (_unit getVariable "LifelineBleedOutTime");
	_realseconds = round(_bleedout - time); // to adjust exactly	
	_counter = _realseconds;
	_colour = "#FFFAF8";	
	// _font = Lifelinefonts select Lifeline_HUD_dist_font;//added for distance

	while {_counter >= 0 && lifeState _unit == "INCAPACITATED"} do {

		if (_unit getVariable ["Lifeline_canceltimer",false]) exitWith {/*_unit setVariable ["Lifeline_canceltimer",false,true]; */};

		if (time > (_bleedout - (Lifeline_cntdwn_disply+3)) && Lifeline_RevMethod == 2) then {

			// if (_counter <= 60 && isPlayer _unit) then {_colour = "#A10A0A"};
			if (_counter <= 60 && isPlayer _unit) then {_colour = "#EF5736"};
			if (_counter <= 10 && isPlayer _unit) then {_colour = "#FF0000";playSound "beep_hi_1";};
			if (isPlayer _unit && _counter <= _seconds) then { 
					[format ["<t align='right' size='%3' color='%1'>..%2</t><br>..<br>..",_colour,_counter,0.7],((safeZoneW - 1) * 0.48),1.3,5,0,0,Lifelinetxt2Layer] spawn BIS_fnc_dynamicText;
					// [format ["<t align='right' size='%3' color='%1'>..%2</t><br>..<br>..",_colour,_counter,0.7],((safeZoneW - 1) * 0.48),1.3,1,0,0,LifelineBleedoutLayer] spawn BIS_fnc_dynamicText;
			};			
		};	

		//========================= ADDED distance
		if (Lifeline_HUD_distance) then {
			_AssignedMedic = (_unit getVariable ["Lifeline_AssignedMedic",[]]); 
			if (_AssignedMedic isNotEqualTo []) then {
				_incap = _unit;
				_medic = _AssignedMedic select 0;
				_distcalc = _medic distance2D _incap;
				if (isPlayer _incap && _distcalc > 10) then {
					// [format ["<t align='right' size='%3' color='%4' font='%5'>%1    %2m</t><br>..<br>..",name _medic, _distcalc toFixed 0,0.5,"#FFFAF8",_font],((safeZoneW - 1) * 0.48),1.26,3,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText; //BIS_fnc_dynamicText METHOD
					   [format ["<t align='right' size='%3' color='%4' font='%5'>%1    %2m</t><br>..<br>..",name _medic, _distcalc toFixed 0,0.5,"#FFFAF8",Lifeline_HUD_dist_font],((safeZoneW - 1) * 0.48),1.26,3,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText; //BIS_fnc_dynamicText METHOD
					// [format ["<t align='right' size='%3' color='%4' font='%5'>%1    %2m</t><br>..<br>..",name _medic, _distcalc toFixed 0,0.5,"#FFFAF8",_font],((safeZoneW - 1) * 0.48),1.26,5,0,0,LifelineDistLayer] spawn BIS_fnc_dynamicText; //BIS_fnc_dynamicText METHOD
				};
				if (isPlayer _incap && (_distcalc <= 10 && _distcalc >= 5 ) && Lifeline_HUD_distance) then {
					// ["",0.64,1.26,5,0,0,Lifelinetxt1Layer] remoteExec ["BIS_fnc_dynamicText",_incap];
					["",0.64,1.26,5,0,0,Lifelinetxt1Layer] spawn BIS_fnc_dynamicText;
					// ["",0.64,1.26,5,0,0,LifelineDistLayer] remoteExec ["BIS_fnc_dynamicText",_incap];
				};			
			};	
		};
		//last 3 are just counter instead of calc time
		if (_counter < 4) then {
			_counter = _counter - 1;
		} else { 
			// _counter = round(_bleedout - time);
			_counter = round((_unit getVariable "LifelineBleedOutTime") - time);
		};
		sleep 1;
	}; // end while

	// _unit setVariable ["Lifeline_canceltimer",false,true];
	_unit setVariable ["Lifeline_countdown_start",false,true];
};

Lifeline_reset_variables = {
	params ["_unit"];
	_unit setVariable ["Lifeline_Down",false,true];// for Revive Method 2
	_unit setVariable ["Lifeline_autoRecover",false,true];
	_unit setVariable ["Lifeline_allowdeath",false,true];
	_unit setVariable ["Lifeline_bullethits",0,true];
	_unit setVariable ["Lifeline_countdown_start",false,true];
	_unit setVariable ["Lifeline_canceltimer",false,true]; 
	_unit setVariable ["ReviveInProgress",0,true];
	if (Lifeline_RevMethod == 2 && Lifeline_BandageLimit > 1) then {
		_actionId = _x getVariable "Lifeline_ActionMenuWounds"; 
		if (!isNil "_actionId") then {
				[[_x,_actionId],{params ["_unit","_actionId"];_unit setUserActionText [_actionId, ""];}] remoteExec ["call", 0, true];
		};
	};
};

Lifeline_timer = {
	params ["_seconds"];
	sleep _seconds;
	true
};

// work in progress. Finish later.
/*
Lifeline_radio_how_copy = {
	params ["_voice","_medic"];
	sleep 2;
	//[_incap, [_voice+"_hangtight1", 50, 1, true]] remoteExec ["say3D", _incap];
	_RPArand = selectRandom RadioPartA;
	_RPBrand = selectRandom RadioPartB;
	_medic groupRadio (_voice+_RPArand); 
	_medic groupRadio (_voice+_RPBrand); 
};
*/

