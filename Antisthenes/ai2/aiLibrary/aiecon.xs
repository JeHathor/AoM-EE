//==============================================================================
// AoMXaiEcon.xs
//
// Handles common economy functions.
//==============================================================================
/*
	Index:
	----------------------------
	getEconPop
	getMilPop
	getPlayerMilPop
	findNumberOfUnitsInBase
	findBestSettlement
	findASettlement
	getNumberUnits
	getUnit
	getNextGathererUpgrade
	findBiggestBorderArea
	setGathererDistribution
	setEarlyEconBO
	updateWoodBreakdown
	updateGoldBreakdown
	updateFoodBreakdown
	updateResourceHandler
	relocateFarming
	startLandScouting
	autoBuildOutpost
	airScouting
	econAge1Handler
	econAge2Handler
	econAge3Handler
	econAge4Handler
	initEcon
	postInitEcon
	fishing
	buildSecondDock
	equal
	isSameAreaGroup
	findIsolatedSettlement
	buildHouseClassic
	buildHouse
	aiTaskBuildSettlement
	buildSettlements
	claimRemoteSettlement
	opportunities
	randomUpgrader
	buildGarden
	dwarfGatherGold
	chooseGardenResource
*/
//==============================================================================
// getEconPop
//
// Returns the unit count of villagers, dwarves, fishing boats, trade carts and oxcarts.
//==============================================================================
int getEconPop(int pID=cMyID)	//Allow to check for other players too.
{
   int retVal = 0;

   retVal = retVal + kbUnitCount(pID, getGathererType(0), cUnitStateAlive);

   retVal = retVal + kbUnitCount(pID, cUnitTypeDwarf, cUnitStateAlive);
   retVal = retVal + kbUnitCount(pID, cUnitTypeFishingShipGreek, cUnitStateAlive);
   retVal = retVal + kbUnitCount(pID, cUnitTypeFishingShipNorse, cUnitStateAlive);
   retVal = retVal + kbUnitCount(pID, cUnitTypeFishingShipEgyptian, cUnitStateAlive);
   retVal = retVal + kbUnitCount(pID, cUnitTypeFishingShipAtlantean, cUnitStateAlive);   
   retVal = retVal + kbUnitCount(pID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
   retVal = retVal + kbUnitCount(pID, cUnitTypeOxCart, cUnitStateAlive);

   return(retVal);
}

//==============================================================================
// getMilPop
//
// Returns the pop slots used by military units
//==============================================================================
int getMilPop(void)
{
   return(kbGetPop() - getEconPop());
}

//==============================================================================
// getPlayerMilPop
//
// Returns the pop slots used by military units
//==============================================================================
int getPlayerMilPop(int pID=cMyID)	//Allow to check for other players too.
{
   int myID = cMyID;
   if(pID >= 0 && pID != myID)
   {
	xsSetContextPlayer(pID);
   }
   int milPop = kbGetPop() - getEconPop(pID);
   if(xsGetContextPlayer() != myID)
   {
	xsSetContextPlayer(myID);
   }
   return(milPop);
}

//==============================================================================
// findNumberOfUnitsInBase
//
//==============================================================================
int findNumberOfUnitsInBase(int playerID=0, int baseID=-1, int unitTypeID=-1)
{
   int count=-1;
   static int unitQueryID=-1;

   //Create the query if we don't have it.
   if (unitQueryID < 0)
	  unitQueryID=kbUnitQueryCreate("getUnitsInBaseQuery");
   
	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	  kbUnitQuerySetBaseID(unitQueryID, baseID);
	  kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
	  kbUnitQuerySetState(unitQueryID, cUnitStateAny);
	}
	else
	return(-1);

   kbUnitQueryResetResults(unitQueryID);
	return(kbUnitQueryExecute(unitQueryID));
}

//==============================================================================
// findBestSettlement
//
// Will find the closest settlement of the given playerID
//==============================================================================
vector findBestSettlement(int playerID=0)
{
   vector townLocation=kbGetTownLocation();
   vector best=townLocation;

   int count=-1;
   static int unitQueryID=-1;

   //Create the query if we don't have it yet.
   if (unitQueryID < 0)
	  unitQueryID=kbUnitQueryCreate("getUnClaimedSettlements");
   
	//Define a query to get all matching units.
	if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	  kbUnitQuerySetUnitType(unitQueryID, cUnitTypeSettlement);
	  kbUnitQuerySetState(unitQueryID, cUnitStateAny);
	}
	else
	return(best);

   //Find the best one.
	float bestDistSqr=100000000.0;
   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);
   for (i=0; < numberFound)
   {
	  vector position=kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i));
	  float dx=xsVectorGetX(townLocation)-xsVectorGetX(position);
	  float dz=xsVectorGetZ(townLocation)-xsVectorGetZ(position);
	  
	  float curDistSqr=((dx*dx) + (dz*dz));
	  if(curDistSqr < bestDistSqr)
	  {
		 best=position;
		 bestDistSqr=curDistSqr;
	  }
   }
   return(best);
}

//==============================================================================
// findASettlement
//
// Will find an unclaimed settlement
//==============================================================================
bool findASettlement()
{
    int count = -1;
    static int unitQueryID = -1;

    // Create the query if we don't have it yet.
    if (unitQueryID < 0)
	unitQueryID = kbUnitQueryCreate("getUnClaimedSettlements");

    // Define a query to get all matching units.
    if (unitQueryID != -1)
    {
	kbUnitQuerySetPlayerID(unitQueryID, 0);
	kbUnitQuerySetUnitType(unitQueryID, cUnitTypeSettlement);
	kbUnitQuerySetState(unitQueryID, cUnitStateAny);
    }
    else
	return(false);

    kbUnitQueryResetResults(unitQueryID);
    int numberFound = kbUnitQueryExecute(unitQueryID);

    if (numberFound > 0)
	return(true);

    return(false);
}

//==============================================================================
// getNumberUnits
//==============================================================================
int getNumberUnits(int unitType = -1, int playerID = -1, int state = cUnitStateAlive)
{
    int count = -1;
    static int unitQueryID = -1;

    // Create the query if we don't have it yet.
    if (unitQueryID < 0)
	unitQueryID = kbUnitQueryCreate("GetNumberOfUnitsQuery");

    // Define a query to get all matching units.
    if (unitQueryID != -1)
    {
	kbUnitQuerySetPlayerID(unitQueryID, playerID);
	kbUnitQuerySetUnitType(unitQueryID, unitType);
	kbUnitQuerySetState(unitQueryID, state);
    }
    else
	return(0);

    kbUnitQueryResetResults(unitQueryID);
    return(kbUnitQueryExecute(unitQueryID));
}

//==============================================================================
// getUnit
//==============================================================================
int getUnit(int unitType = -1)
{
    int retVal = -1;
    int count = -1;
    static int unitQueryID = -1;

    // Create the query if we don't have it yet.
    if (unitQueryID < 0)
	unitQueryID = kbUnitQueryCreate("getUnitQuery");

    // Define a query to get all matching units.
    if (unitQueryID != -1)
    {
	kbUnitQuerySetPlayerID(unitQueryID, cMyID);
	kbUnitQuerySetUnitType(unitQueryID, unitType);
	kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
    }
    else
	return(-1);

    kbUnitQueryResetResults(unitQueryID);
    count = kbUnitQueryExecute(unitQueryID);

    // Pick a unit and return its ID, or return -1.
    if (count > 0)
	retVal = kbUnitQueryGetResult(unitQueryID, 0);

    return(retVal);
}

//==============================================================================
// getNextGathererUpgrade
//
// sets up a progression plan to research the next upgrade that benefits the given
// resource.
//==============================================================================
rule getNextGathererUpgrade
   minInterval 16
   inactive
   runImmediately
{
   if (cMyCulture != cCultureAtlantean)
	  if (kbSetupForResource(kbBaseGetMainID(cMyID), cResourceWood, 25.0, 600) == false)
		 return;

   static int id=0;

	int gathererTypeID=getGathererType(0);
	if (gathererTypeID < 0)
	  return();
	
	for (i=0; < 3)
   {
	  int affectedUnitType=-1;
	  if (i == cResourceGold)
		 affectedUnitType=cUnitTypeGold;
	  else if (i == cResourceWood)
		 affectedUnitType=cUnitTypeWood;
	  else //(i == cResourceFood)
	  {
		 //If we're not farming yet, don't get anything.
		 if (gFarming != true)
			continue;
		 if (kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAlive) >= 0)   // Farms always first
			affectedUnitType=cUnitTypeFarm;
	  }

	  //Get the building that we drop this resource off at.
	   int dropSiteFilterID=kbTechTreeGetDropsiteUnitIDByResource(i, 0);
	  if (cMyCulture == cCultureAtlantean)
		 dropSiteFilterID = cUnitTypeGuild;  // All econ techs at guild
	   if (dropSiteFilterID < 0)
		   continue;

	  //Don't do anything until you have a dropsite.
	  if (getUnit(dropSiteFilterID) == -1)
		 continue;

	  //Get the cheapest thing.
	   int upgradeTechID=kbTechTreeGetCheapestUnitUpgrade(gathererTypeID, cUpgradeTypeWorkRate, -1, dropSiteFilterID, false, affectedUnitType);
	   if (upgradeTechID < 0)
		   continue;
	   //Dont make another plan if we already have one.
	  if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, upgradeTechID) != -1)
		 continue;

	  //Make plan to get this upgrade.
	   int planID=aiPlanCreate("nextGathererUpgrade - "+id, cPlanProgression);
	   if (planID < 0)
		   continue;

	   aiPlanSetVariableInt(planID, cProgressionPlanGoalTechID, 0, upgradeTechID);
	   aiPlanSetDesiredPriority(planID, 25);
	   aiPlanSetEscrowID(planID, cEconomyEscrowID);
	   aiPlanSetActive(planID);
	  printEcho("**** getNextGathererUpgrade: successful in creating a progression to "+kbGetTechName(upgradeTechID));
	   id++;
   }
}

//==============================================================================
// findBiggestBorderArea
//
// given an areaid, find the biggest border area in tiles.
//==============================================================================
int findBiggestBorderArea(int areaID=-1)
{
	if(areaID == -1)
		return(-1);

	int numBorders=kbAreaGetNumberBorderAreas(areaID);
	int borderArea=-1;
	int numTiles=-1;
	int bestTiles=-1;
	int bestArea=-1;

	for (i=0; < numBorders)
	{
		borderArea=kbAreaGetBorderAreaID(areaID, i);
		numTiles=kbAreaGetNumberTiles(borderArea);
		if (numTiles > bestTiles)
		{
			bestTiles=numTiles;
			bestArea=borderArea;
		}
	}

	return(bestArea);
}

//==============================================================================
// setGathererDistribution
//==============================================================================
void setGathererDistribution(int food=1, int wood=1, int gold=1, int favor=0)
{
   float modifier = 100/(food+wood+gold);

   float foodGPct = modifier*food;
   float woodGPct = modifier*wood;
   float goldGPct = modifier*gold;

   float favorGPct = modifier*favor;

   aiSetResourceGathererPercentage(cResourceFood, foodGPct, false, cRGPScript);
   aiSetResourceGathererPercentage(cResourceWood, woodGPct, false, cRGPScript);
   aiSetResourceGathererPercentage(cResourceGold, goldGPct, false, cRGPScript);

   aiSetResourceGathererPercentage(cResourceFavor, favorGPct, false, cRGPScript);
   aiNormalizeResourceGathererPercentages(cRGPScript);
}

