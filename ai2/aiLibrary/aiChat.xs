//==============================================================================
// aiChat.xs
//==============================================================================

//==============================================================================
// RULE introChat
//==============================================================================
rule introChat
   minInterval 5
   active
{
   //Only the captain does this.
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
      return;

   if (cvMasterDifficulty != cDifficultyEasy)
   {
      for (i=1; < cNumberPlayers)
      {
	 if (i == cMyID)
	    continue;
	 if (kbIsPlayerAlly(i) == true)
	    continue;
	 if (kbIsPlayerHuman(i) == true)
	    if( cvOkToChat == true ) aiCommsSendStatement(i, cAICommPromptIntro, -1);
      }
   }

   xsDisableSelf();
}

//==============================================================================
// RULE myAgeTracker
//==============================================================================
rule myAgeTracker
   minInterval 60
   active
{
   static bool bMessage=false;
   static int messageAge=-1;

   //Disable this in deathmatch.
   if (aiGetGameMode() == cGameModeDeathmatch)
   {
      xsDisableSelf();
      return;
   }

   //Only the captain does this.
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
      return;

   //Are we greater age than our most hated enemy?
   int myAge=kbGetAge();
   int hatedPlayerAge=kbGetAgeForPlayer(aiGetMostHatedPlayerID());

   //Reset the message counter if we have changed ages.
   if (bMessage == true)
   {
      if (messageAge == myAge)
	 return;
      bMessage=false;
   }

   //Make a message??
   if ((myAge > hatedPlayerAge) && (bMessage == false))
   {
      bMessage=true;
      messageAge=myAge;
      if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIWinningAgeRace, -1);
   }
   if ((hatedPlayerAge > myAge) && (bMessage == false))
   {
      bMessage=true;
      messageAge=myAge;
      if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAILosingAgeRace, -1);
   }

   //Stop when we reach the finish line.
   if (myAge == cAge4)
      xsDisableSelf();
}

//==============================================================================
// RULE mySettlementTracker
//==============================================================================
rule mySettlementTracker
   minInterval 11
   active
{
   static int tcCountQueryID=-1;
   //Only the captain does this
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
      return;

   //If we don't have a query ID, create it.
   if (tcCountQueryID < 0)
   {
      tcCountQueryID=kbUnitQueryCreate("SettlementCount");
      //If we still don't have one, bail.
      if (tcCountQueryID < 0)
	 return;
   }

   //Else, setup the query data.
   kbUnitQuerySetPlayerID(tcCountQueryID, cMyID);
   kbUnitQuerySetUnitType(tcCountQueryID, cUnitTypeAbstractSettlement);
   kbUnitQuerySetState(tcCountQueryID, cUnitStateAlive);

   //Reset the results.
   kbUnitQueryResetResults(tcCountQueryID);
   //Run the query.  Be dumb and just take the first TC for now.
   int count=kbUnitQueryExecute(tcCountQueryID);

   if ((count < gNumberMySettlements) && (gNumberMySettlements != -1))
   {
      if (count == 0)
	 if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAILostLastSettlement, -1);
      else
	 if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAILostSettlement, -1);
   }

   //Set the number.
   gNumberMySettlements=count;

   if(gNumberMySettlements > gSettlementHighScoreID)	//Update.
   {
	gSettlementHighScoreID = gNumberMySettlements;
   }
}

//==============================================================================
// RULE enemySettlementTracker
//==============================================================================
rule enemySettlementTracker
   minInterval 9
   active
{
  //Only the captain does this.
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
      return;

   if (gTrackingPlayer == -1)
      gTrackingPlayer = aiGetMostHatedPlayerID();

   bool reset=false;
   if (aiGetMostHatedPlayerID() != gTrackingPlayer)
   {
      gTrackingPlayer = aiGetMostHatedPlayerID();
      gNumberTrackedPlayerSettlements = -1;
      reset = true;
   }

   if (gTrackingPlayer == -1)
      return;

   static int tcCountQueryID=-1;
   //If we don't have a query ID, create it.
   if (tcCountQueryID < 0)
   {
      tcCountQueryID=kbUnitQueryCreate("SettlementCount");
      //If we still don't have one, bail.
      if (tcCountQueryID < 0)
	 return;
   }

   //Else, setup the query data.
   kbUnitQuerySetPlayerID(tcCountQueryID, gTrackingPlayer);
   kbUnitQuerySetUnitType(tcCountQueryID, cUnitTypeAbstractSettlement);
   kbUnitQuerySetState(tcCountQueryID, cUnitStateAlive);

   //Reset the results.
   kbUnitQueryResetResults(tcCountQueryID);
   //Run the query.  Be dumb and just take the first TC for now.
   int count=kbUnitQueryExecute(tcCountQueryID);

   //If we are doing a reset, then just get out after storing the count.
   if (reset == true)
   {
      gNumberTrackedPlayerSettlements=count;
      return;
   }

   //If the number of settlements is greater than 1, and we have not sent a message.
   if ((count > 1) && (gNumberTrackedPlayerSettlements == -1))
   {
      if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptEnemyBuildSettlement, -1);
      gNumberTrackedPlayerSettlements=count;
   }

   //If the number of settlements is equal to one and we have sent a message
   //about them growing, then send one about the loss of territory
   if ((count == 1) && (gNumberTrackedPlayerSettlements > 1))
   {
      if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptEnemyLostSettlement, -1);
      gNumberTrackedPlayerSettlements=1;
   }

   //The count is = 0, and we think they have nothing left, and we have already sent a message
   if ((count == 0) && (gNumberTrackedPlayerSettlements != -1))
   { 
      if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptEnemyLostSettlement, -1);
      gNumberTrackedPlayerSettlements=-1;
   }
}

