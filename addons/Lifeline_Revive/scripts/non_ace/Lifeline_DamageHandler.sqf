params ["_unit"];
// call with curley bracket version
		[[_unit],
			{ //curely bracket start
				params ["_unit"];
				_unit removeAllEventHandlers "handleDamage";

				//ADD Lifeline CUSTOM DAMAGE HANDLER
				_actionId = _unit addEventHandler ["handleDamage", {
					params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator", "_hitPoint", "_directHit", "_context"];
					//change damage power curve
					// _powerValue = 1; 
					// _threshold = 0;
					// _damage = [_damage,_powerValue,_threshold] call powerCurve;
					_Lifeline_DHcount = _unit getVariable ["DHcount",0];
					_Lifeline_DHcount = _Lifeline_DHcount + 1;
					_unit setVariable ["DHcount",_Lifeline_DHcount,true];

					if (_hitPoint != "hitlegs" && _hitPoint != "hitarms" && _hitPoint != "hithands" && _damage >= 0.998 && !(_unit getVariable ["Lifeline_allowdeath",false])) then {
										_preventdeath = 0;   
										if (Lifeline_InstantDeath == 1) then {
											_preventdeath = _unit getVariable ["Lifeline_PreventDeath_count",0];
										};

										if (Lifeline_InstantDeath == 0 || Lifeline_InstantDeath == 1 && (_preventdeath < 4 && !(_hitPoint == "hithead" && _damage > 2.66))) then {
											// this resets the preventdeath counter after 3 seconds.
												if (Lifeline_InstantDeath == 1 && _preventdeath == 0) then {
													[_unit] spawn {
														params ["_unit"];
														sleep 3;
														_unit setVariable ["Lifeline_PreventDeath_count", 0, true]
													};
												};
											if (Lifeline_InstantDeath == 1) then {_unit setVariable ["Lifeline_PreventDeath_count", _preventdeath + 1, true]}; 
											_damage = 0.998; //there is a weird bug where a value of 0.999 will round up to 0.1 on the server, which breaks things. So better to use 0.998
										};
					};	

					if (_hitPoint == "" && _damage >= 1 && (_unit getVariable ["Lifeline_Down",false]) && Lifeline_InstantDeath != 3 && Lifeline_Revive_debug) then {
						_diag_text = format ["%1 | %2 xxxxxxxxxxxxxxxxxxxx KILLED WHILE DOWN xxxxxxxxxxxxxxxxxxx", name _unit, lifestate _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
						//_diag_text = format ["%1 | %2 xxxxxxxxxxxxxxxxxxxx KILLED WHILE DOWN xxxxxxxxxxxxxxxxxxx", name _unit, lifestate _unit]; if !(isServer) then {[_diag_text] remoteExec ["diag_log", 2];} else {diag_log _diag_text};
					};

					// use _hitPoint == "incapacitated" to count bullets. Its not exact but close enough.
					_bullethits = (_unit getVariable ["Lifeline_bullethits",0]); 
					if (_hitPoint == "incapacitated" && _directHit == true) then {
						// _damage = 0;
						_bullethits = _bullethits + 1;
						_unit setVariable ["Lifeline_bullethits",_bullethits,true];
					};

					//headshot version
					if (((_damage > Lifeline_IncapThres && _hitPoint == "") ||  damage _unit > Lifeline_IncapThres  ||  ((_hitPoint == "hitface" || _hitPoint == "hitneck" || _hitPoint == "hithead") && _damage >= 0.998)) && isTouchingGround vehicle _unit && !(_unit getVariable ["Lifeline_Down",false])) then {			
					// other version
					// if (((_damage > Lifeline_IncapThres && _hitPoint == "") ||  damage _unit > Lifeline_IncapThres ||  _hitPoint != "hitlegs" && _hitPoint != "hithands" && _hitPoint != "hitarms" && _damage > Lifeline_IncapThres) && isTouchingGround vehicle _unit && !(_unit getVariable ["Lifeline_Down",false])) then {

						// _unit setCaptive true;	
						// [_unit,true] remoteExec ["setCaptive", _unit];	

						// _BleedOut = (time + round Lifeline_BleedOutTime); //this in Lifeline_Incapped now
						// _unit setVariable ["LifelineBleedOutTime", _BleedOut, true];  // this in Lifeline_Incapped
						_unit setVariable ["countdowntimer",true,true];
						_unit setVariable ["Lifeline_Down",true,true];
						// _unit setUnconscious true; //TEMPOFF		
						[_unit,_damage,false] call Lifeline_Incapped;
						// [_unit,_damage,false] spawn Lifeline_Incapped;

					}; // === END INCAP GATE

					//=========== non-projectile damage like fire and falling
					if (_directHit == false && _hitPoint == "") then {
						_lastotherdamage = _unit getVariable ["lastotherdamage",0];
						_otherdamagediff = _damage - _lastotherdamage;
						_otherdamage = _unit getVariable ["otherdamage",0];
						_otherdamage = _otherdamage + _otherdamagediff;
						_unit setVariable ["otherdamage",_otherdamage,true];
						_unit setVariable ["lastotherdamage",_damage,true];
					};										
					//========================================================

					// prevent more damage if the unconcoius state was triggered (spawn above resets it after 5 secs however)
					if (_unit getVariable ["Lifeline_Down",false]) then {	
						// this prevent death is needed for quick single shots building up 
						if (_hitPoint == "" && _damage >= 0.999) then {
							_damage = 0.998;
							// _unit setVariable ["preventdeath",true,true];
						};							
					};

					// if (_damage == _last_dmg) exitWith {};
					// _unit setVariable ["last_dmg",_damage,true];	

					_damage 
				}]; //end DamageHandler
				// ADD DH ID
				_unit setVariable ["Lifeline_DH_ID",_actionId,true];

			} //end curly bracket
		// ] remoteExec ["call", _unit, true];
		] remoteExec ["call", 0, true];

