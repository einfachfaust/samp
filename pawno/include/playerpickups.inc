/*
!PP! - Player pickups by iWhite/!LukniS!

Functions:

native CreatePlayerPickup(playerid, modelid, Float:x, Float:y, Float:z, Float:range=1.0);
playerid - playerid to show pickup
modelid - object model id to show as player pickup
x, y, z - coordinates
range - range of pickup, from where pickup can be picked up(default 1.0)
returns pickupid or -1, if pickup creation failed

native DestroyPlayerPickup(playerid, pickupid);
playerid - playerid for whom destroy pickup
pickupid - pickupid to destroy
returns 1 on success, 0 on failure(there is no pickup on that id)

native IsPlayerPickupCreated(playerid, pickupid);
playerid - playerid to check if pickup has been created for him
pickupid - to check if that pickup exists
returns 1 on success, 0 on failure

Callbacks:

public OnPlayerPickUpPlayerPickup(playerid, pickupid)
playerid - playerid, who picked up pickup
pickupid - pickupid, which was picked up
*/


#define MAX_PLAYER_PICKUPS 128 //Set max amount of player pickups for one player

enum ppick
{
   Objectid,
   bool:Moveup,
   #if !defined _inc_streamer
      Float:pickrange,
      Float:ppx,
      Float:ppy,
      Float:ppy
   #else
      Areaid
   #endif
};
new PPickupData[MAX_PLAYERS][MAX_PLAYER_PICKUPS][ppick];
forward OnPlayerPickUpPlayerPickup(playerid, pickupid);

