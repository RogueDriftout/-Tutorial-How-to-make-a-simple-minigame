///By Rogue .
#define FILTERSCRIT
#include <a_samp>

new bool:dmstarted,bool:pfrozen[MAX_PLAYERS],bool:pleasewait,bool:indm[MAX_PLAYERS];//Event variables Indicated By Names
new playernumberdm,playerstimerdm[MAX_PLAYERS];//Event Variables Indicated by names
new Float:X,Float:Y,Float:Z;//Event Entering Place
new Float:x,Float:y,Float:z;//Event Place Inside for each player (make sure each is different.)

#define EventCash 2500 // The cash fee to enter.
#define DmWorld 6487 // The virtual world to separate the players from other players not playing the event.
#define EventRange 5.0 // the range where the player enters from
#define MAX_EVENT_PLAYERS 6 //the max amount of players in the event depends on the position cases at PlayerPos
#define Delay_Time 50*1000 // 50 seconds to give players a chance to join
public OnPlayerCommandText(playerid, cmdtext[])
{
    if (strcmp("/dmevent", cmdtext, true, 10) == 0)
    {
        if(GetPlayerState(playerid) == PLAYER_STATE_ONFOOT)//Related to event
        {
            if(dmstarted) return SendClientMessage(playerid, -1,"DM IS ALREADY IN PROCESS");//if its already in progress
            if(GetPlayerWantedLevel(playerid) >=1) return SendClientMessage(playerid,-1,"You can't join events if you're wanted!");//(Optioinal)
            if(!IsPlayerInRangeOfPoint(playerid, EventRange, X,Y,Z)) return SendClientMessage(playerid,-1,"You need to be in the event range.");//(Optional)
            if(GetPlayerMoney(playerid) < EventCash) return SendClientMessage(playerid,-1,"You don't have enough cash (EventCash$)");//Price Optional
            if(pleasewait)  return SendClientMessage(playerid,-1,"You need to wait at least 2 seconds between each player entering!");// Precaution
            if(playernumberdm ==MAX_EVENT_PLAYERS) return SendClientMessage(playerid,-1,"You can't join dm its full!");//Max players in depending on the positions you put.
            if(playernumberdm ==0)//setting the starter timer only once
            {
                SetTimerEx("DelayDmEvent", 50*1000, false, "d", playerid);//Delay timer to give players a chance to join.
                SendClientMessageToAll(-1,"DEATH MATCHING EVENT(DM) IS STARTING IN 50 SECONDS!");//Notify players.
                }
            playerstimerdm[playerid] = SetTimerEx("DmCheck", 1000, true, "i", playerid);//in event check explained in its function
            TogglePlayerControllable(playerid,0), ResetPlayerWeapons(playerid); //Optional related to the event
            indm[playerid] = true, pleasewait = true; //a check that we'll need one for indm to see if a player is in the DM event and the other is to keep 2 players from entering at the same second.
            SetTimer("removepleasewait", 2000, false), playernumberdm++;//increasing the player's count and removing the wait check.
            SetPlayerVirtualWorld(playerid,DmWorld);//Related to Event
            GivePlayerWeapon(playerid, 27,500), GivePlayerWeapon(playerid, 31,500), GivePlayerWeapon(playerid, 28,500);//Related To event
            GivePlayerWeapon(playerid, 34,500), GivePlayerWeapon(playerid, 24,500), GivePlayerWeapon(playerid, 8,500);//Related To event
            SetPlayerHealth(playerid,100), SetPlayerArmour(playerid,100);//Related To event
            PlayerPos(playerid), GivePlayerMoney(playerid, -2500);//Related To event
            }
        else
        {
            SendClientMessage(playerid,-1,"YOU NEED TO BE ON FOOT TO ENTER THE DM EVENT");//Related To event
            }
        return 1;
        }
    return 0;
}