//==============================================================================
// RULE enemyWallTracker
//==============================================================================
rule enemyWallTracker
   minInterval 61
   active
{
   static int wallCountQueryID=-1;
   //Only the captain does this.
   if (aiGetCaptainPlayerID(cMyID) != cMyID)
      return;

   //If we don't have a query ID, create it.
   if (wallCountQueryID < 0)
   {
      wallCountQueryID=kbUnitQueryCreate("WallCount");
      //If we still don't have one, bail.
      if (wallCountQueryID < 0)
	 return;
   }

   //Else, setup the query data.
   kbUnitQuerySetPlayerID(wallCountQueryID, aiGetMostHatedPlayerID());
   kbUnitQuerySetUnitType(wallCountQueryID, cUnitTypeAbstractWall);
   kbUnitQuerySetState(wallCountQueryID, cUnitStateAlive);

   //Reset the results.
   kbUnitQueryResetResults(wallCountQueryID);
   //Run the query. 
   int count=kbUnitQueryExecute(wallCountQueryID);

   //Do we have enough knowledge of walls to send a message?
   if (count > 10)
   {
      if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptPlayerBuildingWalls, -1);
      //Kill this rule.
      xsDisableSelf();
   }
}

//==============================================================================
// attackChatCallback
//==============================================================================
void attackChatCallback(int parm1=-1)
{
    if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIAttack, -1);
    printEcho("Launching an attack.");
}

//==============================================================================
// attackUnitMessage
//==============================================================================
void attackUnitMessage(int targetID=-1) 
{
   if (targetID >= 0)
   {
      for (i=1; < cNumberPlayers)
      {
	 vector position = kbUnitGetPosition(targetID);
	 if (i == cMyID)
	    continue;
	 if (kbIsPlayerAlly(i) == true)
	    continue;
	 if( cvOkToChat == true ) aiCommsSendStatementWithVector(i, cAICommPromptAIAttackHere, -1, position);
      }
   }
}

//==============================================================================
// RULE baseAttackTracker
//==============================================================================
rule baseAttackTracker
   minInterval 23
   active
{
   static bool messageSent=false;
   //Set our min interval back to 23 if it has been changed.
   if (messageSent == true)
   {
      xsSetRuleMinIntervalSelf(23);
      messageSent=false;
   }

   //Get our main base.
   int mainBaseID=kbBaseGetMainID(cMyID);
   if (mainBaseID < 0)
      return;

   //Get the time under attack.
   int secondsUnderAttack=kbBaseGetTimeUnderAttack(cMyID, mainBaseID);
   if (secondsUnderAttack < 30)
	 return;

   vector location=kbBaseGetLastKnownDamageLocation(cMyID, kbBaseGetMainID(cMyID));
   for (i=1; < cNumberPlayers)
   {
      if (i == cMyID)
	 continue;
      if(kbIsPlayerAlly(i) == true)
	 if( cvOkToChat == true ) aiCommsSendStatementWithVector(i, cAICommPromptHelpHere, -1, location);
   } 
   
   //Try to use a god power to help us.
   findTownDefenseGP(kbBaseGetMainID(cMyID));

   //Keep the books
   messageSent=true;
   xsSetRuleMinIntervalSelf(600);
}

