//==============================================================================
// AoMXaiMil.xs
//==============================================================================
/*
	Index:
	----------------------------
	getPlanPopSlots
	getEstimatedMilPop
	createSimpleAttackGoal
	createSimpleTrainPlan
	createBaseGoal
	createCallbackGoal
	createBuildBuildingGoal
	createBuildSettlementGoal
	createTransportPlan
	setMilitaryGatherPointAllBases
	pauseBaseDefendPlan
	defendPlanRule
	reactivateDefendPlan
	activateObeliskClearingPlan
*/
//==============================================================================
// getPlanPopSlots()  Returns the total pop slots taken by units in this plan
//==============================================================================
int getPlanPopSlots(int planID=-1)
{
   //And here's the proof that it can be done...
   int unitCount = aiPlanGetNumberUnits(planID, cUnitTypeUnit);

   int popSlots = 0;
   for (i=0; < unitCount)
   {
      int unitID = aiPlanGetUnitByIndex(planID, i);
	popSlots = popSlots + kbProtoUnitGetPopulationCount(kbUnitGetProtoUnitID(unitID));
   }
   return(popSlots);
}


//==============================================================================
// getEstimatedMilPop
//==============================================================================
int getEstimatedMilPop(int pID=cMyID)
{
   int milCount = kbUnitCount(pID, cUnitTypeMilitary, cUnitStateAlive);

   int cavCount = kbUnitCount(pID, cUnitTypeAbstractCavalry, cUnitStateAlive);
   int siegeCount = kbUnitCount(pID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
   int mythCount = kbUnitCount(pID, cUnitTypeMythUnit, cUnitStateAlive);
   int titanCount = kbUnitCount(pID, cUnitTypeAbstractTitan, cUnitStateAlive);

   return(2*milCount + cavCount + 2*siegeCount + 2*mythCount + 18*titanCount);
}

//==============================================================================
// createSimpleAttackGoal
//==============================================================================
int createSimpleAttackGoal(string name="BUG", int attackPlayerID=-1,
   int unitPickerID=-1, int repeat=-1, int minAge=-1, int maxAge=-1,
   int baseID=-1, bool allowRetreat=false)
{
   printEcho("CreateSimpleAttackGoal:  Name="+name+", AttackPlayerID="+attackPlayerID+".");
   printEcho("  UnitPickerID="+unitPickerID+", Repeat="+repeat+", baseID="+baseID+".");
   printEcho("  MinAge="+minAge+", maxAge="+maxAge+", allowRetreat="+allowRetreat+".");

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
	  return(-1);

   //Priority.
   aiPlanSetDesiredPriority(goalID, 60);	//was 90. (More room for other plans)
   //Attack player ID.
   if (attackPlayerID >= 0)
	  aiPlanSetVariableInt(goalID, cGoalPlanAttackPlayerID, 0, attackPlayerID);
   else
	  aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
   //Base.
   if (baseID >= 0)
	  aiPlanSetBaseID(goalID, baseID);
   else
	  aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateBase, 0, true);
   //Attack.
   aiPlanSetAttack(goalID, true);
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeAttack);
   //Military.
   aiPlanSetMilitary(goalID, true);
   aiPlanSetEscrowID(goalID, cMilitaryEscrowID);
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);
   //Unit Picker.
   aiPlanSetVariableInt(goalID, cGoalPlanUnitPickerID, 0, unitPickerID);
   //Retreat.
   aiPlanSetVariableBool(goalID, cGoalPlanAllowRetreat, 0, allowRetreat);
   // Upgrade Building prefs.
   if(gNewCivMod==false){
   switch(cMyCulture)
   {
      case cCultureGreek:
      {
	aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 8, true);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeGranary);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeStorehouse);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeSettlementLevel1);
	if(cMyCiv == cCivZeus) {
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeBarracks);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 4, cUnitTypeStable);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 5, cUnitTypeArcheryRange);
	}else if(cMyCiv == cCivPoseidon) {
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeStable);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 4, cUnitTypeArcheryRange);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 5, cUnitTypeBarracks);
	}else if(cMyCiv == cCivHades) {
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeArcheryRange);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 4, cUnitTypeBarracks);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 5, cUnitTypeStable);
	}
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 6, cUnitTypeArmory);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 7, cUnitTypeTemple);
      }
      case cCultureEgyptian:
      {
	aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 8, true);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeGranary);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeMiningCamp);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeLumberCamp);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeSettlementLevel1);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 4, cUnitTypeMigdolStronghold);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 5, cUnitTypeBarracks);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 6, cUnitTypeArmory);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 7, cUnitTypeTemple);
      }
      case cCultureNorse:
      {
	aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 5, true);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeOxCart);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeSettlementLevel1);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeLonghouse);
	if(cMyCiv == cCivThor) {
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeDwarfFoundry);
	}else{
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeArmory);
	}
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 4, cUnitTypeTemple);
      }
      case cCultureAtlantean:
      {
	aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 6, true);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeGuild);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeSettlementLevel1);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeCounterBuilding);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeBarracksAtlantean);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 4, cUnitTypeArmory);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 5, cUnitTypeTemple);
      }
      case cCultureChinese:
      {
	aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 6, true);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeStoragePit);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeSettlementLevel1);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeBarracksChinese);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeStableChinese);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 4, cUnitTypeArmory);
	aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 5, cUnitTypeTemple);
      }
   }
   }else{
		setModUpgradePrefs(goalID);
   }
   //Handle maps where the enemy player is usually on a diff island.
   if (gTransportMap == true)	// removed map list, added transport flag check
   {
	  aiPlanSetVariableBool(goalID, cGoalPlanSetAreaGroups, 0, true);
   }
   //Always choose the best route pattern.
   aiPlanSetVariableInt(goalID, cGoalPlanAttackRoutePatternType, 0, cAttackPlanAttackRoutePatternBest);
   // Handle OkToAttack control variable
   if (cvOkToAttack == false)   
   {
	  printEcho("CreateSimpleAttackPlan:  Setting attack "+goalID+" to idle.");
	  aiPlanSetVariableBool(goalID, cGoalPlanIdleAttack, 0, true);   // Prevent attacks
   }
   //Done.
   return(goalID);
}

