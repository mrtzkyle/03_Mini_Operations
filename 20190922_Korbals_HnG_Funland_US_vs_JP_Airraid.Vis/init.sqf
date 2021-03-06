RESPAWN_VEHICLE = {
private ["_veh", 
        "_OLDveh",
        "_KeepCargo",
        "_txtr",
        "_LoadStuff",
        "_CargoMAGS",
        "_CargoWEAP",
        "_CargoITEM",
        "_CargoBKP",
        "_syncedObjects",
        "_lockedArray",
        "_lockVeh",
        "_CurrentpylonMAGs",
        "_pylonPaths",
        "_i",
        "_j",
        "_k",
        "_nonPylonWeapons"
        
        ];
_veh = (_this select 0) select 0;
_OLDveh = (_this select 0) select 1;
_KeepCargo = _this select 1;
_CurrentpylonMAGs = getPylonMagazines _OLDveh;        //Get old vehicle pylon mags
_syncedObjects = synchronizedObjects _OLDveh;        //Get the old vehicles synced objects 
_txtr = getObjectTextures _OLDveh;                    //Get old vehicle textures
_OLDveh setpos [0,0,-9999];

///START SYNCED OBJECTS
//ZEUS_EDITABLE synchronizeObjectsAdd [_veh];
//{_x  synchronizeObjectsAdd [_veh]} foreach _syncedObjects;
//_veh synchronizeObjectsAdd _syncedObjects;        //This syncs the old objects to the new vehicle
///END SYNCED OBJECTS

///START VEHICLE LOCK
_lockedArray = ["UNLOCKED","DEFAULT","LOCKED","LOCKEDPLAYER"];    //This is needed to reset the vehicle lock
_lockVeh = locked _OLDveh;
_veh setVehicleLock (_lockedArray select _lockVeh);
///END VEHICLE LOCK

///START BLACK MAGIC FOR VEHICLE PYLONS
_pylonPaths = (configProperties [configFile >> "CfgVehicles" >> typeOf _veh >> "Components" >> "TransportPylonsComponent" >> "Pylons", "isClass _x"]) apply {getArray (_x >> "turret")};  //Gets pylon paths from Config
_nonPylonWeapons = []; 
{_nonPylonWeapons append getArray (_x >> "weapons")} forEach ([_veh, configNull] call BIS_fnc_getTurrets);
{_veh removeWeaponGlobal _x } forEach ((weapons _veh) - _nonPylonWeapons);

if (count _pylonPaths != 0) then {
    for "_j" from 0 to ((count _pylonPaths) -1) do {
        _veh setPylonLoadOut [_j + 1, _CurrentpylonMAGs select _j, false, _pylonPaths select _j];
        };
    };
///END BLACK MAGIC FOR VEHICLE PYLONS

///START VEHICLE TYPE SPECIFIC TWEAKS
if(typeOf _veh == "B_Plane_Fighter_01_F") then    {[_veh,"",["wing_fold_l",1]] call BIS_fnc_initVehicle}; //THIS WILL START THE JETS OFF WITH FOLDED WINGS
if(typeOf _veh == "B_Plane_Fighter_01_Stealth_F") then    {[_veh,"",["wing_fold_l",1]] call BIS_fnc_initVehicle}; //THIS WILL START THE JETS OFF WITH FOLDED WINGS
///END VEHICLE TYPE SPECIFIC TWEAKS

///START SET VEHICLE TEXTURE
if !(isNil "_txtr") then {
    for "_k" from 0 to (count _txtr - 1) do {
        _veh setObjectTextureGlobal [_k, _txtr select _k];
        };
    };
///END SET VEHICLE TEXTURE

///START VEHICLE CARGO
_LoadStuff = {
    private["_crate","_array","_count","_i","_Job", "_arr1", "_arr2"];
    //Usage [<object>, <Job>, <array>] call _LoadStuff
    _crate     = _this select 0; //Object ClassNames are being loaded into
    _Job     = _this select 1; //Options are "AMMO" , "WEAP" , "ITEM" , "BKP"
    _arr1     = (_this select 2) select 0; //ClassName
    _arr2     = (_this select 2) select 1; //Amount
    _count = count _arr1;
if(_Job == "AMMO") then {
    for "_i" from 0 to (_count - 1) do {
        _crate addMagazineCargoGlobal [(_arr1 select _i),(_arr2 select _i)];};};    
if(_Job == "WEAP") then {
    for "_i" from 0 to (_count - 1) do {
        _crate addWeaponCargoGlobal [(_arr1 select _i),(_arr2 select _i)];};};        
if(_Job == "ITEM") then {
    for "_i" from 0 to (_count - 1) do {
        _crate addItemCargoGlobal [(_arr1 select _i),(_arr2 select _i)];};};            
if(_Job == "BKP") then {
    for "_i" from 0 to (_count - 1) do {
        _crate addBackpackCargoGlobal [(_arr1 select _i),(_arr2 select _i)];};};            
    };
If (_KeepCargo != 0) then {
    clearMagazineCargoGlobal _veh;            
    clearWeaponCargoGlobal _veh;            
    clearItemCargoGlobal _veh;
    If (_KeepCargo == 2) then {
        _CargoMAGS     = getMagazineCargo _OLDveh;
        [_veh,"AMMO",_CargoMAGS] call _LoadStuff;
        _CargoWEAP     = getWeaponCargo _OLDveh;
        [_veh,"WEAP",_CargoWEAP] call _LoadStuff;
        _CargoITEM     = getItemCargo _OLDveh;
        [_veh,"ITEM",_CargoITEM] call _LoadStuff;
        _CargoBKP     = getBackpackCargo _OLDveh;
        [_veh,"BKP",_CargoBKP] call _LoadStuff;
        };
    };
///END VEHICLE CARGO
deleteVehicle _OLDveh;
};