//==============================================================================
// RULE: setEarlyEconBO
//==============================================================================
rule setEarlyEconBO		//TODO
   minInterval 3
   inactive
   runImmediately
{
	if(kbGetAge() > cAge1)
	{
		xsDisableSelf();
		return;
	}

	if(xsGetTime() > 2*60*1000)	//We need a temple!
	{
		/*xsEnableRule("ageUpBuildingMonitor");*/
	}

	bool age1Researching = false;
	if(kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching)
	{
		age1Researching = true;
		//This will activate econForecastAge2Early...
		xsEnableRule("econForecastAge1Mid");
	}
	//Water BO is not counting fishing ships!!!
	int gathererCount = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);
	//-->[food, wood, gold, favor]
	if(cMyCulture == cCultureGreek && gFishMap == false)		//Greek, Land
	{
	    if(gHuntMap)	//High Hunt?
	    {
		if(age1Researching) {setGathererDistribution(5,7,5,1);}		//shift for age2
		else
		if(gathererCount <= 4) {setGathererDistribution(4,0,0);}	//4 -> food
		else
		if(gathererCount == 5) {setGathererDistribution(4,1,0);}
		else
		if(gathererCount == 6) {setGathererDistribution(4,2,0);}
		else
		if(gathererCount == 7) {setGathererDistribution(4,3,0);}	//3 -> wood
		else
		if(gathererCount == 8) {setGathererDistribution(4,3,1);}
		else
		if(gathererCount == 9) {setGathererDistribution(4,3,2);}	//2 -> gold
		else
		if(gathererCount == 10) {setGathererDistribution(5,3,2);}
		else
		if(gathererCount == 11) {setGathererDistribution(6,3,2);}
		else
		if(gathererCount == 12) {setGathererDistribution(7,3,2);}
		else
		if(gathererCount == 13) {setGathererDistribution(8,3,2);}	//4 -> food
		else
		if(gathererCount == 14) {setGathererDistribution(8,3,2,1);}	//1 -> favor
		else
		if(gathererCount == 15) {setGathererDistribution(9,3,2,1);}
		else
		if(gathererCount == 16) {setGathererDistribution(10,3,2,1);}
		else
		if(gathererCount == 17) {setGathererDistribution(11,3,2,1);}
		else
		if(gathererCount == 18) {setGathererDistribution(12,3,2,1);}	//4 -> food
	    }else{
		if(age1Researching) {setGathererDistribution(5,7,5,1);}		//shift for age2
		else
		if(gathererCount <= 3) {setGathererDistribution(3,0,0);}	//3 -> food
		else
		if(gathererCount == 4) {setGathererDistribution(3,1,0);}
		else
		if(gathererCount == 5) {setGathererDistribution(3,2,0);}	//2 -> wood
		else
		if(gathererCount == 6) {setGathererDistribution(3,2,1);}	//1 -> gold
		else
		if(gathererCount == 7) {setGathererDistribution(4,2,1);}
		else
		if(gathererCount == 8) {setGathererDistribution(5,2,1);}
		else
		if(gathererCount == 9) {setGathererDistribution(6,2,1);}
		else
		if(gathererCount == 10) {setGathererDistribution(7,2,1);}
		else
		if(gathererCount == 11) {setGathererDistribution(8,2,1);}	//5 -> food
		else
		if(gathererCount == 12) {setGathererDistribution(8,2,1,1);}	//1 -> favor
		else
		if(gathererCount == 13) {setGathererDistribution(8,2,2,1);}	//1 -> gold
		else
		if(gathererCount == 14) {setGathererDistribution(9,2,2,1);}
		else
		if(gathererCount == 15) {setGathererDistribution(10,2,2,1);}
		else
		if(gathererCount == 16) {setGathererDistribution(11,2,2,1);}
		else
		if(gathererCount == 17) {setGathererDistribution(12,2,2,1);}	//4 -> food
		else
		if(gathererCount == 18) {setGathererDistribution(12,3,2,1);}	//1 -> wood
	    }
	}
	if(cMyCulture == cCultureGreek && gFishMap == true)		//Greek, Water
	{
		if(age1Researching) {setGathererDistribution(0,11,5,1);}	//shift for age2
		else
		if(gathererCount <= 3) {setGathererDistribution(0,3,0);}	//3 -> wood
		else
		if(gathererCount <= 4) {setGathererDistribution(1,3,0);}
		else
		if(gathererCount <= 5) {setGathererDistribution(2,3,0);}
		else
		if(gathererCount <= 6) {setGathererDistribution(3,3,0);}
		else
		if(gathererCount <= 7) {setGathererDistribution(4,3,0);}	//4 -> food
		else
		if(gathererCount <= 8) {setGathererDistribution(4,4,0);}
		else
		if(gathererCount <= 9) {setGathererDistribution(4,5,0);}	//2 -> wood
		else
		if(gathererCount <= 10) {setGathererDistribution(5,5,0);}
		else
		if(gathererCount <= 11) {setGathererDistribution(6,5,0);}
		else
		if(gathererCount <= 12) {setGathererDistribution(7,5,0);}
		else
		if(gathererCount <= 13) {setGathererDistribution(8,5,0);}	//4 -> food
		else
		if(gathererCount <= 14) {setGathererDistribution(8,5,1);}	//1 -> gold
		else
		if(gathererCount <= 15) {setGathererDistribution(8,5,1,1);}	//1 -> favor
		else
		if(gathererCount <= 16) {setGathererDistribution(8,6,1,1);}	//1 -> wood
		else
		if(gathererCount <= 17) {setGathererDistribution(8,6,2,1);}	//1 -> gold
	}
	if(cMyCulture == cCultureEgyptian && gFishMap == false)		//Eggy, Land
	{
	    if(gathererCount <= 4){
		setGathererDistribution(4,0,0);
	    }else
	    if(gathererCount <= 7){
		setGathererDistribution(4,0,3);
	    }else
	    if(gathererCount <= 16){
		setGathererDistribution(13,0,3);
	    }else
	    if(gathererCount <= 17 || age1Researching){
		setGathererDistribution(8,3,6);		//shift
	    }
	}
	if(cMyCulture == cCultureEgyptian && gFishMap == true)		//Eggy, Water
	{
	    if(gathererCount <= 4){
		setGathererDistribution(4,0,0);
	    }else
	    if(gathererCount <= 7){
		setGathererDistribution(4,0,3);
	    }else
	    if(gathererCount <= 10){
		setGathererDistribution(4,3,3);
	    }else
	    if(gathererCount <= 16){
		setGathererDistribution(10,3,3);
	    }else
	    if(gathererCount <= 17 || age1Researching){
		setGathererDistribution(7,4,6);		//shift
	    }
	}
	if(cMyCulture == cCultureNorse && gFishMap == false)		//Norse, Land
	{
	    if(gathererCount <= 4){
		setGathererDistribution(4,0,0);
	    }else
	    if(gathererCount <= 6){
		setGathererDistribution(4,0,2);
	    }else
	    if(gathererCount <= 8){
		setGathererDistribution(4,2,2);
	    }else
	    if(gathererCount <= 11){
		setGathererDistribution(4,2,5);
	    }else
	    if(gathererCount <= 15){
		setGathererDistribution(8,2,5);
	    }else
	    if(gathererCount <= 16 || age1Researching){
		setGathererDistribution(7,4,5);		//shift
	    }
	}
	if(cMyCulture == cCultureNorse && gFishMap == true)		//Norse, Water
	{
	    if(gathererCount <= 4){
		setGathererDistribution(4,0,0);
	    }else
	    if(gathererCount <= 8){
		setGathererDistribution(4,4,0);
	    }else
	    if(gathererCount <= 12){
		setGathererDistribution(4,4,4);
	    }else
	    if(gathererCount <= 14){
		setGathererDistribution(6,4,4);
	    }else
	    if(gathererCount <= 15){
		setGathererDistribution(6,4,5);
	    }else
	    if(gathererCount <= 16 || age1Researching){
		setGathererDistribution(7,4,5);		//shift
	    }
	}
	if(cMyCulture == cCultureAtlantean && gFishMap == false)	//Atty, Land
	{
	    if(gathererCount <= 2){
		setGathererDistribution(2,0,0);
	    }else
	    if(gathererCount <= 3){
		setGathererDistribution(2,1,0);
	    }else
	    if(gathererCount <= 4){
		setGathererDistribution(2,1,1);
	    }else
	    if(gathererCount <= 6){
		setGathererDistribution(4,1,1);
	    }else
	    if(gathererCount <= 7 || age1Researching){
		setGathererDistribution(3,3,2);		//shift
	    }
	}
	if(cMyCulture == cCultureAtlantean && gFishMap == true)	//Atty, Water
	{
	    if(gathererCount <= 2){
		setGathererDistribution(2,0,0);
	    }else
	    if(gathererCount <= 4){
		setGathererDistribution(2,2,0);
	    }else
	    if(gathererCount <= 5){
		setGathererDistribution(2,2,1);
	    }else
	    if(gathererCount <= 6){
		setGathererDistribution(3,2,1);
	    }else
	    if(gathererCount <= 7 || age1Researching){
		setGathererDistribution(3,3,2);		//shift
	    }
	}
	if(cMyCulture == cCultureChinese && gFishMap == false)		//Chinese, Land
	{
	    if(gathererCount <= 4){
		setGathererDistribution(4,0,0);
	    }else
	    if(gathererCount <= 7){
		setGathererDistribution(4,3,0);
	    }else
	    if(gathererCount <= 9){
		setGathererDistribution(4,3,2);
	    }else
	    if(gathererCount <= 13){
		setGathererDistribution(8,3,2);
	    }else
	    if(gathererCount <= 17){
		setGathererDistribution(11,3,3);
	    }else
	    if(gathererCount <= 18 || age1Researching){
		setGathererDistribution(6,7,6);		//shift
	    }
	}
	if(cMyCulture == cCultureChinese && gFishMap == true)		//Chinese, Water
	{
	    if(gathererCount <= 4){
		setGathererDistribution(4,0,0);
	    }else
	    if(gathererCount <= 9){
		setGathererDistribution(4,5,0);
	    }else
	    if(gathererCount <= 9){
		setGathererDistribution(4,5,2);
	    }else
	    if(gathererCount <= 13){
		setGathererDistribution(6,5,2);
	    }else
	    if(gathererCount <= 17){
		setGathererDistribution(9,5,3);
	    }else
	    if(gathererCount <= 18 || age1Researching){
		setGathererDistribution(6,7,6);		//shift
	    }
	}
}

//==============================================================================
// RULE: UpdateWoodBreakdown
//==============================================================================
rule updateWoodBreakdown
   minInterval 12
   inactive
   group startRules
{
   int mainBaseID = kbBaseGetMainID(cMyID);

   int woodPriority=50;
   if (cMyCulture == cCultureEgyptian && kbGetAge() >= cAge2)
	  woodPriority=55;

   if(gFishMap && kbGetAge() == cAge1)
	woodPriority=70;

   int gathererCount = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);
   int woodGathererCount = 0.5 + aiGetResourceGathererPercentage(cResourceWood, cRGPActual) * gathererCount;

   // If we have no need for wood, set plans=0 and exit
   if (woodGathererCount <= 0)
   {
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, 0);
	  aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, mainBaseID);
	  if (gWoodBaseID != mainBaseID)
		 aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, gWoodBaseID);
	  //printEcho("	No wood cutters needed.");
	  return;
   }

   // If we're this far, we need some wood gatherers.  The number of plans we use will be the greater of 
   // a) the ideal number for this number of gatherers, or
   // b) the number of plans active that have resource sites, either main base or wood base.

   //Count of sites.
   int numberMainBaseSites=kbGetNumberValidResources(mainBaseID, cResourceWood, cAIResourceSubTypeEasy);
   int numberWoodBaseSites = 0;
   if ( (gWoodBaseID >= 0) && (gWoodBaseID != mainBaseID) ) // Count wood base if different
	  numberWoodBaseSites = kbGetNumberValidResources(gWoodBaseID, cResourceWood, cAIResourceSubTypeEasy);

   //Get the count of plans we currently have going.
   int numWoodPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0);

   int desiredWoodPlans = 1 + (woodGathererCount/12);

   if (desiredWoodPlans < numWoodPlans)
	  desiredWoodPlans = numWoodPlans;  // Try to preserve existing plans

   // Three cases are possible:
   // 1)  We have enough sites at our main base.  All should work in main base.
   // 2)  We have some wood at main, but not enough.  Split the sites
   // 3)  We have no wood at main...use woodBase

   if (numberMainBaseSites >= desiredWoodPlans) // case 1
   {
	  // remove any breakdown for woodBaseID
	  if (gWoodBaseID != mainBaseID)
		 aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, gWoodBaseID);
	  gWoodBaseID = mainBaseID;
	  aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans, woodPriority, 1.0, mainBaseID);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);
	  return;
   }

   if ( (numberMainBaseSites > 0) && (numberMainBaseSites < desiredWoodPlans) )  // case 2
   {
	  aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numberMainBaseSites, woodPriority, 1.0, mainBaseID);

	  if (numberWoodBaseSites > 0)  // We do have remote wood
	  {
		 aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans-numberMainBaseSites, woodPriority, 1.0, gWoodBaseID);
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);
	  }
	  else  // No remote wood...bummer.  Kill old breakdown, look for more
	  {
		 aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, gWoodBaseID);   // Remove old breakdown
		 //Try to find a new wood base.
		 gWoodBaseID=kbBaseFindCreateResourceBase(cResourceWood, cAIResourceSubTypeEasy, kbBaseGetMainID(cMyID));
		 if (gWoodBaseID >= 0)
		 {
			printEcho("	New wood base is "+gWoodBaseID);
			aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);  // We can have the full amount
			 aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans-numberMainBaseSites, woodPriority, 1.0, gWoodBaseID);
		 }
		 else
		 {
			aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, numberMainBaseSites);   // That's all we get
		 }
	  }
	  return;
   }

   if (numberMainBaseSites < 1)  // case 3
   {
	  aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy,mainBaseID);

	  if (numberWoodBaseSites >= desiredWoodPlans)  // We have enough remote wood
	  {
		 aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans, woodPriority, 1.0, gWoodBaseID);
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);
	  }
	  else if (numberWoodBaseSites > 0)   // We have some, but not enough
	  {
		 aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numberWoodBaseSites, woodPriority, 1.0, gWoodBaseID);
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, numberWoodBaseSites);
	  }
	  else  // We have none, try elsewhere
	  {
		 aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, gWoodBaseID);   // Remove old breakdown
		 //Try to find a new wood base.
		 gWoodBaseID=kbBaseFindCreateResourceBase(cResourceWood, cAIResourceSubTypeEasy, kbBaseGetMainID(cMyID));
		 if (gWoodBaseID >= 0)
		 {
			printEcho("	New wood base is "+gWoodBaseID);
			numberWoodBaseSites = kbGetNumberValidResources(gWoodBaseID, cResourceWood, cAIResourceSubTypeEasy);
			if (numberWoodBaseSites < desiredWoodPlans)
			   desiredWoodPlans = numberWoodBaseSites;
			aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, desiredWoodPlans);  
			 aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, desiredWoodPlans, woodPriority, 1.0, gWoodBaseID);
		 }
	  }
	  return;
   }
}

