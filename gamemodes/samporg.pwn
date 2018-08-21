#include <a_samp>
#include <ocmd>
#include <a_mysql>
#include <streamer>
#include <sscanf2>
#include <timerfix>
#include <callbacks>
#include <mapandreas>

#define M_HOST "127.0.0.1"
#define M_USER "samporg"
#define M_PASS "W07oDGtwFkDt3o16"
#define M_DATA "samporg"

new txtstr[145];
#define SendFormMessage(%0,%1,%2,%3) format(txtstr, 145, %2, %3) && SendClientMessage(%0, %1, txtstr)
#define SendFormMessageToAll(%0,%1,%2) format(txtstr, 145, %1, %2) && SendClientMessageToAll(%0, txtstr)

// ----- Colors -----
#define COLOR_DARKGREEN 0x00CC00FF
#define COLOR_RED 0xFF0000FF
#define COLOR_GREY 0x8F8F8FFF
#define COLOR_YELLOW 0xEEEE00FF
#define COLOR_ADMINRED 0x8B2500FF
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_GREEN 0x00EE00FF
#define COLOR_LIGHTBLUE 0x3B83BDFF
// ------------------

// ----- Defines -----
#undef MAX_VEHICLES
#define MAX_VEHICLES 500
#define MAX_GARAGES 100
#undef MAX_PLAYERS
#define MAX_PLAYERS 50
// -------------------

// ----- Dialoge -----
enum {
	D_LOGIN,
	D_REGISTER,
	D_SHOWPLAYERVEHS,
	D_TRAVEL,
	D_RELOAD
};
// -------------------
enum PlayerData {
	id,
	Adminlevel,
	Money,
	Banned,
	BanReason[45],
	BanDate[20],
	BannedBy[MAX_PLAYER_NAME+1],
	Float:posX,
	Float:posY,
	Float:posZ,
	Float:posA,
	fsID,
	FightStyle,
	Skin,
	LoggedIn,
	dTimer
}
new pInfo[MAX_PLAYERS][PlayerData];

enum VehicleData {
	v_id,
	v_vehicleid,
	v_model,
	v_licenseplate[12],
	v_kilometers,
	v_owner,
	v_tank,
	v_color1,
	v_color2,
	v_paintjob,
	v_spoiler,
	v_hood,
	v_roof,
	v_sideskirt_left,
	v_sideskirt_right,
	v_nitro,
	v_lamps,
	v_exhaust,
	v_wheels,
	v_stereo,
	v_hydraulics,
	v_bullbar,
	v_bullbar_rear,
	v_bullbar_front,
	v_sign_front,
	v_bumper_front,
	v_bumper_rear,
	v_bullbars,
	v_vents
}
new vInfo[MAX_VEHICLES][VehicleData];

enum GarageData {
	g_id,
	g_Name[64],
	Text3D:g_3DText,
	g_Pickup,
	g_Type,
	Float:g_GarageX,
	Float:g_GarageY,
	Float:g_GarageZ,
	Float:g_GarageR,
	Float:g_SpawnX1,
	Float:g_SpawnY1,
	Float:g_SpawnZ1,
	Float:g_SpawnR1,
	Float:g_SpawnX2,
	Float:g_SpawnY2,
	Float:g_SpawnZ2,
	Float:g_SpawnR2,
	Float:g_SpawnX3,
	Float:g_SpawnY3,
	Float:g_SpawnZ3,
	Float:g_SpawnR3,
	Float:g_SpawnX4,
	Float:g_SpawnY4,
	Float:g_SpawnZ4,
	Float:g_SpawnR4
};
new gInfo[MAX_GARAGES][GarageData];

new VehNames[][] =
{
	"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel",
	"Dumper", "Firetruck", "Trashmaster", "Stretch", "Manana", "Infernus",
	"Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
	"Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection",
	"Hunter", "Premier", "Enforcer", "Securicar", "Banshee", "Predator", "Bus",
	"Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach", "Cabbie",
	"Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster", "Admiral",
	"Squalo", "Seasparrow", "Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder",
	"Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair", "Berkley's RC Van",
	"Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale",
	"Oceanic","Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy",
	"Hermes", "Sabre", "Rustler", "ZR-350", "Walton", "Regina", "Comet", "BMX",
	"Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper",
	"Rancher", "FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking",
	"Blista Compact", "Police Maverick", "Boxville", "Benson", "Mesa", "RC Goblin",
	"Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher", "Super GT",
	"Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt",
 	"Tanker", "Roadtrain", "Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra",
 	"FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck", "Fortune",
 	"Cadrona", "FBI Truck", "Willard", "Forklift", "Tractor", "Combine", "Feltzer",
 	"Remington", "Slamvan", "Blade", "Freight", "Streak", "Vortex", "Vincent",
	"Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder", "Primo",
	"Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite",
	"Windsor", "Monster", "Monster", "Uranus", "Jester", "Sultan", "Stratium",
	"Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
	"Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper",
	"Broadway", "Tornado", "AT-400", "DFT-30", "Huntley", "Stafford", "BF-400",
	"News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
	"Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car",
 	"Police Car", "Police Car", "Police Ranger", "Picador", "S.W.A.T", "Alpha",
 	"Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs", "Boxville",
 	"Tiller", "Utility Trailer"
};

forward CheckAccount(playerid);
forward AccountLogin(playerid);
forward AccountRegister(playerid);
forward SaveAccount(playerid);
forward KickPlayer(playerid);
forward ShowPlayerVehicles(playerid, garageid);
forward LoadGarages();
forward ResetDamageTimer(playerid);
forward UpdateClock();
forward OneSecondTimer(playerid);
forward RespawnPlayer(playerid, Float:X, Float:Y, Float:Z);
forward Unfreeze(playerid);
forward RestartServer();
forward UnloadGuns(playerid);

new MySQL:handler;
new Name[MAX_PLAYER_NAME][MAX_PLAYERS];
new SaveTimer[MAX_PLAYERS];
new FirstLogin[MAX_PLAYERS];
new Float:MarkPos[MAX_PLAYERS][4];
new MarkSaved[MAX_PLAYERS];
new LogIn[MAX_PLAYERS];
new DamageTimer[MAX_PLAYERS];
new TimeHour;
new TimeMinute;
new Text:Clock;
new PlayerText:Health[MAX_PLAYERS];
new PlayerText:Armour[MAX_PLAYERS];
new OneSecond[MAX_PLAYERS];
new Menu:HoboMenu;
new Weapon[MAX_PLAYERS][42];
new AdminRank[][15] = {
	"Player",
	"Supporter",
	"Administrator",
	"Server Owner"
};
new WeaponName[][47] = {
	"Fist", "Brass Knuckles", "Golf Club",
	"Nightstick", "Knife", "Baseball Bat",
	"Shovel", "Pool Cue", "Katana",
	"Chainsaw", "Purple Dildo", "Dildo",
	"Vibrator", "Silver Vibrator", "Flowers",
	"Cane", "Grenade", "Tear Gas",
	"Molotov Cocktail", "", "",
	"", "9mm", "Silenced 9mm",
	"Desert Eagle", "Shotgun", "Sawnoff Shotgun",
	"Combat Shotgun", "Micro SMG", "MP5",
	"AK-47", "M4", "Tec-9",
	"Country Rifle", "Sniper Rifle", "RPG",
	"HS Rocket", "Flamethrower", "Minigun",
	"Satchel Charge", "Detonator", "Spraycan",
	"Fire Extinguisher", "Camera", "",
	"", "Parachute"
};
enum rSp {
	rsID,
	Float:spawnX,
	Float:spawnY,
	Float:spawnZ,
	Float:spawnA,
	FightStyle
};
new randomSpawn[][rSp] = {
	{1, 2621.1633, 212.5138, 59.0695, 319.4377, FIGHT_STYLE_GRABKICK}, // HankyPanky
	{2, 2478.5625, -1245.8259, 28.7706, 183.5509, FIGHT_STYLE_BOXING}, // EastLS
	{3, 1955.5347, 691.5303, 10.8203, 89.1271, FIGHT_STYLE_NORMAL}, // RockShore West
	{4, -761.4552, 1615.0485, 27.1172, 356.1084, FIGHT_STYLE_ELBOW}, // Las Barrancas
	{5, -2080.5703, -2546.9583, 30.6250, 298.0318, FIGHT_STYLE_KNEEHEAD}, // AngelPine
	{6, -2240.5330, 577.3491, 35.1719, 182.1359, FIGHT_STYLE_KUNGFU} // Chinatown
};
new randomSkins[][6] = {
	{73, 78, 134, 135, 77, 197}, // HankyPanky
	{5, 6, 28, 30, 13, 190}, // EastLS
	{2, 3, 23, 29, 56, 53}, // RockShore West
	{179, 182, 183, 222, 207, 218}, // Last Barrancas
	{161, 128, 160, 168, 151, 129}, // AngelPine
	{123, 121, 229, 117, 141, 169} // Chinatown
};
enum TravelData {
	tID,
	Float:tX,
	Float:tY,
	Float:tZ,
	Float:tDX,
	Float:tDY,
	Float:tDZ,
	Float:tDA,
	tsName[35],
	Type
}
new TravelPos[][TravelData] = {
	/* Train Travel */
	{1, 1757.1107, -1944.0425, 13.5681, 1763.9489, -1943.1060, 13.5635, 314.7150, "Los Santos Train Station", 1},
	{2, 825.0736, -1353.6986, 13.5369, 817.8281, -1341.7056, 13.5263, 88.3601, "Los Santos Metro", 1},
	{3, -1975.3186, -569.3350, 25.6802, -1969.3849, -568.9618, 25.2988, 277.5843, "San Fierro Foster Valley", 1},
	{4, -1973.9847, 117.5540, 27.6875, -1972.8093, 137.6855, 27.6875, 88.4312, "San Fierro Train Station", 1},
	{5, -1688.8149, -17.1884, 3.5547, -1685.8719, -14.6223, 3.5547, 118.7823, "San Fierro Easter Basin", 1},
	{6, 571.1689, 1217.9426, 11.7905, 560.6390, 1217.8099, 11.7188, 233.5452, "Las Venturas Octane Spring", 1},
	{7, 730.0837, 1932.4736, 5.5391, 731.0877, 1940.3416, 5.5391, 104.5995, "Las Venturas Spread Ranch", 1},
	{8, 1436.2892, 2656.8005, 11.3926, 1432.7573, 2648.8611, 11.3926, 1.9973, "Las Venturas Train Station", 1},
	{9, 2379.0972, 2700.7095, 10.8081, 2396.5408, 2703.7183, 10.8203, 296.6951, "Las Venturas Spiny Bed", 1},
	{10, 2778.3882, 1732.4832, 11.3926, 2778.4707, 1751.4727, 11.3926, 110.5209, "Las Venturas Sobell", 1},
	{11, 2857.7542, 1314.5885, 11.3906, 2852.4817, 1290.8641, 11.3906, 88.9240, "Las Venturas Linden", 1},
	{12, 2295.1128, -1158.7957, 26.6275, 2295.1223, -1169.9501, 26.2464, 191.1737, "East Los Santos", 1},
	{13, 2218.1255, -1657.0381, 15.1890, 2215.0603, -1667.7705, 14.7600, 257.2626, "Los Santos Idlewood", 1},

	/* Boat Travel */
	{14, -2941.9460, 483.6489, 4.9103, -2947.6912, 492.8041, 2.4273, 183.5086, "San Fierro Ocean Flats", 2},
	{15, -2654.7236, 1487.6765, 7.1875, -2649.4011, 1480.3859, 7.1875, 46.8547, "San Fierro Battery Point", 2},
	{16, -2333.4551, 2329.5090, 4.9844, -2329.0029, 2317.4524, 3.5000, 14.5239, "Bayside", 2},
	{17, -1920.4556, 1391.9714, 7.1807, -1927.7982, 1392.1709, 7.1806, 270.8113, "San Fierro Esplanade North", 2},
	{18, -1484.9578, 718.0222, 7.1784, -1485.2469, 724.1362, 7.1786, 191.6976, "San Fierro Garver Bridge", 2},
	{19, -1629.8563, 150.1000, 3.5547, -1622.2632, 158.2154, 3.5547, 138.4562, "San Fierro Easter Basin", 2},
	{20, -469.3106, 608.4298, 15.1365, -481.3058, 609.6005, 10.1464, 267.2355, "Las Venturas Bone County", 2},
	{21, -654.1920, 915.2777, 11.7879, -657.4455, 900.7539, 6.9163, 354.2154, "Las Venturas Tierra Robada", 2},
	{22, -382.3287, 1166.7662, 19.3855, -393.0803, 1171.6830, 15.9760, 253.5828, "Las Venturas Fort Carson", 2},
	{23, -859.5013, 1421.9749, 13.9314, -868.9758, 1404.7815, 9.4526, 332.9549, "Las Venturas Las Barrancas", 2},
	{24, 786.6932, 391.2599, 21.7641, 793.5041, 400.4509, 18.9261, 137.6931, "Red County Trailer Park", 2},
	{25, 1635.2611, 624.1349, 10.8203, 1628.9712, 608.6076, 7.7557, 337.4368, "Las Venturas Randolph Industrial", 2},
	{26, 2294.6013, 606.5112, 10.8203, 2293.3772, 595.7621, 7.7813, 340.5154, "Las Venturas South", 2},
	{27, 2814.1946, 224.6030, 7.8577, 2812.5515, 240.8401, 1.8413, 174.2004, "Palomino Creek Hanky Panky Point", 2},
	{28, 2858.5774, -217.7820, 11.3871, 2869.5491, -222.4245, 7.9285, 53.9402, "Red County Palomino Creek", 2},
	{29, 2951.3684, -1455.3141, 10.6958, 2956.3003, -1464.9729, 9.3881, 345.6354, "Los Santos East Beach Plaza", 2},
	{30, 2900.6445, -2049.4778, 3.5480, 2914.5015, -2052.2422, 3.5480, 89.5435, "Los Santos East Beach", 2},
	{31, 2689.0317, -2327.4502, 13.3327, 2699.8652, -2327.0354, 13.3324, 90.4986, "Los Santos Harbour", 2},
	{32, 707.9387, -1739.6006, 14.0428, 706.5930, -1726.5690, 8.6875, 184.1178, "Los Santos Santa Marina Canal", 2},
	{33, 160.0530, -1884.6571, 3.7734, 167.7120, -1885.2415, 1.3050, 354.0833, "Los Santos Santa Marina Beach", 2},
	{34, -10.9137, -1099.2134, 7.4195, 0.3631, -1097.6772, 3.8187, 78.4862, "Los Santos Flint County", 2},
	{35, -352.2413, -446.0833, 7.2255, -339.8123, -454.7617, 3.4243, 45.0659, "Los Santos Fallen Tree", 2},
	{36, 380.6955, -255.6080, 2.6073, 384.6530, -264.3894, 1.2717, 11.4184, "Red County Blueberry", 2},
	{37, 1410.1971, -303.9029, 3.4553, 1407.9508, -290.0535, 1.9253, 197.1060, "Los Santos Mulholland", 2},
	{38, 2128.3730, -84.5710, 2.4684, 2114.9148, -96.4722, 2.1952, 302.0951, "Palomino Creek Fisher's Lagoon", 2},
	{39, -2652.1470, -2223.5852, 8.2197, -2655.7012, -2212.4973, 5.2244, 203.1263, "Angel Pine", 2},
	{40, -1258.9299, -2909.0313, 57.0163, -1265.0083, -2928.3586, 47.8922, 332.3703, "Whetstone", 2},

	/* Air Travel */
	{41, -2243.3499, 2340.9443, 4.9844, -2243.1079, 2327.2837, 4.9844, 347.8817, "Bayside", 3},
	{42, 1683.5175, 1447.8961, 10.7714, 1683.5175, 1447.8961, 10.7714, 272.3454, "Las Venturas Airport", 3},
	{43, 406.8473, 2534.8713, 16.5465, 406.8473, 2534.8713, 16.5465, 132.7081, "Las Venturas Boneyard Airfield", 3},
	{44, -1423.1484, -289.1392, 14.1484, -1423.1484, -289.1392, 14.1484, 137.1859, "San Fierro Airport", 3},
	{45, -2221.5974, 576.4275, 35.1719, -2216.2439, 577.3145, 35.1719, 92.6719, "San Fierro Chinatown", 3},
	{46, 1577.3860,-1330.0430,16.4844,1577.3860,-1330.0430,16.4844,316.2920, "Los Santos Startower", 3},
	{47, 1449.1116, -2286.8623, 13.5469, 1449.1116, -2286.8623, 13.5469, 90.5432, "Los Santos Airport", 3}
};

