#include <a_samp>
#include <ocmd>
#include <a_mysql>
#include <streamer>
#include <sscanf2>

#define M_HOST "127.0.0.1"
#define M_USER "samporg"
#define M_PASS "W07oDGtwFkDt3o16"
#define M_DATA "samporg"

new txtstr[145];
#define SendFormMessage(%0,%1,%2,%3) format(txtstr, 145, %2, %3) && SendClientMessage(%0, %1, txtstr)
#define SendFormMessageToAll(%0,%1,%2) format(txtstr, 145, %1, %2) && SendClientMessageToAll(%0, txtstr)

// ----- Farben -----
#define COLOR_DARKGREEN 0x00CC00FF
#define COLOR_RED 0xFF0000FF
#define COLOR_GREY 0x8F8F8FFF
#define COLOR_YELLOW 0xEEEE00FF
#define COLOR_ADMINRED 0x8B2500FF
// ------------------

// ----- Dialoge -----
#define D_LOGIN 1
#define D_REGISTER 2
// -------------------
enum PlayerData {
	Adminlevel,
	Banned,
	BanReason[45],
	BanDate[20],
	BannedBy[MAX_PLAYER_NAME+1],
	LoggedIn
}
new pInfo[MAX_PLAYERS][PlayerData];

forward CheckAccount(playerid);
forward AccountLogin(playerid);
forward AccountRegister(playerid);
forward SaveAccount(playerid);
forward KickPlayer(playerid);

new MySQL:handler;
new Name[MAX_PLAYER_NAME][MAX_PLAYERS];
new SaveTimer[MAX_PLAYERS];

main() {
	print("\n");
	print("============================================================");
	print("Gamemode created for SA-MP.org");
	print("This gamemode is licensed under the GNU Affero General Public License v3.0");
	print("============================================================\n");
}

// ----- Commands -----
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
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/goto', '%e', '%e', '%e')", Name[playerid], Name[target], currentTime(1));
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
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/gethere', '%e', '%e', '%e')", Name[playerid], Name[target], currentTime(1));
		mysql_query(handler, Query);
		return 1;
	} return NoPermission(playerid);
}

ocmd:kick(playerid, params[]) {
	new target, reason[45], Query[256];
	if(pInfo[playerid][Adminlevel] >= 1) {
		if(sscanf(params, "us[45]", target, reason)) return SendClientMessage(playerid, COLOR_GREY, "Usage: /kick <PlayerName/PlayerID> <Reason>");
		if(!IsPlayerConnected(target)) return SendClientMessage(playerid, COLOR_GREY, "This player isn't loggedin!");
		if(pInfo[target][Adminlevel] >= pInfo[playerid][Adminlevel] && pInfo[playerid][Adminlevel] < 5) return SendClientMessage(playerid, COLOR_GREY, "You are not allowed to use this command on this player!");
		SendFormMessageToAll(COLOR_ADMINRED, "[ADM]: %s got kicked by %s for %s", Name[target], Name[playerid], reason);
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `PunishLog` (`Type`, `Target`, `Admin`, `Reason`, `Time`) VALUES ('Kick', '%e', '%e', '%e', '%e')", Name[target], Name[playerid], reason, currentTime(1));
		mysql_query(handler, Query);
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/kick', '%e', '%e', '%e')", Name[playerid], Name[target], currentTime(1));
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
		mysql_format(handler, Query, sizeof(Query), "INSERT INTO `AdminLog` (`Command`, `Admin`, `Target`, `Time`) VALUES ('/ban', '%e', '%e', '%e')", Name[playerid], Name[target], currentTime(1));
		mysql_query(handler, Query);
		SetTimerEx("KickPlayer", 50, 0, "i", playerid);
		return 1;
	} return NoPermission(playerid);
}

ocmd:gmx(playerid, params[]) {
	if(pInfo[playerid][Adminlevel] == 5) {
		SendRconCommand("gmx");
		return 1;
	} return NoPermission(playerid);
}

public OnGameModeInit()
{
	mysql_log(ALL);
	handler = mysql_connect(M_HOST, M_USER, M_PASS, M_DATA);
	if(mysql_errno() != 0) printf("Database connection could not be established! (%d)", mysql_errno());
	else print("Database connection successfully established!");
	
	CreateVehicle(560, 2406.4075, -1391.0314, 23.8891, 359.8459, -1, -1, 0, 0);

	// ----- Disables/Settings -----
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	
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
	GetPlayerName(playerid, Name[playerid], MAX_PLAYER_NAME);
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
	SetPlayerPos(playerid, 2416.1909, -1374.5367, 24.5734);
	SetPlayerFacingAngle(playerid, 125.9723);
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
				//Salt[i] = random(79)+47;
				Salt[i] = random(2) ? (random(26) + (random(2) ? 'a' : 'A')) : (random(10) + '0');
			}
			Salt[25] = 0;
			SHA256_PassHash(inputtext, Salt, H_Pass, 64);
			mysql_format(handler, Query, sizeof(Query), "INSERT INTO `Player` (`Name`, `Password`, `Salt`) VALUES ('%e', '%e', '%e')", Name[playerid], H_Pass, Salt);
			mysql_tquery(handler, Query, "AccountRegister", "i", playerid);
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
		cache_get_value_name_int(0, "Adminlevel", pInfo[playerid][Adminlevel]);
		cache_get_value_name_int(0, "Banned", pInfo[playerid][Banned]);
		cache_get_value_name(0, "BanReason", pInfo[playerid][BanReason], 45);
		cache_get_value_name(0, "BanDate", pInfo[playerid][BanDate], 20);
		cache_get_value_name(0, "BannedBy", pInfo[playerid][BannedBy], MAX_PLAYER_NAME+1);
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
	pInfo[playerid][Adminlevel] = 0;
	pInfo[playerid][Banned] = 0;
	pInfo[playerid][BanReason] = '\0';
	pInfo[playerid][BanDate] = '\0';
	pInfo[playerid][BannedBy] = '\0';
	pInfo[playerid][LoggedIn] = 1;
	SaveTimer[playerid] = SetTimerEx("SaveAccount", 300000, 1, "i", playerid);
	SpawnPlayer(playerid);
	return 1;
}

public SaveAccount(playerid) {
	new Query[1024];
	if(pInfo[playerid][LoggedIn] == 1) {
		mysql_format(handler, Query, sizeof(Query), "UPDATE `Player` SET `Adminlevel` = '%d', `Banned` = '%d', `BanReason` = '%e', `BanDate` = '%e', `BannedBy` = '%e' WHERE `Name` = '%e'", pInfo[playerid][Adminlevel], pInfo[playerid][Banned], pInfo[playerid][BanReason], pInfo[playerid][BanDate], pInfo[playerid][BannedBy], Name[playerid]);
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