//==============================================================================
// RULE: UpdateGoldBreakdown
//==============================================================================
rule updateGoldBreakdown
   minInterval 13
   inactive
   group startRules
{
   int mainBaseID = kbBaseGetMainID(cMyID);

   int goldPriority=49; // Lower than wood for non-Egyptians
   if (cMyCulture == cCultureEgyptian)  // Higher than Egyptian wood
	  goldPriority=56;

   int gathererCount = kbUnitCount(cMyID,cUnitTypeAbstractVillager,cUnitStateAlive);
   int goldGathererCount = 0.5 + aiGetResourceGathererPercentage(cResourceGold, cRGPActual) * gathererCount;

   // If we have no need for gold, set plans=0 and exit
   if (goldGathererCount <= 0)
   {
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, 0);
	  aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, mainBaseID);
	  if (gGoldBaseID != mainBaseID)
		 aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, gGoldBaseID);
	  return;
   }

   // If we're this far, we need some gold gatherers.  The number of plans we use will be the greater of 
   // a) the ideal number for this number of gatherers, or
   // b) the number of plans active that have resource sites, either main base or gold base.

   //Count of sites.
   int numberMainBaseSites=kbGetNumberValidResources(mainBaseID, cResourceGold, cAIResourceSubTypeEasy);
   int numberGoldBaseSites = 0;
   if ( (gGoldBaseID >= 0) && (gGoldBaseID != mainBaseID) ) // Count gold base if different
	  numberGoldBaseSites = kbGetNumberValidResources(gGoldBaseID, cResourceGold, cAIResourceSubTypeEasy);

   //Get the count of plans we currently have going.
   int numGoldPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0);

   int desiredGoldPlans = 1 + (goldGathererCount/12);

   if (desiredGoldPlans < numGoldPlans)
	  desiredGoldPlans = numGoldPlans;  // Try to preserve existing plans

   // Three cases are possible:
   // 1)  We have enough sites at our main base.  All should work in main base.
   // 2)  We have some gold at main, but not enough.  Split the sites
   // 3)  We have no gold at main...use goldBase

   if (numberMainBaseSites >= desiredGoldPlans) // case 1
   {
	  // remove any breakdown for goldBaseID
	  if (gGoldBaseID != mainBaseID)
		 aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, gGoldBaseID);
	  gGoldBaseID = mainBaseID;
	  aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans, goldPriority, 1.0, mainBaseID);
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);
	  return;
   }

   if ( (numberMainBaseSites > 0) && (numberMainBaseSites < desiredGoldPlans) )  // case 2
   {
	  aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numberMainBaseSites, goldPriority, 1.0, mainBaseID);

	  if (numberGoldBaseSites > 0)  // We do have remote gold
	  {
		 aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans-numberMainBaseSites, goldPriority, 1.0, gGoldBaseID);
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);
	  }
	  else  // No remote gold...bummer.  Kill old breakdown, look for more
	  {
		 aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, gGoldBaseID);   // Remove old breakdown
		 //Try to find a new gold base.
		 gGoldBaseID=kbBaseFindCreateResourceBase(cResourceGold, cAIResourceSubTypeEasy, kbBaseGetMainID(cMyID));
		 if (gGoldBaseID >= 0)
		 {
			printEcho("	New gold base is "+gGoldBaseID);
			aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);  // We can have the full amount
			 aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans-numberMainBaseSites, goldPriority, 1.0, gGoldBaseID);
		 }
		 else
		 {
			aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, numberMainBaseSites);   // That's all we get
		 }
	  }
	  return;
   }


   if (numberMainBaseSites < 1)  // case 3
   {
	  aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy,mainBaseID);

	  if (numberGoldBaseSites >= desiredGoldPlans)  // We have enough remote gold
	  {
		 aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans, goldPriority, 1.0, gGoldBaseID);
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);
	  }
	  else if (numberGoldBaseSites > 0)   // We have some, but not enough
	  {
		 aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numberGoldBaseSites, goldPriority, 1.0, gGoldBaseID);
		 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, numberGoldBaseSites);
	  }
	  else  // We have none, try elsewhere
	  {
		 aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, gGoldBaseID);   // Remove old breakdown
		 //Try to find a new gold base.
		 gGoldBaseID=kbBaseFindCreateResourceBase(cResourceGold, cAIResourceSubTypeEasy, kbBaseGetMainID(cMyID));
		 if (gGoldBaseID >= 0)
		 {
			printEcho("	New gold base is "+gGoldBaseID);
			numberGoldBaseSites = kbGetNumberValidResources(gGoldBaseID, cResourceGold, cAIResourceSubTypeEasy);
			if (numberGoldBaseSites < desiredGoldPlans)
			   desiredGoldPlans = numberGoldBaseSites;
			aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, desiredGoldPlans);  
			 aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, desiredGoldPlans, goldPriority, 1.0, gGoldBaseID);
		 }
	  }
	  return;
   }
}

//==============================================================================
// updateFoodBreakdown
//==============================================================================
rule updateFoodBreakdown
   minInterval 9
   inactive
   group startRules
{
	
   int mainBaseID = kbBaseGetMainID(cMyID);
   int numAggressivePlans = aiGetResourceBreakdownNumberPlans(cResourceFood, cAIResourceSubTypeHuntAggressive, mainBaseID );

	  
   float distance = gMaximumBaseResourceDistance - 10.0;	// Make sure we don't get resources near perimeter that might wander out of range.
   //Get the number of valid resources spots.
   int numberAggressiveResourceSpots=kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHuntAggressive, distance);

   if ( (cvMasterDifficulty == cDifficultyEasy) && (cvRandomMapName != "erebus") ) // Changed 8/18/03 to force Easy hunting on Erebus.
   {
	  numberAggressiveResourceSpots = 0;  // Never get enough vills to go hunting.
   }

   int numberHuntResourceSpots = kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHunt, distance);
   if ( kbUnitCount(0, cUnitTypeHuntable) > 0)
   {
	// Our plan can't use this and will break...
	//numberHuntResourceSpots = numberHuntResourceSpots + 1;
   }
   int numberEasyResourceSpots=kbGetNumberValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeEasy, distance);
   if ( kbUnitCount(cMyID, cUnitTypeHerdable) > 0)
   {	// We have herdables, make up for the fact that the resource count excludes them.
	  numberEasyResourceSpots = numberEasyResourceSpots + 1;
   }
   if ( kbGetAge() < cAge2 && cvMasterDifficulty > cDifficultyHard && numberHuntResourceSpots > 0)
   {
	numberEasyResourceSpots = 0;	//don't gather crops if we have hunt!
   }
   // Only do one aggressive site at a time, they tend to take lots of gatherers
   if (numberAggressiveResourceSpots > 1)
   {
	  numberAggressiveResourceSpots = 1;
   }
   int totalNumberResourceSpots=numberAggressiveResourceSpots + numberEasyResourceSpots + numberHuntResourceSpots;
   printEcho("Food resources:  "+numberAggressiveResourceSpots+" aggressive, "+numberHuntResourceSpots+" hunt, and "+numberEasyResourceSpots+" easy.");

   float aggressiveAmount=kbGetAmountValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHuntAggressive, distance);
   float easyAmount=kbGetAmountValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeEasy, distance);
   easyAmount = easyAmount + 100* kbUnitCount(cMyID, cUnitTypeHerdable);	  // Add in the herdables, overlooked by the kbGetAmount call.
   float huntAmount=kbGetAmountValidResources(mainBaseID, cResourceFood, cAIResourceSubTypeHunt, distance);
   float totalAmount=aggressiveAmount+easyAmount+huntAmount;
   printEcho("Food amounts:  "+aggressiveAmount+" aggressive, "+huntAmount+" hunt, and "+easyAmount+" easy.");

   int gathererCount = kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer, 0),cUnitStateAlive);
   if (cMyCulture == cCultureNorse)
	  gathererCount = gathererCount + kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer, 1),cUnitStateAlive);  // dwarves
   int foodGathererCount = 0.5 + aiGetResourceGathererPercentage(cResourceFood, cRGPActual) * gathererCount;

   if (foodGathererCount <= 0)
	  foodGathererCount = 1;	 // Avoid div 0

   // Preference order is existing farms (except in age 1), new farms if low on food sites, aggressive hunt (size permitting), hunt, easy, then age 1 farms.  
   // MK:  "hunt" isn't supported in the kbGetNumberValidResource calls, but if we add it, this code should use it properly.
   int aggHunters = 0;
   int hunters = 0;
   int easy = 0;
   int farmers = 0;
   int unassigned = foodGathererCount;
   int farmerReserve = 0;  // Number of farms we already have, use them first unless Egypt first age (slow slow farming)
   int farmerPreBuild = 0; // Number of farmers to ask for ahead of time when food starts running low.

	if ( (gFarmBaseID >= 0) && (kbGetTechStatus(cTechPlow) >= cTechStatusResearching))   // Farms get first priority 
	{
		farmerReserve = findNumberOfUnitsInBase(cMyID, gFarmBaseID, cUnitTypeFarm);
	}

   if (farmerReserve > unassigned)
	  farmerReserve = unassigned;   // Can't reserve more than we have!

   if ((farmerReserve > 0) && ((kbGetAge()>cAge1)||cvOkToFarmEarly) ) // Should we farm? Only after age 1
   {
	  unassigned = unassigned - farmerReserve;
   }

   if ( (aiGetGameMode() == cGameModeLightning) || (aiGetGameMode() == cGameModeDeathmatch) )
	  totalAmount = 200;   // Fake a shortage so that farming always starts early in these game modes
   if ( (kbGetAge() > cAge1) || (cMyCulture == cCultureEgyptian) )   // can build farms
   {
	  if ( ((totalNumberResourceSpots < 2) && (xsGetTime() > 150000)) || (totalAmount <= (500 + 50*foodGathererCount)) || (kbGetAge()==cAge3) )
	  {  // Start building if only one spot left, or if we're low on food.  In age 3, start farming anyway.
		 farmerPreBuild = 4;  // Starting prebuild
		 if (cMyCulture == cCultureAtlantean)
			farmerPreBuild = 2;
		 if (farmerPreBuild > unassigned)
			farmerPreBuild = unassigned;
		 //printEcho("Reserving "+farmerPreBuild+" slots for prebuilding farms.");
		 unassigned = unassigned - farmerPreBuild;
		 if (farmerPreBuild > 0)
				gFarming = true;
	  }
   }
   // Want 1 plan per 12 vills, or fraction thereof.
   int numPlansWanted = 1 + unassigned/12;
   if (cMyCulture == cCultureAtlantean)
	  numPlansWanted = 1 + unassigned/4;
   if (unassigned == 0)
	  numPlansWanted = 0;

   if (numPlansWanted > totalNumberResourceSpots)
   {
	  numPlansWanted = totalNumberResourceSpots;
   }
   int numPlansUnassigned = numPlansWanted;


   int minVillsToStartAggressive = aiGetMinNumberNeedForGatheringAggressives()+0;   // Don't start a new aggressive plan unless we have this many vills...buffer above strict minimum.
   if (cMyCulture == cCultureAtlantean)
	  minVillsToStartAggressive = aiGetMinNumberNeedForGatheringAggressives()+0;

  