//==============================================================================
// resignMessage
//==============================================================================
void resignMessage(int type=-1)
{
   if(type < 0)		//Update?
   {
		gResignType = type;
   }

   if(cvOkToChat == true)
   {
	if(gResignType == cResignSettlements)
	{
		aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIResignSettlements, -1);
	}
	if(gResignType == cResignGatherers)
	{
		aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIResignGatherers, -1);
	}
	if(gResignType == cResignTeammates || gResignType == cResignMilitaryPop)
	{
		aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIResignActiveEnemies, -1);
	}
   }
}

//==============================================================================
// build handler
//==============================================================================
void buildHandler(int protoID=-1) 
{
   if (protoID == cUnitTypeSettlement)
   {
      for (i=1; < cNumberPlayers)
      {
	 vector position = kbUnitGetPosition(protoID);
	 if (i == cMyID)
	    continue;
	 if (kbIsPlayerAlly(i) == true)
	    continue;
	 if( cvOkToChat == true ) aiCommsSendStatementWithVector(i, cAICommPromptAIBuildSettlement, -1, position);
      }
   }
}

//==============================================================================
// god power handler
//==============================================================================
void gpHandler(int powerProtoID=-1)
{ 
   if (powerProtoID == -1)
      return;
   if (powerProtoID == cPowerSpy)
      return;

	// If the power is TitanGate, then we need to launch the repair plan to build it..
   if (powerProtoID == cPowerTitanGate)
   {
      printEcho("======< Titan Gate placed!!!>=======");
      // Don't look for it now, just set up the rule that looks for it
      // and then launches a repair plan to build it. 
      xsEnableRule("repairTitanGate");
	   return;
   }


   //Most hated player chats.
   if ((powerProtoID == cPowerPlagueofSerpents)
      ||(powerProtoID == cPowerEarthquake)
      ||(powerProtoID == cPowerCurse)
      ||(powerProtoID == cPowerFlamingWeapons)
      ||(powerProtoID == cPowerForestFire)
      ||(powerProtoID == cPowerFrost)
      ||(powerProtoID == cPowerLightningStorm)
      ||(powerProtoID == cPowerLocustSwarm)
      ||(powerProtoID == cPowerMeteor)
      ||(powerProtoID == cPowerAncestors)
      ||(powerProtoID == cPowerFimbulwinter)
      ||(powerProtoID == cPowerTornado)
      ||(powerProtoID == cPowerBolt))
   {
      if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptOffensiveGodPower, -1);
      return;
   }
   
   //Any player chats.
   int type=cAICommPromptGenericGodPower;
   if ((powerProtoID == cPowerProsperity)
      ||(powerProtoID == cPowerPlenty)
      ||(powerProtoID == cPowerLure)
      ||(powerProtoID == cPowerDwarvenMine)
      ||(powerProtoID == cPowerGreatHunt)
      ||(powerProtoID == cPowerRain))
   {
      type=cAICommPromptEconomicGodPower;
   }

   //Tell all the enemy players
   for (i=1; < cNumberPlayers)
   {
      if (i == cMyID)
	 continue;
      if (kbIsPlayerAlly(i) == true)
	 continue;
      if( cvOkToChat == true ) aiCommsSendStatement(i, type, -1);
   }
}

//==============================================================================
// wonder death handler
//==============================================================================
void wonderDeathHandler(int playerID = -1)
{
   if (playerID == cMyID)
   {
      if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIWonderDestroyed, -1);
      return;
   }
   if (playerID == aiGetMostHatedPlayerID())
      if( cvOkToChat == true ) aiCommsSendStatement(playerID, cAICommPromptPlayerWonderDestroyed, -1);
}

//==============================================================================
// retreat handler
//==============================================================================
void retreatHandler(int planID = -1)
{
   if( cvOkToChat == true ) aiCommsSendStatement(aiGetMostHatedPlayerID(), cAICommPromptAIRetreat, -1);
}

//==============================================================================
// relic handler
//==============================================================================
void relicHandler(int relicID = -1)
{
   if (aiRandInt(3) != 0)
      return;

   for (i=1; < cNumberPlayers)
   {
      if (i == cMyID)
	 continue;

      //Only a 33% chance for either of these chats
      if (kbIsPlayerAlly(i) == true)
      {
	 if (relicID != -1)
	 {
	    vector position = kbUnitGetPosition(relicID);
	    if( cvOkToChat == true ) aiCommsSendStatementWithVector(i, cAICommPromptTakingAllyRelic, -1, position);
	 }
	 else 
	    if( cvOkToChat == true ) aiCommsSendStatement(i, cAICommPromptTakingAllyRelic, -1);
      }
      else 
	 if( cvOkToChat == true ) aiCommsSendStatement(i, cAICommPromptTakingEnemyRelic, -1);
   }
}