stock CreatePlayerPickup(playerid, modelid, Float:x, Float:y, Float:z, Float:range=1.0)
{
   for(new o; o<MAX_PLAYER_PICKUPS; o++)
   {
      if(IsValidPlayerObject(playerid, PPickupData[playerid][o][Objectid]))
      {
         continue;
      }
      PPickupData[playerid][o][Objectid] = CreatePlayerObject(playerid, modelid, x, y, z, 0.0, 0.0, 0.0);
      #if !defined _inc_streamer
         PPickupData[playerid][o][ppx] = x;
         PPickupData[playerid][o][ppy] = y;
         PPickupData[playerid][o][ppz] = z;
         PPickupData[playerid][o][pickrange] = range;
      #else
         PPickupData[playerid][o][Areaid] = CreateDynamicCircle(x, y, range, -1, -1, playerid);
      #endif
      MovePlayerObject(playerid, PPickupData[playerid][o][Objectid], x, y, z-0.01, 0.01, 0.0, 0.0, 90.0);
      PPickupData[playerid][o][Moveup] = true;
      return o;
   }
   return -1;
}
stock DestroyPlayerPickup(playerid, pickupid)
{
   if(!IsValidPlayerObject(playerid, PPickupData[playerid][pickupid][Objectid]))
   {
      return 0;
   }
   DestroyPlayerObject(playerid, PPickupData[playerid][pickupid][Objectid]);
   #if defined _inc_streamer
      DestroyDynamicArea(PPickupData[playerid][pickupid][Areaid]);
      PPickupData[playerid][pickupid][Areaid]=-1;
   #else
      PPickupData[playerid][pickupid][ppx]=-1.0;
      PPickupData[playerid][pickupid][ppy]=-1.0;
      PPickupData[playerid][pickupid][ppz]=-1.0;
      PPickupData[playerid][pickupid][pickrange]=-1.0;
   #endif
   PPickupData[playerid][pickupid][Objectid]=-1;
   return 1;
}
stock IsPlayerPickupCreated(playerid, pickupid)
{
   return IsValidPlayerObject(playerid, PPickupData[playerid][pickupid][Objectid];
}
public OnPlayerObjectMoved(playerid, objectid)
{
    for(new p; p<MAX_PLAYER_PICKUPS; p++)
    {
          if(objectid == PPickupData[playerid][p][Objectid])
          {
             new Float:x, Float:y, Float:z, Float:rot;
             GetPlayerObjectPos(playerid, PPickupData[playerid][p][Objectid], x, y, z);
             GetPlayerObjectRot(playerid, PPickupData[playerid][p][Objectid], rot, rot, rot);
             if(z >= 360.0)
             {
                z=0.0;
             }
             if(PPickupData[playerid][p][Moveup])
             {
                MovePlayerObject(playerid, PPickupData[playerid][p][Objectid], x, y, z+0.01, 0.01, 0.0, 0.0, rot+90.0);
                PPickupData[playerid][p][Moveup]=false;
             }
             else
             {
                MovePlayerObject(playerid, PPickupData[playerid][p][Objectid], x, y, z-0.01, 0.01, 0.0, 0.0, rot+90.0);
                PPickupData[playerid][p][Moveup]=true;
             }
          }
    }
}
#if defined _ALS_OnPlayerObjectMoved
          #undef OnPlayerObjectMoved
       #else
          #define _ALS_OnPlayerObjectMoved
       #endif
       #define OnPlayerObjectMoved PP_OnPlayerObjectMoved
       #if defined PP_OnPlayerObjectMoved
          forward PP_OnPlayerObjectMoved(playerid,objectid);
#endif
public OnPlayerDisconnect(playerid, reason)
{
    for(new p; p<MAX_PLAYER_PICKUPS; p++)
    {
          if(IsValidPlayerObject(playerid, PPickupData[playerid][p][Objectid]))
          {
             DestroyPlayerPickup(playerid, p);
          }
    }
}
#if defined _ALS_OnPlayerDisconnect
          #undef OnPlayerDisconnect
       #else
          #define _ALS_OnPlayerDisconnect
       #endif
       #define OnPlayerDisconnect PP_OnPlayerDisconnect
       #if defined PP_OnPlayerDisconnect
          forward PP_OnPlayerDisconnect(playerid,reason);
#endif
#if defined _inc_streamer

   public OnPlayerEnterDynamicArea(playerid, areaid)
   {
      for(new p = 0; p < MAX_PLAYER_PICKUPS; p++)
      {
         if(!IsValidPlayerObject(playerid, PPickupData[playerid][p][Objectid]))
         {
            continue;
         }
         if(PPickupData[playerid][p][Areaid] != areaid)
         {
            continue;
         }
         CallLocalFunction("OnPlayerPickUpPlayerPickup", "ii", playerid, p);
         DestroyPlayerPickup(playerid, p);
      }
   }
   #if defined _ALS_OnPlayerEnterDynamicArea
      #undef OnPlayerEnterDynamicArea
   #else
      #define _ALS_OnPlayerEnterDynamicArea
   #endif
   #define OnPlayerEnterDynamicArea PP_OnPlayerEnterDynamicArea
   #if defined PP_OnPlayerEnterDynamicArea
      forward PP_OnPlayerEnterDynamicArea(playerid,areaid);
   #endif
#else
   public OnPlayerUpdate(playerid)
   {
      for(new p = 0; p < MAX_PLAYER_PICKUPS; p++)
      {
         if(!IsValidPlayerObject(playerid, PPickupData[playerid][p][Objectid]))
         {
            continue;
         }
         if(!IsPlayerInRangeOfPoint(playerid, PPickupData[playerid][p][pickrange], PPickupData[playerid][p][ppx], PPickupData[playerid][p][ppy], PPickupData[playerid][p][ppz]))
         {
            continue;
         }
         CallLocalFunction("OnPlayerPickUpPlayerPickup", "ii", playerid, p);
         DestroyPlayerObject(playerid, PPickupData[playerid][p][Objectid]);
      }
   }
   #if defined _ALS_OnPlayerUpdate
      #undef OnPlayerUpdate
   #else
      #define _ALS_OnPlayerUpdate
   #endif
   #define OnPlayerUpdate PP_OnPlayerUpdate
   #if defined PP_OnPlayerUpdate
      forward PP_OnPlayerUpdate(playerid);
   #endif
#endif
