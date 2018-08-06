#include <a_samp>
#include <ocmd>
#include <a_mysql>
#include <streamer>
#include <sscanf2>
#include <mysql_connect>

new txtstr[145];
#define SendFormMessage(%0,%1,%2,%3) format(txtstr, 145, %2, %3) && SendClientMessage(%0, %1, txtstr)
#define SendFormMessageToAll(%0,%1,%2) format(txtstr, 145, %1, %2) && SendClientMessageToAll(%0, txtstr)

// ----- Farben -----
#define COLOR_DARKGREEN 0x00CC00FF
#define COLOR_RED 0xFF0000FF
#define COLOR_GREY 0x8F8F8FFF
#define COLOR_YELLOW 0xEEEE00FF
#define COLOR_ADMINRED 0x8B2500FF
#define COLOR_WHITE 0xFFFFFFFF
#define COLOR_GREEN 0x00EE00FF
// ------------------

// ----- Defines -----
#undef MAX_VEHICLES
#define MAX_VEHICLES 500
#define MAX_GARAGES 100
// -------------------

// ----- Dialoge -----
enum {
	D_LOGIN,
	D_REGISTER,
	D_SHOWPLAYERVEHS,
	D_TRAVELLSTS,
	D_TRAVELLSM,
	D_TRAVELSFFV,
	D_TRAVELSFTS,
	D_TRAVELLVOS,
	D_TRAVELLVSR,
	D_TRAVELLVTS,
	D_TRAVELLVSB,
	D_TRAVELLVS,
	D_TRAVELLVL,
	DTRAVELELS,
	D_TRAVELLSI
};
// -------------------
enum PlayerData {
	id,
	Adminlevel,
	Banned,
	BanReason[45],
	BanDate[20],
	BannedBy[MAX_PLAYER_NAME+1],
	Float:posX,
	Float:posY,
	Float:posZ,
	Float:posA,
	FightStyle,
	Skin,
	LoggedIn
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
forward ShowPlayerVehicles(playerid);

new MySQL:handler;
new Name[MAX_PLAYER_NAME][MAX_PLAYERS];
new SaveTimer[MAX_PLAYERS];
new FirstLogin[MAX_PLAYERS];
enum rSp {
	Float:spawnX,
	Float:spawnY,
	Float:spawnZ,
	Float:spawnA,
	FightStyle
};
new randomSpawn[][rSp] = {
	{2621.1633, 212.5138, 59.0695, 319.4377, FIGHT_STYLE_GRABKICK}, // HankyPanky
	{2478.5625, -1245.8259, 28.7706, 183.5509, FIGHT_STYLE_BOXING}, // EastLS
	{1955.5347, 691.5303, 10.8203, 89.1271, FIGHT_STYLE_NORMAL}, // RockShore West
	{-761.4552, 1615.0485, 27.1172, 356.1084, FIGHT_STYLE_ELBOW}, // Las Barrancas
	{-2080.5703, -2546.9583, 30.6250, 298.0318, FIGHT_STYLE_KNEEHEAD}, // AngelPine
	{-2240.5330, 577.3491, 35.1719, 182.1359, FIGHT_STYLE_KUNGFU} // Chinatown
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
	Float:tZ
}
new TravelPos[][TravelData] = {
	{1, 1757.1107, -1944.0425, 13.5681}, // Los Santos Train Station
	{2, 825.0736, -1353.6986, 13.5369}, // Los Santos Metro
	{3, -1975.3186, -569.3350, 25.6802}, // San Fierro Foster Valley
	{4, -1973.9847, 117.5540, 27.6875}, // San Fierro Train Station
	{5, 571.1689, 1217.9426, 11.7905}, // Las Venturas Octane Spring
	{6, 730.0837, 1932.4736, 5.5391}, // Las Venturas Spread Ranch
	{7, 1436.2892, 2656.8005, 11.3926}, // Las Venturas Train Station
	{8, 2379.0972, 2700.7095, 10.8081}, // Las Venturas Spiny Bed
	{9, 2778.3882, 1732.4832, 11.3926}, // Las Ventural Sobell
	{10, 2857.7542, 1314.5885, 11.3906}, // Las Ventural Linden
	{11, 2295.1128, -1158.7957, 26.6275}, // East Los Santos
	{12, 2218.1255, -1657.0381, 15.1890} // Los Santos Idlewood
};

main() {
	print("\n");
	print("============================================================");
	print("Gamemode created for SA-MP.org");
	print("This gamemode is licensed under the GNU Affero General Public License v3.0");
	print("============================================================\n");
}

// ----- Commands -----
ocmd:spawn(playerid, params[]) {
	new Pos = random(sizeof(randomSpawn));
	SetPlayerPos(playerid, randomSpawn[Pos][spawnX], randomSpawn[Pos][spawnY], randomSpawn[Pos][spawnZ]);
	SetPlayerFacingAngle(playerid, randomSpawn[Pos][spawnA]);
	pInfo[playerid][posX] = randomSpawn[Pos][spawnX];
	pInfo[playerid][posY] = randomSpawn[Pos][spawnY];
	pInfo[playerid][posZ] = randomSpawn[Pos][spawnZ];
	pInfo[playerid][posA] = randomSpawn[Pos][spawnA];
	SetPlayerFightingStyle(playerid, randomSpawn[Pos][FightStyle]);
	pInfo[playerid][FightStyle] = randomSpawn[Pos][FightStyle];
	new pSkin = random(6);
	SetPlayerSkin(playerid, randomSkins[Pos][pSkin]);
	pInfo[playerid][Skin] = randomSkins[Pos][pSkin];
	return 1;
}

ocmd:goto(playerid, params[]) {
	new target, Float:X, Float:Y, Float:Z, Query[256];
	if(pInfo[playerid][Adminlevel] >= 1) {
		if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /goto <PlayerName/PlayerID>");
		if(!IsPlayerConnected(target) || pInfo[playerid][LoggedIn] == 0) return SendClientMessage(playerid, COLOR_GREY, "This player isn't loggedin!");
		GetPlayerPos(target, X, Y, Z);
		if(!IsPlayerInAnyVehicle(playerid)) SetPlayerPos(playerid, X, Y+1, Z);
		else SetVehiclePos(GetPlayerVehicleID(playerid), X, Y+2, Z);
		SendFormMessage(playerid, COLOR_YELLOW, "You have teleported to the player %s.", Name[target]);
		SendFormMessage(target, COLOR_YELLOW, "Admin %s have teleported to you.", Name[playerid]);
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/goto %e', '%e', '%e', '%e')", params, Name[playerid], Name[target], currentTime(1));
		mysql_query(handler, Query);
		return 1;
	} return NoPermission(playerid);
}

ocmd:gotopos(playerid, params[]) {
	new target, Float:Pos[3], Query[256];
	if(pInfo[playerid][Adminlevel] >= 1) {
		if(sscanf(params, "p<,>fff", Pos[0], Pos[1], Pos[2])) return SendClientMessage(playerid, COLOR_GREY, "Usage: /gotopos <X> <Y> <Z>");
		if(!IsPlayerConnected(target) || pInfo[playerid][LoggedIn] == 0) return SendClientMessage(playerid, COLOR_GREY, "This player isn't loggedin!");
		if(!IsPlayerInAnyVehicle(playerid)) SetPlayerPos(playerid, Pos[0], Pos[1], Pos[2]);
		else SetVehiclePos(GetPlayerVehicleID(playerid), Pos[0], Pos[1], Pos[2]);
		SendFormMessage(playerid, COLOR_YELLOW, "You have teleported to the coordinate %0.2f %0.2f %0.2f", Pos[0], Pos[1], Pos[2]);
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/gotopos %e', '%e', '%e', '%e')", params, Name[playerid], Name[target], currentTime(1));
		mysql_query(handler, Query);
		return 1;
	} return NoPermission(playerid);
}

ocmd:gethere(playerid, params[]) {
	new target, Float:X, Float:Y, Float:Z, Query[256];
	if(pInfo[playerid][Adminlevel] >= 1) {
		if(sscanf(params, "u", target)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /gethere <PlayerName/PlayerID>");
		if(!IsPlayerConnected(target) || pInfo[playerid][LoggedIn] == 0) return SendClientMessage(playerid, COLOR_GREY, "This player isn't loggedin!");
		GetPlayerPos(playerid, X, Y, Z);
		if(!IsPlayerInAnyVehicle(target)) SetPlayerPos(target, X, Y+1, Z);
		else SetVehiclePos(GetPlayerVehicleID(target), X, Y+2, Z);
		SendFormMessage(playerid, COLOR_YELLOW, "You have teleported the player %s to you.", Name[target]);
		SendFormMessage(target, COLOR_YELLOW, "Admin %s has teleported you to him", Name[playerid]);
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/gethere %e', '%e', '%e', '%e')", params, Name[playerid], Name[target], currentTime(1));
		mysql_query(handler, Query);
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
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/kick %e', '%e', '%e', '%e')", params, Name[playerid], Name[target], currentTime(1));
		mysql_query(handler, Query);
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
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/ban %e', '%e', '%e', '%e')", params, Name[playerid], Name[target], currentTime(1));
		mysql_query(handler, Query);
		SetTimerEx("KickPlayer", 50, 0, "i", playerid);
		return 1;
	} return NoPermission(playerid);
}

ocmd:gmx(playerid, params[]) {
	if(pInfo[playerid][Adminlevel] == 3) {
		SendRconCommand("gmx");
		return 1;
	} return NoPermission(playerid);
}

ocmd:loadcar(playerid, params[])
{
	new string[256];
	mysql_format(handler, string, sizeof(string), "SELECT * FROM `vehicles` WHERE `owner` = '%d'", pInfo[playerid][id]);
	mysql_pquery(handler, string, "ShowPlayerVehicles", "d", playerid);
	return 1;
}

ocmd:veh(playerid, params[]) {
	new vehicle[25], sCar, Float:X, Float:Y, Float:Z, Float:A, aVehicle, color1, color2;
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	if(sscanf(params, "s[25]dd", vehicle, color1, color2)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /veh <VehicleID/VehicleName> <Color1> <Color2>");
	if(!IsNumeric(vehicle)) sCar = GetVehicleModelFromName(vehicle);
	else sCar = strval(vehicle);
	if(sCar == -1) return SendFormMessage(playerid, COLOR_GREY, "The vehicle %s can't be found!", vehicle);
	GetPlayerPos(playerid, X, Y, Z);
	GetPlayerFacingAngle(playerid, A);
	aVehicle = CreateVehicle(sCar, X, Y, Z, A, color1, color2, -1);
	PutPlayerInVehicle(playerid, aVehicle, 0);
	return 1;
}

ocmd:dveh(playerid, params[]) {
	new vehicle;
	if(pInfo[playerid][Adminlevel] < 2) return NoPermission(playerid);
	if(sscanf(params, "d", vehicle)) {
		if(!IsPlayerInAnyVehicle(playerid)) {
			SendClientMessage(playerid, COLOR_GREY, "You need to be in a vehicle or give a vehicleid");
			SendClientMessage(playerid, COLOR_GREY, "Usage: /dveh <VehicleID>");
			return 1;
		} else {
			DestroyVehicle(GetPlayerVehicleID(playerid));
			SendFormMessage(playerid, COLOR_WHITE, "You have deleted the vehicle %d", GetPlayerVehicleID(playerid));
			return 1;
		}
	} else {
		if(!GetVehicleModel(vehicle)) {
			return SendClientMessage(playerid, COLOR_GREY, "This vehicle doesn't exists!");
		} else {
			DestroyVehicle(vehicle);
			SendFormMessage(playerid, COLOR_WHITE, "You have deleted the vehicle %d", vehicle);
			return 1;
		}
	}
}

ocmd:fixveh(playerid) {
	if(pInfo[playerid][Adminlevel] < 1) return NoPermission(playerid);
	if(!IsPlayerInAnyVehicle(playerid)) return SendClientMessage(playerid, COLOR_GREY, "You need to be in a vehicle!");
	RepairVehicle(GetPlayerVehicleID(playerid));
	SendClientMessage(playerid, COLOR_GREEN, "Your vehicle was successfully repaired!");
	return 1;
}

ocmd:travel(playerid) {
	if(pInfo[playerid][LoggedIn] == 0) return 1;
	for(new i = 0; i < sizeof(TravelPos); i++) {
		if(IsPlayerInRangeOfPoint(playerid, 3.0, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ])) {
			if(i == 0) {
				ShowPlayerDialog(playerid, D_TRAVELLSTS, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Los Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Venturas Train Station\nLas Venturas Spinybed\nLas Venturas Sobell\nLas Venturas Linden\nEast Los Santos\nLos Santos Idlewood", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 1) {
				ShowPlayerDialog(playerid, D_TRAVELLSM, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "San Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Ventural Train Station\nLas Ventural Spiny Bed\nLas Ventural Sobell\nLas Ventural Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 2) {
				ShowPlayerDialog(playerid, D_TRAVELSFFV, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "San Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Ventural Train Station\nLas Ventural Spiny Bed\nLas Ventural Sobell\nLas Ventural Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 3) {
				ShowPlayerDialog(playerid, D_TRAVELSFTS, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Ventural Train Station\nLas Ventural Spiny Bed\nLas Ventural Sobell\nLas Ventural Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 4) {
				ShowPlayerDialog(playerid, D_TRAVELLVOS, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Venturas Spread Ranch\nLas Ventural Train Station\nLas Ventural Spiny Bed\nLas Ventural Sobell\nLas Ventural Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 5) {
				ShowPlayerDialog(playerid, D_TRAVELLVSR, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Ventural Train Station\nLas Ventural Spiny Bed\nLas Ventural Sobell\nLas Ventural Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 6) {
				ShowPlayerDialog(playerid, D_TRAVELLVTS, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Ventural Spiny Bed\nLas Ventural Sobell\nLas Ventural Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 7) {
				ShowPlayerDialog(playerid, D_TRAVELLVSB, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Ventural Sobell\nLas Ventural Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Ventural Train Station", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 8) {
				ShowPlayerDialog(playerid, D_TRAVELLVS, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Las Ventural Linden\nEast Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Ventural Train Station\nLas Ventural Spiny Bed", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 9) {
				ShowPlayerDialog(playerid, D_TRAVELLVL, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "East Los Santos\nLos Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Ventural Train Station\nLas Ventural Spiny Bed\nLas Ventural Sobell", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 10) {
				ShowPlayerDialog(playerid, DTRAVELELS, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Los Santos Idlewood\nLos Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Ventural Train Station\nLas Ventural Spiny Bed\nLas Ventural Sobell\nLas Ventural Linden", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			} else if(i == 11) {
				ShowPlayerDialog(playerid, D_TRAVELLSI, DIALOG_STYLE_LIST, "SA-MP.org | Travel", "Los Santos Train Station\nLos Santos Metro\nSan Fierro Foster Valley\nSan Fierro Train Station\nLas Venturas Octane Spring\nLas Venturas Spread Ranch\nLas Ventural Train Station\nLas Ventural Spiny Bed\nLas Ventural Sobell\nLas Ventural Linden\nEast Los Santos", "Travel", "Cancel");
				SetPVarInt(playerid, "Travel", TravelPos[i][tID]);
				return 1;
			}
		} return SendClientMessage(playerid, COLOR_GREY, "You are not at a train station!");
	} return 1;
}

public OnGameModeInit()
{
	mysql_log(ALL);
	handler = mysql_connect(M_HOST, M_USER, M_PASS, M_DATA);
	if(mysql_errno() != 0) printf("Database connection could not be established! (%d)", mysql_errno());
	else print("Database connection successfully established!");

	CreateVehicle(560, 2406.4075, -1391.0314, 23.8891, 359.8459, -1, -1, 0, 0);

	LoadGarages();

	for(new i = 0; i < sizeof(TravelPos); i++) {
		CreateDynamicPickup(1239, 1, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ]);
		CreateDynamic3DTextLabel("Trainstation\n\nUsage: /travel", COLOR_YELLOW, TravelPos[i][tX], TravelPos[i][tY], TravelPos[i][tZ], 15.0);
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
	FirstLogin[playerid] = 0;
	GetPlayerName(playerid, Name[playerid], MAX_PLAYER_NAME);
	SetSpawnInfo(playerid, 0, 0, 0.0, 0.0, 0.0, 0.0, 0, 0, 0, 0, 0, 0);
	mysql_format(handler, Query, sizeof(Query), "SELECT * FROM `Player` WHERE `Name` = '%e'", Name[playerid]);
	mysql_tquery(handler, Query, "CheckAccount", "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	KillTimer(SaveTimer[playerid]);
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
		SetPlayerFightingStyle(playerid, randomSpawn[Pos][FightStyle]);
		pInfo[playerid][FightStyle] = randomSpawn[Pos][FightStyle];
		new pSkin = random(6)+1;
		SetPlayerSkin(playerid, randomSkins[Pos][pSkin]);
		pInfo[playerid][Skin] = randomSkins[Pos][pSkin];
		FirstLogin[playerid] = 0;
	} else {
	    SetPlayerPos(playerid, pInfo[playerid][posX], pInfo[playerid][posY], pInfo[playerid][posZ]);
	    SetPlayerFacingAngle(playerid, pInfo[playerid][posA]);
	    SetPlayerSkin(playerid, pInfo[playerid][Skin]);
	    SetPlayerFightingStyle(playerid, pInfo[playerid][FightStyle]);
	}
	return 1;
}

public OnPlayerDeath(playerid, killerid, reason)
{
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
	return 0;
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
	return 1;
}

public OnPlayerExitedMenu(playerid)
{
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
		    new dbid, trash[10], string[128], plate[15];
			sscanf(inputtext, "s[4]d", trash, dbid);
			mysql_format(handler, string, sizeof(string), "SELECT * FROM `vehicles` WHERE `id` = '%d' AND `owner` = '%d'", dbid, pInfo[playerid][id]);
			printf("dbid: %d, owner: %d", dbid, pInfo[playerid][id]);
			new Cache:result = mysql_query(handler, string);
			new i;
			for(; i < MAX_VEHICLES; i++) {
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

			new gID = GetNearestGarage(playerid);

			vInfo[i][v_vehicleid] = CreateVehicle(vInfo[i][v_model], gInfo[gID][g_SpawnX1], gInfo[gID][g_SpawnY1], gInfo[gID][g_SpawnZ1], gInfo[gID][g_SpawnR1], vInfo[i][v_color1], vInfo[i][v_color2], -1, 0);
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


			//PutPlayerInVehicle(playerid, vInfo[i][v_vehicleid], 0);

			cache_delete(result);
			print("Fertig");

			cache_delete(result);
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
		cache_get_value_name_int(0, "id", pInfo[playerid][id]);
		cache_get_value_name_int(0, "Banned", pInfo[playerid][Banned]);
		cache_get_value_name(0, "BanReason", pInfo[playerid][BanReason], 45);
		cache_get_value_name(0, "BanDate", pInfo[playerid][BanDate], 20);
		cache_get_value_name(0, "BannedBy", pInfo[playerid][BannedBy], MAX_PLAYER_NAME+1);
		cache_get_value_name_float(0, "posX", pInfo[playerid][posX]);
		cache_get_value_name_float(0, "posY", pInfo[playerid][posY]);
		cache_get_value_name_float(0, "posZ", pInfo[playerid][posZ]);
		cache_get_value_name_float(0, "posA", pInfo[playerid][posA]);
		cache_get_value_name_int(0, "FightStyle", pInfo[playerid][FightStyle]);
		cache_get_value_name_int(0, "Skin", pInfo[playerid][Skin]);
		pInfo[playerid][LoggedIn] = 1;
		SaveTimer[playerid] = SetTimerEx("SaveAccount", 300000, 1, "i", playerid);
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
	FirstLogin[playerid] = 1;
	SaveTimer[playerid] = SetTimerEx("SaveAccount", 300000, 1, "i", playerid);
	SpawnPlayer(playerid);
	return 1;
}

public SaveAccount(playerid) {
	new Query[1024], string[256];
	if(pInfo[playerid][LoggedIn] == 1) {
		mysql_format(handler, Query, sizeof(Query), "UPDATE `Player` SET `Adminlevel` = '%d', `Banned` = '%d', `BanReason` = '%e', `BanDate` = '%e', `BannedBy` = '%e' WHERE `id` = '%d'", pInfo[playerid][Adminlevel], pInfo[playerid][Banned], pInfo[playerid][BanReason], pInfo[playerid][BanDate], pInfo[playerid][BannedBy], pInfo[playerid][id]);
		GetPlayerPos(playerid, pInfo[playerid][posX], pInfo[playerid][posY], pInfo[playerid][posZ]);
		GetPlayerFacingAngle(playerid, pInfo[playerid][posA]);
		mysql_format(handler, string, sizeof(string), "UPDATE `Player` SET `Adminlevel` = '%d', `Banned` = '%d', `BanReason` = '%e', `BanDate` = '%e', `BannedBy` = '%e', \n", pInfo[playerid][Adminlevel], pInfo[playerid][Banned], pInfo[playerid][BanReason], pInfo[playerid][BanDate], pInfo[playerid][BannedBy]);
		strcat(Query, string);
		mysql_format(handler, string, sizeof(string), "`Skin` = '%d', `posX` = '%.5f', `posY` = '%.5f', `posZ` = '%.5f', `posA` = '%.5f', `FightStyle` = '%d' WHERE `id` = '%d'", pInfo[playerid][Skin], pInfo[playerid][posX], pInfo[playerid][posY], pInfo[playerid][posZ], pInfo[playerid][posA], pInfo[playerid][FightStyle], pInfo[playerid][id]);
		strcat(Query, string);
		mysql_query(handler, Query);
	} return 1;
}

public KickPlayer(playerid) {
	return Kick(playerid);
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

public ShowPlayerVehicles(playerid)
{
	new rows;
	cache_get_row_count(rows);
	if(!rows) return SendClientMessage(playerid, COLOR_RED, "You did not have any vehicles.");
	new plate[12], vid, model, string[2048], type;
	if(IsPlayerInRangeOfPoint(playerid, 5, 2380.5435, -1376.7015, 24.0000)) type = 1;
	else type = 0;
	format(string, sizeof(string), "{FFFFFF}");
	for(new i; i < rows; i++)
	{
		cache_get_value_name_int(i, "id", vid);
		cache_get_value_name_int(i, "model", model);
		cache_get_value_name(i, "licenseplate", plate, sizeof(plate));
		if(GetVehicleType(model) != type) continue;
		format(string, sizeof(string), "%sID: %d | Name: %s | Plate: %s\n", string, vid, GetVehicleName(model), plate);
	}
	ShowPlayerDialog(playerid, D_SHOWPLAYERVEHS, DIALOG_STYLE_LIST, "{FFFFFF}Garage", string, "{FFFFFF}Choose", "{FFFFFF}Back");
	return 1;
}

stock GetVehicleType(modelid)
{
	switch(modelid)
	{
		case 417,425,447,469,487,488,497,548,563: { return 2; }     		// 	Helicopters
		case 441,464,465,501,564,594: { return 3; }                 		//	RC Vehicles
		case 430,446,452..454,472,473,484,493,495: { return 4; }    		//  Boats
		case 435,450,584,591,606..608,610,611: { return 5; }    			// 	Trailers
		case 460,476,511..513,519,520,553,577,592,593: { return 6; }        //  Airplanes
		case 537,538,569,570,590,449: { return 7; }                         //  Trains
		default: { return 1; }
	}
	return 0;
}

stock GetVehicleName(modelid)
{
	new vname[30];
	format(vname, sizeof(vname), "%s", VehNames[modelid - 400]);
	return vname;
}

stock GetNearestGarage(playerid)
{
	new garage, Float:distance1, Float:distance2 = 10000000, i;
	for(; i < sizeof(gInfo); i++)
	{
		distance1 = GetPlayerDistanceFromPoint(playerid, gInfo[i][g_SpawnX1], gInfo[i][g_SpawnY1], gInfo[i][g_SpawnZ1]);
		if(distance1 < distance2) distance2 = distance1, garage = i;
	}
	return garage;
}

stock LoadGarages()
{
    gInfo[0][g_SpawnX1] = 2375.8301; gInfo[0][g_SpawnY1] = -1389.0652; gInfo[0][g_SpawnZ1] = 23.6478; gInfo[0][g_SpawnR1] = 268.0640; // East Los Santos
    new label[64];
	for(new i; i < sizeof(gInfo); i++)
	{
	    format(label, sizeof(label), "Garage %d\n\nUsage: /loadcar", i);
	    CreateDynamicPickup(19132, 20, gInfo[i][g_GarageX], gInfo[i][g_GarageY], gInfo[i][g_GarageZ]);
		CreateDynamic3DTextLabel(label, COLOR_WHITE, gInfo[i][g_GarageX], gInfo[i][g_GarageY], gInfo[i][g_GarageZ], 15);
	}
	return 1;
}

stock GetVehicleModelFromName(vehName[]) {
	for(new i = 0; i < 211; i++) {
		if(strfind(VehNames[i], vehName, true) != -1)
			return i + 400;
	} return -1;
}

stock IsNumeric(string[]) {
	for (new i = 0, j = strlen(string); i < j; i++)
	{
		if(string[i] > '9' || string[i] < '0') return 0;
	} return 1;
}