forward PlayerPos(playerid);
public PlayerPos(playerid)
{
    switch(playernumberdm)//Setting player's position depending on the count number this is better than rand cuz rand might return one pos 2 times = players stuck.
    {
    case 1:
    {
        SetPlayerPos(playerid, x,y,z);
        }
    case 2:
    {
        SetPlayerPos(playerid,x,y,z);
        }
    case 3:
    {
        SetPlayerPos(playerid, x,y,z);
        }
    case 4:
    {
        SetPlayerPos(playerid, x,y,z);
        }
    case 5:
    {
        SetPlayerPos(playerid,x,y,z);
        }
    case 6:
    {
        SetPlayerPos(playerid, x,y,z);
        }
    }
    return 1;
}

forward DelayDmEvent(playerid);
public DelayDmEvent(playerid)//after 50 seconds had passed
{
    if(playernumberdm <=1)//if there's only one player or less inside end it and kill all variables that were set.
    {
        SendClientMessage(playerid,-1,"DM HAS ENDED DUE TO NOT ENOUGH PLAYERS ENTERING");
        TogglePlayerControllable(playerid,1);
        GivePlayerMoney(playerid,EventCash);
        dmstarted =false;
        pfrozen[playerid] =false;
        playernumberdm =0;
        indm[playerid] =false;
        KillTimer(playerstimerdm[playerid]);
        SetPlayerVirtualWorld(playerid,0);
        SetPlayerPos(playerid, X,Y,Z);
        }
    else//if there is more than 1 player start it.
    {
        SendClientMessageToAll(-1,"DM HAS STARTED!");
        dmstarted = true;
        TogglePlayerControllable(playerid,1);
        }
    return 1;
}

forward DmCheck(playerid,vehicleid);
public DmCheck(playerid,vehicleid)//The event checker to see who won this is set for each player entering separately.
{
    new names[26],strings[126];
    if(dmstarted && !pfrozen[playerid])//unfreezing the player after the event starts.
    {
        pfrozen[playerid] =true;
        TogglePlayerControllable(playerid,1);
        }
    if(playernumberdm==1 && dmstarted)//if there's only one player in there (the player with this timer) and it has started then announce the winner and end it.
    {//then kill all variables that were set.
        GetPlayerName(playerid,names,sizeof(names));
        format(strings,sizeof(strings),".:%s HAS WON THE DM AND EARNED 5000$!:.",names);
        SendClientMessageToAll(-1,strings);
        TogglePlayerControllable(playerid,1), ResetPlayerWeapons(playerid), SetPlayerWantedLevel(playerid,0);
        pfrozen[playerid] =false, indm[playerid] =false, dmstarted = false;
        GivePlayerMoney(playerid, EventCash*2);
        SetPlayerVirtualWorld(playerid,0), SetPlayerPos(playerid,X,Y,Z);
        KillTimer(playerstimerdm[playerid]), playernumberdm =0;
        }
    return 1;
}

public OnPlayerDeath(playerid,killerid,reason)//If a player dies in the event
{
    if(indm[playerid] && !dmstarted && playernumberdm ==1)//If he's in the event and it hasn't started and there's only one player in there (him) then end the event.
    {
        SendClientMessage(playerid,-1,"DM HAS ENDED DUE TO NO PLAYERS ENTERING");
        TogglePlayerControllable(playerid,1), ResetPlayerWeapons(playerid);
        pfrozen[playerid] =false, dmstarted =false, indm[playerid] =false;
        GivePlayerMoney(playerid,2500), playernumberdm =0;
        KillTimer(playerstimerdm[playerid]), SetPlayerVirtualWorld(playerid,0);
        }
    else if(indm[playerid])//if he's just in the event and someone killed him or he just died.
    {
        playernumberdm--;//decrease the allocated number of players in the event and kill his variables.
        indm[playerid] =false, pfrozen[playerid] =false;
        ResetPlayerWeapons(playerid), SetPlayerVirtualWorld(playerid,0);
        SetPlayerWantedLevel(playerid,0), KillTimer(playerstimerdm[playerid]);
        }
    return 1;
}

public OnPlayerDisconnect(playerid,reason)// if a player disconnects in the event.
{
    if(indm[playerid])//if he's in the event kill his variables and decrease the allocated number of players inside.
    {
        indm[playerid] =false, pfrozen[playerid] =false;
        SetPlayerWantedLevel(playerid,0), ResetPlayerWeapons(playerid);
        playernumberdm--, KillTimer(playerstimerdm[playerid]);
        }
    return 1;
}