//==============================================================================
// createSimpleTrainPlan
//==============================================================================
int createSimpleTrainPlan(int puid = -1, int number = 1, int escrowID = -1, int baseID = -1, int durationMS = -1)
{
	string planName="SimpleTrain"+kbGetProtoUnitName(puid);
	int planID=aiPlanCreate(planName, cPlanTrain);
	if (planID < 0)
	return(-1);

	aiPlanSetEscrowID(planID, escrowID);
	aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
	aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, number);
	if (baseID >= 0)
	{
		aiPlanSetBaseID(planID, baseID);
		aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, baseID));
	}
	if (durationMS >= 0)	//Time in milliseconds
	{
		aiPlanAddUserVariableInt(planID, 0, "SelfDestruct Timer", 2);
		aiPlanSetUserVariableInt(planID, 0, 0, 150);
		aiPlanSetUserVariableInt(planID, 0, 1, xsGetTime()+durationMS);
	}
	aiPlanSetActive(planID);
	return(planID);
}

//==============================================================================
// createBaseGoal
//==============================================================================
int createBaseGoal(string name="BUG", int goalType=-1, int attackPlayerID=-1,
   int repeat=-1, int minAge=-1, int maxAge=-1, int parentBaseID=-1)
{
   printEcho("CreateBaseGoal:  Name="+name+", AttackPlayerID="+attackPlayerID+".");
   printEcho("  GoalType="+goalType+", Repeat="+repeat+", parentBaseID="+parentBaseID+".");
   printEcho("  MinAge="+minAge+", maxAge="+maxAge+".");

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
	  return(-1);

   //Priority.
   aiPlanSetDesiredPriority(goalID, 90);
   //"Parent" Base.
   aiPlanSetBaseID(goalID, parentBaseID);
   //Base Type.
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, goalType);
   if (goalType == cGoalPlanGoalTypeForwardBase)
   {
	  //Attack player ID.
	  if (attackPlayerID >= 0)
		 aiPlanSetVariableInt(goalID, cGoalPlanAttackPlayerID, 0, attackPlayerID);
	  else
		 aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateAttackPlayerID, 0, true);
	  //Military.
	  aiPlanSetMilitary(goalID, true);
	  aiPlanSetEscrowID(goalID, cMilitaryEscrowID);
	  //Active health.
	  aiPlanSetVariableInt(goalID, cGoalPlanActiveHealthTypeID, 0, cUnitTypeBuilding);
	  aiPlanSetVariableFloat(goalID, cGoalPlanActiveHealth, 0, 0.25);
   }
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

   //Done.
   return(goalID);
}