// Start a new plan if we have enough villies and we have the resource.
// If we have a plan open, don't kill it as long as we are within 2 of the needed min...the plan will steal from elsewhere.
   if ( (numPlansUnassigned > 0) && (numberAggressiveResourceSpots > 0)
		&& ( (unassigned > minVillsToStartAggressive)|| ((numAggressivePlans>0) && (unassigned>=(aiGetMinNumberNeedForGatheringAggressives()-2))) ) )   // Need a plan, have resources and enough hunters...or one plan exists already.
   {
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 1);
	  //printEcho("Making 1 aggressive plan.");
	  aggHunters = aiGetMinNumberNeedForGatheringAggressives(); // This plan will over-grab due to high priority
	  if (numPlansUnassigned == 1)
		 aggHunters = unassigned;   // use them all if we're small enough for 1 plan
	  numPlansUnassigned = numPlansUnassigned - 1;
	  unassigned = unassigned - aggHunters;
	  numberAggressiveResourceSpots = 1;  // indicates 1 used
   }
   else  // Can't go aggressive
   {
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 0);
	  numberAggressiveResourceSpots = 0;  // indicate none used
   }

   if ( (numPlansUnassigned > 0) && (numberHuntResourceSpots > 0) )
   {
	  if (numberHuntResourceSpots > numPlansUnassigned)
		 numberHuntResourceSpots = numPlansUnassigned;
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt, numberHuntResourceSpots);
	  hunters = (numberHuntResourceSpots * unassigned) / numPlansUnassigned;  // If hunters are 2 of 3 plans, they get 2/3 of gatherers.
	  unassigned = unassigned - hunters;
	  numPlansUnassigned = numPlansUnassigned - numberHuntResourceSpots;
   }
   else
   {
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt, 0);
	  numberHuntResourceSpots = 0;
   }

   if ( (numPlansUnassigned > 0) && (numberEasyResourceSpots > 0) )
   {
	  if (numberEasyResourceSpots > numPlansUnassigned)
		 numberEasyResourceSpots = numPlansUnassigned;
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, numberEasyResourceSpots);
	  easy = (numberEasyResourceSpots * unassigned) / numPlansUnassigned;
	  unassigned = unassigned - easy;
	  numPlansUnassigned = numPlansUnassigned - numberEasyResourceSpots;
   }
   else
   {
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
	  numberEasyResourceSpots = 0;
   }

   // If we still have some unassigned, and we're in the first age, and we're not egyptian, try to dump them into a plan.
   if ( (kbGetAge() == cAge1) && (unassigned > 0) && (cMyCulture != cCultureEgyptian) )
   {
	  if ( (aggHunters > 0) && (unassigned > 0) )
	  {
		 aggHunters = aggHunters + unassigned;
		 unassigned = 0;
	  }
	  if ( (hunters > 0) && (unassigned > 0) )
	  {
		 hunters = hunters + unassigned;
		 unassigned = 0;
	  }
	  if ( (easy > 0) && (unassigned > 0) )
	  {
		 easy = easy + unassigned;
		 unassigned = 0;
	  }

	  // If we're here and unassigned > 0, we'll just make an easy plan and dump them there, hoping
	  // that there's easy food somewhere outside our base.
	  //printEcho("Making an emergency easy plan.");
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, numberEasyResourceSpots+1);
	  easy = easy + unassigned;
	  unassigned = 0;
	  if ( (gMaximumBaseResourceDistance < 110.0) && (kbGetAge()<cAge2) )
	  {
		 gMaximumBaseResourceDistance = gMaximumBaseResourceDistance + 10.0;
		 printEcho("**** Expanding gather radius to "+gMaximumBaseResourceDistance);
	  }
   }  
  
 
   // Now, the number of farmers we want is the unassigned total, plus reserve (existing farms) and prebuild (plan ahead).
   farmers = farmerReserve + farmerPreBuild;
   unassigned = unassigned - farmers;

   if (unassigned > 0)
   {  // Still unassigned?  Make an extra easy plan, hope they can find food somewhere
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, numberEasyResourceSpots+1);
	  easy = easy + unassigned;
	  unassigned = 0;
   }

   int numFarmPlansWanted = 0;
   if (farmers > 0)
   {
	  numFarmPlansWanted = 1 + ( farmers / aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0) );
	  gFarming = true;
   }
   else
		gFarming = false;

   //Egyptians can farm in the first age and if we're forced to farm early we should do so
   if (((kbGetAge() > 0) || (cMyCulture == cCultureEgyptian)) && (gFarmBaseID != -1) && (xsGetTime() > 180000)||cvOkToFarmEarly)
   {
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, numFarmPlansWanted);
   }
   else
   {
	  numFarmPlansWanted = 0;
   }

   printEcho("Assignments are "+aggHunters+" aggressive hunters, "+hunters+" hunters, "+easy+" gatherers, and "+farmers+" farmers.");

   //Set breakdown based on goals.
   aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, numFarmPlansWanted, 90, (100.0*farmers)/(foodGathererCount*100.0), gFarmBaseID);
   aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, numberAggressiveResourceSpots, 45, (100.0*aggHunters)/(foodGathererCount*100.0), mainBaseID);
   aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, numberHuntResourceSpots, 78, (100.0*hunters)/(foodGathererCount*100.0), mainBaseID);
   aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, numberEasyResourceSpots, 65, (100.0*easy)/(foodGathererCount*100.0), mainBaseID);
}

//==============================================================================
// updateResourceHandler
//==============================================================================
void updateResourceHandler(int parm=0)
{
   //Handle Food.
   if (parm == cResourceFood)
   {
	  updateFoodBreakdown();
	  xsEnableRule("updateFoodBreakdown");
   }
   //Handle Gold.
   if (parm == cResourceGold)
   {
	  updateGoldBreakdown();
	  xsEnableRule("updateGoldBreakdown");
   }
   //Handle Wood.
   if (parm == cResourceWood)
   {
	  updateWoodBreakdown();
	  xsEnableRule("updateWoodBreakdown");
   }
}

//==============================================================================
// RULE: relocateFarming
//==============================================================================
rule relocateFarming
   minInterval 30
   inactive
{
   //Not farming yet, don't do anything.
   if (gFarming == false)
	  return;

   //Fixup the old RB for farming.
   if (gFarmBaseID != -1)
   {
	  //Check the current farm base for a settlement.
	  if (findNumberOfUnitsInBase(cMyID, gFarmBaseID, cUnitTypeAbstractSettlement) > 0)
		 return;
	  //Remove the old breakdown.
	  aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, gFarmBaseID);
   }

   //If no settlement, then move the farming to another base that has a settlement.
   int unit=findUnit(cMyID, cUnitStateAlive, cUnitTypeAbstractSettlement);
   if (unit != -1)
   {
	  //Get new base ID.
	  gFarmBaseID=kbUnitGetBaseID(unit);
	  //Make a new breakdown.
	  int numFarmPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm);
	  aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, numFarmPlans, 100, 1.0, gFarmBaseID);
   }
   else
   {
	  //If there are no other bases without settlements... stop farming.
	  gFarmBaseID=-1;
	  aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, 0);
   }
}

//==============================================================================
// RULE: startLandScouting
//
// grabs the first scout in the scout list and starts scouting with it.
//==============================================================================
rule startLandScouting
   minInterval 1
   active
{
   //If no scout, go away.
   if (gLandScout == -1)
   {
	  xsDisableSelf();
	  return;
   }

   if (cMyCulture == cCultureAtlantean)
	  return;   // Atlanteans use special low-pri explore plans with pauses for oracle LOS.

   //Land based Scouting.
	gLandExplorePlanID=aiPlanCreate("Explore_Land", cPlanExplore);
   if (gLandExplorePlanID >= 0)
   {
	  aiPlanAddUnitType(gLandExplorePlanID, gLandScout, 1, 1, 1);

	  aiPlanSetEscrowID(gLandExplorePlanID, cEconomyEscrowID);

//  int oneStopPath = kbPathCreate("Start scout");
//  vector firstStop = kbGetTownLocation();
//  firstStop = firstStop + (kbBaseGetFrontVector(cMyID,kbBaseGetMainID(cMyID))*50);
	  
//  kbPathAddWaypoint(oneStopPath, firstStop);
//  aiPlanSetWaypoints(gLandExplorePlanID, oneStopPath);
	  aiPlanSetVariableFloat(gLandExplorePlanID, cExplorePlanLOSMultiplier, 0, 1.7);
	  aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, true);
	  aiPlanSetVariableInt(gLandExplorePlanID, cExplorePlanNumberOfLoops, 0, 2);
	  aiPlanSetInitialPosition(gLandExplorePlanID, kbBaseGetLocation(cMyID,kbBaseGetMainID(cMyID)));
	  
	  //Don't loop as egyptian.
	  if (cMyCulture == cCultureEgyptian)
		 aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);

	  aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanCanBuildLOSProto, 0, true);

	  aiPlanSetActive(gLandExplorePlanID);
   }

   //Go away now.
   xsDisableSelf();
}

//==============================================================================
// RULE: autoBuildOutpost
//
// Restrict Egyptians from building outposts until they have a temple.
//==============================================================================
rule autoBuildOutpost
   minInterval 10
   inactive // Disabled because I'm starting it in startLandScouting, above
{
   if ((gLandScout == -1) || (cMyCulture != cCultureEgyptian))
   {
	  xsDisableSelf();
	  return;
   }
   if (getUnit(cUnitTypeTemple) == -1)
	  return;

   aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanCanBuildLOSProto, 0, true);
   xsDisableSelf();
}

//==============================================================================
// RULE: airScouting
//
// scout with a flying scout.
//==============================================================================
rule airScouting
   minInterval 1
   inactive
{
   //Stop this if there are no flying scout.
   if (gAirScout == -1)
   {
	  printEcho("No Air scout specified.  Turning off air scout rule");
	  xsDisableSelf();
	  return;
   }

   //Maintain 1 air scout.
   createSimpleMaintainPlan(gAirScout, gMaintainNumberAirScouts, true, -1);

   //Create a progression to the air scout.
   int pid=aiPlanCreate("AirScoutProgression", cPlanProgression);
	if (pid >= 0)
	{ 
	  printEcho("Creating air scout progression.");
	  aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 0, gAirScout);
		aiPlanSetDesiredPriority(pid, 100);
		aiPlanSetEscrowID(pid, cEconomyEscrowID);
		aiPlanSetActive(pid);
	}
   else
	  printEcho("Could not create train air scout plan.");

   //Once we have unit to scout with, set it in motion.
   int exploreID=aiPlanCreate("Explore_Air", cPlanExplore);
	if (exploreID >= 0)
	{
		printEcho("Setting up air explore plan.");
	  aiPlanAddUnitType(exploreID, gAirScout, 1, 1, 1);
	  aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
	  //aiPlanSetVariableBool(exploreID, cExplorePlanAvoidingAttackedAreas, 0, true);
		aiPlanSetActive(exploreID);
	  aiPlanSetEscrowID(exploreID, cEconomyEscrowID);
	}
   else
	  printEcho("Could not create air explore plan.");

   //Go away.
   xsDisableSelf();
}