main() {
	print("\n");
	print("============================================================");
	print("Gamemode created for SA-MP.org");
	print("This gamemode is licensed under the GNU Affero General Public License v3.0");
	print("============================================================\n");
}

stock FIX_valstr(dest[], value, bool:pack = false)
{
    static const cellmin_value[] = !"-2147483648";

    if (value == cellmin)
        pack && strpack(dest, cellmin_value, 12) || strunpack(dest, cellmin_value, 12);
    else
        format(dest, 12, "%d", value), pack && strpack(dest, dest, 12);
}
#define valstr FIX_valstr

// ----- Commands -----
ocmd:spawn(playerid, params[]) {
	if(pInfo[playerid][Adminlevel] < 3) return NoPermission(playerid);
	new Pos = random(sizeof(randomSpawn));
	SetPlayerPos(playerid, randomSpawn[Pos][spawnX], randomSpawn[Pos][spawnY], randomSpawn[Pos][spawnZ]);
	SetPlayerFacingAngle(playerid, randomSpawn[Pos][spawnA]);
	pInfo[playerid][posX] = randomSpawn[Pos][spawnX];
	pInfo[playerid][posY] = randomSpawn[Pos][spawnY];
	pInfo[playerid][posZ] = randomSpawn[Pos][spawnZ];
	pInfo[playerid][posA] = randomSpawn[Pos][spawnA];
	pInfo[playerid][fsID] = randomSpawn[Pos][rsID];
	SetPlayerFightingStyle(playerid, randomSpawn[Pos][FightStyle]);
	pInfo[playerid][FightStyle] = randomSpawn[Pos][FightStyle];
	new pSkin = random(6);
	SetPlayerSkin(playerid, randomSkins[Pos][pSkin]);
	pInfo[playerid][Skin] = randomSkins[Pos][pSkin];
	AdminLog("/spawn", params, Name[playerid], "-", currentTime(1));
	return 1;
}

ocmd:respawn(playerid) {
	new Float:rX, Float:rY, Float:rZ;
	if(pInfo[playerid][dTimer] != 0) return SendClientMessage(playerid, COLOR_GREY, "You can't use this command just now!");
	if(GetMoney(playerid) < 300) return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to respawn!");
	GetPlayerPos(playerid, rX, rY, rZ);
	SetTimerEx("RespawnPlayer", 10000, 0, "ifff", playerid, rX, rY, rZ);
	SendClientMessage(playerid, COLOR_YELLOW, "You will respawn in 10 seconds, this cost you $300. Please stay at your current position!");
	return 1;
}

