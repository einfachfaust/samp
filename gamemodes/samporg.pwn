#include <a_samp>
#include <ocmd>
#include <a_mysql>
#include <streamer>
#include <sscanf2>
#include <strlib>

#define M_HOST "127.0.0.1"
#define M_USER "samporg"
#define M_PASS "W07oDGtwFkDt3o16"
#define M_DATA "samporg"

// ----- Farben -----
#define COLOR_DARKGREEN 0x00CC00FF
#define COLOR_RED 0xFF0000FF

// ----- Dialoge -----
enum {
	D_LOGIN,
	D_REGISTER
}

forward CheckAccount(playerid);
forward AccountLogin(playerid);
forward AccountRegister(playerid);

new MySQL:handler;
new Name[MAX_PLAYER_NAME][MAX_PLAYERS];

main() {}

public OnGameModeInit()
{
	handler = mysql_connect(M_HOST, M_USER, M_PASS, M_DATA);
	if(mysql_errno() != 0) printf("Datenbankverbindung konnte nicht hergestellt werden! (%d)", mysql_errno());
	else print("Datenbankverbindung wurde erfolgreich hergestellt.");
	
	CreateVehicle(560, 2406.4075, -1391.0314, 23.8891, 359.8459, -1, -1, 0, 0);

	// ----- Disables -----
	DisableInteriorEnterExits();
	EnableStuntBonusForAll(0);
	// --------------------
	return 1;
}

public OnGameModeExit()
{
	return 1;
}

public OnPlayerRequestClass(playerid, classid)
{
	return 1;
}

public OnPlayerConnect(playerid)
{
	new Query[128];
	GetPlayerName(playerid, Name[playerid], MAX_PLAYER_NAME);
	mysql_format(handler, Query, sizeof(Query), "SELECT * FROM `Spieler` WHERE `Name` = '%e'", Name[playerid]);
	mysql_tquery(handler, Query, "CheckAccount", "i", playerid);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
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
			mysql_format(handler, Query, sizeof(Query), "SELECT `Salt` FROM `Spieler` WHERE `Name` = '%e' LIMIT 1", Name[playerid]);
			new Cache:result = mysql_query(handler, Query);
			cache_get_value_name(0, "Salt", Salt, 26);
			cache_delete(result);
	        SHA256_PassHash(inputtext, Salt, H_Pass, sizeof(H_Pass));
	        mysql_format(handler, Query, sizeof(Query), "SELECT * FROM `Spieler` WHERE `Name` = '%e' AND `Passwort` = '%e'", Name[playerid], H_Pass);
	        mysql_tquery(handler, Query, "AccountLogin", "i", playerid);
		}
		case D_REGISTER: {
		    if(!response) return Kick(playerid);
		    if(strlen(inputtext) < 6) {
				SendClientMessage(playerid, COLOR_RED, "Your password need at least 6 digits.");
				return ShowPlayerDialog(playerid, D_REGISTER, DIALOG_STYLE_INPUT, "SA-MP.org | Register", sprintf("{FFFFFF}Welcome %s,\nwe can't find an account with this name in the database,\nplease enter a password to register a account.", Name[playerid]), "Register", "Cancel");
			}
			new Query[256], H_Pass[64], Salt[26];
			for(new i; i < 25; i++) {
			    Salt[i] = random(79)+47;
			}
			Salt[25] = 0;
			SHA256_PassHash(inputtext, Salt, H_Pass, 64);
			mysql_format(handler, Query, sizeof(Query), "INSERT INTO `Spieler` (`Name`, `Passwort`, `Salt`) VALUES ('%e', '%e', '%e')", Name[playerid], H_Pass, Salt);
			mysql_tquery(handler, Query, "AccountRegister", "i", playerid);
		}
	}
	return 1;
}

public OnPlayerClickPlayer(playerid, clickedplayerid, source)
{
	return 1;
}

public CheckAccount(playerid)
{
	new Rows;
	cache_get_row_count(Rows);
	if(Rows >= 1) {
	    ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "SA-MP.org | Login", sprintf("{FFFFFF}Welcome back %s,\nplease enter your account password.", Name[playerid]), "Login", "Cancel");
	} else {
	    ShowPlayerDialog(playerid, D_REGISTER, DIALOG_STYLE_INPUT, "SA-MP.org | Register", sprintf("{FFFFFF}Welcome %s,\nwe can't find an account with this name in the database,\nplease enter a password to register a account.", Name[playerid]), "Register", "Cancel");
	}
	return 1;
}

public AccountLogin(playerid)
{
	new Rows;
	cache_get_row_count(Rows);
	if(Rows >= 1) {
	    SendClientMessage(playerid, COLOR_DARKGREEN, "Login Successful");
	    SpawnPlayer(playerid);
	} else {
	    SendClientMessage(playerid, COLOR_RED, "Login unsuccessful, password is wrong!");
	    ShowPlayerDialog(playerid, D_LOGIN, DIALOG_STYLE_PASSWORD, "SA-MP.org | Login", sprintf("{FFFFFF}Welcome back %s,\nplease enter your account password.", Name[playerid]), "Login", "Cancel");
	}
	return 1;
}

public AccountRegister(playerid)
{
	SendClientMessage(playerid, COLOR_DARKGREEN, sprintf("Welcome %s, your registration was successful!", Name[playerid]));
	SpawnPlayer(playerid);
	return 1;
}