// JIP Check (This code should be placed first line of init.sqf file)
if (!isServer && isNull player) then {isJIP=true;} else {isJIP=false;};

//Exec Vcom AI function
[] execVM "Vcom\VcomInit.sqf";
//End of Vcom commands

//////////////////////View Distance Settings///////////////////////////////////////////////////////////////////////////////////////////

CHVD_allowNoGrass = false;
CHVD_maxView = 12000;
CHVD_maxObj = 6000;

////////////////Anit Cheat/////////////////////////////////////////////////////

// Admin and cheat mods
if (["KA_proving_ground",
	"NSS_Admin_Console",
	"MGI_TP_V3",
	"MGI_TG",
	"XEDOM_AdminTool",
	"SSPCM",
	"Revo_DC", 
	"mcc_sandbox",
	"mcc_sandbox_curatorExp",
	"sn_backpack_air",
	"sn_backpack_tt",
	"sn_backpack_sw",
	"SPCONTROLMOD",
	"targetedBUGHANDLER",
	"TPW_HUD"] apply {isClass(configFile>>"CfgPatches">>_x)} findIf {_x} > -1) then{
	["AdminMod", false, 2] call BIS_fnc_endMission;};

    //Mods banned off the Server
if (["tf47_launchers",
	"ravage",
	"BloodSplatter",
	"BloodlustLITE_Auto",
	"BloodSplatterLITE",
	"AACC",
	"KA_Suitcase_Nuke",
	"hlcweapons_M134",
	"bullet_cases"] apply {isClass(configFile>>"CfgPatches">>_x)} findIf {_x} > -1) then{
		["RestrictedMods", false, 2] call BIS_fnc_endMission;};

//arsenal Block
if (["PA_arsenal",	
	"VAS_Diag",
	"Gear_Loadout", 
	"KA_VAA",
	"vaa_arsenal",
	"nks_arsenal",
	"IA_ACE_VAA",
	"Lordeath_arsenal",
	"Roys_Arsenal"] apply {isClass(configFile>>"CfgPatches">>_x)} findIf {_x} > -1) then{
	["ArsenalMod", false, 2] call BIS_fnc_endMission;};

///////////////////////////Remove Shack Tac vis////////////////////////////////////////////////

STGI_Update = {}; 
STNT_Update ={};

///////////////////////////Damage Disabled Area////////////////////////////////////////////////

0 = [] spawn { 
    while{true} do { 
        { 
            if(_x distance (getMarkerPos "mrk_safe_zone") < 200) then {_x allowDamage false} else {_x allowDamage true}; 
        } forEach allUnits + vehicles; 
        sleep 1; 
    }; 
};

///////////////////////////End Loading Screen////////////////////////////////////////////////

_EndSplashScreen = {
    for "_x" from 1 to 4 do {
        endLoadingScreen;
        sleep 3;
    };
};

[] spawn _EndSplashScreen;