//==============================================================================
// econAge1Handler
//==============================================================================
void econAge1Handler(int age=0)
{
   printEcho("Economy Age "+age+".");

   // Set escrow caps
   kbEscrowSetCap( cEconomyEscrowID, cResourceFood, 500.0); // Age 2
   kbEscrowSetCap( cEconomyEscrowID, cResourceWood, 300.0);
   kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 400.0);
   kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 10.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceFood, 100.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceWood, 100.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceGold, 100.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceFavor, 10.0);

   if (aiGetGameMode() == cGameModeDeathmatch)  // Add emergency houses
   {
	  if (cMyCulture == cCultureAtlantean)
	  {
		 createSimpleBuildPlan(cUnitTypeManor, 1, 80, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	  }
	  else
	  {
		 createSimpleBuildPlan(cUnitTypeHouse, 3, 80, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
	  }
   }

   if (gHuntMap)	//Hunting dogs.
   {
	int huntingDogsPlanID=aiPlanCreate("getHuntingDogsEarly", cPlanProgression);
	if (huntingDogsPlanID != 0)
	{
	  aiPlanSetVariableInt(huntingDogsPlanID, cProgressionPlanGoalTechID, 0, cTechHuntingDogs);
	   aiPlanSetDesiredPriority(huntingDogsPlanID, 34);
	   aiPlanSetEscrowID(huntingDogsPlanID, cEconomyEscrowID);
	   aiPlanSetActive(huntingDogsPlanID);
	}
	if (cMyCulture == cCultureAtlantean)
	{
		//addUnitForecast(cUnitTypeManor, 1);
		gGoldForecast = gGoldForecast + kbUnitCostPerResource(cUnitTypeManor, cResourceGold);
		gWoodForecast = gWoodForecast + kbUnitCostPerResource(cUnitTypeManor, cResourceWood);
		createSimpleBuildPlan(cUnitTypeGuild, 1, 80, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
		createSimpleBuildPlan(cUnitTypeManor, 1, 50, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	}else{
		//addUnitForecast(cUnitTypeHouse, 1);
		gWoodForecast = gWoodForecast + kbUnitCostPerResource(cUnitTypeHouse, cResourceWood);
	}
   }

   xsEnableRule("setEarlyEconBO");	//Age1 Build Order!
}

//==============================================================================
// econAge2Handler
//==============================================================================
void econAge2Handler(int age=1)
{
   printEcho("Economy Age "+age+".");
   
   // Start early settlement monitor if not already active (vinland, team mig, nomad)
   xsEnableRule("buildSettlements");	//Nice and early!

   //Start up air scouting.
   airScouting();
   //Re-enable buildHouse.
   xsEnableRule("buildHouse");
   //Fire up opportunities.
   xsEnableRule("opportunities");

   //Farming is worthless without plow, get it first
	int plowPlanID=aiPlanCreate("getPlow", cPlanProgression);
	if (plowPlanID != 0)
   {
	  aiPlanSetVariableInt(plowPlanID, cProgressionPlanGoalTechID, 0, cTechPlow);
	   aiPlanSetDesiredPriority(plowPlanID, 100);   // Do it ASAP!
	   aiPlanSetEscrowID(plowPlanID, cEconomyEscrowID);
	   aiPlanSetActive(plowPlanID);
   }
   //Make plan to get husbandry unless you're Atlantean
   if (cMyCulture != cCultureAtlantean)
   {
	   int husbandryPlanID=aiPlanCreate("getHusbandry", cPlanProgression);
	   if (husbandryPlanID != 0)
	  {
		 aiPlanSetVariableInt(husbandryPlanID, cProgressionPlanGoalTechID, 0, cTechHusbandry);
		  aiPlanSetDesiredPriority(husbandryPlanID, 25);
		  aiPlanSetEscrowID(husbandryPlanID, cEconomyEscrowID);
		  aiPlanSetActive(husbandryPlanID);
	  }
   }
   else  // Turn on the settlement rule
	  xsEnableRule("buildSettlements");
   
   // Transports
   if (gTransportMap == true)
   {
	   int enclosedDeckID=aiPlanCreate("getEnclosedDeck", cPlanProgression);
	   if (enclosedDeckID != 0)
	  {
		 aiPlanSetVariableInt(enclosedDeckID, cProgressionPlanGoalTechID, 0, cTechEnclosedDeck);
		  aiPlanSetDesiredPriority(enclosedDeckID, 60);   
		  aiPlanSetEscrowID(enclosedDeckID, cEconomyEscrowID);
		  aiPlanSetActive(enclosedDeckID);
	  }
   }

   //Hunting dogs.
   int huntingDogsPlanID=aiPlanCreate("getHuntingDogs", cPlanProgression);
   if (huntingDogsPlanID != 0 && kbGetTechStatus(cTechHuntingDogs) < cTechStatusResearching)
   {
	  aiPlanSetVariableInt(huntingDogsPlanID, cProgressionPlanGoalTechID, 0, cTechHuntingDogs);
	   aiPlanSetDesiredPriority(huntingDogsPlanID, 25);
	   aiPlanSetEscrowID(huntingDogsPlanID, cEconomyEscrowID);
	   aiPlanSetActive(huntingDogsPlanID);
   }

   // Fishing
   if (gFishing == true) 
   {
	   int purseSeineID=aiPlanCreate("getPurseSeine", cPlanProgression);
	   if (purseSeineID != 0)
	  {
		 aiPlanSetVariableInt(purseSeineID, cProgressionPlanGoalTechID, 0, cTechPurseSeine);
		  aiPlanSetDesiredPriority(purseSeineID, 45);   
		  aiPlanSetEscrowID(purseSeineID, cEconomyEscrowID);
		  aiPlanSetActive(purseSeineID);
	  }
   }


   if ( (aiGetGameMode() == cGameModeDeathmatch) || (aiGetGameMode() == cGameModeLightning) )  // Add an emergency armory
   {
	  if (cMyCulture == cCultureAtlantean)
	  {
		 createSimpleBuildPlan(cUnitTypeArmory, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
		 createSimpleBuildPlan(cUnitTypeManor, 3, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
		 //Add an additional military building!
		 createSimpleBuildPlan(cUnitTypeBarracksAtlantean, 1, 80, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
		 createSimpleBuildPlan(cUnitTypeCounterBuilding, 1, 80, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
	  }
	  else
	  {
		 createSimpleBuildPlan(cUnitTypeArmory, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 3);
		 createSimpleBuildPlan(cUnitTypeHouse, 6, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
	  }
	  if (cMyCulture == cCultureNorse)	//Help norse with early unit spam!
	  {
		 createSimpleBuildPlan(cUnitTypeLonghouse, 2, 80, true, true, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 2);
	  }
   }

   // Set escrow caps
   kbEscrowSetCap( cEconomyEscrowID, cResourceFood, 800.0); // Age 3
   kbEscrowSetCap( cEconomyEscrowID, cResourceWood, 300.0);
   kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 500.0); // Age 3
   kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 30.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceFood, 100.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceWood, 200.0);   // Towers
   kbEscrowSetCap( cMilitaryEscrowID, cResourceGold, 200.0);   // Towers
   kbEscrowSetCap( cMilitaryEscrowID, cResourceFavor, 30.0);
}

//==============================================================================
// econAge3Handler
//==============================================================================
void econAge3Handler(int age=0)
{
   printEcho("Economy Age "+age+".");

   //Enable misc rules.
   xsEnableRule("buildHouse");
   xsEnableRule("relocateFarming");

   xsEnableRule("getFortifiedTownCenter");

   // Fishing
   if (gFishing == true) 
   {
	   int saltAmphoraID=aiPlanCreate("getSaltAmphora", cPlanProgression);
	   if (saltAmphoraID != 0)
	  {
		 aiPlanSetVariableInt(saltAmphoraID, cProgressionPlanGoalTechID, 0, cTechSaltAmphora);
		  aiPlanSetDesiredPriority(saltAmphoraID, 80);  
		  aiPlanSetEscrowID(saltAmphoraID, cEconomyEscrowID);
		  aiPlanSetActive(saltAmphoraID);
	  }
   }

   if ((aiGetGameMode() == cGameModeDeathmatch) || (aiGetGameMode() == cGameModeLightning))   // Add an emergency market
   {

	  if (cMyCulture == cCultureAtlantean)
	  {
		 createSimpleBuildPlan(cUnitTypeMarket, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
		 gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.	   
		 createSimpleBuildPlan(cUnitTypeManor, 1, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	  }
	  else
	  {
		 createSimpleBuildPlan(cUnitTypeMarket, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 5);
		 gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.	   
		 createSimpleBuildPlan(cUnitTypeHouse, 2, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	  }
   }

   //Enable gatherer upgrades.
   xsEnableRule("getNextGathererUpgrade");

   // Set escrow caps
   kbEscrowSetCap( cEconomyEscrowID, cResourceFood, 1000.0);	// Age 4
   kbEscrowSetCap( cEconomyEscrowID, cResourceWood, 400.0);  // Settlements, upgrades
   kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 1000.0);	// Age 4
   kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 30.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceFood, 300.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceWood, 400.0);   
   kbEscrowSetCap( cMilitaryEscrowID, cResourceGold, 400.0);   
   kbEscrowSetCap( cMilitaryEscrowID, cResourceFavor, 30.0);

   kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 85.0);   
}

//==============================================================================
// econAge4Handler
//==============================================================================
void econAge4Handler(int age=0)
{
   printEcho("Economy Age "+age+".");
   xsEnableRule("buildHouse");
   xsEnableRule("randomUpgrader");
   int numBuilders = 0;
   int bigBuildingType = 0;
   int littleBuildingType = 0;
   if (aiGetGameMode() == cGameModeDeathmatch)   // Add 3 extra big buildings and 6 little buildings
   {
	  switch(cMyCulture)
	  {
		 case cCultureGreek:
			{
			   bigBuildingType = cUnitTypeFortress;
			   numBuilders = 3;
			   createSimpleBuildPlan(cUnitTypeBarracks, 2, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
			   createSimpleBuildPlan(cUnitTypeStable, 2, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
			   createSimpleBuildPlan(cUnitTypeArcheryRange, 2, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
			   break;
			}
		 case cCultureEgyptian:
			{
			   numBuilders = 5;
			   createSimpleBuildPlan(cUnitTypeBarracks, 5, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 2);
			   createSimpleBuildPlan(cUnitTypeSiegeCamp, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
			   bigBuildingType = cUnitTypeMigdolStronghold;
			   break;
			}
		 case cCultureNorse:
			{
			   numBuilders = 2;
			   createSimpleBuildPlan(cUnitTypeLonghouse, 6, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
			   bigBuildingType = cUnitTypeHillFort;
			   break;
			}
		 case cCultureAtlantean:
			{
			   numBuilders = 1;
			   createSimpleBuildPlan(cUnitTypeBarracksAtlantean, 5, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
			   createSimpleBuildPlan(cUnitTypeCounterBuilding, 1, 90, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
			   bigBuildingType = cUnitTypePalace;
			   break;
			}
	  }
	  createSimpleBuildPlan(bigBuildingType, 3, 80, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), numBuilders);
	  createSimpleBuildPlan(cUnitTypeTemple, 1, 80, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
   }

   // Set escrow caps tighter
   if(kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusUnobtainable)
   {
   kbEscrowSetCap( cEconomyEscrowID, cResourceFood, 800.0); 
   kbEscrowSetCap( cEconomyEscrowID, cResourceWood, 800.0); 
   kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 800.0); 
   kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 60.0);

	   if(cMyCulture == cCultureGreek || cMyCulture == cCultureChinese)
	   {
		aiSetFavorNeedModifier(20.0);
	   }
   }else{
   kbEscrowSetCap( cEconomyEscrowID, cResourceFood, 300.0); 
   kbEscrowSetCap( cEconomyEscrowID, cResourceWood, 300.0); 
   kbEscrowSetCap( cEconomyEscrowID, cResourceGold, 300.0); 
   kbEscrowSetCap( cEconomyEscrowID, cResourceFavor, 40.0);

	   if(cMyCulture == cCultureGreek || cMyCulture == cCultureChinese)
	   {
		aiSetFavorNeedModifier(10.0);
	   }
   }
   kbEscrowSetCap( cMilitaryEscrowID, cResourceFood, 300.0);
   kbEscrowSetCap( cMilitaryEscrowID, cResourceWood, 300.0);   
   kbEscrowSetCap( cMilitaryEscrowID, cResourceGold, 300.0);   
   kbEscrowSetCap( cMilitaryEscrowID, cResourceFavor, 40.0);
}

//==============================================================================
// initEcon
//
// setup the initial Econ stuff.
//==============================================================================
void initEcon()
{
   printEcho("Economy Init.");

   //Set our update resource handler.
   aiSetUpdateResourceEventHandler("updateResourceHandler");

   //Set up auto-gather escrows.
   aiSetAutoGatherEscrowID(cEconomyEscrowID);
   aiSetAutoFarmEscrowID(cEconomyEscrowID);
	
   //Distribute the resources we have.
   kbEscrowAllocateCurrentResources();

   //Set our bases.
   gFarmBaseID=kbBaseGetMainID(cMyID);
   gGoldBaseID=kbBaseGetMainID(cMyID);
   gWoodBaseID=kbBaseGetMainID(cMyID);
	
   //Make a plan to manage the villager population.
   gCivPopPlanID=aiPlanCreate("civPop", cPlanTrain);
   if (gCivPopPlanID >= 0)
   {
	  //Get our mainline villager PUID.
	  int gathererPUID=getGathererType(0);
	  aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0, gathererPUID);
	  //Train off of economy escrow.
	  aiPlanSetEscrowID(gCivPopPlanID, cEconomyEscrowID);
	  //Default to 10.
	  aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0, 10);   // Default until reset by updateEM
	  aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement);   // Abstract fixes Citadel problem
	  aiPlanSetVariableBool(gCivPopPlanID, cTrainPlanUseMultipleBuildings, 0, true);
	  aiPlanSetDesiredPriority(gCivPopPlanID, 97); // MK:  Changed priority 100->97 so that oxcarts and ulfsark reserves outrank villagers.
	  aiPlanSetActive(gCivPopPlanID);
   }
   //Create a herd plan to gather all herdables that we ecounter.
   gHerdPlanID=aiPlanCreate("GatherHerdable Plan", cPlanHerd);
   if (gHerdPlanID >= 0)
   {
	  aiPlanAddUnitType(gHerdPlanID, cUnitTypeHerdable, 0, 100, 100);
	  aiPlanSetVariableFloat(gHerdPlanID, cHerdPlanDistance, 0, 16.0);
	  if ((cRandomMapName != "vinlandsaga") && (cRandomMapName != "team migration"))
		 aiPlanSetBaseID(gHerdPlanID, kbBaseGetMainID(cMyID));
	  else
	  {
		 if ((cMyCulture == cCultureGreek) || (cMyCulture == cCultureEgyptian))
			aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeGranary);  
		 else if (cMyCulture == cCultureNorse)
			aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeOxCart);
		 else if (cMyCulture == cCultureAtlantean)
			aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeAbstractVillager);  
		 else if (cMyCulture == cCultureChinese)
			aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingTypeID, 0, cUnitTypeStoragePit);
	  }
	  aiPlanSetActive(gHerdPlanID);
   }
   // Set our target for early-age settlements, based on 2x boom and 1x econ bias.
   float score = 2.0 * (-1.0*cvRushBoomSlider); // Minus one, we want the boom side
   score = score + (-1.0 * cvMilitaryEconSlider);
   printEcho("Early settlement score is "+score);   // Range is -3 to +3

   if (score > -0.5)
	  gEarlySettlementTarget = 1;
   if (score > 0.0)
	  gEarlySettlementTarget = 2;
   if (score > 1.5)
	  gEarlySettlementTarget = 3;
   printEcho("Early settlement target is "+gEarlySettlementTarget);

   if ((cvMigrationMap == false) && (cvNomadMap == false))
   {
	  xsEnableRule("buildSettlements");	// Turn on monitor, otherwise it waits for age 2 handler
   }
}

//==============================================================================
// postInitEcon
//==============================================================================
void postInitEcon()
{
   printEcho("Post Economy Init.");

   //Set the RGP weights.  Script in charge.
   aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanScriptRPGPct, 0, 1.0);
   aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanCostRPGPct, 0, 0.0);
   aiSetResourceGathererPercentageWeight(cRGPScript, 1.0);
   aiSetResourceGathererPercentageWeight(cRGPCost, 0.0);

   //Setup AI Cost weights.
   kbSetAICostWeight(cResourceFood, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFood));
   kbSetAICostWeight(cResourceWood, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceWood));
   kbSetAICostWeight(cResourceGold, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceGold));
   kbSetAICostWeight(cResourceFavor, aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFavor));

   //Set initial gatherer percentages.
   float foodGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, 0, cResourceFood);   
   float woodGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, 0, cResourceWood);   
   float goldGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, 0, cResourceGold);   
   float favorGPct=aiPlanGetVariableFloat(gGatherGoalPlanID, 0, cResourceFavor);

   aiSetResourceGathererPercentage(cResourceFood, 1.0, false, cRGPScript);  // Changed these to 100% food early then
   aiSetResourceGathererPercentage(cResourceWood, 0.0, false, cRGPScript);  // the setEarlyEcon rule above will set the 
   aiSetResourceGathererPercentage(cResourceGold, 0.0, false, cRGPScript);  // former "initial" values once we have 9 (or 3 atlantean) gatherers.
   aiSetResourceGathererPercentage(cResourceFavor, 0.0, false, cRGPScript);
   if (cMyCulture == cCultureEgyptian){
   aiSetResourceGathererPercentage(cResourceFood, 0.8, false, cRGPScript);
   aiSetResourceGathererPercentage(cResourceGold, 0.2, false, cRGPScript);
   }else
   if(gFishMap == true){
   aiSetResourceGathererPercentage(cResourceFood, 0.6, false, cRGPScript);
   aiSetResourceGathererPercentage(cResourceWood, 0.4, false, cRGPScript);  // get some extra wood for fishing ships.
   }else
   if(gHuntMap == true){
   aiSetResourceGathererPercentage(cResourceFood, 0.7, false, cRGPScript);
   aiSetResourceGathererPercentage(cResourceWood, 0.2, false, cRGPScript);
   aiSetResourceGathererPercentage(cResourceGold, 0.1, false, cRGPScript);
   }
   aiNormalizeResourceGathererPercentages(cRGPScript);

   //Set up the initial resource break downs.
   int numFoodHuntPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt);
   int numFoodEasyPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy);
   int numFoodHuntAggressivePlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive);
   int numFishPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish);
   int numWoodPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0);
   int numGoldPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0);
   int numFavorPlans=aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0);

   aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, numFoodHuntPlans, 100, 1.0, kbBaseGetMainID(cMyID));
   aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, numFishPlans, 100, 1.0, kbBaseGetMainID(cMyID));
   aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, numFoodEasyPlans, 90, 1.0, kbBaseGetMainID(cMyID));
   aiSetResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, numFoodHuntAggressivePlans, 80, 0.0, kbBaseGetMainID(cMyID));  // MK: Set from 1.0 to 0.0
   if (cMyCulture == cCultureEgyptian)
   {
	  aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numWoodPlans, 50, 1.0, kbBaseGetMainID(cMyID));
	   aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numGoldPlans, 55, 1.0, kbBaseGetMainID(cMyID));
   }
   else
   {
	  aiSetResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, numWoodPlans, 55, 1.0, kbBaseGetMainID(cMyID));
	   aiSetResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, numGoldPlans, 50, 1.0, kbBaseGetMainID(cMyID));
   }
   aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, numFavorPlans, 40, 1.0, kbBaseGetMainID(cMyID));

   econAge1Handler();		//Specific age1 behaviors...
}

