//==============================================================================
// RULE makeWonder
//==============================================================================
rule makeWonder
minInterval 6
inactive       //  Activated on reaching age 4 if game isn't conquest
{

   int   targetArea = -1;
   vector target = cInvalidVector;     // Will be used to center the building placement behind the town.
   target = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
   vector offset = cInvalidVector;
   offset = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));
   offset = offset * 30.0;
   target = target + offset;
   targetArea = kbAreaGetIDByPosition(target);
   printEcho("**** Starting wonder progression for vector "+target+" in area "+targetArea);

   int planID=aiPlanCreate("Wonder Build", cPlanBuild);
   if (planID < 0)
      return;

   printEcho("Wonder build plan ID is "+planID);
   aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeWonder);

   aiPlanSetVariableInt(planID, cBuildPlanAreaID, 0, targetArea);
	aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 0, 2);

   aiPlanSetDesiredPriority(planID, 99);

   //Mil vs. Econ.
   aiPlanSetMilitary(planID, false);
   aiPlanSetEconomy(planID, true);

   //Escrow.
   aiPlanSetEscrowID(planID, cEconomyEscrowID);

   int builderUnit = cUnitTypeAbstractVillager;
   if (cMyCulture == cCultureNorse)
      builderUnit = cUnitTypeAbstractInfantry;

   printEcho("Builder unit is "+builderUnit);

   int builderCount = -1;
   builderCount = kbUnitCount(cMyID, builderUnit, cUnitStateAlive);

   //Builders.
	aiPlanAddUnitType(planID, builderUnit,
      (2*builderCount)/3, builderCount, (3*builderCount)/2);   // Two thirds, all, or 150%...in case new builders are created.
   //Base ID.
   aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));

   //Go.
   aiPlanSetActive(planID);

   printEcho("Activating maintainWonder rule.");
   xsEnableRule("maintainWonder");     // Looks for wonder placement, starts defensive reaction.
   xsDisableSelf();
}

//==============================================================================
// RULE watchForFirstWonderStart
//==============================================================================
// Look for any wonder being built.  If found, activate the high-speed rule that
// watches for completion
rule watchForFirstWonderStart
active
minInterval 90    // Hopefully nobody will build one faster than this
{
   static int wonderQueryStart = -1;
   if (wonderQueryStart < 0)
   {
      wonderQueryStart = kbUnitQueryCreate("Start wonder query");
      if ( wonderQueryStart == -1)
      {
	 xsDisableSelf();
	 return;
      }
      kbUnitQuerySetPlayerRelation(wonderQueryStart, cPlayerRelationAny);
      kbUnitQuerySetUnitType(wonderQueryStart, cUnitTypeWonder);
      kbUnitQuerySetState(wonderQueryStart, cUnitStateAliveOrBuilding);     // Any wonder under construction
   }

   kbUnitQueryResetResults(wonderQueryStart);
   if (kbUnitQueryExecute(wonderQueryStart) > 0)
   {
      printEcho("**** Someone is building a wonder!");
      xsDisableSelf();
      xsEnableRule("watchForFirstWonderComplete");
   }
}