//==============================================================================
// createCallbackGoal
//==============================================================================
int createCallbackGoal(string name="BUG", string callbackName="BUG", int repeat=-1,
   int minAge=-1, int maxAge=-1, bool autoUpdate=false)
{
   printEcho("CreateCallbackGoal:  Name="+name+", CallbackName="+callbackName+".");
   printEcho("  Repeat="+repeat+", MinAge="+minAge+", maxAge="+maxAge+".");

   //Get the callbackFID.
   int callbackFID=xsGetFunctionID(callbackName);
   if (callbackFID < 0)
	  return(-1);

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
	  return(-1);

   //Goal Type.
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeCallback);
   //Auto update.
   aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
   //Callback FID.
   aiPlanSetVariableInt(goalID, cGoalPlanFunctionID, 0, callbackFID);
   //Priority.
   aiPlanSetDesiredPriority(goalID, 90);
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

   //Done.
   return(goalID);
}

//==============================================================================
// createBuildBuildingGoal
//==============================================================================
int createBuildBuildingGoal(string name="BUG", int buildingTypeID=-1, int repeat=-1,
   int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1,
   bool autoUpdate=true, int pri=90, int buildingPlacementID = -1)
{
   printEcho("CreateBuildBuildingGoal:  Name="+name+", BuildingType="+kbGetUnitTypeName(buildingTypeID)+".");
   printEcho("  Repeat="+repeat+", MinAge="+minAge+", maxAge="+maxAge+".");

   //Create the goal.
   int goalID=aiPlanCreate(name, cPlanGoal);
   if (goalID < 0)
	  return(-1);

   //Goal Type.
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuilding);
   //Base ID.
   aiPlanSetBaseID(goalID, baseID);
   //Auto update.
   aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
   //Building Type ID.
   aiPlanSetVariableInt(goalID, cGoalPlanBuildingTypeID, 0, buildingTypeID);
   //Building Placement ID.
   aiPlanSetVariableInt(goalID, cGoalPlanBuildingPlacementID, 0, buildingPlacementID);
   //Set the builder parms.
   aiPlanSetVariableInt(goalID, cGoalPlanMinUnitNumber, 0, 1);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxUnitNumber, 0, numberUnits);
   aiPlanSetVariableInt(goalID, cGoalPlanUnitTypeID, 0, builderUnitTypeID);
   
   //Priority.
   aiPlanSetDesiredPriority(goalID, pri);
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, repeat);

   //Done.
   return(goalID);
}