// Age 4 freeze not below
//==============================================================================
// RULE: fishing
//==============================================================================
rule fishing
   minInterval 30
   inactive
{
   //Removed check for water map, rule is now only activated on water or unknown maps.

	//Get the closest water area.  if there isn't one, we can't fish.
	int areaID=-1;
	areaID=kbAreaGetClosetArea(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), cAreaTypeWater);
	if (areaID == -1)
	{
		printEcho("Can't fish on this map, no water.");
		xsDisableSelf();
		return;
	}
	printEcho("Closest water area is "+areaID+", centered at "+kbAreaGetCenter(areaID));

	//Get our fish gatherer.
	int fishGatherer=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);

	//Create the fish plan.
	int fishPlanID=aiPlanCreate("FishPlan", cPlanFish);
	if (fishPlanID >= 0)
	{
	   int fishCount = kbUnitCount(0, cUnitTypeFish, cUnitStateAlive);
	   int maxNumBoats = gNumBoatsToMaintain;
	   if (maxNumBoats > fishCount && fishCount > -1)
	   {
		maxNumBoats = fishCount;
	   }
	   printEcho("Starting up the fishing plan.  Will fish when I find fish.");
	   aiPlanSetDesiredPriority(fishPlanID, 52);
	   aiPlanSetVariableVector(fishPlanID, cFishPlanLandPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	   //If you don't explicitly set the water point, the plan will find one for you.
	   aiPlanSetVariableVector(fishPlanID, cFishPlanWaterPoint, 0, kbAreaGetCenter(areaID));
	   aiPlanSetVariableBool(fishPlanID, cFishPlanAutoTrainBoats, 0, false);
	   aiPlanSetEscrowID(fishPlanID, cEconomyEscrowID);
	   aiPlanAddUnitType(fishPlanID, fishGatherer, 2, maxNumBoats, maxNumBoats);
	   aiPlanSetVariableFloat(fishPlanID, cFishPlanMaximumDockDist, 0, 500.0);
	   gFishing = true;
	   aiPlanSetActive(fishPlanID);
	}

   //We need some fishermen!
   xsEnableRule("TrainFishingShips");

   //Add one fish plan to our list.
   aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish, 1);

   //Hack-o-rific test...move the scouting unit directly over there to find water ASAP
   printEcho("Leading scout to water.");
   int scout = findUnit(cMyID, cUnitStateAlive, gLandScout);
   if (scout >= 0)
   {
	  aiTaskUnitMove(scout, kbAreaGetCenter(areaID));
   }

   gHouseAvailablePopRebuild = gHouseAvailablePopRebuild + 5;
   printEcho("House rebuild is now "+gHouseAvailablePopRebuild);

   //Make a plan to explore with our water scout.
   if(cMyCiv == cCivPoseidon || (gTransportMap == true && cvMasterDifficulty < cDifficultyHard))
   {
	int waterExploreID=aiPlanCreate("Explore_Water", cPlanExplore);
	if (waterExploreID >= 0)
	{
		printEcho("Creating water explore plan.");
	  aiPlanAddUnitType(waterExploreID, gWaterScout, 1, 1, 1);
		aiPlanSetDesiredPriority(waterExploreID, 100);
	  aiPlanSetVariableBool(waterExploreID, cExplorePlanDoLoops, 0, false);
	  aiPlanSetActive(waterExploreID);
	  aiPlanSetEscrowID(cEconomyEscrowID);
	}
	xsDisableSelf();
   }
}

//==============================================================================
// RULE: buildSecondDock
//==============================================================================
rule buildSecondDock
   minInterval 14
   active
{
   if(gFishMap == false)	//Is it worth it?
   {
	return;
   }
   if(kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching)
   {
	return;
   }
   int fishCount = kbUnitCount(0, cUnitTypeFish, cUnitStateAlive);
   if (fishCount > 6*(cNumberPlayers-1) && kbResourceGet(cResourceWood) > 150 && kbResourceGet(cResourceGold) > 50)
   {
	int dockThreshold = 1;	//2nd dock.
	if(kbGetAge() > cAge2 && cvMasterDifficulty >= cDifficultyHard)
	{
		dockThreshold = 2;	//3rd dock.
	}
	// Make sure we have a dock
	if(kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding) <= dockThreshold)
	{
		int areaID = kbAreaGetClosetArea(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), cAreaTypeWater);
		int buildDock = aiPlanCreate("BuildDock2", cPlanBuild);
		if (buildDock >= 0)
		{
		   aiPlanSetVariableInt(buildDock, cBuildPlanBuildingTypeID, 0, cUnitTypeDock);
		   aiPlanSetDesiredPriority(buildDock, 80);
		   aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
		   aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 1, kbAreaGetCenter(areaID));
		   aiPlanAddUnitType(buildDock, getBuilderType(), 1, 1, 1);
		   aiPlanSetEscrowID(buildDock, cEconomyEscrowID);
		   aiPlanSetActive(buildDock);
		}
	}
	xsSetRuleMinIntervalSelf(95);		//Check again later.
   }
}

//==============================================================================
// ORDER: true if the given vectors are equal
//==============================================================================
bool equal(vector left=cInvalidVector, vector right=cInvalidVector)
{
   float lx = xsVectorGetX( left );
   float ly = xsVectorGetY( left );
   float lz = xsVectorGetZ( left );
   float rx = xsVectorGetX( right );
   float ry = xsVectorGetY( right );
   float rz = xsVectorGetZ( right );

   if ( lx == rx &&
	ly == ry &&
	lz == rz )
   {
      return(true);
   }

   return(false);
}

//==============================================================================
// ORDER: true if the given areas are equal
//==============================================================================
bool isSameAreaGroup(vector vec1 = cInvalidVector, vector vec2 = cInvalidVector)
{
   if (kbAreaGroupGetIDByPosition(vec1) == kbAreaGroupGetIDByPosition(vec2))
   {
		return(true);
   }else{
		return(false);
   }
}

//==============================================================================
// findIsolatedSettlement
//
// Will find an unclaimed settlement that needs a transport to reach.
//==============================================================================
int findIsolatedSettlement(void)
{
   vector homeLocation=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
   int count=-1;
   static int unitQueryID=-1;

   //Create the query if we don't have it yet.
   if (unitQueryID < 0)
	  unitQueryID=kbUnitQueryCreate("getIsolatedSettlements");
   
	//Define a query to get all matching units.
	if (unitQueryID != -1)
	{
		kbUnitQuerySetPlayerID(unitQueryID, 0);
	  kbUnitQuerySetUnitType(unitQueryID, cUnitTypeSettlement);
	  kbUnitQuerySetState(unitQueryID, cUnitStateAny);
	  if(equal(homeLocation, cInvalidVector)==false)
	  {
	    kbUnitQuerySetPosition(unitQueryID, homeLocation);
	    kbUnitQuerySetAscendingSort(unitQueryID, true);
	  }
	}
	else
	return(-1);

   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);
   for (i=0; < numberFound)
   {
	int someTC = kbUnitQueryGetResult(unitQueryID, i);
	vector here = homeLocation;
	vector there = kbUnitGetPosition(someTC);

	if (isSameAreaGroup(there, here)==false && equal(there, cInvalidVector)==false && someTC > 0)
	{
		return(someTC);		//found one!
	}
   }
   return(-1);
}

//==============================================================================
// RULE: buildHouseClassic
//==============================================================================
rule buildHouseClassic
   minInterval 11
   inactive
{
   int houseProtoID = cUnitTypeHouse;
   if (cMyCulture == cCultureAtlantean)
	   houseProtoID = cUnitTypeManor;

	//Don't build another house if we've got at least gHouseAvailablePopRebuild open pop slots.
   if (kbGetPop()+gHouseAvailablePopRebuild < kbGetPopCap())
	  return;

   //If we have any houses that are building, skip.
   if (kbUnitCount(cMyID, houseProtoID, cUnitStateBuilding) > 0)
	  return;
   
	//If we already have gHouseBuildLimit houses, we shouldn't build anymore.
   if (gHouseBuildLimit != -1)
   {
	  int numberOfHouses=kbUnitCount(cMyID, houseProtoID, cUnitStateAliveOrBuilding);
	  if (numberOfHouses >= gHouseBuildLimit)
		 return;
   }

	//Get the current Age.
	int age=kbGetAge();
	//Limit the number of houses we build in each age.
	if (gAgeCapHouses == true)
   {
	  if (age == 0)
	   {
		   if (numberOfHouses >= 2)
		   {
			   xsDisableSelf();
			   return;
		   }
	   }
   }

   //If we already have a house plan active, skip.
   if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, houseProtoID) > -1)
	  return;

   //Over time, we will find out what areas are good and bad to build in.  Use that info here, because we want to protect houses.
	int planID=aiPlanCreate("BuildHouse", cPlanBuild);
   if (planID >= 0)
   {
	  aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, houseProtoID);
	  aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
	  aiPlanSetDesiredPriority(planID, 100);

		int builderTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0);
	  if (cMyCulture == cCultureNorse)
		 builderTypeID = cUnitTypeAbstractInfantry;   // Any human soldier basically

		aiPlanAddUnitType(planID, getBuilderType(), gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
	  aiPlanSetEscrowID(planID, cEconomyEscrowID);

	  vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));

	  float x = xsVectorGetX(backVector);
	  float z = xsVectorGetZ(backVector);
	  x = x * 40.0;
	  z = z * 40.0;

	  backVector = xsVectorSetX(backVector, x);
	  backVector = xsVectorSetZ(backVector, z);
	  backVector = xsVectorSetY(backVector, 0.0);
	  vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	  int areaGroup1 = kbAreaGroupGetIDByPosition(location);   // Base area group
	  location = location + backVector;
	  int areaGroup2 = kbAreaGroupGetIDByPosition(location);   // Back vector area group
	  if (areaGroup1 != areaGroup2)
		 location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));   // Reset to area center if back is in wrong area group

	  // Hack to test norse scout-building if only one ulfsark exists
	  if ( (cMyCulture == cCultureNorse) && ( kbUnitCount(cMyID, cUnitTypeUlfsark, cUnitStateAlive) == 1 ) 
		 && (aiPlanGetLocation(gLandExplorePlanID) != cInvalidVector) )
	  {
		 location = aiPlanGetLocation(gLandExplorePlanID);
		 aiPlanSetBaseID(planID, -1);
		 aiPlanSetVariableInt(planID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(location));
	  }
	  else
		 aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));   // Move this back up to block of aiPlanSets if we kill the hack
	  // end hack

	  aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 20.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 1.0);

	  aiPlanSetActive(planID);
   }
}