ocmd:sethealth(playerid, params[]) {
	new target, Float:health;
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	if(sscanf(params, "uf", target, health)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /sethealth <PlayerName/PlayerID> <Health>");
	if(health < 0 || health > 255) return SendClientMessage(playerid, COLOR_GREY, "Health have be between 0 and 255!");
	SetPlayerHealth(target, health);
	SendFormMessage(playerid, COLOR_YELLOW, "You have setted the health of %s to %.0f", Name[target], health);
	SendFormMessage(target, COLOR_YELLOW, "%s has setted your health to %.0f", Name[playerid], health);
	AdminLog("/sethealth", params, Name[playerid], Name[target], currentTime(1));
	return 1;
}

ocmd:setarmour(playerid, params[]) {
	new target, Float:armour;
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	if(sscanf(params, "uf", target, armour)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /setarmour <PlayerName/PlayerID> <Armour>");
	if(armour < 0 || armour > 255) return SendClientMessage(playerid, COLOR_GREY, "Armour have be between 0 and 255!");
	SetPlayerArmour(target, armour);
	SendFormMessage(playerid, COLOR_YELLOW, "You have setted the armour of %s to %.0f", Name[target], armour);
	SendFormMessage(target, COLOR_YELLOW, "%s has setted your armour to %.0f", Name[playerid], armour);
	AdminLog("/setarmour", params, Name[playerid], Name[target], currentTime(1));
	return 1;
}

ocmd:setweapon(playerid, params[]) {
	new weap, ammo, target;
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	if(sscanf(params, "uii", target, weap, ammo)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /setweapon <PlayerName/PlayerID> <WeaponID> <Ammo amount>");
	if(!IsValidWeapon(weap)) return SendClientMessage(playerid, COLOR_GREY, "Invalid weapon id!");
	if(ammo < 1 || ammo > 9999) return SendClientMessage(playerid, COLOR_GREY, "Invalid ammo amount!");
	GivePlayerGun(target, weap, ammo);
	SendFormMessage(playerid, COLOR_YELLOW, "You gave %s a weapon!", Name[target]);
	SendFormMessage(target, COLOR_YELLOW, "%s gave you a weapon!", Name[playerid]);
	AdminLog("/setweapon", params, Name[playerid], Name[target], currentTime(1));
	return 1;
}

ocmd:goto(playerid, params[]) {
	new target, Float:X, Float:Y, Float:Z;
	if(pInfo[playerid][Adminlevel] >= 1) {
		if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /goto <PlayerName/PlayerID>");
		if(!IsPlayerConnected(target) || pInfo[playerid][LoggedIn] == 0) return SendClientMessage(playerid, COLOR_GREY, "This player isn't loggedin!");
		GetPlayerPos(target, X, Y, Z);
		if(!IsPlayerInAnyVehicle(playerid)) SetPlayerPos(playerid, X, Y+1, Z);
		else SetVehiclePos(GetPlayerVehicleID(playerid), X, Y+2, Z);
		SendFormMessage(playerid, COLOR_YELLOW, "You have teleported to the player %s.", Name[target]);
		SendFormMessage(target, COLOR_YELLOW, "Admin %s have teleported to you.", Name[playerid]);
		AdminLog("/goto", params, Name[playerid], Name[target], currentTime(1));
		return 1;
	} return NoPermission(playerid);
}

ocmd:admins(playerid, params[]) {
	new count = 0;
	if(pInfo[playerid][LoggedIn] == 0) return 1;
	SendClientMessage(playerid, COLOR_GREEN, "Adminlist:");
	for(new i = 0; i < MAX_PLAYERS; i++) {
		if(pInfo[i][Adminlevel] < 1 || IsPlayerPaused(i)) continue;
		SendFormMessage(playerid, COLOR_WHITE, "%s - %s [%d]", AdminRank[pInfo[i][Adminlevel]], Name[i], i);
		count ++;
	}
	if(count == 0) return SendClientMessage(playerid, COLOR_WHITE, "There are no admins online!");
	return 1;
}

ocmd:setadmin(playerid, params[]) {
	new target, rank;
	if(IsPlayerAdmin(playerid) && (!strcmp(Name[playerid], "Shirobaka") || !strcmp(Name[playerid], "Bobby"))) {
		if(sscanf(params, "ui", target, rank)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /setadmin <PlayerID/PlayerName> <Rank>");
		if(rank < 0 || rank > 3) return SendClientMessage(playerid, COLOR_GREY, "The admin-rank should be between 0 and 3"), SendClientMessage(playerid, COLOR_GREY, "0 = player, 1 = supporter, 2 = administrator, 3 = server owner");
		if(pInfo[target][LoggedIn] == 0) return SendClientMessage(playerid, COLOR_GREY, "This player is not loggedin!");
		if(pInfo[target][Adminlevel] == rank) return SendClientMessage(playerid, COLOR_GREY, "This player is already at this admin-level!");
		if(rank > pInfo[target][Adminlevel]) SendFormMessage(playerid, COLOR_LIGHTBLUE, "You have promoted %s to a %s", Name[target], AdminRank[rank]), SendFormMessage(target, COLOR_LIGHTBLUE, "%s has promoted you to a %s", Name[playerid], AdminRank[rank]);
		else  SendFormMessage(playerid, COLOR_LIGHTBLUE, "You have demoted %s to a %s", Name[target], AdminRank[rank]), SendFormMessage(target, COLOR_LIGHTBLUE, "%s has demoted you to a %s", Name[playerid], AdminRank[rank]);
		pInfo[target][Adminlevel] = rank;
		AdminLog("/setadmin", params, Name[playerid], Name[target], currentTime(1));
		return 1;
	} return 1;
}

ocmd:gotopos(playerid, params[]) {
	new Float:Pos[3];
	if(pInfo[playerid][Adminlevel] >= 1) {
		if(sscanf(params, "p<,>fff", Pos[0], Pos[1], Pos[2])) return SendClientMessage(playerid, COLOR_GREY, "Usage: /gotopos <X> <Y> <Z>");
		if(!IsPlayerInAnyVehicle(playerid)) SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		else SetVehiclePos(GetPlayerVehicleID(playerid), Pos[0], Pos[1], Pos[2]);
		SendFormMessage(playerid, COLOR_YELLOW, "You have teleported to the coordinate %0.2f %0.2f %0.2f", Pos[0], Pos[1], Pos[2]);
		AdminLog("/gotopos", params, Name[playerid], "-", currentTime(1));
		return 1;
	} return NoPermission(playerid);
}

ocmd:gethere(playerid, params[]) {
	new target, Float:X, Float:Y, Float:Z;
	if(pInfo[playerid][Adminlevel] >= 1) {
		if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /gethere <PlayerName/PlayerID>");
		if(!IsPlayerConnected(target) || pInfo[playerid][LoggedIn] == 0) return SendClientMessage(playerid, COLOR_GREY, "This player isn't loggedin!");
		GetPlayerPos(playerid, X, Y, Z);
		if(!IsPlayerInAnyVehicle(target)) SetPlayerPos(target, X, Y+1, Z);
		else SetVehiclePos(GetPlayerVehicleID(target), X, Y+2, Z);
		SendFormMessage(playerid, COLOR_YELLOW, "You have teleported the player %s to you.", Name[target]);
		SendFormMessage(target, COLOR_YELLOW, "Admin %s has teleported you to him", Name[playerid]);
		AdminLog("/gethere", params, Name[playerid], Name[target], currentTime(1));
		return 1;
	} return NoPermission(playerid);
}

ocmd:kick(playerid, params[]) {
	new target, reason[45], Query[256];
	if(pInfo[playerid][Adminlevel] >= 1) {
		if(sscanf(params, "us[45]", target, reason)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /kick <PlayerName/PlayerID> <Reason>");
		if(!IsPlayerConnected(target)) return SendClientMessage(playerid, COLOR_GREY, "This player isn't loggedin!");
		if(pInfo[target][Adminlevel] >= pInfo[playerid][Adminlevel] && pInfo[playerid][Adminlevel] < 3) return SendClientMessage(playerid, COLOR_GREY, "You are not allowed to use this command on this player!");
		SendFormMessageToAll(COLOR_ADMINRED, "[ADM]: %s got kicked by %s for %s", Name[target], Name[playerid], reason);
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `PunishLog` (`Type`, `Target`, `Admin`, `Reason`, `Time`) VALUES ('Kick', '%e', '%e', '%e', '%e')", Name[target], Name[playerid], reason, currentTime(1));
		mysql_query(handler, Query);
		AdminLog("/kick", params, Name[playerid], Name[target], currentTime(1));
		SetTimerEx("KickPlayer", 50, 0, "i", playerid);
		return 1;
	} return NoPermission(playerid);
}

ocmd:ban(playerid, params[]) {
	new target, reason[45], Query[256];
	if(pInfo[playerid][Adminlevel] >= 2) {
		if(sscanf(params, "us[45]", target, reason)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /ban <PlayerName/PlayerID> <Reason>");
		if(!IsPlayerConnected(playerid)) return SendClientMessage(playerid, COLOR_GREY, "This player isn't loggedin!");
		if(pInfo[target][Adminlevel] >= pInfo[playerid][Adminlevel] && pInfo[playerid][Adminlevel] < 5) return SendClientMessage(playerid, COLOR_GREY, "You are not allowed to use this command on this player!");
		SendFormMessageToAll(COLOR_ADMINRED, "[ADM]: %s got banned by %s for %s", Name[target], Name[playerid], reason);
		pInfo[target][Banned] = 1;
		format(pInfo[target][BanReason], 45, "%s", reason);
		format(pInfo[target][BanDate], 20, "%s", currentTime(1));
		format(pInfo[target][BannedBy], MAX_PLAYER_NAME+1, "%s", Name[playerid]);
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `PunishLog` (`Type`, `Target`, `Admin`, `Reason`, `Time`) VALUES ('Ban', '%e', '%e', '%e', '%e')", Name[target], Name[playerid], reason, currentTime(1));
		mysql_query(handler, Query);
		AdminLog("/ban", params, Name[playerid], Name[target], currentTime(1));
		SetTimerEx("KickPlayer", 50, 0, "i", playerid);
		return 1;
	} return NoPermission(playerid);
}

ocmd:gmx(playerid, params[]) {
	if(pInfo[playerid][Adminlevel] == 3) {
		for(new i = 0; i < MAX_PLAYERS; i++) {
			if(pInfo[i][LoggedIn] == 1) SaveAccount(i);
		}
		SetTimer("RestartServer", 5000, 0);
		SendClientMessageToAll(COLOR_RED, "The server will restarting in 5 seconds!");
		return 1;
	} return NoPermission(playerid);
}

ocmd:loadcar(playerid, params[])
{
	for(new i; i < sizeof(gInfo); i++)
	{
		if(!IsPlayerInRangeOfPoint(playerid, 3, gInfo[i][g_GarageX], gInfo[i][g_GarageY], gInfo[i][g_GarageZ])) continue;
		new string[256];
		mysql_format(handler, string, sizeof(string), "SELECT * FROM `Vehicles` WHERE `owner` = '%d'", pInfo[playerid][id]);
		mysql_pquery(handler, string, "ShowPlayerVehicles", "dd", playerid, i);
		return 1;
	}
	return SendClientMessage(playerid, COLOR_WHITE, "You are not at a garage.");
}

ocmd:veh(playerid, params[]) {
	new vehicle[25], sCar, Float:X, Float:Y, Float:Z, Float:A, aVehicle, color1, color2;
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	if(sscanf(params, "s[25]I(-255)I(-255)", vehicle, color1, color2)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /veh <VehicleID/VehicleName> <Color1 (optional)> <Color2 (optional)>");
	if(color1 == -255) color1 = random(256);
	if(color2 == -255) color2 = random(256);
	if(!IsNumeric(vehicle)) sCar = GetVehicleModelFromName(vehicle);
	else sCar = strval(vehicle);
	if(sCar == -1) return SendFormMessage(playerid, COLOR_GREY, "The vehicle %s can not be found!", vehicle);
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, A);
	aVehicle = CreateVehicle(sCar, X, Y, Z+0.5, A, color1, color2, -1);
	PutPlayerInVehicle(playerid, aVehicle, 0);
	AdminLog("/veh", params, Name[playerid], "-", currentTime(1));
	return 1;
}

ocmd@2:dveh,delveh(playerid, params[]) {
	new vehicle, vstring[25];
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	if(sscanf(params, "d", vehicle)) {
		if(!IsPlayerInAnyVehicle(playerid)) {
			SendClientMessage(playerid, COLOR_GREY, "You need to be in a vehicle or give a vehicleid");
			SendClientMessage(playerid, COLOR_GREY, "Usage: /dveh <VehicleID>");
			return 1;
		} else {
			DestroyVehicle(GetPlayerVehicleID(playerid));
			SendFormMessage(playerid, COLOR_WHITE, "You have deleted the vehicle %d", GetPlayerVehicleID(playerid));
			format(vstring, 25, "%d", GetPlayerVehicleID(playerid));
			AdminLog("/dveh", vstring, Name[playerid], "-", currentTime(1));
			return 1;
		}
	} else {
		if(!GetVehicleModel(vehicle)) {
			return SendClientMessage(playerid, COLOR_GREY, "This vehicle doesn't exists!");
		} else {
			DestroyVehicle(vehicle);
			SendFormMessage(playerid, COLOR_WHITE, "You have deleted the vehicle %d", vehicle);
			AdminLog("/dveh", params, Name[playerid], "-", currentTime(1));
			return 1;
		}
	}
}

ocmd:buy(playerid) {
	if(IsPlayerInRangeOfPoint(playerid, 2.0, 458.5027, -107.3624, 999.5454)) {
		ShowMenuForPlayer(HoboMenu, playerid);
		TogglePlayerControllable(playerid, 0);
	} return 1;
}

ocmd:enter(playerid) {
	if(IsPlayerInAnyVehicle(playerid)) return 1;
	if(IsPlayerInRangeOfPoint(playerid, 5.0, 875.9323, -968.3762, 37.1875)) {
		TogglePlayerControllable(playerid, 0);
		SetTimerEx("Unfreeze", 1500, 0, "i", playerid);
		SetPlayerPos(playerid, 459.0843, -110.5203, 999.5454);
		SetPlayerFacingAngle(playerid, 2.4657);
		SetPlayerInterior(playerid, 5);
	} return 1;
}

ocmd:exit(playerid) {
	if(IsPlayerInAnyVehicle(playerid)) return 1;
	if(IsPlayerInRangeOfPoint(playerid, 2.0, 458.8982, -110.7152, 999.5454)) {
		SetPlayerPos(playerid, 875.9323, -968.3762, 37.1875);
		SetPlayerInterior(playerid, 0);
	} return 1;
}

ocmd:jetpack(playerid) {
	if(IsPlayerInAnyVehicle(playerid)) return 1;
	if(pInfo[playerid][Adminlevel] == 3) {
		SetPlayerSpecialAction(playerid, SPECIAL_ACTION_USEJETPACK);
		AdminLog("/jetpack", "-", Name[playerid], "-", currentTime(1));
	} return NoPermission(playerid);
}

ocmd:fixveh(playerid) {
	if(pInfo[playerid][Adminlevel] < 1) return NoPermission(playerid);
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You need to be in a vehicle!");
	RepairVehicle(GetPlayerVehicleID(playerid));
	SendClientMessage(playerid, COLOR_GREEN, "Your vehicle has been successfully repaired!");
	AdminLog("/fixveh", "-", Name[playerid], "-", currentTime(1));
	return 1;
}

ocmd:travel(playerid) {
	new string[1024];
	if(pInfo[playerid][LoggedIn] == 0) return 1;
	if(IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You can't travel with your vehicle!");
	if(pInfo[playerid][dTimer] > 0) return SendClientMessage(playerid, COLOR_GREY, "You are involved in a fight, you can't travel now!");
	for(new i = 0; i < sizeof(TravelPos); i++) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ])) {
			/* Train Travel */
			if(i == 0) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Los Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spinybed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 1) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "San Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 2) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "San Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 3) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "San Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 4) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 5) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 6) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
		 	else if(i == 7) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 8) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 9) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 10) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "East Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 11) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Los Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nNearest Harbour\nNearest Airport", "Travel", "Cancel");
			else if(i == 12) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Los Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nSan Fierro Easter Basin\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spiny Bed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nNearest Harbour\nNearest Airport", "Travel", "Cancel");

			/* Boat Travel */
			else if(i == 13) {
				strcat(string, "San Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\n");
				strcat(string, "Red County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\n");
				strcat(string, "Los Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 14) {
				strcat(string, "Bayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\n");
				strcat(string, "Las Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\n");
				strcat(string, "Los Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 15) {
				strcat(string, "San Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\n");
				strcat(string, "Las Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\n");
				strcat(string, "Los Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 16) {
				strcat(string, "San Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\n");
				strcat(string, "Palomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\n");
				strcat(string, "Red County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 17) {
				strcat(string, "San Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\n");
				strcat(string, "Red County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\n");
				strcat(string, "Los Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 18) {
				strcat(string, "Las Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\n");
				strcat(string, "Los Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\n");
				strcat(string, "Palomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 19) {
				strcat(string, "Las Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\n");
				strcat(string, "Los Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\n");
				strcat(string, "Angel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 20) {
				strcat(string, "Las Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\n");
				strcat(string, "Los Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\n");
				strcat(string, "Whetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 21) {
				strcat(string, "Las Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\n");
				strcat(string, "Los Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\n");
				strcat(string, "Whetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 22) {
				strcat(string, "Red County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\n");
				strcat(string, "Los Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\n");
				strcat(string, "San Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 23) {
				strcat(string, "Las Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\n");
				strcat(string, "Los Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\n");
				strcat(string, "San Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 24) {
				strcat(string, "Las Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\n");
				strcat(string, "Los Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\n");
				strcat(string, "Bayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 25) {
				strcat(string, "Palomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\n");
				strcat(string, "Los Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\n");
				strcat(string, "San Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 26) {
				strcat(string, "Red County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\n");
				strcat(string, "Red County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\n");
				strcat(string, "San Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 27) {
				strcat(string, "Los Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\n");
				strcat(string, "Los Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\n");
				strcat(string, "San Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 28) {
				strcat(string, "Los Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\n");
				strcat(string, "Palomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\n");
				strcat(string, "Las Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 29) {
				strcat(string, "Los Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\n");
				strcat(string, "Angel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\n");
				strcat(string, "Las Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 30) {
				strcat(string, "Los Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\n");
				strcat(string, "Whetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\n");
				strcat(string, "Las Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 31) {
				strcat(string, "Los Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\n");
				strcat(string, "San Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\n");
				strcat(string, "Red County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 32) {
				strcat(string, "Los Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\n");
				strcat(string, "San Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\n");
				strcat(string, "Las Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 33) {
				strcat(string, "Los Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\n");
				strcat(string, "Bayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\n");
				strcat(string, "Las Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 34) {
				strcat(string, "Red County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\n");
				strcat(string, "San Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\n");
				strcat(string, "Palomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 35) {
				strcat(string, "Los Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\n");
				strcat(string, "San Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\n");
				strcat(string, "Red County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 36) {
				strcat(string, "Palomino Creek Fisher's Lagoon\nAngel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\n");
				strcat(string, "San Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\n");
				strcat(string, "Los Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 37) {
				strcat(string, "Angel Pine\nWhetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\n");
				strcat(string, "Las Venturas Bone County\nLas Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\n");
				strcat(string, "Los Santos East Beach Plaza\nLos Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 38) {
				strcat(string, "Whetstone\nSan Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\n");
				strcat(string, "Las Venturas Tierra Robada\nLas Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach Plaza\n");
				strcat(string, "Los Santos East Beach\nLos Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			} else if(i == 39) {
				strcat(string, "San Fierro Ocean Flats\nSan Fierro Battery Point\nBayside\nSan Fierro Esplanade North\nSan Fierro Garver Bridge\nSan Fierro Easter Basin\nLas Venturas Bone County\nLas Venturas Tierra Robada\n");
				strcat(string, "Las Venturas Fort Carson\nLas Venturas Las Barrancas\nRed County Trailer Park\nLas Venturas Randolph Industrial\nLas Venturas South\nPalomino Creek Hanky Panky Point\nRed County Palomino Creek\nLos Santos East Beach Plaza\nLos Santos East Beach Plaza\nLos Santos East Beach\n");
				strcat(string, "Los Santos Harbour\nLos Santos Santa Marina Canal\nLos Santos Santa Marina Beach\nLos Santos Flint County\nLos Santos Fallen Tree\nRed County Blueberry\nLos Santos Mulholland\nPalomino Creek Fisher's Lagoon\nAngel Pine\nNearest Airport\nNearest Train Station");
				ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", string, "Travel", "Cancel");
			}

			/* Air Travel */
			else if(i == 40) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Airport\nLas Venturas Boneyard Airfield\nSan Fierro Airport\nSan Fierro Chinatown\nLos Santos Startower\nLos Santos Airport\nNearest Harbour\nNearest Train Station", "Travel", "Cancel");
			else if(i == 41) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Boneyard Airfield\nSan Fierro Airport\nSan Fierro Chinatown\nLos Santos Startower\nLos Santos Airport\nBayside\nNearest Harbour\nNearest Train Station", "Travel", "Cancel");
			else if(i == 42) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "San Fierro Airport\nSan Fierro Chinatown\nLos Santos Startower\nLos Santos Airport\nLas Venturas Airport\nBayside\nNearest Harbour\nNearest Train Station", "Travel", "Cancel");
			else if(i == 43) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "San Fierro Chinatown\nLos Santos Startower\nLos Santos Airport\nLas Venturas Airport\nBayside\nLas Venturas Boneyard Airfield\nNearest Harbour\nNearest Train Station", "Travel", "Cancel");
			else if(i == 44) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Los Santos Startower\nLos Santos Airport\nLas Venturas Airport\nBayside\nLas Venturas Boneyard Airfield\nSan Fierro Airport\nNearest Harbour\nNearest Train Station", "Travel", "Cancel");
			else if(i == 45) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Los Santos Airport\nLas Venturas Airport\nBayside\nLas Venturas Boneyard Airfield\nSan Fierro Airport\nSan Fierro Chinatown\nNearest Harbour\nNearest Train Station", "Travel", "Cancel");
			else if(i == 46) ShowPlayerDialog(playerid, D_TRAVEL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Airport\nBayside\nLas Venturas Boneyard Airfield\nSan Fierro Airport\nSan Fierro Chinatown\nLos Santos Startower\nNearest Harbour\nNearest Train Station", "Travel", "Cancel");
			SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
			return 1;
		}
	} return SendClientMessage(playerid, COLOR_GREY, "You are not at a travel point!");
}

ocmd:mark(playerid) {
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	GetPlayerPos(playerid, MarkPos[playerid][0], MarkPos[playerid][1], MarkPos[playerid][2]);
	GetPlayerFacingAngle(playerid, MarkPos[playerid][3]);
	MarkSaved[playerid] = 1;
	AdminLog("/mark", "-", Name[playerid], "-", currentTime(1));
	return SendClientMessage(playerid, COLOR_WHITE, "Position saved, teleport with /gotomark");
}

ocmd:gotomark(playerid) {
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	if(!MarkSaved[playerid]) return SendClientMessage(playerid, COLOR_GREY, "You have no position saved!");
	SetPlayerPos(playerid, MarkPos[playerid][0], MarkPos[playerid][1], MarkPos[playerid][2]);
	SetPlayerFacingAngle(playerid, MarkPos[playerid][3]);
	AdminLog("/gotomark", "-", Name[playerid], "-", currentTime(1));
	return SendClientMessage(playerid, COLOR_WHITE, "You have successfully teleported to your marked position!");
}

ocmd:reload(playerid, params[])
{
	if(pInfo[playerid][Adminlevel] < 3) return NoPermission(playerid);
	ShowPlayerDialog(playerid, D_RELOAD, DIALOG_STYLE_LIST, "{FFFFFF}Systems:", "{FFFFFF}Garage", "Reload", "Close");
	return 1;
}

public OnGameModeInit()
{
	mysql_log(ALL);
	handler = mysql_connect(M_HOST, M_USER, M_PASS, M_DATA);
	if(mysql_errno() != 0) printf("Database connection could not be established! (%d)", mysql_errno());
	else print("Database connection successfully established!");

	MapAndreas_Init(MAP_ANDREAS_MODE_FULL);

	mysql_pquery(handler, "SELECT * FROM `Garages`", "LoadGarages");

	TimeHour = 6;
	TimeMinute = 0;
	SetTimer("UpdateClock", 10000, 1);

	Clock = TextDrawCreate(548.332946, 22.700006, "06:00");
	TextDrawLetterSize(Clock, 0.567666, 2.218514);
	TextDrawAlignment(Clock, 1);
	TextDrawColor(Clock, -1);
	TextDrawSetShadow(Clock, 0);
	TextDrawSetOutline(Clock, 2);
	TextDrawBackgroundColor(Clock, 255);
	TextDrawFont(Clock, 3);
	TextDrawSetProportional(Clock, 1);
	TextDrawSetShadow(Clock, 0);

	/* Objects */
	// HeliPad SF
	CreateDynamicObject(3934,-2228.8000000,590.2000100,50.4000000,0.0000000,0.0000000,270.0000000); //object(helipad01) (1)
	CreateDynamicObject(16337,-2218.3000000,581.2000100,50.6000000,0.0000000,0.0000000,0.7480000); //object(des_cranecontrol) (1)
	CreateDynamicObject(1215,-2215.6001000,601.7999900,51.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (1)
	CreateDynamicObject(1215,-2219.6001000,579.0999800,51.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (2)
	CreateDynamicObject(1215,-2215.6001000,582.4000200,51.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (3)
	CreateDynamicObject(1215,-2236.8999000,579.0999800,51.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (4)
	CreateDynamicObject(1215,-2242.3000000,583.7999900,51.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (5)
	CreateDynamicObject(1215,-2242.3000000,597.0999800,51.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (6)
	CreateDynamicObject(1215,-2236.8000000,601.9000200,51.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (7)

	// SF Hafen
	CreateDynamicObject(10773,-1695.6000000,97.9000000,5.2000000,0.0000000,0.0000000,135.0000000); //object(dk_cargoshp2_sfse) (1)
	CreateDynamicObject(8077,-1691.1000000,12.2000000,6.5000000,0.0000000,0.0000000,135.0000000); //object(vgsfrates06) (1)
	CreateDynamicObject(3578,-1703.0000000,63.1000000,3.3000000,0.0000000,0.0000000,291.0000000); //object(dockbarr1_la) (1)
	CreateDynamicObject(3578,-1692.3000000,47.7000000,3.3000000,0.0000000,0.0000000,314.9950000); //object(dockbarr1_la) (3)
	CreateDynamicObject(3578,-1678.6000000,39.4000000,3.3000000,0.0000000,0.0000000,340.9950000); //object(dockbarr1_la) (4)
	CreateDynamicObject(1278,-1731.3000000,-6.9000000,16.8000000,0.0000000,0.0000000,139.9990000); //object(sub_floodlite) (1)
	CreateDynamicObject(1278,-1740.0000000,72.4000000,16.7000000,0.0000000,0.0000000,49.9990000); //object(sub_floodlite) (2)
	CreateDynamicObject(1278,-1704.5000000,-10.2000000,16.7000000,0.0000000,0.0000000,227.9980000); //object(sub_floodlite) (3)
	CreateDynamicObject(1278,-1706.2000000,110.7000000,16.7000000,0.0000000,0.0000000,355.9940000); //object(sub_floodlite) (4)

	// Ocean Springs Fill Station
	CreateDynamicObject(703,708.9000200,1289.0000000,11.3000000,0.0000000,0.0000000,40.0000000); //object(sm_veg_tree7_big) (1)
	CreateDynamicObject(705,698.0000000,1266.3000000,10.8000000,0.0000000,0.0000000,35.5000000); //object(sm_veg_tree7vbig) (1)
	CreateDynamicObject(708,689.5999800,1296.9000000,10.7000000,0.0000000,0.0000000,310.0000000); //object(sm_veg_tree4_vbig) (1)
	CreateDynamicObject(973,625.5999800,1269.3000000,11.5000000,0.0000000,0.0000000,206.5000000); //object(sub_roadbarrier) (1)
	CreateDynamicObject(973,633.9000200,1273.5000000,11.5000000,0.0000000,0.0000000,206.9990000); //object(sub_roadbarrier) (2)
	CreateDynamicObject(973,642.2000100,1277.7000000,11.5000000,0.0000000,0.0000000,206.7490000); //object(sub_roadbarrier) (3)
	CreateDynamicObject(973,650.5000000,1281.9000000,11.5000000,0.0000000,0.0000000,206.7460000); //object(sub_roadbarrier) (4)
	CreateDynamicObject(973,659.0999800,1282.3000000,11.5000000,0.0000000,0.0000000,158.7460000); //object(sub_roadbarrier) (5)
	CreateDynamicObject(973,667.4000200,1278.1000000,11.5000000,0.0000000,0.0000000,147.4910000); //object(sub_roadbarrier) (6)
	CreateDynamicObject(1554,670.7999900,1274.9000000,10.7000000,0.0000000,0.0000000,330.0000000); //object(cj_water_barrier) (1)
	CreateDynamicObject(1554,672.0000000,1274.9000000,10.7000000,0.0000000,0.0000000,19.9960000); //object(cj_water_barrier) (2)
	CreateDynamicObject(1554,673.0999800,1275.6000000,10.7000000,0.0000000,0.0000000,338.9960000); //object(cj_water_barrier) (3)
	CreateDynamicObject(16337,544.9000200,1179.7000000,11.5000000,0.0000000,0.0000000,283.2480000); //object(des_cranecontrol) (1)
	CreateDynamicObject(16337,544.9000200,1179.7000000,9.7400000,180.0000000,0.0000000,101.5900000); //object(des_cranecontrol) (2)
	CreateDynamicObject(1215,536.7999900,1199.4000000,10.9000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (1)
	CreateDynamicObject(1215,537.2999900,1197.5000000,10.4000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (2)
	CreateDynamicObject(1215,537.7999900,1195.6000000,10.6000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (3)
	CreateDynamicObject(1215,538.2999900,1193.5000000,11.2000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (4)
	CreateDynamicObject(1215,542.0999800,1183.4000000,11.6000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (5)
	CreateDynamicObject(1215,539.9000200,1182.2000000,11.3000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (6)
	CreateDynamicObject(1215,538.5999800,1180.8000000,11.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (7)
	CreateDynamicObject(1215,538.2000100,1179.1000000,10.7000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (8)
	CreateDynamicObject(3287,684.0000000,1238.6000000,15.3000000,0.0000000,0.0000000,28.0000000); //object(cxrf_oiltank) (1)
	CreateDynamicObject(3287,678.2999900,1249.3000000,15.3000000,0.0000000,0.0000000,27.9990000); //object(cxrf_oiltank) (2)
	CreateDynamicObject(3287,672.2999900,1260.5000000,15.3000000,0.0000000,0.0000000,27.9990000); //object(cxrf_oiltank) (3)
	CreateDynamicObject(3287,680.7000100,1236.9000000,13.1000000,0.0000000,0.0000000,27.9990000); //object(cxrf_oiltank) (4)
	CreateDynamicObject(3287,674.9000200,1247.5000000,13.1000000,0.0000000,0.0000000,27.9990000); //object(cxrf_oiltank) (5)
	CreateDynamicObject(3287,668.7999900,1258.7000000,13.1000000,0.0000000,0.0000000,27.9990000); //object(cxrf_oiltank) (6)
	CreateDynamicObject(3631,638.2000100,1229.7000000,11.3000000,0.0000000,0.0000000,210.0000000); //object(oilcrat_las) (1)
	CreateDynamicObject(3631,638.2000100,1229.7000000,12.4400000,0.0000000,0.0000000,209.9980000); //object(oilcrat_las) (2)
	CreateDynamicObject(2934,629.7999900,1263.6000000,12.1000000,0.0000000,0.0000000,298.7500000); //object(kmb_container_red) (1)
	CreateDynamicObject(2935,631.0999800,1259.7000000,12.1000000,0.0000000,0.0000000,296.0000000); //object(kmb_container_yel) (1)
	CreateDynamicObject(925,628.2999900,1224.6000000,11.7000000,0.0000000,0.0000000,16.5000000); //object(rack2) (1)
	CreateDynamicObject(931,631.0000000,1226.1000000,11.7000000,0.0000000,0.0000000,30.0000000); //object(rack3) (1)
	CreateDynamicObject(3287,587.9000200,1228.3000000,13.8000000,0.0000000,0.0000000,299.7490000); //object(cxrf_oiltank) (7)
	CreateDynamicObject(16112,656.2000100,1184.7000000,2.1000000,0.0000000,0.0000000,310.0000000); //object(des_rockfl1_) (1)
	CreateDynamicObject(3241,590.4000200,1185.3000000,11.2000000,0.0000000,0.0000000,284.9960000); //object(conhoos2) (1)
	CreateDynamicObject(700,577.2999900,1168.7000000,10.9000000,0.0000000,0.0000000,174.9980000); //object(sm_veg_tree6) (1)
	CreateDynamicObject(700,568.2000100,1169.2000000,11.0000000,0.0000000,0.0000000,269.7460000); //object(sm_veg_tree6) (2)
	CreateDynamicObject(669,557.7000100,1166.2000000,10.9000000,0.0000000,0.0000000,307.9990000); //object(sm_veg_tree4) (1)
	CreateDynamicObject(669,548.7000100,1154.4000000,11.8000000,0.0000000,0.0000000,210.9970000); //object(sm_veg_tree4) (2)
	CreateDynamicObject(669,567.4000200,1156.1000000,11.9000000,0.0000000,0.0000000,260.9920000); //object(sm_veg_tree4) (3)
	CreateDynamicObject(9131,554.5999800,1185.2000000,12.2000000,0.0000000,0.0000000,20.0000000); //object(shbbyhswall13_lvs) (1)
	CreateDynamicObject(9131,560.9000200,1187.3000000,12.2000000,0.0000000,0.0000000,18.2450000); //object(shbbyhswall13_lvs) (2)
	CreateDynamicObject(9131,567.0000000,1189.2000000,12.2000000,0.0000000,0.0000000,15.9910000); //object(shbbyhswall13_lvs) (3)

	// Ocean Springs Gasstation
	CreateDynamicObject(3255,575.9000200,1633.8000000,6.6000000,0.0000000,0.0000000,123.5000000); //object(ref_oiltank01) (1)
	CreateDynamicObject(3255,589.5000000,1642.8000500,6.6000000,0.0000000,0.0000000,123.5000000); //object(ref_oiltank01) (2)
	CreateDynamicObject(3287,600.7999900,1652.5000000,10.7000000,0.0000000,0.0000000,244.5000000); //object(cxrf_oiltank) (1)
	CreateDynamicObject(3287,607.7000100,1649.2000000,10.7000000,0.0000000,0.0000000,244.4950000); //object(cxrf_oiltank) (2)
	CreateDynamicObject(1215,653.0000000,1748.1000000,4.8000000,0.0000000,0.0000000,20.0000000); //object(bollardlight) (1)
	CreateDynamicObject(1215,650.7999900,1747.8000000,4.7000000,0.0000000,0.0000000,19.9950000); //object(bollardlight) (2)
	CreateDynamicObject(1215,648.2999900,1748.5000000,4.6000000,0.0000000,0.0000000,9.9950000); //object(bollardlight) (3)
	CreateDynamicObject(1215,632.4000200,1736.9000000,4.9000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (4)
	CreateDynamicObject(1215,633.0999800,1735.0000000,5.1000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (5)
	CreateDynamicObject(1215,632.2999900,1733.1000000,5.2000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (6)
	CreateDynamicObject(1215,547.5000000,1665.3000000,6.5000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (7)
	CreateDynamicObject(1215,554.9000200,1654.2000000,6.5000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (8)
	CreateDynamicObject(1215,501.0000000,1655.1000000,13.2000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (9)
	CreateDynamicObject(1215,500.7000100,1652.7000000,13.3000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (10)
	CreateDynamicObject(1215,503.6000100,1650.8000000,13.1000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (11)
	CreateDynamicObject(1215,484.7999900,1645.1000000,14.1000000,0.0000000,0.0000000,9.9920000); //object(bollardlight) (12)
	CreateDynamicObject(1215,486.8999900,1644.3000000,14.1000000,0.0000000,0.0000000,42.4920000); //object(bollardlight) (13)
	CreateDynamicObject(1215,489.7000100,1642.1000000,14.1000000,0.0000000,0.0000000,42.4900000); //object(bollardlight) (14)

	// Hobos
	CreateDynamicObject(3095,456.5000000,-107.6000000,997.9900500,0.0000000,0.0000000,0.0000000); //object(a51_jetdoor) (1)
	CreateDynamicObject(3095,447.6000100,-107.6000000,997.9900500,0.0000000,0.0000000,0.0000000); //object(a51_jetdoor) (4)
	CreateDynamicObject(3095,446.1000100,-107.5000000,997.9900500,0.0000000,0.0000000,0.2500000); //object(a51_jetdoor) (5)
	CreateDynamicObject(3095,461.0000000,-107.6000000,998.0000000,0.0000000,90.0000000,0.0000000); //object(a51_jetdoor) (6)
	CreateDynamicObject(3095,457.0000000,-111.7000000,998.0000000,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (7)
	CreateDynamicObject(3095,448.0000000,-111.7000000,998.0000000,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (8)
	CreateDynamicObject(3095,445.7999900,-111.7000000,998.0000000,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (9)
	CreateDynamicObject(3095,441.7999900,-107.5000000,998.0000000,0.0000000,90.0000000,180.0000000); //object(a51_jetdoor) (10)
	CreateDynamicObject(3095,445.7999900,-102.9300000,998.0000000,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (12)
	CreateDynamicObject(3095,454.7000100,-102.9300000,998.0000000,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (13)
	CreateDynamicObject(3095,460.7999900,-102.9300000,998.0000000,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (14)
	CreateDynamicObject(3095,456.8999900,-106.0000000,995.0999800,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (15)
	CreateDynamicObject(3095,449.5000000,-106.0000000,995.0999800,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (16)
	CreateDynamicObject(3095,456.8999900,-106.4000000,994.2000100,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (17)
	CreateDynamicObject(3095,449.5000000,-106.4000000,994.2000100,0.0000000,90.0000000,270.0000000); //object(a51_jetdoor) (18)
	CreateDynamicObject(2125,445.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,0.0000000); //object(med_din_chair_1) (1)
	CreateDynamicObject(2125,447.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,322.5000000); //object(med_din_chair_1) (2)
	CreateDynamicObject(2125,446.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,352.4980000); //object(med_din_chair_1) (3)
	CreateDynamicObject(2125,448.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,26.4960000); //object(med_din_chair_1) (4)
	CreateDynamicObject(2125,449.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,279.4980000); //object(med_din_chair_1) (5)
	CreateDynamicObject(2125,450.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,279.4980000); //object(med_din_chair_1) (6)
	CreateDynamicObject(2125,451.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,329.4980000); //object(med_din_chair_1) (10)
	CreateDynamicObject(2125,452.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,3.4960000); //object(med_din_chair_1) (11)
	CreateDynamicObject(2125,453.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,323.4940000); //object(med_din_chair_1) (12)
	CreateDynamicObject(2125,454.6000100,-107.4000000,998.9000200,0.0000000,0.0000000,317.4920000); //object(med_din_chair_1) (13)
	CreateDynamicObject(2125,455.7000100,-107.4000000,998.9000200,0.0000000,0.0000000,267.4880000); //object(med_din_chair_1) (14)
	CreateDynamicObject(2125,456.7000100,-107.4000000,998.9000200,0.0000000,0.0000000,87.4840000); //object(med_din_chair_1) (15)
	CreateDynamicObject(2125,457.7000100,-107.4000000,998.9000200,0.0000000,0.0000000,37.4790000); //object(med_din_chair_1) (16)
	CreateDynamicObject(1670,445.7999900,-106.3000000,999.6300000,0.0000000,0.0000000,0.0000000); //object(propcollecttable) (1)
	CreateDynamicObject(1670,453.2000100,-106.3000000,999.6300000,0.0000000,0.0000000,222.0000000); //object(propcollecttable) (2)
	CreateDynamicObject(2713,442.3999900,-104.0000000,998.7000100,0.0000000,0.0000000,258.2500000); //object(cj_bucket) (1)
	CreateDynamicObject(2700,442.2999900,-106.3000000,1001.7000000,0.0000000,0.0000000,0.0000000); //object(cj_sex_tv2) (1)
	CreateDynamicObject(2417,446.7000100,-104.0000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(cj_ff_cooker) (1)
	CreateDynamicObject(2415,445.8999900,-104.3000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(cj_ff_fryer) (1)
	CreateDynamicObject(2360,448.0000000,-104.1000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(cj_ice_fridge_2) (1)
	CreateDynamicObject(2344,446.6000100,-106.3000000,999.6389800,0.0000000,0.0000000,217.0000000); //object(cj_remote) (1)
	CreateDynamicObject(2340,450.0000000,-104.1000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(cj_kitch2_washer) (1)
	CreateDynamicObject(2340,451.0000000,-104.1000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(cj_kitch2_washer) (2)
	CreateDynamicObject(2340,452.0000000,-104.1000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(cj_kitch2_washer) (3)
	CreateDynamicObject(2149,449.8999900,-104.0000000,999.7000100,0.0000000,0.0000000,14.0000000); //object(cj_microwave1) (2)
	CreateDynamicObject(1951,447.5000000,-106.2000000,999.7999900,0.0000000,0.0000000,340.0000000); //object(kb_beer01) (1)
	CreateDynamicObject(1668,450.3999900,-106.3000000,999.7999900,0.0000000,0.0000000,50.0000000); //object(propvodkabotl1) (1)
	CreateDynamicObject(1667,447.7999900,-106.4000000,999.7000100,0.0000000,0.0000000,0.0000000); //object(propwineglass1) (1)
	CreateDynamicObject(1455,450.2000100,-106.4000000,999.7000100,0.0000000,0.0000000,0.0000000); //object(dyn_glass) (1)
	CreateDynamicObject(2418,453.8999900,-104.1000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(cj_ff_worktop) (1)
	CreateDynamicObject(2114,460.6000100,-105.7000000,998.7000100,0.0000000,0.0000000,0.0000000); //object(basketball) (1)
	CreateDynamicObject(3963,461.0000000,-109.6000000,1000.3000000,0.0000000,0.0000000,89.0000000); //object(lee_plane08) (1)
	CreateDynamicObject(2426,456.2000100,-103.8000000,999.4500100,0.0000000,0.0000000,0.0000000); //object(cj_ff_pizza_oven) (1)
	CreateDynamicObject(2418,455.7999900,-104.1000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(cj_ff_worktop) (2)
	CreateDynamicObject(2683,455.2000100,-106.3000000,999.7200300,0.0000000,0.0000000,0.0000000); //object(pizza_s_p) (1)
	CreateDynamicObject(1370,459.2999900,-104.0000000,999.0999800,0.0000000,0.0000000,260.0000000); //object(cj_flame_drum) (1)
	CreateDynamicObject(2900,460.3999900,-104.2000000,998.5000000,0.0000000,0.0000000,0.0000000); //object(temp_cardbox) (2)
	CreateDynamicObject(1235,460.5000000,-107.5000000,999.0000000,0.0000000,0.0000000,30.0000000); //object(wastebin) (1)
	CreateDynamicObject(2245,449.7000100,-110.5000000,999.5999800,0.0000000,0.0000000,40.0000000); //object(plant_pot_11) (1)
	CreateDynamicObject(2011,460.5000000,-111.1000000,998.5000000,0.0000000,0.0000000,24.0000000); //object(nu_plant2_ofc) (1)

	// Hobos Exterior
	CreateDynamicObject(1334,866.2999900,-970.0000000,36.0000000,0.0000000,0.0000000,33.2500000); //object(binnt04_la) (1)
	CreateDynamicObject(1332,863.0999800,-972.0000000,35.8000000,0.0000000,0.0000000,206.0000000); //object(binnt02_la) (1)
	CreateDynamicObject(1333,860.2000100,-973.7000100,35.4000000,0.0000000,0.0000000,20.2500000); //object(binnt03_la) (1)
	CreateDynamicObject(1215,861.7000100,-985.7999900,34.1000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (1)
	CreateDynamicObject(1215,865.0000000,-983.7999900,34.5000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (2)
	CreateDynamicObject(1215,868.2000100,-981.7999900,34.7000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (3)
	CreateDynamicObject(1215,874.7000100,-977.7999900,35.2000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (4)
	CreateDynamicObject(1215,878.0000000,-975.7999900,35.5000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (5)
	CreateDynamicObject(1215,881.2000100,-973.9000200,35.8000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (6)
	CreateDynamicObject(1215,871.7999900,-979.7999900,34.9000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (7)
	CreateDynamicObject(713,887.2000100,-967.5999800,35.8000000,0.0000000,0.0000000,346.7500000); //object(veg_bevtree1) (1)
	CreateDynamicObject(1215,884.5999800,-971.9000200,36.1000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (8)
	CreateDynamicObject(1215,887.5000000,-970.7999900,36.3000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (9)
	CreateDynamicObject(1215,890.5999800,-969.7999900,36.5000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (10)
	CreateDynamicObject(1215,893.5000000,-968.7999900,36.7000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (11)
	CreateDynamicObject(1215,896.5999800,-967.7000100,36.9000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (12)
	CreateDynamicObject(1215,899.5000000,-966.7000100,37.1000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (13)
	CreateDynamicObject(1215,902.5999800,-965.5999800,37.3000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (14)
	CreateDynamicObject(1215,905.5000000,-964.5999800,37.5000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (15)
	CreateDynamicObject(1215,908.5999800,-963.5000000,37.7000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (16)
	CreateDynamicObject(1215,910.2000100,-963.0999800,37.8000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (17)
	CreateDynamicObject(1215,913.9000200,-962.2999900,37.8000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (18)
	CreateDynamicObject(1215,917.5999800,-961.5000000,37.9000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (19)
	CreateDynamicObject(1215,921.2999900,-960.7000100,37.9000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (20)
	CreateDynamicObject(1215,924.9000200,-959.9000200,38.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (21)
	CreateDynamicObject(1215,928.7000100,-959.0000000,38.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (22)
	CreateDynamicObject(1215,932.2999900,-958.2000100,38.0000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (23)
	CreateDynamicObject(1215,936.0999800,-957.4000200,38.1000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (24)
	CreateDynamicObject(1215,939.7000100,-956.7000100,38.2000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (25)
	CreateDynamicObject(1215,943.5999800,-956.0999800,38.6000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (26)
	CreateDynamicObject(1215,947.4000200,-955.4000200,38.9000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (27)
	CreateDynamicObject(1215,951.2999900,-954.7999900,39.3000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (28)
	CreateDynamicObject(1215,955.0000000,-954.2000100,39.6000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (29)
	CreateDynamicObject(1215,958.7999900,-953.7000100,39.6000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (30)
	CreateDynamicObject(1215,962.2999900,-953.2999900,39.5000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (31)
	CreateDynamicObject(1215,966.0000000,-952.7999900,39.5000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (32)
	CreateDynamicObject(1215,969.5000000,-953.0000000,39.6000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (33)
	CreateDynamicObject(1215,973.0999800,-953.2000100,39.6000000,0.0000000,0.0000000,0.0000000); //object(bollardlight) (34)
	CreateDynamicObject(1211,861.5999800,-991.5999800,33.7000000,0.0000000,0.0000000,40.0000000); //object(fire_hydrant) (1)
	CreateDynamicObject(1211,885.7000100,-976.5000000,36.5000000,0.0000000,0.0000000,17.9960000); //object(fire_hydrant) (2)
	CreateDynamicObject(638,878.2000100,-973.4000200,35.8000000,3.5000000,0.0000000,299.7500000); //object(kb_planter_bush) (2)
	CreateDynamicObject(638,873.5999800,-976.0000000,35.3000000,3.9000000,0.0000000,299.7450000); //object(kb_planter_bush) (4)
	CreateDynamicObject(638,869.0000000,-978.5999800,35.0000000,3.0000000,0.0000000,299.7450000); //object(kb_planter_bush) (6)
	CreateDynamicObject(638,864.4000200,-981.2000100,34.7000000,4.5000000,0.0000000,299.7450000); //object(kb_planter_bush) (8)
	CreateDynamicObject(638,859.7999900,-983.7999900,34.4000000,3.4000000,0.0000000,299.7450000); //object(kb_planter_bush) (10)
	CreateDynamicObject(803,887.7000100,-965.5999800,36.6000000,0.0000000,0.0000000,0.0000000); //object(genveg_bush09) (1)
	CreateDynamicObject(803,889.0000000,-965.0000000,36.6000000,0.0000000,0.0000000,40.0000000); //object(genveg_bush09) (2)
	CreateDynamicObject(869,895.2999900,-965.2999900,36.9000000,0.0000000,0.0000000,0.0000000); //object(veg_pflowerswee) (1)
	CreateDynamicObject(869,896.7000100,-965.0000000,36.8000000,0.0000000,0.0000000,90.0000000); //object(veg_pflowerswee) (2)
	CreateDynamicObject(700,911.7999900,-960.5999800,38.0000000,0.0000000,0.0000000,0.0000000); //object(sm_veg_tree6) (1)
	CreateDynamicObject(700,923.7000100,-958.4000200,37.8000000,0.0000000,0.0000000,340.0000000); //object(sm_veg_tree6) (2)
	CreateDynamicObject(700,936.5999800,-955.7999900,38.0000000,0.0000000,0.0000000,289.9970000); //object(sm_veg_tree6) (3)

	// Hobos
	CreateDynamicPickup(1239, 1, 875.9323, -968.3762, 37.1875);
	CreateDynamicPickup(1239, 1, 458.8982, -110.7152, 999.5454);
	CreateDynamicPickup(1582, 1, 458.5027, -107.3624, 999.5454);

	// Hobos
	CreateActor(168, 458.3746, -105.2684, 999.5454, 181.9454);

	// Hobos
	HoboMenu = CreateMenu("Food", 2, 5, 180, 200, 150);
	SetMenuColumnHeader(HoboMenu, 0, "Menu");
	SetMenuColumnHeader(HoboMenu, 1, "Price");
	AddMenuItem(HoboMenu, 0, "Little Hobo");
	AddMenuItem(HoboMenu, 1, "$6");
	AddMenuItem(HoboMenu, 0, "Vegan Hobo w/ Salad");
	AddMenuItem(HoboMenu, 1, "$8");
	AddMenuItem(HoboMenu, 0, "Road Kill w/ Sauce");
	AddMenuItem(HoboMenu, 1, "$10");
	AddMenuItem(HoboMenu, 0, "Shopping Cart Fire");
	AddMenuItem(HoboMenu, 1, "$14");
	AddMenuItem(HoboMenu, 0, "Everything from something");
	AddMenuItem(HoboMenu, 1, "$20");


	for(new i = 0; i < sizeof(TravelPos); i++) {
		if(TravelPos[i][Type] == 1) { // Train
			CreateDynamicPickup(1239, 1, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ]);
			CreateDynamic3DTextLabel("{9A2D25}Train Travel{EEEE00}\nTicket price: $45\nUsage: /travel", COLOR_YELLOW, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ], 15.0);
		} else if(TravelPos[i][Type] == 2) { // Boat
			CreateDynamicPickup(1239, 1, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ]);
			CreateDynamic3DTextLabel("{9A2D25}Boat Travel{EEEE00}\nTicket price: $45\nUsage: /travel", COLOR_YELLOW, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ], 15.0);
		} else if(TravelPos[i][Type] == 3) { // Air
			CreateDynamicPickup(1239, 1, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ]);
			CreateDynamic3DTextLabel("{9A2D25}Air Travel{EEEE00}\nTicket price: $45\nUsage: /travel", COLOR_YELLOW, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ], 15.0);
		}
	}

	// ----- Disables/Settings -----
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	UsePlayerPedAnims();

	SetGameModeText("SA-MP.org v0.1");
	// --------------------
	return 1;
}

public OnGameModeExit()
{
	mysql_close(handler);
	MapAndreas_Unload();
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	new Query[128];
	if(!IsPlayerNPC(playerid)) {
		for(new i; PlayerData:i < PlayerData; i++) pInfo[playerid][PlayerData:i] = 0;
	}
	for(new i = 0; i < sizeof(TravelPos); i++) {
		SetPlayerMapIcon(playerid, i, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ], 42, 0, MAPICON_LOCAL);
	}
	FirstLogin[playerid] = 0;
	MarkSaved[playerid] = 0;
	LogIn[playerid] = 0;
	DamageTimer[playerid] = -1;

	Health[playerid] = CreatePlayerTextDraw(playerid, 576.163940, 66.470344, "100");
	PlayerTextDrawLetterSize(playerid, Health[playerid], 0.308001, 0.939999);
	PlayerTextDrawAlignment(playerid, Health[playerid], 2);
	PlayerTextDrawColor(playerid, Health[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Health[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Health[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Health[playerid], 255);
	PlayerTextDrawFont(playerid, Health[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Health[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Health[playerid], 0);

	Armour[playerid] = CreatePlayerTextDraw(playerid, 576.263916, 44.600318, "100");
	PlayerTextDrawLetterSize(playerid, Armour[playerid], 0.308001, 0.939999);
	PlayerTextDrawAlignment(playerid, Armour[playerid], 2);
	PlayerTextDrawColor(playerid, Armour[playerid], -1);
	PlayerTextDrawSetShadow(playerid, Armour[playerid], 0);
	PlayerTextDrawSetOutline(playerid, Armour[playerid], 1);
	PlayerTextDrawBackgroundColor(playerid, Armour[playerid], 255);
	PlayerTextDrawFont(playerid, Armour[playerid], 1);
	PlayerTextDrawSetProportional(playerid, Armour[playerid], 1);
	PlayerTextDrawSetShadow(playerid, Armour[playerid], 0);

	TextDrawHideForPlayer(playerid, Clock);
	PlayerTextDrawHide(playerid, Health[playerid]);
	PlayerTextDrawHide(playerid, Armour[playerid]);

	// SF Hafen
	RemoveBuildingForPlayer(playerid, 10914, -1706.4766, 13.0156, 7.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -1706.2891, -7.0781, 16.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, -1660.4844, -6.5391, 4.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, -1656.7578, -10.2656, 4.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, -1667.9297, 0.9063, 4.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, -1664.2031, -2.8125, 4.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 10831, -1706.4766, 13.0156, 7.4063, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, -1674.6953, 7.6875, 4.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 1411, -1678.3750, 11.3594, 4.0313, 0.25);
	RemoveBuildingForPlayer(playerid, 966, -1676.2578, 4.6563, 2.5156, 0.25);
	RemoveBuildingForPlayer(playerid, 968, -1676.2266, 4.6250, 3.2422, 0.25);
	RemoveBuildingForPlayer(playerid, 967, -1674.9609, 5.5547, 2.5156, 0.25);
	RemoveBuildingForPlayer(playerid, 1278, -1706.1172, 33.1641, 16.6172, 0.25);
	RemoveBuildingForPlayer(playerid, 10773, -1711.0234, 65.1250, 5.5156, 0.25);

	// Ampeln
	RemoveBuildingForPlayer(playerid, 3855, 0.0, 0.0, 0.0, 3000.0);
	RemoveBuildingForPlayer(playerid, 1283, 0.0, 0.0, 0.0, 3000.0);
	RemoveBuildingForPlayer(playerid, 3516, 0.0, 0.0, 0.0, 3000.0);
	RemoveBuildingForPlayer(playerid, 1315, 0.0, 0.0, 0.0, 3000.0);
	RemoveBuildingForPlayer(playerid, 1350, 0.0, 0.0, 0.0, 3000.0);
	RemoveBuildingForPlayer(playerid, 1351, 0.0, 0.0, 0.0, 3000.0);
	RemoveBuildingForPlayer(playerid, 1284, 0.0, 0.0, 0.0, 3000.0);

	// Hobos
	RemoveBuildingForPlayer(playerid, 5854, 992.5313, -962.7344, 60.7813, 0.25);
	RemoveBuildingForPlayer(playerid, 1261, 874.6875, -1021.8672, 45.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1261, 883.8516, -972.0156, 48.4531, 0.25);
	RemoveBuildingForPlayer(playerid, 1267, 874.6875, -1021.8672, 45.5313, 0.25);
	RemoveBuildingForPlayer(playerid, 1267, 883.8516, -972.0156, 48.4531, 0.25);

	OneSecond[playerid] = SetTimerEx("OneSecondTimer", 1000, 1, "i", playerid);

	GetPlayerName(playerid, Name[playerid], MAX_PLAYER_NAME);
	SetSpawnInfo(playerid, 0, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	mysql_format(handler, Query, sizeof(Query), "SELECT * FROM `Player` WHERE `Name` = '%e'", Name[playerid]);
	mysql_tquery(handler, Query, "CheckAccount", "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(SaveTimer[playerid]);
	KillTimer(DamageTimer[playerid]);
	KillTimer(OneSecond[playerid]);
	SaveAccount(playerid);
	pInfo[playerid][LoggedIn] = 0;
	return 1;
}

public OnPlayerSpawn(playerid)
{
	if(FirstLogin[playerid] == 1) {
		new Pos = random(sizeof(randomSpawn));
		SetPlayerPos(playerid, randomSpawn[Pos][spawnX], randomSpawn[Pos][spawnY], randomSpawn[Pos][spawnZ]);
		SetPlayerFacingAngle(playerid, randomSpawn[Pos][spawnA]);
		pInfo[playerid][posX] = randomSpawn[Pos][spawnX];
		pInfo[playerid][posY] = randomSpawn[Pos][spawnY];
		pInfo[playerid][posZ] = randomSpawn[Pos][spawnZ];
		pInfo[playerid][posA] = randomSpawn[Pos][spawnA];
		pInfo[playerid][fsID] = randomSpawn[Pos][rsID];
		SetPlayerFightingStyle(playerid, randomSpawn[Pos][FightStyle]);
		pInfo[playerid][FightStyle] = randomSpawn[Pos][FightStyle];
		new pSkin = random(6)+1;
		SetPlayerSkin(playerid, randomSkins[Pos][pSkin]);
		pInfo[playerid][Skin] = randomSkins[Pos][pSkin];
		FirstLogin[playerid] = 0;
		TextDrawShowForPlayer(playerid, Clock);
		UnloadGuns(playerid);
	} else if(LogIn[playerid] == 1) {
		SetPlayerPos(playerid, pInfo[playerid][posX], pInfo[playerid][posY], pInfo[playerid][posZ]);
		SetPlayerFacingAngle(playerid, pInfo[playerid][posA]);
		SetPlayerSkin(playerid, pInfo[playerid][Skin]);
		SetPlayerFightingStyle(playerid, pInfo[playerid][FightStyle]);
		LogIn[playerid] = 0;
		TextDrawShowForPlayer(playerid, Clock);
		UnloadGuns(playerid);
	} else {
		for(new i = 0; i < sizeof(randomSpawn); i++) {
			if(randomSpawn[i][rsID] == pInfo[playerid][fsID]) {
				SetPlayerPos(playerid, randomSpawn[i][spawnX], randomSpawn[i][spawnY], randomSpawn[i][spawnZ]);
				SetPlayerFacingAngle(playerid, randomSpawn[i][spawnA]);
			}
		}
		SetPlayerSkin(playerid, pInfo[playerid][Skin]);
		SetPlayerFightingStyle(playerid, pInfo[playerid][FightStyle]);
		TextDrawShowForPlayer(playerid, Clock);
		UnloadGuns(playerid);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
	TextDrawHideForPlayer(playerid, Clock);
	PlayerTextDrawHide(playerid, Health[playerid]);
	PlayerTextDrawHide(playerid, Armour[playerid]);
	HideMenuForPlayer(HoboMenu, playerid);
	return 1;
}

public OnVehicleSpawn(vehicleid)
{
	return 1;
}

public OnVehicleDeath(vehicleid, killerid)
{
	return 1;
}

public OnPlayerText(playerid, text[])
{
	return 1;
}

public OnPlayerCommandText(playerid, cmdtext[])
{
	return 1;
}

public OnPlayerEnterVehicle(playerid, vehicleid, ispassenger)
{
	return 1;
}

public OnPlayerExitVehicle(playerid, vehicleid)
{
	return 1;
}

public OnPlayerStateChange(playerid, newstate, oldstate)
{
	return 1;
}

public OnPlayerEnterCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveCheckpoint(playerid)
{
	return 1;
}

public OnPlayerEnterRaceCheckpoint(playerid)
{
	return 1;
}

public OnPlayerLeaveRaceCheckpoint(playerid)
{
	return 1;
}

public OnRconCommand(cmd[])
{
	return 1;
}

public OnPlayerRequestSpawn(playerid)
{
	if(pInfo[playerid][LoggedIn] == 0 && !IsPlayerNPC(playerid)) {
		return Kick(playerid);
	}
	return 1;
}

public OnObjectMoved(objectid)
{
	return 1;
}

public OnPlayerObjectMoved(playerid, objectid)
{
	return 1;
}

public OnPlayerPickUpPickup(playerid, pickupid)
{
	return 1;
}

public OnVehicleMod(playerid, vehicleid, componentid)
{
	return 1;
}

public OnVehiclePaintjob(playerid, vehicleid, paintjobid)
{
	return 1;
}

public OnVehicleRespray(playerid, vehicleid, color1, color2)
{
	return 1;
}

public OnPlayerSelectedMenuRow(playerid, row)
{
	new Float:pHealth;
	GetPlayerHealth(playerid, pHealth);
	if(GetPlayerMenu(playerid) == HoboMenu) {
		if(row == 0) {
			if(pHealth > 110) {
				SendClientMessage(playerid, COLOR_GREY, "You have enough health!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			if(GetMoney(playerid) < 6) {
				SendClientMessage(playerid, COLOR_GREY, "You don't have enough money!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			SetPlayerHealth(playerid, pHealth+40);
			GiveMoney(playerid, -6);
			SendClientMessage(playerid, COLOR_YELLOW, "You have bought Little Hobo for $6!");
			HideMenuForPlayer(HoboMenu, playerid);
			TogglePlayerControllable(playerid, 1);
		} else if(row == 1) {
			if(pHealth > 90) {
				SendClientMessage(playerid, COLOR_GREY, "You have enough health!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			if(GetMoney(playerid) < 8) {
				SendClientMessage(playerid, COLOR_GREY, "You don't have enough money!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			SetPlayerHealth(playerid, pHealth+60);
			GiveMoney(playerid, -8);
			SendClientMessage(playerid, COLOR_YELLOW, "You have bought Vegan Hobo with Salad for $8!");
			HideMenuForPlayer(HoboMenu, playerid);
			TogglePlayerControllable(playerid, 1);
		} else if(row == 2) {
			if(pHealth > 65) {
				SendClientMessage(playerid, COLOR_GREY, "You have enough health!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			if(GetMoney(playerid) < 10) {
				SendClientMessage(playerid, COLOR_GREY, "You don't have enough money!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			SetPlayerHealth(playerid, pHealth+85);
			GiveMoney(playerid, -10);
			SendClientMessage(playerid, COLOR_YELLOW, "You have bought Vegan Road Kill with Sauce for $10!");
			HideMenuForPlayer(HoboMenu, playerid);
			TogglePlayerControllable(playerid, 1);
		} else if(row == 3) {
			if(pHealth > 45) {
				SendClientMessage(playerid, COLOR_GREY, "You have enough health!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			if(GetMoney(playerid) < 14) {
				SendClientMessage(playerid, COLOR_GREY, "You don't have enough money!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			SetPlayerHealth(playerid, pHealth+105);
			GiveMoney(playerid, -14);
			SendClientMessage(playerid, COLOR_YELLOW, "You have bought Shopping Cart Fire for $14!");
			HideMenuForPlayer(HoboMenu, playerid);
			TogglePlayerControllable(playerid, 1);
		} else if(row == 4) {
			if(pHealth > 10) {
				SendClientMessage(playerid, COLOR_GREY, "You have enough health!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			if(GetMoney(playerid) < 20) {
				SendClientMessage(playerid, COLOR_GREY, "You don't have enough money!");
				TogglePlayerControllable(playerid, 1);
				return 1;
			}
			SetPlayerHealth(playerid, pHealth+140);
			GiveMoney(playerid, -20);
			SendClientMessage(playerid, COLOR_YELLOW, "You have bought Everything from something for $20!");
			HideMenuForPlayer(HoboMenu, playerid);
			TogglePlayerControllable(playerid, 1);
		}
	}	return 1;
}

public OnPlayerExitedMenu(playerid)
{
	TogglePlayerControllable(playerid, 1);
	return 1;
}

public OnPlayerInteriorChange(playerid, newinteriorid, oldinteriorid)
{
	return 1;
}

public OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	return 1;
}

public OnRconLoginAttempt(ip[], password[], success)
{
	return 1;
}

public OnPlayerUpdate(playerid)
{
	return 1;
}

public OnPlayerStreamIn(playerid, forplayerid)
{
	return 1;
}

public OnPlayerStreamOut(playerid, forplayerid)
{
	return 1;
}

public OnVehicleStreamIn(vehicleid, forplayerid)
{
	return 1;
}

public OnVehicleStreamOut(vehicleid, forplayerid)
{
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid) {
		case D_LOGIN: {
			if(!response) return Kick(playerid);
			new Query[256], H_Pass[129], Salt[26];
			mysql_format(handler, Query, sizeof(Query), "SELECT `Salt` FROM `Player` WHERE `Name` = '%e' LIMIT 1", Name[playerid]);
			new Cache:result = mysql_query(handler, Query);
			cache_get_value_name(0, "Salt", Salt, 26);
			cache_delete(result);
			SHA256_PassHash(inputtext, Salt, H_Pass, sizeof(H_Pass));
			mysql_format(handler, Query, sizeof(Query), "SELECT * FROM `Player` WHERE `Name` = '%e' AND `Password` = '%e'", Name[playerid], H_Pass);
			mysql_tquery(handler, Query, "AccountLogin", "i", playerid);
		}
		case D_REGISTER: {
			if(!response) return Kick(playerid);
			if(strlen(inputtext) < 6) {
				new string[156];
				SendClientMessage(playerid, COLOR_RED, "Your password need at least 6 digits.");
				format(string, sizeof(string), "{FFFFFF}Welcome %s,\nwe can't find an account with this name in the database,\nplease enter a password to register a account.", Name[playerid]);
				return ShowPlayerDialog(playerid, D_REGISTER, DIALOG_STYLE_INPUT, "SA-MP.org | Register", string, "Register", "Cancel");
			}
			new Query[256], H_Pass[64], Salt[26];
			for(new i; i < 25; i++) {
				Salt[i] = random(2) ? (random(26) + (random(2) ? 'a' : 'A')) : (random(10) + '0');
			}
			Salt[25] = 0;
			SHA256_PassHash(inputtext, Salt, H_Pass, 64);
			mysql_format(handler, Query, sizeof(Query), "INSERT INTO `Player` (`Name`, `Password`, `Salt`) VALUES ('%e', '%e', '%e')", Name[playerid], H_Pass, Salt);
			mysql_tquery(handler, Query, "AccountRegister", "i", playerid);
		}
		case D_SHOWPLAYERVEHS: {
			if(!response) return 1;
		    new dbid, trash[10], string[128], plate[15], Float:Coords[4], gID = GetNearestGarage(playerid), Park[4] = false;
			sscanf(inputtext, "s[4]d", trash, dbid);
			mysql_format(handler, string, sizeof(string), "SELECT * FROM `Vehicles` WHERE `id` = '%d' AND `owner` = '%d'", dbid, pInfo[playerid][id]);

			for(new j = 1, d = GetVehiclePoolSize() + 1; j < d; j++)
			{
			    if(j == INVALID_VEHICLE_ID) continue;
			    if(IsVehicleInRangeOfPoint(j, 2.0, gInfo[gID][g_SpawnX1], gInfo[gID][g_SpawnY1], gInfo[gID][g_SpawnZ1])) Park[0] = true;
			    if(IsVehicleInRangeOfPoint(j, 2.0, gInfo[gID][g_SpawnX2], gInfo[gID][g_SpawnY2], gInfo[gID][g_SpawnZ2])) Park[1] = true;
			   	if(IsVehicleInRangeOfPoint(j, 2.0, gInfo[gID][g_SpawnX3], gInfo[gID][g_SpawnY3], gInfo[gID][g_SpawnZ3])) Park[2] = true;
			    if(IsVehicleInRangeOfPoint(j, 2.0, gInfo[gID][g_SpawnX4], gInfo[gID][g_SpawnY4], gInfo[gID][g_SpawnZ4])) Park[3] = true;
			    continue;
			}
			if(!Park[0]) Coords[0] = gInfo[gID][g_SpawnX1], Coords[1] = gInfo[gID][g_SpawnY1], Coords[2] = gInfo[gID][g_SpawnZ1], Coords[3] = gInfo[gID][g_SpawnR1];
			else if(!Park[1]) Coords[0] = gInfo[gID][g_SpawnX2], Coords[1] = gInfo[gID][g_SpawnY2], Coords[2] = gInfo[gID][g_SpawnZ2], Coords[3] = gInfo[gID][g_SpawnR2];
			else if(!Park[2]) Coords[0] = gInfo[gID][g_SpawnX3], Coords[1] = gInfo[gID][g_SpawnY3], Coords[2] = gInfo[gID][g_SpawnZ3], Coords[3] = gInfo[gID][g_SpawnR3];
			else if(!Park[3]) Coords[0] = gInfo[gID][g_SpawnX4], Coords[1] = gInfo[gID][g_SpawnY4], Coords[2] = gInfo[gID][g_SpawnZ4], Coords[3] = gInfo[gID][g_SpawnR4];
			else return SendClientMessage(playerid, COLOR_RED, "Can't find a place to park.");

			new Cache:result = mysql_query(handler, string);
			new i = 0, y = GetVehiclePoolSize() + 1;
			for(; i < y; i++) {
				if(GetVehicleModel(i) >= 400) continue;
				cache_get_value_name_int(0, "model", vInfo[i][v_model]);
				cache_get_value_name(0, "licenseplate", plate, sizeof(plate));
				format(vInfo[i][v_licenseplate], sizeof(plate), plate);
				cache_get_value_name_int(0, "kilometers", vInfo[i][v_kilometers]);
				cache_get_value_name_int(0, "owner", vInfo[i][v_owner]);
				cache_get_value_name_int(0, "tank", vInfo[i][v_tank]);
				cache_get_value_name_int(0, "color1", vInfo[i][v_color1]);
				cache_get_value_name_int(0, "color2", vInfo[i][v_color2]);
				cache_get_value_name_int(0, "paintjob", vInfo[i][v_paintjob]);
				cache_get_value_name_int(0, "spoiler", vInfo[i][v_spoiler]);
				cache_get_value_name_int(0, "hood", vInfo[i][v_hood]);
				cache_get_value_name_int(0, "roof", vInfo[i][v_roof]);
				cache_get_value_name_int(0, "sideskirt_left", vInfo[i][v_sideskirt_left]);
				cache_get_value_name_int(0, "sideskirt_right", vInfo[i][v_sideskirt_right]);
				cache_get_value_name_int(0, "nitro", vInfo[i][v_nitro]);
				cache_get_value_name_int(0, "lamps", vInfo[i][v_lamps]);
				cache_get_value_name_int(0, "exhaust", vInfo[i][v_exhaust]);
				cache_get_value_name_int(0, "wheels", vInfo[i][v_wheels]);
				cache_get_value_name_int(0, "stereo", vInfo[i][v_stereo]);
				cache_get_value_name_int(0, "hydraulics", vInfo[i][v_hydraulics]);
				cache_get_value_name_int(0, "bullbar", vInfo[i][v_bullbar]);
				cache_get_value_name_int(0, "bullbar_rear", vInfo[i][v_bullbar_rear]);
				cache_get_value_name_int(0, "bullbar_front", vInfo[i][v_bullbar_front]);
				cache_get_value_name_int(0, "sign_front", vInfo[i][v_sign_front]);
				cache_get_value_name_int(0, "bumper_front", vInfo[i][v_bumper_front]);
				cache_get_value_name_int(0, "bumper_rear", vInfo[i][v_bumper_rear]);
				cache_get_value_name_int(0, "bullbars", vInfo[i][v_bullbars]);
				cache_get_value_name_int(0, "vents", vInfo[i][v_vents]);
				vInfo[i][v_vehicleid] = i;
				break;
			}

			vInfo[i][v_vehicleid] = CreateVehicle(vInfo[i][v_model], Coords[0], Coords[1], Coords[2], Coords[3], vInfo[i][v_color1], vInfo[i][v_color2], -1, 0);
			SetVehicleNumberPlate(vInfo[i][v_vehicleid], vInfo[i][v_licenseplate]);

			if(vInfo[i][v_spoiler] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_spoiler]);
			if(vInfo[i][v_hood] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_hood]);
			if(vInfo[i][v_roof] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_roof]);
			if(vInfo[i][v_sideskirt_left] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_sideskirt_left]);
			if(vInfo[i][v_sideskirt_right] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_sideskirt_right]);
			if(vInfo[i][v_nitro] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_nitro]);
			if(vInfo[i][v_lamps] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_lamps]);
			if(vInfo[i][v_exhaust] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_exhaust]);
			if(vInfo[i][v_wheels] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_wheels]);
			if(vInfo[i][v_stereo] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_stereo]);
			if(vInfo[i][v_hydraulics] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_hydraulics]);
			if(vInfo[i][v_bullbar] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_bullbar]);
			if(vInfo[i][v_bullbar_rear] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_bullbar_rear]);
			if(vInfo[i][v_bullbar_front] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_bullbar_front]);
			if(vInfo[i][v_sign_front] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_sign_front]);
			if(vInfo[i][v_bumper_front] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_bumper_front]);
			if(vInfo[i][v_bumper_rear] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_bumper_rear]);
			if(vInfo[i][v_bullbars] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_bullbars]);
			if(vInfo[i][v_vents] > 0) AddVehicleComponent(vInfo[i][v_vehicleid], vInfo[i][v_vents]);
			ChangeVehicleColor(vInfo[i][v_vehicleid], vInfo[i][v_color1], vInfo[i][v_color2]);
			if(vInfo[i][v_paintjob] < 1337) ChangeVehiclePaintjob(vInfo[i][v_vehicleid], vInfo[i][v_paintjob]);

			cache_delete(result);
			SendClientMessage(playerid, COLOR_RED, "Vehicle successfully parked.");
			return 1;
		}
		case D_TRAVEL: {
			if(!response) return 1;
			if(GetMoney(playerid) < 45) return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to travel!");
			new travelID = listitem+GetPVarInt(playerid, "Travel");
			new travID = GetPVarInt(playerid, "Travel")-1;
			if(TravelPos[travID][Type] == 1) {
				if(strcmp(inputtext, "Nearest Airport") && strcmp(inputtext, "Nearest Harbour")) {
					if(travelID > 12) travelID = (travelID -13);
					SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
					SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
				} else if(!strcmp(inputtext, "Nearest Airport")) {
					travelID = GetNearestAirport(playerid);
					SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
					SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
				} else if(!strcmp(inputtext, "Nearest Harbour")) {
					travelID = GetNearestHarbour(playerid);
					SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
					SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
				}
			} else if(TravelPos[travID][Type] == 2) {
				if(strcmp(inputtext, "Nearest Airport") && strcmp(inputtext, "Nearest Train Station")) {
					if(travelID > 39) travelID = (travelID -27);
					SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
					SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
				} else if(!strcmp(inputtext, "Nearest Airport")) {
					travelID = GetNearestAirport(playerid);
					SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
					SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
				} else if(!strcmp(inputtext, "Nearest Train Station")) {
					travelID = GetNearestTrainStation(playerid);
					SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
					SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
				}
			} else if(TravelPos[travID][Type] == 3) {
				if(strcmp(inputtext, "Nearest Harbour") && strcmp(inputtext, "Nearest Train Station")) {
					if(travelID > 46) travelID = (travelID -7);
					SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
					SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
					} else if(!strcmp(inputtext, "Nearest Harbour")) {
						travelID = GetNearestHarbour(playerid);
						SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
						SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
					} else if(!strcmp(inputtext, "Nearest Train Station")) {
						travelID = GetNearestTrainStation(playerid);
						SetPlayerPos(playerid, TravelPos[travelID][tDX], TravelPos[travelID][tDY], TravelPos[travelID][tDZ]);
						SetPlayerFacingAngle(playerid, TravelPos[travelID][tDA]);
					}
			}
			SendFormMessage(playerid, COLOR_YELLOW, "You have traveled to %s and had to pay $45.", TravelPos[travelID][tsName]);
			GiveMoney(playerid, -45);
			DeletePVar(playerid, "Travel");
			return 1;
		}
		case D_RELOAD: {
			for(new i; i < sizeof(gInfo); i++)
			{
			    if(IsValidDynamicPickup(gInfo[i][g_Pickup])) DestroyDynamicPickup(gInfo[i][g_Pickup]);
			    if(IsValidDynamic3DTextLabel(gInfo[i][g_3DText])) DestroyDynamic3DTextLabel(gInfo[i][g_3DText]);
			}
			mysql_pquery(handler, "SELECT * FROM `Garages`", "LoadGarages");
			SendClientMessage(playerid, COLOR_RED, "Garages have been reloaded successfully.");
			AdminLog("/reload", "Garages", Name[playerid], "-", currentTime(1));
			return 1;
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source) {
	return 1;
}

public CheckAccount(playerid) {
	new Rows, string[512];
	cache_get_row_count(Rows);
	if(Rows >= 1) {
		cache_get_value_name_int(0, "Banned", pInfo[playerid][Banned]);
		cache_get_value_name(0, "BanReason", pInfo[playerid][BanReason], 45);
		cache_get_value_name(0, "BanDate", pInfo[playerid][BanDate], 20);
		cache_get_value_name(0, "BannedBy", pInfo[playerid][BannedBy], MAX_PLAYER_NAME+1);
		if(pInfo[playerid][Banned] == 1) {
			format(string, sizeof(string), "{FFFFFF}Welcome %s,\nunfortunately you got {FF0000}banned{FFFFFF} from our server, that means that you can't play anymore with this account.\n\nBan reason: %s\nBan date: %s\nBanned by: %s\nIf you have any questions about your ban, contact us on our teamspeak.", Name[playerid], pInfo[playerid][BanReason], pInfo[playerid][BanDate], pInfo[playerid][BannedBy]);
			ShowPlayerDialog(playerid, 32767, DIALOG_STYLE_MSGBOX, "SA-MP.org | Baninfo", string, "Close", "");
			return SetTimerEx("KickPlayer", 50, 0, "i", playerid);
		}
		format(string, sizeof(string), "{FFFFFF}Welcome back %s,\nplease enter your account password.", Name[playerid]);
		ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "SA-MP.org | Login", string, "Login", "Cancel");
	} else {
		format(string, sizeof(string), "{FFFFFF}Welcome %s,\nwe can't find an account with this name in the database,\nplease enter a password to register a account.", Name[playerid]);
		ShowPlayerDialog(playerid, D_REGISTER, DIALOG_STYLE_INPUT, "SA-MP.org | Register", string, "Register", "Cancel");
	}
	return 1;
}

public AccountLogin(playerid) {
	new Rows, string[128];
	cache_get_row_count(Rows);
	if(Rows >= 1) {
		SendClientMessage(playerid, COLOR_DARKGREEN, "Login Successful");
		cache_get_value_name_int(0, "id", pInfo[playerid][id]);
		cache_get_value_name_int(0, "Adminlevel", pInfo[playerid][Adminlevel]);
		cache_get_value_name_int(0, "Money", pInfo[playerid][Money]);
		GivePlayerMoney(playerid, pInfo[playerid][Money]);
		cache_get_value_name_int(0, "Banned", pInfo[playerid][Banned]);
		cache_get_value_name(0, "BanReason", pInfo[playerid][BanReason], 45);
		cache_get_value_name(0, "BanDate", pInfo[playerid][BanDate], 20);
		cache_get_value_name(0, "BannedBy", pInfo[playerid][BannedBy], MAX_PLAYER_NAME+1);
		cache_get_value_name_float(0, "posX", pInfo[playerid][posX]);
		cache_get_value_name_float(0, "posY", pInfo[playerid][posY]);
		cache_get_value_name_float(0, "posZ", pInfo[playerid][posZ]);
		cache_get_value_name_float(0, "posA", pInfo[playerid][posA]);
		cache_get_value_name_int(0, "fsID", pInfo[playerid][fsID]);
		cache_get_value_name_int(0, "FightStyle", pInfo[playerid][FightStyle]);
		cache_get_value_name_int(0, "Skin", pInfo[playerid][Skin]);
		pInfo[playerid][LoggedIn] = 1;
		LogIn[playerid] = 1;
		SaveTimer[playerid] = SetTimerEx("SaveAccount", 300000, 1, "i", playerid);
		SetTimerEx("UnloadGuns", 250, 0, "i", playerid);
		SpawnPlayer(playerid);
	} else {
		SendClientMessage(playerid, COLOR_RED, "Login unsuccessful, password is wrong!");
		format(string, sizeof(string), "{FFFFFF}Welcome back %s,\nplease enter your account password.", Name[playerid]);
		ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "SA-MP.org | Login", string, "Login", "Cancel");
	}
	return 1;
}

public AccountRegister(playerid) {
	new string[128];
	format(string, sizeof(string), "Welcome %s, your registration was successful!", Name[playerid]);
	SendClientMessage(playerid, COLOR_DARKGREEN, string);
	pInfo[playerid][id] = cache_insert_id();
	pInfo[playerid][Adminlevel] = 0;
	pInfo[playerid][Banned] = 0;
	pInfo[playerid][BanReason] = '\0';
	pInfo[playerid][BanDate] = '\0';
	pInfo[playerid][BannedBy] = '\0';
	pInfo[playerid][LoggedIn] = 1;
	GiveMoney(playerid, 500);
	FirstLogin[playerid] = 1;
	SaveTimer[playerid] = SetTimerEx("SaveAccount", 300000, 1, "i", playerid);
	SpawnPlayer(playerid);
	return 1;
}

public SaveAccount(playerid) {
	new Query[1024], string[256];
	if(pInfo[playerid][LoggedIn] == 1) {
		GetPlayerPos(playerid, pInfo[playerid][posX], pInfo[playerid][posY], pInfo[playerid][posZ]);
		MapAndreas_FindZ_For2DCoord(pInfo[playerid][posX], pInfo[playerid][posY], pInfo[playerid][posZ]);
		GetPlayerFacingAngle(playerid, pInfo[playerid][posA]);
		mysql_format(handler, string, sizeof(string), "UPDATE `Player` SET `Adminlevel` = '%d', `Money` = '%d', `Banned` = '%d', `BanReason` = '%e', `BanDate` = '%e', `BannedBy` = '%e', \n", pInfo[playerid][Adminlevel], pInfo[playerid][Money], pInfo[playerid][Banned], pInfo[playerid][BanReason], pInfo[playerid][BanDate], pInfo[playerid][BannedBy]);
		strcat(Query, string);
		mysql_format(handler, string, sizeof(string), "`Skin` = '%d', `posX` = '%.5f', `posY` = '%.5f', `posZ` = '%.5f', `posA` = '%.5f', `fsID` = '%d', `FightStyle` = '%d' WHERE `id` = '%d'", pInfo[playerid][Skin], pInfo[playerid][posX], pInfo[playerid][posY], pInfo[playerid][posZ]+2.5, pInfo[playerid][posA], pInfo[playerid][fsID], pInfo[playerid][FightStyle], pInfo[playerid][id]);
		strcat(Query, string);
		mysql_query(handler, Query);
	} return 1;
}

public KickPlayer(playerid) {
	return Kick(playerid);
}

public LoadGarages()
{
    print("Loading garages..");
	new rows, var;
    cache_get_row_count(rows);
	if(!rows) return print("Could not find any Garages to load.");
	new name[64], label[64];
	for(new i; i < rows; i++)
	{
		cache_get_value_name_float(i, "GarageX", gInfo[i][g_GarageX]);
		cache_get_value_name_float(i, "GarageY", gInfo[i][g_GarageY]);
		cache_get_value_name_float(i, "GarageZ", gInfo[i][g_GarageZ]);

		cache_get_value_name_float(i, "SpawnX1", gInfo[i][g_SpawnX1]);
		cache_get_value_name_float(i, "SpawnY1", gInfo[i][g_SpawnY1]);
		cache_get_value_name_float(i, "SpawnZ1", gInfo[i][g_SpawnZ1]);
		cache_get_value_name_float(i, "SpawnR1", gInfo[i][g_SpawnR1]);

		cache_get_value_name_float(i, "SpawnX2", gInfo[i][g_SpawnX2]);
		cache_get_value_name_float(i, "SpawnY2", gInfo[i][g_SpawnY2]);
		cache_get_value_name_float(i, "SpawnZ2", gInfo[i][g_SpawnZ2]);
		cache_get_value_name_float(i, "SpawnR2", gInfo[i][g_SpawnR2]);

		cache_get_value_name_float(i, "SpawnX3", gInfo[i][g_SpawnX3]);
		cache_get_value_name_float(i, "SpawnY3", gInfo[i][g_SpawnY3]);
		cache_get_value_name_float(i, "SpawnZ3", gInfo[i][g_SpawnZ3]);
		cache_get_value_name_float(i, "SpawnR3", gInfo[i][g_SpawnR3]);

		cache_get_value_name_float(i, "SpawnX4", gInfo[i][g_SpawnX4]);
		cache_get_value_name_float(i, "SpawnY4", gInfo[i][g_SpawnY4]);
		cache_get_value_name_float(i, "SpawnZ4", gInfo[i][g_SpawnZ4]);
		cache_get_value_name_float(i, "SpawnR4", gInfo[i][g_SpawnR4]);

		cache_get_value_name_int(i, "Type", gInfo[i][g_Type]);

		cache_get_value_name(i, "Name", name);
		format(gInfo[i][g_Name], sizeof(name), name);

		gInfo[i][g_id] = i;

		format(label, sizeof(label), "Garage '%s' (ID: %d)\n\nUsage: /loadcar", gInfo[i][g_Name], i);
	    gInfo[i][g_Pickup] = CreateDynamicPickup(19132, 20, gInfo[i][g_GarageX], gInfo[i][g_GarageY], gInfo[i][g_GarageZ]);
		gInfo[i][g_3DText] = CreateDynamic3DTextLabel(label, COLOR_WHITE, gInfo[i][g_GarageX], gInfo[i][g_GarageY], gInfo[i][g_GarageZ], 15);
		var++;
	}
	return printf("%d/%d garages loaded sucsessfully.", var, rows);
}

stock NoPermission(playerid) {
	return SendClientMessage(playerid, COLOR_GREY, "You have no permission to use this command!");
}

stock currentTime(type = 1) {
	new cTime[20], Hour, Minute, Second, Year, Month, Day, date[20], hour[10];
	gettime(Hour, Minute, Second);
	getdate(Year, Month, Day);
	if(type == 1) {
		format(date, sizeof(date), "%02d.%02d.%02d", Day, Month, Year);
		format(hour, sizeof(hour), "%02d:%02d", Hour, Minute);
		format(cTime, sizeof(cTime), "%s - %s", date, hour);
	} else if(type == 2) {
		format(hour, sizeof(hour), "%02d:%02d", Hour, Minute);
		format(cTime, sizeof(cTime), "%s", hour);
	} else if(type == 3) {
		format(date, sizeof(date), "%02d.%02d.%02d", Day, Month, Year);
		format(cTime, sizeof(cTime), "%s", date);
	} return cTime;
}

public ShowPlayerVehicles(playerid, garageid) {
	new rows;
	cache_get_row_count(rows);
	if(!rows) return SendClientMessage(playerid, COLOR_RED, "You did not have any vehicles.");
	new plate[12], vid, model, string[2048];
	format(string, sizeof(string), "{FFFFFF}");
	for(new i; i < rows; i++)	{
		cache_get_value_name_int(i, "id", vid);
		cache_get_value_name_int(i, "model", model);
		cache_get_value_name(i, "licenseplate", plate, sizeof(plate));
		if(GetVehicleType(model) != gInfo[garageid][g_Type]) continue;
		format(string, sizeof(string), "%sID: %d | Name: %s | Plate: %s\n", string, vid, GetVehicleName(model), plate);
	}
	ShowPlayerDialog(playerid, D_SHOWPLAYERVEHS, DIALOG_STYLE_LIST, "{FFFFFF}Garage", string, "{FFFFFF}Choose", "{FFFFFF}Back");
	return 1;
}

public OnPlayerTakeDamage(playerid, issuerid, Float:amount, weaponid, bodypart) {
	if(issuerid != INVALID_PLAYER_ID) {
		pInfo[playerid][dTimer] = 1;
		DamageTimer[playerid] = SetTimerEx("ResetDamageTimer", 15000, 0, "i", playerid);
	}	return 1;
}

public ResetDamageTimer(playerid) {
	pInfo[playerid][dTimer] = 0;
	return 1;
}

public UpdateClock() {
	new clockString[6];
	TimeMinute = TimeMinute+1;
	if(TimeMinute == 60) {
		TimeMinute = 0;
		TimeHour ++;
	}
	if(TimeHour == 24) TimeHour = 0;
	SetWorldTime(TimeHour);
	if(TimeHour < 10 && TimeMinute < 10) format(clockString, 6, "0%d:0%d", TimeHour, TimeMinute);
	if(TimeHour > 9 && TimeMinute < 10) format(clockString, 6, "%d:0%d", TimeHour, TimeMinute);
	if(TimeHour < 10 && TimeMinute > 9) format(clockString, 6, "0%d:%d", TimeHour, TimeMinute);
	if(TimeHour > 9 && TimeMinute > 9) format(clockString, 6, "%d:%d", TimeHour, TimeMinute);
	TextDrawSetString(Clock, clockString);
	return 1;
}

public OneSecondTimer(playerid) {
	/* Health / Armor TextDraw */
	new Float:pHealth, Float:pArmour, HealthString[4], ArmourString[4], Query[256];
	GetPlayerHealth(playerid, pHealth);
	GetPlayerArmour(playerid, pArmour);
	format(HealthString, 4, "%.0f", pHealth);
	format(ArmourString, 4, "%.0f", pArmour);
	PlayerTextDrawSetString(playerid, Health[playerid], HealthString);
	PlayerTextDrawSetString(playerid, Armour[playerid], ArmourString);
	if(pHealth > 0) PlayerTextDrawShow(playerid, Health[playerid]);
	else PlayerTextDrawHide(playerid, Health[playerid]);
	if(pArmour > 0) PlayerTextDrawShow(playerid, Armour[playerid]);
	else PlayerTextDrawHide(playerid, Armour[playerid]);

	/* Anti Money-Hack */
	if(pInfo[playerid][Money] != GetPlayerMoney(playerid)) GivePlayerMoney(playerid, -GetPlayerMoney(playerid)), GivePlayerMoney(playerid, pInfo[playerid][Money]);
	if(!IsPlayerPaused(playerid) && pInfo[playerid][LoggedIn] == 1) {
		if(Weapon[playerid][GetPlayerWeapon(playerid)] == 0 && GetPlayerWeapon(playerid) != 0 && GetPlayerWeapon(playerid) != WEAPON_PARACHUTE) {
			pInfo[playerid][Banned] = 1;
			format(pInfo[playerid][BanReason], 45, "Weapon-Hack: %s", WeaponName[GetPlayerWeapon(playerid)]);
			format(pInfo[playerid][BannedBy], 25, "System");
			format(pInfo[playerid][BanDate], 20, "%s", currentTime(1));
			SendFormMessageToAll(COLOR_ADMINRED, "AC: %s got banned by anti-cheat for weapon-hack (%s).", Name[playerid], WeaponName[GetPlayerWeapon(playerid)]);
			mysql_format(handler, Query, sizeof(Query), "INSERT INTO `PunishLog` (`Type`, `Target`, `Admin`, `Reason`, `Time`) VALUES ('Ban', '%e', 'System', 'Weapon-Hack: %e', '%e')", Name[playerid], WeaponName[GetPlayerWeapon(playerid)], currentTime(1));
			mysql_query(handler, Query);
			SetTimerEx("KickPlayer", 100, 0, "i", playerid);
		}
	}
	return 1;
}

public RespawnPlayer(playerid, Float:X, Float:Y, Float:Z) {
	if(!IsPlayerInRangeOfPoint(playerid, 3.0, X, Y, Z)) return SendClientMessage(playerid, COLOR_GREY, "Your respawn was canceled because you have moved from your position!");
	if(pInfo[playerid][dTimer] != 0) return SendClientMessage(playerid, COLOR_GREY, "You took damage, you can't teleport now!");
	if(GetMoney(playerid) < 300) return SendClientMessage(playerid, COLOR_GREY, "You don't have enough money to respawn!");
	for(new i = 0; i < sizeof(randomSpawn); i++) {
		if(pInfo[playerid][fsID] == randomSpawn[i][rsID]) {
			SetPlayerPos(playerid, randomSpawn[i][spawnX], randomSpawn[i][spawnY], randomSpawn[i][spawnZ]);
			SetPlayerFacingAngle(playerid, randomSpawn[i][spawnA]);
			GiveMoney(playerid, -300);
			SendClientMessage(playerid, COLOR_YELLOW, "You have been successfully respawned, you had to pay $300!");
		}
	}
	return 1;
}

public RestartServer() {
	SendRconCommand("gmx");
	return 1;
}

public Unfreeze(playerid) {
	TogglePlayerControllable(playerid, 1);
	return 1;
}

public UnloadGuns(playerid) {
	ResetPlayerWeapons(playerid);
	for(new i = 1; i < 42; i++) Weapon[playerid][i] = 0;
	return 1;
}

stock LoadGuns(playerid) {
	for(new i = 1; i < 42; i++) Weapon[playerid][i] = 1;
	return 1;
}

stock GivePlayerGun(playerid, WeapID, Ammo) {
	Weapon[playerid][WeapID] = 1;
	GivePlayerWeapon(playerid, WeapID, Ammo);
	return 1;
}

stock GetVehicleType(modelid) {
	switch(modelid)	{
		case 417,425,447,469,487,488,497,548,563: { return 2; }				// 	Helicopters
		case 441,464,465,501,564,594: { return 3; }										//	RC Vehicles
		case 430,446,452..454,472,473,484,493,495: { return 4; }	 		//	Boats
		case 435,450,584,591,606..608,610,611: { return 5; }	 				// 	Trailers
		case 460,476,511..513,519,520,553,577,592,593: { return 6; }	//	Airplanes
		case 537,538,569,570,590,449: { return 7; }								 		//	Trains
		default: { return 1; }
	}	return 0;
}

stock GetVehicleName(modelid) {
	new vname[30];
	format(vname, sizeof(vname), "%s", VehNames[modelid - 400]);
	return vname;
}

stock GetNearestGarage(playerid) {
	new garage, Float:distance1, Float:distance2 = 10000000, i;
	for(; i < sizeof(gInfo); i++)	{
		distance1 = GetPlayerDistanceFromPoint(playerid, gInfo[i][g_SpawnX1], gInfo[i][g_SpawnY1], gInfo[i][g_SpawnZ1]);
		if(distance1 < distance2) distance2 = distance1, garage = i;
	}	return garage;
}

stock GetNearestAirport(playerid) {
	new airport, Float:distance1, Float:distance2 = 10000000, i;
	for(; i < sizeof(TravelPos); i++)	{
		if(TravelPos[i][Type] == 3) {
			distance1 = GetPlayerDistanceFromPoint(playerid, TravelPos[i][tDX], TravelPos[i][tDY], TravelPos[i][tDZ]);
			if(distance1 < distance2) distance2 = distance1, airport = i;
		}
	}	return airport;
}

stock GetNearestHarbour(playerid) {
	new harbour, Float:distance1, Float:distance2 = 10000000, i;
	for(; i < sizeof(TravelPos); i++)	{
		if(TravelPos[i][Type] == 2) {
			distance1 = GetPlayerDistanceFromPoint(playerid, TravelPos[i][tDX], TravelPos[i][tDY], TravelPos[i][tDZ]);
			if(distance1 < distance2) distance2 = distance1, harbour = i;
		}
	}	return harbour;
}

stock GetNearestTrainStation(playerid) {
	new trainstation, Float:distance1, Float:distance2 = 10000000, i;
	for(; i < sizeof(TravelPos); i++)	{
		if(TravelPos[i][Type] == 1) {
			distance1 = GetPlayerDistanceFromPoint(playerid, TravelPos[i][tDX], TravelPos[i][tDY], TravelPos[i][tDZ]);
			if(distance1 < distance2) distance2 = distance1, trainstation = i;
		}
	}	return trainstation;
}

stock IsVehicleInRangeOfPoint(vehicleid, Float:Range, Float:X, Float:Y, Float:Z) {
    new Float:VDistance = GetVehicleDistanceFromPoint(vehicleid, X, Y, Z);
    if(VDistance <= Range) return 1;
	return 0;
}

stock GetVehicleModelFromName(vehName[]) {
	for(new i = 0; i < 211; i++) {
		if(strfind(VehNames[i], vehName, true) != -1)
			return i + 400;
	} return -1;
}

stock IsNumeric(string[]) {
	for (new i = 0, j = strlen(string); i < j; i++)	{
		if(string[i] > '9' || string[i] < '0') return 0;
	} return 1;
}

stock AdminLog(command[], parameters[] = '-', name[], target[] = '-', time[]) {
	new Query[256];
	if(!strcmp(parameters, "'-'")) mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('%e', '%e', '%e', '%e')", command, name, target, time);
	else mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('%e %e', '%e', '%e', '%e')", command, parameters, name, target, time);
	mysql_query(handler, Query);
	return 1;
}

stock GiveMoney(playerid, amount) {
	new namount[32];
	valstr(namount, amount);
	if(amount > 0) GivePlayerMoney(playerid, strval(namount)), pInfo[playerid][Money] += strval(namount);
	else if(amount < 0) strdel(namount, strfind(namount, "-"), strfind(namount, "-")+1), GivePlayerMoney(playerid, -strval(namount)), pInfo[playerid][Money] -= strval(namount);
	return 1;
}

stock GetMoney(playerid) {
	return pInfo[playerid][Money];
}

stock IsValidWeapon(weaponid) {
	if(weaponid == WEAPON_BRASSKNUCKLE) return 1;
	if(weaponid == WEAPON_GOLFCLUB) return 1;
	if(weaponid == WEAPON_NITESTICK) return 1;
	if(weaponid == WEAPON_KNIFE) return 1;
	if(weaponid == WEAPON_BAT) return 1;
	if(weaponid == WEAPON_SHOVEL) return 1;
	if(weaponid == WEAPON_POOLSTICK) return 1;
	if(weaponid == WEAPON_KATANA) return 1;
	if(weaponid == WEAPON_CHAINSAW) return 1;
	if(weaponid == WEAPON_DILDO) return 1;
	if(weaponid == WEAPON_DILDO2) return 1;
	if(weaponid == WEAPON_VIBRATOR) return 1;
	if(weaponid == WEAPON_VIBRATOR2) return 1;
	if(weaponid == WEAPON_FLOWER) return 1;
	if(weaponid == WEAPON_CANE) return 1;
	if(weaponid == WEAPON_GRENADE) return 1;
	if(weaponid == WEAPON_TEARGAS) return 1;
	if(weaponid == WEAPON_MOLTOV) return 1;
	if(weaponid == WEAPON_COLT45) return 1;
	if(weaponid == WEAPON_SILENCED) return 1;
	if(weaponid == WEAPON_DEAGLE) return 1;
	if(weaponid == WEAPON_SHOTGUN) return 1;
	if(weaponid == WEAPON_SAWEDOFF) return 1;
	if(weaponid == WEAPON_SHOTGSPA) return 1;
	if(weaponid == WEAPON_UZI) return 1;
	if(weaponid == WEAPON_MP5) return 1;
	if(weaponid == WEAPON_AK47) return 1;
	if(weaponid == WEAPON_M4) return 1;
	if(weaponid == WEAPON_TEC9) return 1;
	if(weaponid == WEAPON_RIFLE) return 1;
	if(weaponid == WEAPON_SNIPER) return 1;
	if(weaponid == WEAPON_ROCKETLAUNCHER) return 1;
	if(weaponid == WEAPON_HEATSEEKER) return 1;
	if(weaponid == WEAPON_FLAMETHROWER) return 1;
	if(weaponid == WEAPON_MINIGUN) return 1;
	if(weaponid == WEAPON_SATCHEL) return 1;
	if(weaponid == WEAPON_BOMB) return 1;
	if(weaponid == WEAPON_SPRAYCAN) return 1;
	if(weaponid == WEAPON_FIREEXTINGUISHER) return 1;
	if(weaponid == WEAPON_CAMERA) return 1;
	if(weaponid == WEAPON_PARACHUTE) return 1;
	return 0;
}