//==============================================================================
// createBuildSettlementGoal
//==============================================================================
int createBuildSettlementGoal(string name="BUG", int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1,
   bool autoUpdate=true, int pri=100)
{
   int goalNumber = 1+aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true);
   int buildingTypeID = cUnitTypeSettlementLevel1;

   printEcho("CreateBuildSettlementGoal:  Name="+name+", BuildingType="+kbGetUnitTypeName(buildingTypeID)+".");
   printEcho("  MinAge="+minAge+", maxAge="+maxAge+".");

   //Create the goal.
   int goalID=aiPlanCreate(name+goalNumber, cPlanGoal);
   if (goalID < 0)
	  return(-1);

   //Goal Type.
   aiPlanSetVariableInt(goalID, cGoalPlanGoalType, 0, cGoalPlanGoalTypeBuildSettlement);
   //Base ID.
   aiPlanSetBaseID(goalID, baseID);
   //Auto update.
   aiPlanSetVariableBool(goalID, cGoalPlanAutoUpdateState, 0, autoUpdate);
   //Building Type ID.
   aiPlanSetVariableInt(goalID, cGoalPlanBuildingTypeID, 0, buildingTypeID);
   //Building Search ID.
   aiPlanSetVariableInt(goalID, cGoalPlanBuildingSearchID, 0, cUnitTypeSettlement);
   //Set the builder parms.
   aiPlanSetVariableInt(goalID, cGoalPlanMinUnitNumber, 0, 1);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxUnitNumber, 0, numberUnits);
   aiPlanSetVariableInt(goalID, cGoalPlanUnitTypeID, 0, builderUnitTypeID);
   /*
	//Add some protection?
	aiPlanSetVariableInt(goalID, cGoalPlanMinUnitNumber, 1, 0);
	aiPlanSetVariableInt(goalID, cGoalPlanMaxUnitNumber, 1, numberUnits*3);
	aiPlanSetVariableInt(goalID, cGoalPlanUnitTypeID, 1, cUnitTypeHumanSoldier);
   */
   //Escrow ID
   aiPlanSetEscrowID(goalID, cRootEscrowID);
   
   //Priority.
   aiPlanSetDesiredPriority(goalID, pri);
   //Ages.
   aiPlanSetVariableInt(goalID, cGoalPlanMinAge, 0, minAge);
   aiPlanSetVariableInt(goalID, cGoalPlanMaxAge, 0, maxAge);
   //Repeat.
   aiPlanSetVariableInt(goalID, cGoalPlanRepeat, 0, 1);

   //Done.
   return(goalID);
}

//==============================================================================
// createTransportPlan
//==============================================================================
int createTransportPlan(string name="BUG", int startAreaID=-1, int goalAreaID=-1,
   bool persistent=false, int transportPUID=-1, int pri=-1, int baseID=-1)
{
   printEcho("CreateTransportPlan:  Name="+name+", Priority="+pri+".");
   printEcho("  StartAreaID="+startAreaID+", GoalAreaID="+goalAreaID+", Persistent="+persistent+".");
   printEcho("  TransportType="+kbGetUnitTypeName(transportPUID)+", BaseID="+baseID+".");

   //Create the plan.
   int planID=aiPlanCreate(name, cPlanTransport);
   if (planID < 0)
	  return(-1);

   //Priority.
   aiPlanSetDesiredPriority(planID, pri);
   //Base.
   aiPlanSetBaseID(planID, baseID);
   //Set the areas.
   aiPlanSetVariableInt(planID, cTransportPlanPathType, 0, 1);
   aiPlanSetVariableInt(planID, cTransportPlanGatherArea, 0, startAreaID);
   aiPlanSetVariableInt(planID, cTransportPlanTargetArea, 0, goalAreaID);
   //Default the initial position to the start area's location.
   aiPlanSetInitialPosition(planID, kbAreaGetCenter(startAreaID));
   //Transport type.
   aiPlanSetVariableInt(planID, cTransportPlanTransportTypeID, 0, transportPUID);
   //Persistent.
   aiPlanSetVariableBool(planID, cTransportPlanPersistent, 0, persistent);
   //Always add the transport unit type.
   aiPlanAddUnitType(planID, transportPUID, 1, 1, 1);
   //Activate.
   aiPlanSetActive(planID);

   //Done.
   return(planID);
}