//==============================================================================
// RULE watchForFirstWonderComplete	(NEW)
//==============================================================================
// See who makes the first wonder, note its ID, make a defend plan to kill it,
// kill defend plan when it's gone.
rule watchForFirstWonderComplete
inactive
minInterval 1    // Timing is crucial
{
   static int wonderCompleteQuery = -1;
   if (wonderCompleteQuery < 0)
   {
      wonderCompleteQuery = kbUnitQueryCreate("Wonder complete query");
      kbUnitQuerySetPlayerRelation(wonderCompleteQuery, cPlayerRelationAny);
      kbUnitQuerySetUnitType(wonderCompleteQuery, cUnitTypeWonder);
      kbUnitQuerySetState(wonderCompleteQuery, cUnitStateAlive);     // Only completed wonders count
   }

   if (gFirstWonderID >= 0)	//A wonder was built... if it's down, kill the uber-plan
   {
      if (kbUnitGetCurrentHitpoints(gFirstWonderID) <= 0)
      {
	printEcho("**** Wonder "+gFirstWonderID+" has been destroyed!");
	aiPlanDestroy(gOtherWonderDefendPlan);
	gWonderAttackPlan = false;
	/*wonderCompleteQuery = -1;*/ gFirstWonderID = -1;
	xsEnableRule("watchForFirstWonderStart");
	xsDisableSelf();
      }else{
	 // Make sure the enemy wonder 'defend' plan stays open
	 aiPlanSetNoMoreUnits(gOtherWonderDefendPlan, false);
	 aiSetMostHatedPlayerID(kbUnitGetOwner(gFirstWonderID));
      }
	 return;		//Check again later...
   }

   // No wonder has been built yet, look for them!
   kbUnitQueryResetResults(wonderCompleteQuery);
   if (kbUnitQueryExecute(wonderCompleteQuery) <= 0)
   {
	return;			//Nothing found.
   }

   //Assume the first item in this list is the first wonder done.
   gFirstWonderID = kbUnitQueryGetResult(wonderCompleteQuery, 0);
   if (gFirstWonderID < 0)
   {
	return;
   }
   vector wonderLocation = kbUnitGetPosition(gFirstWonderID);
   int wonderOwner = kbUnitGetOwner(gFirstWonderID);
   if (cMyID == wonderOwner)	// I win, quit.
   {
	printEcho("**** I made the first wonder!");
	xsDisableSelf();
	return;
   }
   else if (kbIsPlayerAlly(wonderOwner))
   {
	printEcho("**** An ally made the first wonder!");
	// Create highest-priority defend plan to go protect it.

	if ( kbAreaGroupGetIDByPosition(wonderLocation) == kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) )
	{
	    // It's on my continent, go help!
	    gOtherWonderDefendPlan=aiPlanCreate("Ally Wonder Defend Plan "+cMyID, cPlanDefend);
	    if (gOtherWonderDefendPlan >= 0)
	    {
		aiPlanAddUnitType(gOtherWonderDefendPlan, cUnitTypeMilitary, 200, 200, 200);	// All mil units
		aiPlanSetDesiredPriority(gOtherWonderDefendPlan, 98);		// Uber-plan, except for norse wonder-build plan
		aiPlanSetVariableVector(gOtherWonderDefendPlan, cDefendPlanDefendPoint, 0, wonderLocation);
		aiPlanSetVariableFloat(gOtherWonderDefendPlan, cDefendPlanEngageRange, 0, 50.0);
		aiPlanSetVariableBool(gOtherWonderDefendPlan, cDefendPlanPatrol, 0, false);

		aiPlanSetVariableFloat(gOtherWonderDefendPlan, cDefendPlanGatherDistance, 0, 40.0);
		aiPlanSetInitialPosition(gOtherWonderDefendPlan, wonderLocation);
		aiPlanSetUnitStance(gOtherWonderDefendPlan, cUnitStanceDefensive);

		aiPlanSetVariableInt(gOtherWonderDefendPlan, cDefendPlanRefreshFrequency, 0, 5);
		aiPlanSetNumberVariableValues(gOtherWonderDefendPlan, cDefendPlanAttackTypeID, 2, true);
		aiPlanSetVariableInt(gOtherWonderDefendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
		aiPlanSetVariableInt(gOtherWonderDefendPlan, cDefendPlanAttackTypeID, 1, cUnitTypeBuilding);

		aiPlanSetActive(gOtherWonderDefendPlan);
		printEcho("Creating enemy wonder defend plan");
	    }
	}
   }
   else if (kbIsPlayerEnemy(wonderOwner))
   {
	printEcho("**** The enemy made the first wonder!");
	// Create highest-priority attack plan to go kill it.

	aiSetMostHatedPlayerID(wonderOwner);	//Everyone hates wonder owners!

	gWonderAttackPlan = true;	//Attack even if we'll have a wonder too!

	//Making an attack plan instead, they do a better job of transporting and ignoring some targets en route.
	gOtherWonderDefendPlan=aiPlanCreate("Enemy wonder attack plan", cPlanAttack);
	if (gOtherWonderDefendPlan < 0)
	{
	    return;
	}

	// Specify other continent so that armies will transport
	aiPlanSetNumberVariableValues( gOtherWonderDefendPlan, cAttackPlanTargetAreaGroups,  1, true);
	printEcho("Area group for wonder is "+kbAreaGroupGetIDByPosition(kbUnitGetPosition(gFirstWonderID)));
	aiPlanSetVariableInt(gOtherWonderDefendPlan, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(kbUnitGetPosition(gFirstWonderID)));

	aiPlanSetVariableVector(gOtherWonderDefendPlan, cAttackPlanGatherPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	aiPlanSetVariableFloat(gOtherWonderDefendPlan, cAttackPlanGatherDistance, 0, 300.0);   // Insta-gather, just GO!

	aiPlanAddUnitType(gOtherWonderDefendPlan, cUnitTypeLogicalTypeLandMilitary, 0, 200, 200);

	aiPlanSetInitialPosition(gOtherWonderDefendPlan, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	aiPlanSetRequiresAllNeedUnits(gOtherWonderDefendPlan, false);
	aiPlanSetDesiredPriority(gOtherWonderDefendPlan, 100);
	aiPlanSetVariableBool(gOtherWonderDefendPlan, cAttackPlanMoveAttack, 0, false);
	aiPlanSetVariableInt(gOtherWonderDefendPlan, cAttackPlanSpecificTargetID, 0, gFirstWonderID);

	aiPlanSetActive(gOtherWonderDefendPlan);
   }
}

//==============================================================================
// RULE maintainWonder
//==============================================================================
rule maintainWonder  // See if my wonder has been placed.  If so, go build it.
inactive
minInterval 21
{
   if ( kbUnitCount(cMyID, cUnitTypeWonder, cUnitStateAliveOrBuilding) < 1 )
      return;

   if (gWonderAttackPlan) //Don't defend my wonder if the enemy was faster!!!
      return;

   printEcho("**** A wonder is being built.  Activating wonderDefend plan.");
   xsEnableRule("watchWonderLost");    // Kill the defend plan if the wonder is destroyed.

   int wonderID = findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeWonder);
   vector wonderLocation = kbUnitGetPosition(wonderID);
   printEcho("Wonder is at "+wonderLocation);

   // Make the defend plan
   gWonderDefendPlan = aiPlanCreate("Wonder Defend Plan "+cMyID, cPlanDefend);
   if (gWonderDefendPlan >= 0)
   {
      aiPlanAddUnitType(gWonderDefendPlan, cUnitTypeMilitary, gTargetMilitarySize*0.6, gTargetMilitarySize*0.6, gTargetMilitarySize*0.6);    // Almost all mil units
      aiPlanSetDesiredPriority(gWonderDefendPlan, 97);		       // Uber-plan, except for enemy-wonder plan and wonder-build plan
      aiPlanSetVariableVector(gWonderDefendPlan, cDefendPlanDefendPoint, 0, wonderLocation);
      aiPlanSetVariableFloat(gWonderDefendPlan, cDefendPlanEngageRange, 0, 50.0);
      aiPlanSetVariableBool(gWonderDefendPlan, cDefendPlanPatrol, 0, false);

      aiPlanSetVariableFloat(gWonderDefendPlan, cDefendPlanGatherDistance, 0, 40.0);
      aiPlanSetInitialPosition(gWonderDefendPlan, wonderLocation);
      aiPlanSetUnitStance(gWonderDefendPlan, cUnitStanceDefensive);

      aiPlanSetVariableInt(gWonderDefendPlan, cDefendPlanRefreshFrequency, 0, 5);
      aiPlanSetNumberVariableValues(gWonderDefendPlan, cDefendPlanAttackTypeID, 2, true);
      aiPlanSetVariableInt(gWonderDefendPlan, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
      aiPlanSetVariableInt(gWonderDefendPlan, cDefendPlanAttackTypeID, 1, cUnitTypeBuilding);

      aiPlanSetActive(gWonderDefendPlan);
      printEcho("Creating wonder defend plan");
   }
   xsDisableSelf();
}

//==============================================================================
// RULE watchWonderLost    
//==============================================================================
rule watchWonderLost    // Kill the uber-defend plan if wonder falls
inactive
minInterval 8
{
   if ( kbUnitCount(cMyID, cUnitTypeWonder, cUnitStateAliveOrBuilding) > 0 )
      return;

   aiPlanDestroy(gWonderDefendPlan);
   printEcho("My wonder is gone.  Sigh.  Maybe I'll make another one.  Or not.");
   xsEnableRule("makeWonder");      // Try again if we get a chance
   xsDisableSelf();
}