//==============================================================================
// RULE: buildHouse (New)
//==============================================================================
rule buildHouse
   minInterval 11	//starts in cAge1
   active
{
    int houseProtoID = cUnitTypeHouse;
    if (cMyCulture == cCultureAtlantean)
    {
	houseProtoID = cUnitTypeManor;
    }
	bool skip = false;
	if ((cMyCulture == cCultureNorse) && (kbUnitCount(cMyID, cUnitTypeLogicalTypeHouses, cUnitStateAliveOrBuilding) < 1) && (kbGetAge() == cAge1))
	{
		skip = true;
	}

    //Don't build another house if we've got at least gHouseAvailablePopRebuild open pop slots.
    if ((kbGetPop()+gHouseAvailablePopRebuild < kbGetPopCap()) && (skip == false))
	return;

    //If we already have gHouseBuildLimit houses, we shouldn't build anymore.
    if (gHouseBuildLimit != -1)
    {
	int numHouses = kbUnitCount(cMyID, houseProtoID, cUnitStateAliveOrBuilding);
	if (numHouses >= gHouseBuildLimit)
		return;
	}

    //If we already have a house plan active, skip.
   if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, houseProtoID) > -1)
   {
	  return;
   }
   //Over time, we will find out what areas are good and bad to build in.  Use that info here, because we want to protect houses.
	int planID=aiPlanCreate("BuildHouse", cPlanBuild);
   if (planID >= 0)
   {
	  aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, houseProtoID);
	  aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
	  aiPlanSetVariableInt(planID, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeBuilding);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitDistance, 0, 9);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceUnitValue, 0, -5.0);
	  aiPlanSetDesiredPriority(planID, 100);

		int builderTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0);
	  if (cMyCulture == cCultureNorse)
		 builderTypeID = cUnitTypeAbstractInfantry;   // Any human soldier basically

		aiPlanAddUnitType(planID, getBuilderType(), gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
	  aiPlanSetEscrowID(planID, cEconomyEscrowID);

	  vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));

	  float x = xsVectorGetX(backVector);
	  float z = xsVectorGetZ(backVector);
	  x = x * 25.0;
	  z = z * 25.0;

		if (aiRandInt(2) < 1)
		{
		    //left
		    x = x * (-10);
		    z = z * 10;
		}
		else
		{
		    //right
		    x = z * 10;
		    z = x * (-10);
		}

	  backVector = xsVectorSetX(backVector, x);
	  backVector = xsVectorSetZ(backVector, z);
	  backVector = xsVectorSetY(backVector, 0.0);
	  vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	  int areaGroup1 = kbAreaGroupGetIDByPosition(location);   // Base area group
	  location = location + backVector;
	  int areaGroup2 = kbAreaGroupGetIDByPosition(location);   // Back vector area group
	  if (areaGroup1 != areaGroup2)
		 location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));   // Reset to area center if back is in wrong area group

	  // Hack to test norse scout-building if only one ulfsark exists
	  if ( (cMyCulture == cCultureNorse) && ( kbUnitCount(cMyID, cUnitTypeUlfsark, cUnitStateAlive) == 1 ) 
		 && (aiPlanGetLocation(gLandExplorePlanID) != cInvalidVector) )
	  {
		 location = aiPlanGetLocation(gLandExplorePlanID);
		 aiPlanSetBaseID(planID, -1);
		 aiPlanSetVariableInt(planID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(location));
	  }
	  else
		 aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));   // Move this back up to block of aiPlanSets if we kill the hack
	  // end hack

	  aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 15.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 100.0);

	  aiPlanSetActive(planID);
   }
}

//==============================================================================
// RULE: emergencyHouses
//==============================================================================
rule emergencyHouses
   minInterval 9
   inactive
{
    int houseProtoID = cUnitTypeHouse;
    if (cMyCulture == cCultureAtlantean)
    {
	   houseProtoID = cUnitTypeManor;
    }
    int currentHouses = kbUnitCount(cMyID, houseProtoID, cUnitStateAliveOrBuilding);
    currentHouses = currentHouses + aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, houseProtoID);
    if(gMaxHouseTracker-currentHouses > 2)
    {
	//aiCommsSendStatement(cMyID, cAICommPromptHelpHome, -1);

	int missingHouses = (gMaxHouseTracker-currentHouses)-1;
	createSimpleBuildPlan(houseProtoID, missingHouses, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), missingHouses);

		xsSetRuleMinIntervalSelf(40);
    }else{
		xsSetRuleMinIntervalSelf(9);
    }
    if(currentHouses > gMaxHouseTracker && currentHouses <= kbGetBuildLimit(cMyID,houseProtoID))
    {
	gMaxHouseTracker = currentHouses;
    }
}

//==============================================================================
// ORDER: aiTaskBuildSettlement  [?]
//==============================================================================
void aiTaskBuildSettlement(void)
{
   int tcID = -1;	int builderID = -1;

   if(kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateBuilding) < 1)
   {
	tcID = findClosestRelTo(kbBaseGetMainID(cMyID), 0, cUnitStateAlive, cUnitTypeAbstractSettlement);
	builderID = findClosestRelTo(tcID, cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0));
	vector location = kbUnitGetPosition(tcID);
	aiTaskUnitBuild(builderID,cUnitTypeSettlementLevel1,location);
   }
   if(kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateBuilding) > 0)
   {
	tcID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractSettlement);
	builderID = findClosestRelTo(tcID, cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0));
	aiTaskUnitBuild(builderID,cUnitTypeSettlementLevel1,location);
   }
}

//==============================================================================
// RULE: buildSettlements (NEW)
//==============================================================================
rule buildSettlements
   minInterval 8
   inactive
{
   //No unclaimed Settlements left?
   if (kbUnitCount(0, cUnitTypeSettlement, cUnitStateAny) < 1)
   {
	  return;	//No Foundation!
   }

   //Figure out if we have any active BuildSettlements.
   int numberBuildSettlementGoals=aiGoalGetNumber(cGoalPlanGoalTypeBuildSettlement, cPlanStateWorking, true);
   int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);
   int numberSettlementsPlanned = numberSettlements + numberBuildSettlementGoals;

   if (gNomadMap && numberSettlements < 1 && kbGetAge() <= cAge2)
   {
	return;		// Skip if we're still in nomad startup mode.
   }

   //If we're on Easy and we have 3 settlements, go away.
   if(cvMasterDifficulty <= cDifficultyEasy && numberSettlementsPlanned >= 3)
   {
	return;
   }

   //Look at what our opponent does!
   int mhpSettlements=kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);

   //We usually want one more than our opponent - no more, no less.
   int MaxInProgress = (mhpSettlements-numberSettlementsPlanned)+1;
   if (MaxInProgress < 1)
   {
	if(kbGetAge() < cAge4)
	{
		return;			//Done! For now, we have what we want and shouldn't invest more.
	}else{
		MaxInProgress = 1;	//In age4 allow one more anyways...
	}
   }
   if (aiGetGameMode() == cGameModeDeathmatch)
   {
	if (kbUnitCount(cMyID, cUnitTypeMilitaryBuilding, cUnitStateAlive) <= 2)
	{
		return;			//Military first please!
	}else{
		if (kbGetAge() < cAge4)
		{
			if(MaxInProgress > 1)
			{
				MaxInProgress = 1;
			}
		}else{
			if(MaxInProgress > 4)
			{
				MaxInProgress = 4;
			}
		}
	}

   }else{
		//Non DM Caps.
		if (kbGetAge() < cAge4)
		{
			if(MaxInProgress > 2)
			{
				MaxInProgress = 2;
			}
		}else{
			if(MaxInProgress > 3)
			{
				MaxInProgress = 3;
			}
		}
   }
   if (numberBuildSettlementGoals > MaxInProgress)
   {
		return;		// We have all that we need!
   }
   if (numberSettlementsPlanned >= cvMaxSettlements)
   {
		return;		// Don't go over script limit.
   }
   if (numberSettlements > 2 && cvMasterDifficulty <= cDifficultyModerate)	//Wait for Pop Cap?
   {
	int popCapBuffer=10;
	popCapBuffer = popCapBuffer + ((-1*cvRushBoomSlider)+1)*20;  // Add 0 for extreme rush, 40 for extreme boom
	int currentPopNeeds=kbGetPop()-15;
	int adjustedPopCap=getSoftPopCap()-popCapBuffer;

	//Don't do this unless we need the pop.
	if (currentPopNeeds < adjustedPopCap)
	{
		return;
	}
   }
   //Don't get too many more than our human allies.
   int largestAllyCount=-1;
   int smallestAllyCount=99999;
   for (i=1; < cNumberPlayers)
   {
	  if (i == cMyID)
		 continue;
	  if(kbIsPlayerAlly(i) == false)
		 continue;
	  if(kbIsPlayerHuman(i) == false)   // MK:  Only worry about humans, no sense holding back for confused AI ally
		 continue;
	  if(kbIsPlayerResigned(i) || kbHasPlayerLost(i))
		 continue;
	  int count=getNumberUnits(cUnitTypeAbstractSettlement, i, cUnitStateAliveOrBuilding);
	  if(count > largestAllyCount)
		 largestAllyCount=count;
	  if(count < smallestAllyCount)
		 smallestAllyCount=count;
   }
   //Never have more than 2 more settlements than any human ally.
   int difference=numberSettlementsPlanned-largestAllyCount;
   if (difference > 2 && largestAllyCount >= 0)	// If ally exists and we have more than 2 more...quit
   {
		return;
   }
   if (numberSettlementsPlanned >= 3 && smallestAllyCount < 3)	//Don't steal essential tc's from human allies!
   {
		return;
   }
   //See if there is another human on my team.
   bool haveHumanTeammate=false;
   for (i=1; < cNumberPlayers)
   {
	  if(i == cMyID)
		 continue;
	  //Find the human player
	  if (kbIsPlayerHuman(i) != true)
		 continue;

	  //This player is a human ally and not resigned.
	  if ((kbIsPlayerAlly(i) == true) && (kbIsPlayerResigned(i) == false))
	  {
		 haveHumanTeammate=true;
		 break;
	  }
   }
   if(haveHumanTeammate == true)
   {
	  if (kbGetAge() == cAge2)
	  {
		 if (numberSettlementsPlanned > 3)
			return;
	  }
	  else if (kbGetAge() == cAge3)
	  {
		 if (numberSettlementsPlanned > 4)
			return;
	  }
	  else if (kbGetAge() == cAge4)
	  {
		 if (numberSettlementsPlanned > 5)
			return;
	  }
   }

   printEcho("Creating another settlement goal.");
   int numBuilders = 3;
   if (cMyCulture == cCultureAtlantean)
   {
	  numBuilders = 1;
   }
   if ((cMyCulture == cCultureEgyptian) && (aiGetGameMode() != cGameModeLightning) && (numberSettlements < 2))
   {
	  numBuilders = 7;
   }
   if ((kbGetAge() > cAge2) && (aiGetGameMode() != cGameModeLightning))
   {
	numBuilders = 3+aiRandInt(4);
	if (cMyCulture == cCultureAtlantean)
	{
	    numBuilders = 1+aiRandInt(2);
	}
   }

   int mySettlementWeight = 0;
   if (mhpSettlements >= 2 && kbGetAge() <= cAge2)
   {
		mySettlementWeight = 1;		//High prio for early tc!
   }

   if(kbGetAge() > cAge2 || mySettlementWeight > 0 || aiGetGameMode() == cGameModeDeathmatch)	//Top Priority?
   {
	createBuildSettlementGoal("BuildSettlement", kbGetAge(), -1, kbBaseGetMainID(cMyID), numBuilders, getBuilderType(), true, 100);
   }else{
      if(kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAlive) >= 8*numberSettlements)	//Enough food production?
      {
	createBuildSettlementGoal("BuildSettlement", kbGetAge(), -1, kbBaseGetMainID(cMyID), numBuilders, getBuilderType(), true, 95);
      }else{
	//Else, do it, pri 85 to be below farming at 90.
	createBuildSettlementGoal("BuildSettlement", kbGetAge(), -1, kbBaseGetMainID(cMyID), numBuilders, getBuilderType(), true, 85);
      }
   }
}