//==============================================================================
// setMilitaryGatherPointAllBases
//==============================================================================
vector setMilitaryGatherPointAllBases(vector location=cInvalidVector)
{
   static int baseQueryID=-1;
   //If we don't have a query ID, create it.
   if (baseQueryID < 0)
   {
      baseQueryID=kbUnitQueryCreate("BaseQuery");
      //If we still don't have one, bail.
      if (baseQueryID < 0)
      {
		return(location);
      }else{
	kbUnitQuerySetPlayerID(baseQueryID, cMyID);
	kbUnitQuerySetUnitType(baseQueryID, cUnitTypeAbstractSettlement);
	kbUnitQuerySetState(baseQueryID, cUnitStateAliveOrBuilding);
      }
   }
   kbUnitQueryResetResults(baseQueryID);		//Reset the results.
   int numberFound = kbUnitQueryExecute(baseQueryID);
   for (i=0; < numberFound)
   {
	kbBaseSetMilitaryGatherPoint(cMyID, kbUnitQueryGetResult(baseQueryID, i), location);
   }
   kbBaseSetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID), location);
   return(location);
}

//==============================================================================
// pauseBaseDefendPlan
//==============================================================================
void pauseBaseDefendPlan()
{
	  aiPlanDestroy(gDefendPlanID);
	  gDefendPlanID = -1;
	  xsEnableRule("reactivateDefendPlan");  // Start again after a short break
}

//==============================================================================
// RULE: defendPlanRule
//==============================================================================
// Age 4 freeze not below
rule defendPlanRule   // Make a defend plan, protect the main base, destroy plan when army size is nearly enough for an attack
minInterval 14
inactive
{
   static int defendCount = 0;				// For plan numbering
   int upID = gLandUPID;				// Active unit picker, for getting target military size
   int targetPop = kbUnitPickGetMinimumPop(upID);	// Size needed to launch an attack, in pop slots
   int mainBaseID = kbBaseGetMainID(cMyID);

   if (gDefendPlanID < 0)
   {
	  gDefendPlanID = aiPlanCreate("Defend plan #"+defendCount, cPlanDefend);
	  defendCount = defendCount + 1;
	  //printEcho("***** Making new defend plan.");

	  if (gDefendPlanID < 0)
		 return;
   
	  //aiPlanSetVariableInt(gDefendPlanID, cDefendPlanDefendBaseID, 0, mainBaseID);
	  aiPlanSetVariableVector(gDefendPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
	  aiPlanSetVariableFloat(gDefendPlanID, cDefendPlanEngageRange, 0, 50.0);
	  aiPlanSetVariableInt(gDefendPlanID, cDefendPlanRefreshFrequency, 0, 30);
	  aiPlanSetVariableFloat(gDefendPlanID, cDefendPlanGatherDistance, 0, 50.0);
	  aiPlanSetUnitStance(gDefendPlanID, cUnitStanceDefensive);
	  
	  aiPlanSetNumberVariableValues(gDefendPlanID, cDefendPlanAttackTypeID, 2, true);
	  aiPlanSetVariableInt(gDefendPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeUnit);
	  aiPlanSetVariableInt(gDefendPlanID, cDefendPlanAttackTypeID, 1, cUnitTypeBuilding);

	  //Defend with our complete army.
	  aiPlanSetRequiresAllNeedUnits(gDefendPlanID, false);
	  aiPlanAddUnitType(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary, 0, 200, 200);
	  aiPlanSetDesiredPriority(gDefendPlanID, 20);  // Well below others
	  aiPlanSetActive(gDefendPlanID);
	  return;
   }

   if ( (getPlanPopSlots(gDefendPlanID) > targetPop) || (kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive)>0) )   // Make room for attack plan
   {
	  //printEcho("***** Killing defend plan. ("+getPlanPopSlots(gDefendPlanID)+"/"+targetPop+")");
	  pauseBaseDefendPlan();
	  xsDisableSelf();
   }

   // Check if it's on the wrong continent
   int myAreaGroup = kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, mainBaseID));
   if ( myAreaGroup != kbAreaGroupGetIDByPosition(aiPlanGetLocation(gDefendPlanID)) )
   {  // Defend plan is on a different continent, scratch it.
	  if (kbAreaGroupGetIDByPosition(aiPlanGetLocation(gDefendPlanID)) != -1)
	  {
		 printEcho("***** Defend plan is in wrong areaGroup:"+myAreaGroup+", "+kbAreaGroupGetIDByPosition(aiPlanGetLocation(gDefendPlanID)));
		 pauseBaseDefendPlan();
		 xsDisableSelf();
	  }
   }
}


