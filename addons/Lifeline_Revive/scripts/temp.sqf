   _scenario = 0;
   _scenario = 1; // ALL BLUFOR THEN ALL OPFOR
   //_scenario = 1.5; // ALL BLUFOR 
   //_scenario = 1.6; // ALL BLUFOR INC. PLAYER EXP. BLACKLIST 
   //_scenario = 2; // HEAL 4 OPFOR
   //_scenario = 3; // INCAP 4 OPFOR
   //_scenario = 3.5; // INCAP 7 BLUFOR
   //_scenario = 4; // INCAP ALL BLUFOR PLAYER GROUP
   //_scenario = 5; // INCAP ALL BLUFOR EXCEPT BLACKLIST
   //_scenario = 6; // INCAP BLUFOR EACH GROUP AND HALF REST SUPPRESSED	
   //_scenario = 7; // INCAP OPFOR EACH GROUP AND HALF REST SUPPRESSED	
   //_scenario = 10; // ALL OPFOR THEN ALL BLUFOR
   //_scenario = 11; // HEAL 4 BLUFOR
   //_scenario = 12; // PLAYER GROUP 
   //_scenario = 20; // HEAL OPFOR SL
   //_scenario = 30; // debug statistics all units BLUFOR
   //_scenario = 31; // debug statistics all units OPFOR
   //_scenario = 32; // set behaviour "COMBAT" all OPFOR   
	   //_scenario = 40; // all BLUFOR except "Harry Wright"
   //_scenario = 41; // revive "Bradley Lewis"  
   //_scenario = 42; _resetname = "Ryan White"; // data on  
   //_scenario = 43; _resetname = "Cameron Wilson"; // reset idle medic "Hazib Nazari"  
   //_scenario = 44; // debug statistics for player  
   //_scenario = 45; // 7 from every GROUP BLUFOR   
   //_scenario = 46; // 7 from every GROUP BLUFOR PLUS PlAYER  
   //_scenario = 47; // 4 from every GROUP BLUFOR PLUS PlAYER NO BLACKLIST
   //_scenario = 48; // 4 from every GROUP any PLUS PlAYER NO BLACKLIST
   //_scenario = 49; // 1 less than total from every GROUP any PLUS PlAYER W BLACKLIST
   _scenario = 50; // 1 less than total from every GROUP any PLUS PlAYER 
   _count = 4; 
  {
		//if (_x == leader group _x && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0.71;};  // ONLY SL DOWN
		//if (_x == leader group _x && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0;};	// SL RECOVER
		//if (side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0.71;};						 // ALL OPFOR DOWN
		//if (!isPlayer _x && side group _x == Lifeline_Side) then {_x setDamage 0.71;};				 // ALL BLUFOR DOWN

	//if (_count > 0 && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0.71;};
	//if (_count > 0 && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0;};		  
	//_count =  _count - 1;
   } forEach Lifeline_All_Units;
	if (_scenario == 1) then {
		{if (!isPlayer _x && side group _x == Lifeline_Side) then {_x setDamage 0.71;};} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
		sleep 3;
		{if (side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0.71;};} forEach Lifeline_All_Units; // ALL OPFOR DOWN
	};
	if (_scenario == 1.5) then {
		{if (!isPlayer _x && side group _x == Lifeline_Side) then {_x setDamage 0.71;};} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
		//{if (!isPlayer _x && side group _x == Lifeline_Side and lifestate _x != "INCAPACITATED" && !([_x, _x] call Lifeline_Blacklist_Check)) then {
			//unassignVehicle _x;
			//_x enableAI "SUPPRESSION";
			//_x setSuppression 0;
			 //[_x] call Lifeline_delete_create_unit;
			//_x disableAI "ANIM";
			//_x enableAI "ANIM";

			//[_x,"test"] call serverSide_unitstate;
			//_x setDamage 0;	   
			//_pos = getPosATL _x;
			//_dir = getDir _x;
			//_newPos = [
				//(_pos select 0) + (sin _dir * 5),
				//(_pos select 1) + (cos _dir * 5),
				//(_pos select 2)
			//];
			//_x setPosATL _newPos;
		   //};
		//} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
   };
	if (_scenario == 1.6) then {
		{if (side group _x == Lifeline_Side && !([_x, _x] call Lifeline_Blacklist_Check)) then {_x setDamage 0.71;};} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
   };
	if (_scenario == 2) then {
		 { if (_count > 0 && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0;_count =  _count - 1; };		  
			} forEach Lifeline_All_Units;
	};
	if (_scenario == 3) then {
		 _count = 4;
		 {  if (_count > 0 && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0.75; _count =  _count - 1;  };} forEach Lifeline_All_Units;
	};
	if (_scenario == 3.5) then {
		 _count = 7;
		 {  if (_count > 0 && !isPlayer _x && side group _x == Lifeline_Side) then {_x setDamage 0.75; _count =  _count - 1;  };} forEach Lifeline_All_Units;
	};
	if (_scenario == 4) then {
		 {  if (!isPlayer _x && group _x == group player) then {_x setDamage 0.75;  };} forEach Lifeline_All_Units;
	};
	if (_scenario == 5) then {
		 {  if (!isPlayer _x && side group _x == Lifeline_Side && !([_x, _x] call Lifeline_Blacklist_Check)) then {_x setDamage 0.75;  };} forEach Lifeline_All_Units;
	};
	if (_scenario == 6) then {
		_count = 4;
		_count2 = 2;
		 { 
		  if (!isPlayer _x && side group _x == Lifeline_Side && !([_x, _x] call Lifeline_Blacklist_Check)) then {
			//_x setSuppression 0.9;
			_x setVariable ["testbaby",true]; 
			 if (_count > 0) then {_x setDamage 0.995;_count =  _count - 1; 
			  } else {
				if (_count2 > 0) then {
				//_x setSuppression 0;
				_x setVariable ["testbaby",false];
				_count2 =  _count2 - 1;			  
				};
			  };
		  };
		 } forEach Lifeline_All_Units;
	};
	if (_scenario == 7) then {
		_count = 8;
		_count2 = 3;
		 { 
		  if (!isPlayer _x && side group _x in Lifeline_OPFOR_Sides && !([_x, _x] call Lifeline_Blacklist_Check)) then {
		  //_x setSuppression 0.9;
		  _x setVariable ["testbaby",true]; 
			 if (_count > 0) then {_x setDamage 0.995;_count =  _count - 1; 
			  } else {
				if (_count2 > 0) then {
				//_x setSuppression 0;
				_x setVariable ["testbaby",false];
				_count2 =  _count2 - 1;			  
				};
			  };
		  };
		 } forEach Lifeline_All_Units;
	};
	if (_scenario == 10) then {
		{if (side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0.71;};} forEach Lifeline_All_Units; // ALL OPFOR DOWN
		 sleep 3;
		{if (!isPlayer _x && side group _x == Lifeline_Side) then {_x setDamage 0.71;};} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
	};
	if (_scenario == 11) then {
		 { if (_count > 0 && side group _x == Lifeline_Side) then {_x setDamage 0;_count =  _count - 1;};		  
		} forEach Lifeline_All_Units;
	};
	if (_scenario == 12) then {
		 { if (group _x == group player) then {_x setDamage 0.71};		  
		} forEach Lifeline_All_Units;
	};
	if (_scenario == 20) then {
		 {if (_x == leader group _x && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0;};} forEach Lifeline_All_Units;
	};

	if (_scenario == 30) then {
		 {if (side group _x == Lifeline_Side) then {[_x,"console"] call serverSide_unitstate;}} forEach Lifeline_All_Units;
	};
	if (_scenario == 31) then {
		 {if (side group _x in Lifeline_OPFOR_Sides) then {[_x,"console"] call serverSide_unitstate;}} forEach Lifeline_All_Units;
	};
	if (_scenario == 32) then {
		 {if (side group _x == Lifeline_Side) then {
		 _x disableAI "Move";

		 _x enableAI "Move";
		_x setBehaviour "COMBAT";
		[_x,"console"] call serverSide_unitstate;
		 }} forEach Lifeline_All_Units;
	};
	if (_scenario == 40) then {
		{if (!isPlayer _x && side group _x == Lifeline_Side && name _x != "Harry Wright") then {_x setDamage 0.71;};} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
	};
	if (_scenario == 41) then {
		{if (!isPlayer _x && side group _x == Lifeline_Side && name _x == "Matthew Nelson") then {_x setDamage 0;};} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
	};	
	if (_scenario == 42) then {
		{if (!isPlayer _x && name _x == _resetname) then {[_x,"console"] call serverSide_unitstate;};} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
	};
	if (_scenario == 43) then {
		{
			if (name _x == _resetname) then {
				//[_x] spawn Lifeline_delete_create_unit;
				//[_x] call reset_idle_medics; 
				[_x,"console"] call serverSide_unitstate;
			};
		} forEach Lifeline_All_Units; // ALL BLUFOR DOWN
	};
	if (_scenario == 44) then {
	   [player,"console"] call serverSide_unitstate;
	};
	if (_scenario == 45) then {
		{
			private _group = _x;
			private _units = units _group;
			private _count = 0;
			{
				//if (_count < 7 && !(_x getUnitTrait "medic") && !isPlayer _x && side group _x == Lifeline_Side && !([_x, _x] call Lifeline_Blacklist_Check)) then {
				if (_count < 7 && !isPlayer _x && side group _x == Lifeline_Side && !([_x, _x] call Lifeline_Blacklist_Check)) then {
					_x setDamage 0.75;
					_count = _count + 1;
				};
			} forEach _units;
			//sleep 0.1;
		} forEach allGroups;
	};
	if (_scenario == 46) then {
		{
			private _group = _x;
			private _units = units _group;
			private _count = 0;
			{
				if (_count < 7 && !isPlayer _x && side group _x == Lifeline_Side && !([_x, _x] call Lifeline_Blacklist_Check)) then {
					_x setDamage 0.75;
					_count = _count + 1;
				};
				if (isPlayer _x) then {
					 _x setDamage 0.75;			   
				};
			} forEach _units;
			//sleep 0.1;
		} forEach allGroups;
	};
	if (_scenario == 47) then {
		{
			private _group = _x;
			private _units = units _group;
			private _count = 0;
			{
				if (_count < 4 && !isPlayer _x && side group _x == Lifeline_Side) then {
					_x setDamage 0.75;
					_count = _count + 1;
				};
				if (isPlayer _x) then {
					 _x setDamage 0.75;			   
				};
			} forEach _units;
			//sleep 0.1;
		} forEach allGroups;
	};
	if (_scenario == 48) then {
		{
			private _group = _x;
			private _units = units _group;
			private _count = 0;
			{
				if (_count < 7 && !isPlayer _x) then {
					_x setDamage 0.75;
					_count = _count + 1;
				};
				if (isPlayer _x) then {
					 _x setDamage 0.75;			   
				};
			} forEach _units;
			//sleep 0.1;
		} forEach allGroups;
	};
	if (_scenario == 49) then {
		{
			private _group = _x;
			private _units = units _group;
			private _count = 1;
			_total = count _units;
			{
				if (_count < _total && !isPlayer _x && !([_x, _x] call Lifeline_Blacklist_Check)) then {
					_x setDamage 0.75;
					_count = _count + 1;
				};
				if (isPlayer _x) then {
					 _x setDamage 0.75;			   
				};
			} forEach _units;
			//sleep 0.1;
		} forEach allGroups;
	};	
	if (_scenario == 50) then {
		{
			private _group = _x;
			private _units = units _group;
			private _count = 1;
			_total = count _units;
			{
				if (_count < _total && !([_x, _x] call Lifeline_Blacklist_Check)) then {
					_x setDamage 0.75;
					_count = _count + 1;
				};
			} forEach _units;
			//sleep 0.1;
		} forEach allGroups;
	};

	//sleep 7;
	//{if (_x == leader group _x && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0;};} forEach Lifeline_All_Units; // SL RECOVER
	//{if (_x == leader group _x && side group _x in Lifeline_OPFOR_Sides) then {_x setDamage 0.71;};} forEach Lifeline_All_Units;  // ONLY SL DOWN

	