//==============================================================================
// RULE: claimRemoteSettlement
//==============================================================================
rule claimRemoteSettlement
minInterval 56	//starts in cAge3
inactive
{
   if (kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAlive) < 1)
   {
		return;
   }
   int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);
   if (numberSettlements+1 > cvMaxSettlements)
   {
		return;		// Don't go over script limit.
   }

   int newSettlementID = findIsolatedSettlement();
   if(
	newSettlementID == glastRemoteSettlementTargetID	//example: -1
	||
	(
	    gRemoteSettlementBuildPlan >= 0
	    &&
	    aiPlanGetState(gRemoteSettlementBuildPlan) != cPlanStateDone
	    &&
	    aiPlanGetState(gRemoteSettlementBuildPlan) != cPlanStateFailed
	)
     )
   {
		return;
   }else{
	//clean-up old plans...
	aiPlanDestroy(gRemoteSettlementBuildPlan);
	aiPlanDestroy(gRemoteSettlementTransportPlan);
	aiPlanDestroy(gRemoteSettlementExplorePlan);
	gRemoteSettlementBuildPlan = -1;

	//and then make new ones!
	int baseID = kbBaseGetMainID(cMyID);
	vector baseLoc = kbBaseGetLocation(cMyID, baseID);
	int startAreaID = kbAreaGetIDByPosition(baseLoc);
	vector targetLoc = kbUnitGetPosition(newSettlementID);
	int goalAreaID = kbAreaGetIDByPosition(targetLoc);

	gRemoteSettlementTransportPlan = aiPlanCreate("Remote Settlement Transport", cPlanTransport);
	aiPlanSetDesiredPriority(gRemoteSettlementTransportPlan, 80);
	aiPlanSetBaseID(gRemoteSettlementTransportPlan, baseID);
	aiPlanSetVariableInt(gRemoteSettlementTransportPlan, cTransportPlanPathType, 0, 1);
	aiPlanSetVariableInt(gRemoteSettlementTransportPlan, cTransportPlanGatherArea, 0, startAreaID);
	aiPlanSetVariableInt(gRemoteSettlementTransportPlan, cTransportPlanTargetArea, 0, goalAreaID);
	aiPlanSetInitialPosition(gRemoteSettlementTransportPlan, kbAreaGetCenter(startAreaID));
	aiPlanSetVariableInt(gRemoteSettlementTransportPlan, cTransportPlanTransportTypeID, 0, cUnitTypeTransport);
	aiPlanSetVariableBool(gRemoteSettlementTransportPlan, cTransportPlanPersistent, 0, false);
	aiPlanAddUnitType(gRemoteSettlementTransportPlan, cUnitTypeTransport, 1, 1, 1);
	aiPlanSetActive(gRemoteSettlementTransportPlan);

	int numBuilders = 2;
	if(cMyCulture == cCultureAtlantean) {
	    numBuilders = 1;
	}else
	if(cMyCulture == cCultureEgyptian) {
	    numBuilders = 3;
	}
	aiPlanAddUnitType(gRemoteSettlementTransportPlan, getBuilderType(), numBuilders, numBuilders, numBuilders);

	gRemoteSettlementBuildPlan = aiPlanCreate("Build Remote" + kbGetUnitTypeName(cUnitTypeSettlementLevel1), cPlanBuild);
	if (gRemoteSettlementBuildPlan < 0) {return;}
	aiPlanSetVariableInt(gRemoteSettlementBuildPlan, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
	aiPlanSetDesiredPriority(gRemoteSettlementBuildPlan, 100);
	aiPlanSetEconomy(gRemoteSettlementBuildPlan, true);
	aiPlanSetEscrowID(gRemoteSettlementBuildPlan, cEconomyEscrowID);
	aiPlanAddUnitType(gRemoteSettlementBuildPlan, getBuilderType(), numBuilders, numBuilders, numBuilders);
	aiPlanSetInitialPosition(gRemoteSettlementBuildPlan, targetLoc);
	aiPlanSetVariableVector(gRemoteSettlementBuildPlan, cBuildPlanSettlementPlacementPoint, 0, targetLoc);
	aiPlanSetActive(gRemoteSettlementBuildPlan);

	gRemoteSettlementExplorePlan = aiPlanCreate("Explore Remote", cPlanExplore);
	aiPlanAddUnitType(gRemoteSettlementExplorePlan, getBuilderType(), 0, 0, numBuilders);
	aiPlanSetInitialPosition(gRemoteSettlementExplorePlan, targetLoc);
	aiPlanAddWaypoint(gRemoteSettlementExplorePlan, targetLoc);
	aiPlanSetVariableBool(gRemoteSettlementExplorePlan, cExplorePlanDoLoops, 0, false);
	aiPlanSetVariableBool(gRemoteSettlementExplorePlan, cExplorePlanReExploreAreas, 0, false);
	    aiPlanSetVariableVector(gRemoteSettlementExplorePlan, cExplorePlanQuitWhenPointIsVisiblePt, 0, targetLoc);
	    aiPlanSetVariableBool(gRemoteSettlementExplorePlan, cExplorePlanQuitWhenPointIsVisible, 0, true);
	aiPlanSetDesiredPriority(gRemoteSettlementExplorePlan, 3);
	aiPlanSetActive(gRemoteSettlementExplorePlan);
   }
}

//==============================================================================
// RULE: opportunities
//==============================================================================
rule opportunities
   minInterval 31
   inactive
   runImmediately
{
   float currentFood=kbResourceGet(cResourceFood);
   float currentWood=kbResourceGet(cResourceWood);
   float currentGold=kbResourceGet(cResourceGold);
   //float currentFavor=kbResourceGet(cResourceFavor);
   if (currentFood > 200 && currentGold > 100 && currentWood > 200 &&
	(
	kbGetTechStatus(cTechHandAxe) < cTechStatusResearching
	||
	kbGetTechStatus(cTechPickaxe) < cTechStatusResearching
	)
      )
	{
	  getNextGathererUpgrade();
	}
   else if (currentFood > 500 && currentGold > 300 && currentWood > 300)
   {
	  getNextGathererUpgrade();
   }
}

//==============================================================================
// RULE: randomUpgrader
//
//==============================================================================
rule randomUpgrader
   minInterval 30
   active
   runImmediately
{
   //Can we get a Titan?
   if (
	kbGetTechStatus(cTechSecretsoftheTitans) > cTechStatusUnobtainable
	&&
	kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching
      )
   {
	return;		//get that upgrade first!
   }
/*
   if ((gAge4MinorGod == cTechAge4Hephaestus) && (kbGetTechStatus(cTechForgeofOlympus) <= cTechStatusResearching))
	return;
*/
   static int id=0;
   //Don't do anything until we have some pop.
   int maxPop=kbGetPopCap();
   if (maxPop < 120)		//was 130
	  return;
   //If we still have some pop slots to fill, quit.
   int currentPop=kbGetPop();
   if ((maxPop-currentPop) > 20)
	  return;

   //If we have lots of resources, get a random upgrade.
   float currentFood=kbResourceGet(cResourceFood);
   float currentWood=kbResourceGet(cResourceWood);
   float currentGold=kbResourceGet(cResourceGold);
   float currentFavor=kbResourceGet(cResourceFavor);
   if ((currentFood > 1500) && (currentWood > 1500) && (currentGold > 1500))
   {
	  int upgradeTechID=kbTechTreeGetRandomUnitUpgrade();
	  //Dont make another plan if we already have one.
	  if (aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, upgradeTechID) != -1)
		 return;

	  //Make plan to get this upgrade.
	   int planID=aiPlanCreate("nextRandomUpgrade - "+id, cPlanProgression);
	   if (planID < 0)
		 return;
	  
	   aiPlanSetVariableInt(planID, cProgressionPlanGoalTechID, 0, upgradeTechID);
	   aiPlanSetDesiredPriority(planID, 35);		//was 25
	   aiPlanSetEscrowID(planID, cEconomyEscrowID);
	   aiPlanSetActive(planID);
	  printEcho("randomUpgrader: successful in creating a progression to "+kbGetTechName(upgradeTechID));
	   id++;
   }
}

//==============================================================================
// buildGarden
//==============================================================================
rule buildGarden
   minInterval 11
   active
{
	if(cMyCulture != cCultureChinese)
	{
		xsDisableSelf();
		return;
	}
   int gardenProtoID = cUnitTypeGarden;

   //If we have any gardens that are building, skip.
   if (kbUnitCount(cMyID, gardenProtoID, cUnitStateBuilding) > 0)
	  return;
   
	//If we already have gGardenBuildLimit gardens, we shouldn't build anymore.
   if (gGardenBuildLimit != -1)
   {
	  int numberOfGardens = kbUnitCount(cMyID, gardenProtoID, cUnitStateAliveOrBuilding);
	  if (numberOfGardens >= gGardenBuildLimit)
		 return;
   }
   //If we already have a garden plan active, skip.
   if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, gardenProtoID) > -1)
	  return;

   //Over time, we will find out what areas are good and bad to build in.  Use that info here, because we want to protect gardens.
	int planID = aiPlanCreate("BuildGarden", cPlanBuild);
   if (planID >= 0)
   {
	  aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, gardenProtoID);
	  aiPlanSetVariableBool(planID, cBuildPlanInfluenceAtBuilderPosition, 0, true);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionValue, 0, 100.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluenceBuilderPositionDistance, 0, 5.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanRandomBPValue, 0, 0.99);
	  aiPlanSetDesiredPriority(planID, 100);

		int builderTypeID = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder,0);
	  if (cMyCulture == cCultureNorse)
		 builderTypeID = cUnitTypeUlfsark;   // Exact match for land scout, so build plan can steal scout

		aiPlanAddUnitType(planID, builderTypeID, 1, 1, 1);
	  aiPlanSetEscrowID(planID, cEconomyEscrowID);

	  vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));

	  float x = xsVectorGetX(backVector);
	  float z = xsVectorGetZ(backVector);
	  x = x * 40.0;
	  z = z * 40.0;

	  backVector = xsVectorSetX(backVector, x);
	  backVector = xsVectorSetZ(backVector, z);
	  backVector = xsVectorSetY(backVector, 0.0);
	  vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	  int areaGroup1 = kbAreaGroupGetIDByPosition(location);   // Base area group
	  location = location + backVector;
	  int areaGroup2 = kbAreaGroupGetIDByPosition(location);   // Back vector area group
	  if (areaGroup1 != areaGroup2)
		 location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));   // Reset to area center if back is in wrong area group

	  aiPlanSetVariableVector(planID, cBuildPlanInfluencePosition, 0, location);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionDistance, 0, 20.0);
	  aiPlanSetVariableFloat(planID, cBuildPlanInfluencePositionValue, 0, 1.0);

	  aiPlanSetActive(planID);
   }
}

//==================================================================================================
// dwarfGatherGold - ensures that all dwarves go to gold (except in the case of Thor dwarf build)
//==================================================================================================
rule dwarfGatherGold
   minInterval 10
   active
{

   if (cMyCulture != cCultureNorse)
   	xsDisableSelf();

   int dwarfCount=kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);

   if (dwarfCount < 1)
	return;
  
   if (dwarfCount <= 2 && cMyCiv == cCivThor)
	return;

   static int goldPlanID=-1;
   if (goldPlanID < 0)
       goldPlanID = aiPlanGetIDByTypeAndVariableType(cPlanGather, cGatherPlanResourceType, cResourceGold);

   if (goldPlanID < 0)
   {
	printEcho("Gold Plan ID not found");
	return;
   }
   else
   {
	int absVilNum = aiPlanGetNumberUnits(goldPlanID, cUnitTypeAbstractVillager);
	int norseVilNum = aiPlanGetNumberUnits(goldPlanID, cUnitTypeVillagerNorse);
	if (absVilNum >= dwarfCount)
	{
		aiPlanAddUnitType(goldPlanID, cUnitTypeDwarf, dwarfCount, dwarfCount, dwarfCount);
		aiPlanAddUnitType(goldPlanID, cUnitTypeAbstractVillager, norseVilNum - (dwarfCount - (absVilNum - norseVilNum)), norseVilNum - (dwarfCount - (absVilNum - norseVilNum)), norseVilNum - (dwarfCount - (absVilNum - norseVilNum)));
	}
	else
	{
		aiPlanAddUnitType(goldPlanID, cUnitTypeDwarf, absVilNum, absVilNum, absVilNum);
		aiPlanAddUnitType(goldPlanID, cUnitTypeAbstractVillager, 1, absVilNum, absVilNum);
	}
   }
}

//==============================================================================
// chooseGardenResource
// Simple logic, should favour favor over the others as the Chinese can't get 
// favor from another source.
//==============================================================================
rule chooseGardenResource
minInterval 60
inactive
{
	// We want mythunits
	if(kbUnitCount(cMyID)==0)
	{
		printEcho("Setting gardens to: Favor");
		kbSetGardenResource(cResourceFavor);
		return;
	}
	
	int res		= cResourceGold;	//default
	string resname	= "Gold";
	int need	= aiGetCurrentResourceNeed(res);
	if(need < aiGetCurrentResourceNeed(cResourceWood) || kbResourceGet(cResourceWood) < 50)
	{
		res	= cResourceWood;
		resname	= "Wood";
		need	= aiGetCurrentResourceNeed(res);
	}
	if(need < aiGetCurrentResourceNeed(cResourceFood) || kbResourceGet(cResourceFood) < 50)
	{
		res	= cResourceFood;
		resname	= "Food";
		need	= aiGetCurrentResourceNeed(res);
	}
	if(need < aiGetCurrentResourceNeed(cResourceFavor) || kbResourceGet(cResourceFavor) < 10)
	{
		res	= cResourceFavor;
		resname	= "Favor";
	}
	printEcho("Setting gardens to: " + resname);
	kbSetGardenResource(res);
}