//==============================================================================
// RULE: reactivateDefendPlan
//==============================================================================
rule reactivateDefendPlan
active
minInterval 8	//was 60
{
   printEcho("***** Restarting defendPlanRule.");
   xsEnableRule("defendPlanRule");
   xsDisableSelf();
}




//==============================================================================
// activateObeliskClearingPlan
//==============================================================================
// Create a simple plan to destroy enemy obelisks, remove plan if none exist
// MK: Need to create a rule chain (loop) to create this plan, then set it to not take more units after 
// it's first filled, then check every 90 seconds to see if it's empty and recreate or refill it.
// This will get over the "stream infantry into the enemy town" problem.
// Ideally, another rule could be used to explicitly set the target IDs (rather than Target Type)
// to make sure it doesn't focus over and over on the same obelisk.
rule activateObeliskClearingPlan
active
minInterval 33
{
   if (kbGetAge() < cAge2)
	  return;
   int mainBaseID = kbBaseGetMainID(cMyID);
   static int obeliskPlanCount = 0;

   static int obeliskQueryID=-1;
   //If we don't have a query ID, create it.
   if (obeliskQueryID < 0)
   {
	  obeliskQueryID=kbUnitQueryCreate("Obelisk Query");
	  //If we still don't have one, bail.
	  if (obeliskQueryID < 0)
		 return;
	  //Else, setup the query data.
	  kbUnitQuerySetPlayerRelation( obeliskQueryID, cPlayerRelationEnemy );
	  //kbUnitQuerySetPlayerID(obeliskQueryID, 2);
	  kbUnitQuerySetUnitType(obeliskQueryID, cUnitTypeOutpost);   // NOT cUnitTypeObelisk!!!
	  kbUnitQuerySetState(obeliskQueryID, cUnitStateAliveOrBuilding);
   }

   // Check for obelisks
   kbUnitQueryResetResults(obeliskQueryID);
   int obeliskCount = kbUnitQueryExecute(obeliskQueryID);

   if (obeliskCount < 1)
   {
	  if (gObeliskClearingPlanID >= 0)
	  {
		 aiPlanDestroy(gObeliskClearingPlanID);
		 gObeliskClearingPlanID = -1;
	  }
	  return;   // No targets, take it easy
   }

   // We found targets, make a plan if we don't have one.
   
   if ( (gObeliskClearingPlanID < 0) )
   {
	  gObeliskClearingPlanID = aiPlanCreate("Obelisk plan #"+obeliskPlanCount, cPlanDefend);
	  obeliskPlanCount = obeliskPlanCount + 1;

	  if (gObeliskClearingPlanID < 0)
		 return;
   
	  aiPlanSetVariableVector(gObeliskClearingPlanID, cDefendPlanDefendPoint, 0, kbBaseGetLocation(cMyID, mainBaseID));
	  aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanEngageRange, 0, 1000.0);   // Anywhere!
	  aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanRefreshFrequency, 0, 30);
	  aiPlanSetVariableFloat(gObeliskClearingPlanID, cDefendPlanGatherDistance, 0, 50.0);
	  aiPlanSetUnitStance(gObeliskClearingPlanID, cUnitStanceDefensive);

	  aiPlanSetVariableInt(gObeliskClearingPlanID, cDefendPlanAttackTypeID, 0, cUnitTypeOutpost);

	  aiPlanAddUnitType(gObeliskClearingPlanID, cUnitTypeAbstractInfantry, 1, 1, 1);
	  aiPlanSetDesiredPriority(gObeliskClearingPlanID, 58); // Above normal attack
	  aiPlanSetActive(gObeliskClearingPlanID);
   }
}


