#include "ZSCconfig.sqf"

call compile preprocessFileLineNumbers "ZSC\gold\player_traderMenu.sqf";

BIS_fnc_numberDigits = compile preprocessFileLineNumbers "ZSC\compiles\numberDigits.sqf";
BIS_fnc_numberText = compile preprocessFileLineNumbers "ZSC\compiles\numberText.sqf"; 
SC_fnc_removeCoins = compile preprocessFileLineNumbers "ZSC\compiles\numberDigits.sqf";
SC_fnc_addCoins = compile preprocessFileLineNumbers "ZSC\compiles\numberDigits.sqf";

/*overwrites*/
if( isNil "ZSC_Overwrite_SelfActions" || ZSC_Overwrite_SelfActions)then{
fnc_usec_selfActions = compile preprocessFileLineNumbers "ZSC\compiles\fn_selfActions.sqf";
};
if( isNil "ZSC_Overwrite_SwitchModel" || ZSC_Overwrite_SwitchModel)then{
player_switchModel = compile preprocessFileLineNumbers "ZSC\compiles\player_switchModel.sqf";
};

player_gearSet	=	compile preprocessFileLineNumbers "ZSC\compiles\player_gearSet.sqf";
//This overwrite must happen, or change the files in your version of it. I Don't know any mod that changes this file tbh.


/*overwrites*/

BankDialogTransferAmount = 13000;
BankDialogPlayerBalance = 13001;
BankDialogBankBalance = 13002;
SCTraderDialogCatList = 32000;
SCTraderDialogItemList = 32001;
SCTraderDialogBuyPrice = 32002;
SCTraderDialogSellPrice = 32003;
GivePlayerDialogTransferAmount = 14000;
GivePlayerDialogPlayerBalance = 14001;

BankDialogUpdateAmounts = {
	_storage = ZSC_CurrentStorage;
	_index = ZSC_MoneyStorage find _storage;
	if(_index != -1)then{		
		ctrlSetText [BankDialogPlayerBalance, format["%1 %2", (player getVariable ['cashMoney', 0] call BIS_fnc_numberText), CurrencyName]];
		ctrlSetText [BankDialogBankBalance, format["%1 / %3 %2", (_storage getVariable ['bankMoney', 0] call BIS_fnc_numberText), CurrencyName, ZSC_MoneyCapacity select _index]];
	}else{		
		_vehicleType = typeOf _storage; 
		if(isClass(configFile >> "CfgVehicles" >> _vehicleType ))then{									
		_vehicleMagazines = getNumber (configFile >> "CfgVehicles" >> _vehicleType >> "transportMaxMagazines");		
		_sizeOfMoney = _vehicleMagazines * ZSC_MaxMoneyInVechileMultiplier;		
		ctrlSetText [BankDialogPlayerBalance, format["%1 %2", (player getVariable ['cashMoney', 0] call BIS_fnc_numberText), CurrencyName]];
		ctrlSetText [BankDialogBankBalance, format["%1 / %3 %2", (_storage getVariable ['bankMoney', 0] call BIS_fnc_numberText), CurrencyName, _sizeOfMoney]];
		};
	};
};

GivePlayerDialogAmounts = {
	ctrlSetText [GivePlayerDialogPlayerBalance, format["%1 %2", (player getVariable ['cashMoney', 0] call BIS_fnc_numberText), CurrencyName]];
	ctrlSetText [14003, format["%1", (name ZSC_GiveMoneyTarget)]];
};

BankDialogWithdrawAmount = {
	private ["_amount","_bank","_wealth"];
	
	_amount = parseNumber (_this select 0);	
	_bank = ZSC_CurrentStorage getVariable ["bankMoney", 0];
	_wealth = player getVariable["cashMoney",0];

	if (_amount < 1 or _amount > _bank) exitWith {
		cutText ["You can not withdraw more than is in your storage.", "PLAIN DOWN"];
	};

	player setVariable["cashMoney",(_wealth + _amount),true];
	ZSC_CurrentStorage setVariable["bankMoney",(_bank - _amount),true];

	PVDZE_plr_Save = [player,(magazines player),true,true] ;
	publicVariableServer "PVDZE_plr_Save";
	
	/*
	PVDZE_bank_Save = [player];
	publicVariableServer "PVDZE_bank_Save";
	*/
	PVDZE_veh_Update = [ZSC_CurrentStorage,"gear"];
	publicVariableServer "PVDZE_veh_Update";

	cutText [format["You have withdrawn %1 %2.", [_amount] call BIS_fnc_numberText, CurrencyName], "PLAIN DOWN"];
};

BankDialogDepositAmount = {
	private ["_amount","_bank","_wealth"];	
	_index = ZSC_MoneyStorage find _storage;	
	if(_index != -1)then{		
		_maxCap = ZSC_MoneyCapacity select _index;
	}else{
		_vehicleType = typeOf ZSC_CurrentStorage; 
		if(isClass(configFile >> "CfgVehicles" >> _vehicleType ))then{									
			_vehicleMagazines = getNumber (configFile >> "CfgVehicles" >> _vehicleType >> "transportMaxMagazines");		
			_maxCap = _vehicleMagazines * ZSC_MaxMoneyInVechileMultiplier;	
		}else{
			_maxCap = 0;
		};
	};
		
	_amount = parseNumber (_this select 0);
	_bank = ZSC_CurrentStorage getVariable ["bankMoney", 0];
	_wealth = player getVariable["cashMoney",0];
	
	if (_amount < 1 or _amount > _wealth) exitWith {
		cutText ["You can not deposit more than you have.", "PLAIN DOWN"];
	};

	if( ((_bank + _amount ) >  _maxCap)) then		
			cutText [format["You can only store a max of %1 %2, in this storage.", [_maxCap] call BIS_fnc_numberText,CurrencyName], "PLAIN DOWN"];
	}else{	
		player setVariable["cashMoney",(_wealth - _amount),true];
		ZSC_CurrentStorage setVariable["bankMoney",(_bank + _amount),true];
		cutText [format["You have deposited %1 %2.", [_amount] call BIS_fnc_numberText, CurrencyName], "PLAIN DOWN"];
	};
	PVDZE_plr_Save = [player,(magazines player),true,true] ;
	publicVariableServer "PVDZE_plr_Save";
	
	PVDZE_veh_Update = [ZSC_CurrentStorage,"gear"];
	publicVariableServer "PVDZE_veh_Update";
};

GivePlayerAmount = {
	private ["_amount","_target","_wealth"];
	
	_amount = parseNumber (_this select 0);
	_target = ZSC_GiveMoneyTarget;
	_wealth = player getVariable["cashMoney",0];
	_twealth = _target getVariable["cashMoney",0];
	_isMan = _target in playableUnits;

	if (_amount < 1 or _amount > _wealth) exitWith {
		cutText ["You can not give more than you currently have.", "PLAIN DOWN"];
    };

	if (!_isMan) exitWith {
		cutText ["You can only give money to a player", "PLAIN DOWN"];
	};

	player setVariable["cashMoney",_wealth - _amount, true];

	_target setVariable["cashMoney",_twealth + _amount, true];

	PVDZE_plr_Save = [player,(magazines player),true,true] ;
	publicVariableServer "PVDZE_plr_Save";
	PVDZE_plr_Save = [_target,(magazines _target),true,true] ;
	publicVariableServer "PVDZE_plr_Save";

	cutText [format["You gave %1 %2.", _amount, CurrencyName], "PLAIN DOWN"];
};