//=============================================================================
// aiModSupport.xs
// obviously made for other MODS by JeHathor
//=============================================================================
extern String gModName = "";

int modBuilderType=-1;
int modGathererType=-1;
int modFortType=-1;

int modFoodDropsiteType=-1;
int modWoodDropsiteType=-1;
int modGoldDropsiteType=-1;

int modAdvanceBuildingAge1=cUnitTypeTemple;
int modAdvanceBuildingAge2=cUnitTypeArmory;
int modAdvanceBuildingAge3=cUnitTypeMarket;

//=============================================================================
// The Return Of The Gods
// (The following constants may change!)
//=============================================================================
extern const int modTechAge1Aztec = 626;
//-----------------------------------------------------------------------------
extern const int modTechAge1Tezca = 627;
extern const int modTechAge1Huitz = 628;
extern const int modTechAge1Quetz = 629;
//-----------------------------------------------------------------------------
extern const int modTechAge2Huehue = 646;
extern const int modTechAge2Coyol = 647;
extern const int modTechAge2Xol = 648;
//-----------------------------------------------------------------------------
extern const int modTechAge3Mayahuel = 649;
extern const int modTechAge3Xipe = 650;
extern const int modTechAge3Mict = 651;
//-----------------------------------------------------------------------------
extern const int modTechAge4Tlaloc = 652;
extern const int modTechAge4Coat = 653;
extern const int modTechAge4Ton = 654;
//-----------------------------------------------------------------------------
extern const int modUnitTypeVillagerAztec = 935;
extern const int modUnitTypeTlatoaniQuetz = 937;
extern const int modUnitTypeTlatoani = 938;
extern const int modUnitTypePrisonerSmall = 939;
extern const int modUnitTypeSpearmanAztec = 941;
extern const int modUnitTypeRunnerAztec = 943;
extern const int modUnitTypeGuildMeso = 963;
extern const int modUnitTypeMarketMeso = 1059;
extern const int modUnitTypeQuetzalBird = 1062;
//-----------------------------------------------------------------------------
extern const int modTechCoatenpantli = 706;
//-----------------------------------------------------------------------------
extern const int modPowerHandOfFire = 658;
extern const int modPowerJaguarNight = 659;
extern const int modPowerWarriorBlessing = 660;
extern const int modPowerAmoxForest = 661;
extern const int modPowerDeathsAwaken = 662;
extern const int modPowerEpidemic = 663;
extern const int modPowerFireStrike = 664;
extern const int modPowerDecoys = 665;
extern const int modPowerAbundance = 666;
extern const int modPowerDeathFromAbove = 667;
extern const int modPowerTlalocan = 668;
extern const int modPowerVolcanoRotG = 669;
//=============================================================================
// Age of Star Wars - Reborn
//=============================================================================
extern const int modTechAge1CIS = 617;
extern const int modTechAge1REP = 618;
extern const int modTechAge1ALL = 619;
extern const int modTechAge1IMP = 620;
//-----------------------------------------------------------------------------
extern const int modUnitTypeStarCitizen = 948;
//-----------------------------------------------------------------------------
extern const int modBuildingSupplyStation = 949;
extern const int modBuildingFuelPump = 954;
//=============================================================================
// Norse Retold
//=============================================================================
extern const int modUnitTypeGreatHall = 935;
extern const int modUnitTypeGodi = 936;
//=============================================================================
// Heroes of Mythology  (Iko's Mod)
//=============================================================================
extern const int modUnitTypeEarthPassage = 936;
//=============================================================================
rule delayedInitAztec
minInterval 1
inactive
{
   if (kbGetTechStatus(modTechAge1Aztec) < cTechStatusActive)
   {
      return;
   }
   kbTechTreeAddMinorGodPref( gAge2MinorGod );
   kbTechTreeAddMinorGodPref( gAge3MinorGod );
   kbTechTreeAddMinorGodPref( gAge4MinorGod );

   xsDisableSelf();
}

//=============================================================================
void researchMajorGod()
{
	//Always overwrite if there is a pre-selection!
	if(cvCivSelectorTech > 0)
	{
		gAge1MajorGod = cvCivSelectorTech;
	}

	int researcher = findUnit( cMyID, cUnitStateAny, cUnitTypeBuilding );

	if ( researcher < 0 )	//nomad
	{
		researcher = findUnit( cMyID, cUnitStateAny, cUnitTypeAbstractVillager );
	}
	aiTaskUnitResearch( researcher, gAge1MajorGod );
}

//=============================================================================
void detectMods()
{
    if(cMyCiv == cCivThor)		//Assign this first!
    {
	modAdvanceBuildingAge2=cUnitTypeDwarfFoundry;
    }

    //Check for a unit that is unique to the mod.
    if(kbGetProtoUnitID("Tlatoani") == modUnitTypeTlatoani)	//Is this ROTG?
    {
	if ( kbGetCiv() == cCivShennong )
	{
	    switch( aiRandInt(4) )		//Choose a random major god.
	    {
		case 0: {
			gAge1MajorGod = cTechAge1Shennong;
			printEcho( "gAge1MajorGod => Shennong" );
			break;
		}
		case 1: {
			gAge1MajorGod = modTechAge1Huitz;
			printEcho( "gAge1MajorGod => Huitz" );
			break;
		}
		case 2: {
			gAge1MajorGod = modTechAge1Tezca;
			printEcho( "gAge1MajorGod => Tezca" );
			break;
		}
		case 3: {
			gAge1MajorGod = modTechAge1Quetz;
			printEcho( "gAge1MajorGod => Quetz" );
			break;
		}
	    }
	    //Our decision has been made.
	    if(gAge1MajorGod != cTechAge1Shennong)
	    {
			gNewCivMod = true;
			gModName = "ROTG-Aztec";
			gModDelayStart = true;
			xsEnableRule("delayedInitAztec");
	    }
		researchMajorGod();		//Select!
	}
    }else if(kbGetProtoUnitID("Godi") == modUnitTypeGodi)		//Is this Norse Retold?
    {
		gModName = "Retold";
		xsEnableRule("buildNorseGreatHall");

    }else if(kbGetProtoUnitID("Earth Passage") == modUnitTypeEarthPassage)	//Is this HoM?
    {
		gModName = "HoM";

    }else if(kbGetProtoUnitID("Star Citizen") == modUnitTypeStarCitizen)	//Is this AOSW?
    {
	    switch( aiRandInt(4) )		//Choose a random major god.
	    {
		case 0: {
			gAge1MajorGod = modTechAge1CIS;
			printEcho( "gAge1MajorGod => Separatists" );
			break;
		}
		case 1: {
			gAge1MajorGod = modTechAge1REP;
			printEcho( "gAge1MajorGod => Galactic Republic" );
			break;
		}
		case 2: {
			gAge1MajorGod = modTechAge1ALL;
			printEcho( "gAge1MajorGod => Rebel Alliance" );
			break;
		}
		case 3: {
			gAge1MajorGod = modTechAge1IMP;
			printEcho( "gAge1MajorGod => Galactic Empire" );
			break;
		}
	    }
		gNewCivMod = true;
		gModName = "AOSW-Standard";
		researchMajorGod();		//Select!
    }else{
		gNewCivMod = false;	//No mods detected.
    }
}

//=============================================================================
vector assignMinorGods()	//age2, age3, age4
{
    if(gModName == "ROTG-Aztec")
    {
	if(gAge1MajorGod == modTechAge1Huitz)
	{
	    if(aiRandInt(2)==1)		// Age2
	    {
		gAge2MinorGod=modTechAge2Xol;
	    }else{
		gAge2MinorGod=modTechAge2Coyol;
	    }
	    if(aiRandInt(2)==1)		// Age3
	    {
		gAge3MinorGod=modTechAge3Mayahuel;
	    }else{
		gAge3MinorGod=modTechAge3Mict;
	    }
	    if(aiRandInt(2)==1)		// Age4
	    {
		gAge4MinorGod=modTechAge4Coat;
	    }else{
		gAge4MinorGod=modTechAge4Tlaloc;
	    }

	    //Override with water related gods on a watermap
	    if(gTransportMap==true)
	    {
		gAge2MinorGod=modTechAge2Xol;
		gAge4MinorGod=modTechAge4Tlaloc;
	    }
	}
	if(gAge1MajorGod == modTechAge1Tezca)
	{
	    if(aiRandInt(2)==1)		// Age2
	    {
		gAge2MinorGod=modTechAge2Huehue;
	    }else{
		gAge2MinorGod=modTechAge2Xol;
	    }
	    if(aiRandInt(2)==1)		// Age3
	    {
		gAge3MinorGod=modTechAge3Xipe;
	    }else{
		gAge3MinorGod=modTechAge3Mict;
	    }
	    if(aiRandInt(2)==1)		// Age4
	    {
		gAge4MinorGod=modTechAge4Ton;
	    }else{
		gAge4MinorGod=modTechAge4Tlaloc;
	    }

	    //Override with water related gods on a watermap
	    if(gTransportMap==true)
	    {
		gAge2MinorGod=modTechAge2Xol;
		gAge3MinorGod=modTechAge3Xipe;
		gAge4MinorGod=modTechAge4Tlaloc;
	    }
	}
	if(gAge1MajorGod == modTechAge1Quetz)
	{
	    if(aiRandInt(2)==1)		// Age2
	    {
		gAge2MinorGod=modTechAge2Huehue;
	    }else{
		gAge2MinorGod=modTechAge2Coyol;
	    }
	    if(aiRandInt(2)==1)		// Age3
	    {
		gAge3MinorGod=modTechAge3Mayahuel;
	    }else{
		gAge3MinorGod=modTechAge3Xipe;
	    }
	    if(aiRandInt(2)==1)		// Age4
	    {
		gAge4MinorGod=modTechAge4Ton;
	    }else{
		gAge4MinorGod=modTechAge4Tlaloc;
	    }

	    //Override with water related gods on a watermap
	    if(gTransportMap==true)
	    {
		gAge3MinorGod=modTechAge3Xipe;
		gAge4MinorGod=modTechAge4Tlaloc;
	    }
	}
	printEcho( "ModGods:Player"+cMyID );
    }
    return(xsVectorSet(gAge2MinorGod,gAge3MinorGod,gAge4MinorGod));
}

//=============================================================================
void initMod()
{
   if(gModName == "AOSW-Standard")
   {
	cvOkToBuildWalls = false;	//No Walls.

	modBuilderType = modUnitTypeStarCitizen;
	modGathererType = modUnitTypeStarCitizen;
	modFoodDropsiteType = modBuildingSupplyStation;
	modWoodDropsiteType = modBuildingFuelPump;
	modGoldDropsiteType = modBuildingSupplyStation;

	//Dropsites
	kbTechTreeClearDropsiteUnitIDsByResource(cResourceFood);
	kbTechTreeClearDropsiteUnitIDsByResource(cResourceWood);
	kbTechTreeClearDropsiteUnitIDsByResource(cResourceGold);
	kbTechTreeAddDropsiteUnitIDByResource(cResourceFood,modFoodDropsiteType);
	kbTechTreeAddDropsiteUnitIDByResource(cResourceWood,modWoodDropsiteType);
	kbTechTreeAddDropsiteUnitIDByResource(cResourceGold,modGoldDropsiteType);

	xsEnableRule("manualDropsitePlacement");
   }
   if(gModName == "ROTG-Aztec")
   {
	gLandScout=modUnitTypeRunnerAztec;
	gWaterScout=cUnitTypeFishingShipGreek;
	gAirScout=modUnitTypeQuetzalBird;
	modBuilderType=modUnitTypeVillagerAztec;
	modGathererType=modUnitTypeVillagerAztec;
	modFortType = cUnitTypeHillFort;
	modFoodDropsiteType = cUnitTypeGranary;
	modWoodDropsiteType = cUnitTypeStorehouse;
	modGoldDropsiteType = cUnitTypeStorehouse;
	modAdvanceBuildingAge1=cUnitTypeTemple;
	modAdvanceBuildingAge2=modUnitTypeGuildMeso;
	modAdvanceBuildingAge3=cUnitTypeMarket;
	if(gAge1MajorGod == modTechAge1Quetz)
	{
		//gGatherRelicType=modUnitTypeTlatoaniQuetz;
	}else{
		//gGatherRelicType=modUnitTypeTlatoani;
	}
	//Create the Aztec scout plans.
	int exploreID=-1;
	exploreID = aiPlanCreate("Explore_Special_Aztec", cPlanExplore);
	if (exploreID >= 0)
	{
	    aiPlanAddUnitType(exploreID, gLandScout, 0, 1, 1);
	    aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
	    aiPlanSetActive(exploreID);
	}
	// Make sure we always have at least 1 Scout
	int AztecScoutMaintainPlanID = createSimpleMaintainPlan(gLandScout, 1, false, kbBaseGetMainID(cMyID));
	aiSetAutoFavorGather(false);
	//Dropsites
	kbTechTreeClearDropsiteUnitIDsByResource(cResourceFood);
	kbTechTreeClearDropsiteUnitIDsByResource(cResourceWood);
	kbTechTreeClearDropsiteUnitIDsByResource(cResourceGold);
	kbTechTreeAddDropsiteUnitIDByResource(cResourceFood,modFoodDropsiteType);
	kbTechTreeAddDropsiteUnitIDByResource(cResourceWood,modWoodDropsiteType);
	kbTechTreeAddDropsiteUnitIDByResource(cResourceGold,modGoldDropsiteType);

	xsEnableRule("manualDropsitePlacement");
	//xsEnableRule("removeUnnecessaryDropsites");
	xsEnableRule("buildAztecBarracks");
	xsEnableRule("buildAztecQuarters");
	xsEnableRule("buildAztecTianguis");
	xsEnableRule("makeAztecPrisoners");	//Favor for Calmecac and MythUnits...
   }

   // Default to random minor god choices, override below if needed.
   vector godChoice = assignMinorGods();
   gAge2MinorGod = xsVectorGetX(godChoice);
   gAge3MinorGod = xsVectorGetY(godChoice);
   gAge4MinorGod = xsVectorGetZ(godChoice);

    // Control variable overrides.
    if (cvAge2GodChoice != -1)
	gAge2MinorGod = cvAge2GodChoice;
    if (cvAge3GodChoice != -1)
	gAge3MinorGod = cvAge3GodChoice;
    if (cvAge4GodChoice != -1)
	gAge4MinorGod = cvAge4GodChoice;
}

//=============================================================================
bool setModUpgradePrefs(int goalID=-1)
{
	if(goalID < 0)
	{
		return(false);
	}

	if(gModName == "ROTG-Aztec")
	{
		aiPlanSetNumberVariableValues(goalID, cGoalPlanUpgradeBuilding, 7, true);
		aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 0, cUnitTypeGranary);
		aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 1, cUnitTypeStorehouse);
		aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 2, cUnitTypeSettlementLevel1);
		aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 3, cUnitTypeCounterBuilding);
		aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 4, cUnitTypeBarracks);
		aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 5, modUnitTypeGuildMeso);
		aiPlanSetVariableInt(goalID, cGoalPlanUpgradeBuilding, 6, cUnitTypeTemple);
	}
	return(true);
}

//=============================================================================
int getBuilderType()		//Unit that builds buildings.
{
    if(modBuilderType > 0)
    {
	return(modBuilderType);
    }else
    if(cMyCulture == cCultureChinese)
    {
	return(cUnitTypeVillagerChinese);
    }else
    if(cMyCulture == cCultureNorse)	// Any human soldier basically
    {
	return(cUnitTypeAbstractInfantry);
    }else{
	return(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0));
    }
}

//=============================================================================
int getGathererType(int index=0)	//NorseVills=0, NorseDwarfs=1
{
    if(modGathererType > 0)
    {
	return(modGathererType);
    }else
    if(cMyCulture == cCultureChinese)
    {
	return(cUnitTypeVillagerChinese);
    }else{
	return(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionGatherer, index));
    }
}

//=============================================================================
int getModFortType()
{
	return(modFortType);
}

//=============================================================================
int getModAgeUpBuildingType()
{
    if(kbGetAge()<=cAge1)
    {
	return(modAdvanceBuildingAge1);
    }else
    if(kbGetAge()<=cAge2)
    {
	return(modAdvanceBuildingAge2);
    }else
    if(kbGetAge()<=cAge3)
    {
	return(modAdvanceBuildingAge3);
    }
	return(-1);
}

//=============================================================================
int getModWallUpgradeID()
{
    if(gModName == "ROTG-Aztec")
    {
	if(kbGetTechStatus(cTechStoneWall) < cTechStatusResearching)
	{
		return(cTechStoneWall);
	}else
	if(kbGetTechStatus(modTechCoatenpantli) < cTechStatusResearching)
	{
		return(modTechCoatenpantli);
	}
    }
    return(-1);		//default
}

//=============================================================================
rule buildAztecBarracks
minInterval 15	//starts in cAge2
inactive
{
      if(kbGetAge() < cAge2)
      {
		return;
      }

      int buildingTypeID = cUnitTypeBarracks;
      int numBuilders = 1;

      if(kbUnitCount(cMyID, buildingTypeID, cUnitStateAliveOrBuilding) > 4)
      {
		return;
      }
      if(kbCanAffordUnit(buildingTypeID, cMilitaryEscrowID) == false)
      {
		return;
      }

	createSimpleBuildPlan(buildingTypeID, 1, 80, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 2);
	xsSetRuleMinIntervalSelf(40);
}

//==============================================================================
rule buildAztecQuarters
minInterval 15	//starts in cAge3
inactive
{
      if(kbGetAge() < cAge3)
      {
		return;
      }

      int buildingTypeID = cUnitTypeCounterBuilding;
      int numBuilders = 1;

      if(kbUnitCount(cMyID, buildingTypeID, cUnitStateAliveOrBuilding) > 3)
      {
		return;
      }
      if(kbCanAffordUnit(buildingTypeID, cMilitaryEscrowID) == false)
      {
		return;
      }

	createSimpleBuildPlan(buildingTypeID, 1, 80, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 2);
	xsSetRuleMinIntervalSelf(50);
}

//==============================================================================
rule buildAztecTianguis
minInterval 20	//starts in cAge2
inactive
{
      if(kbGetAge() < cAge2)
      {
		return;
      }

      int buildingTypeID = modUnitTypeMarketMeso;
      int numBuilders = 1;

      if(kbUnitCount(cMyID, buildingTypeID, cUnitStateAliveOrBuilding) > 0)
      {
		return;
      }
      if(kbCanAffordUnit(buildingTypeID, cEconomyEscrowID) == false)
      {
		return;
      }

	createSimpleBuildPlan(buildingTypeID, 1, 50, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	xsSetRuleMinIntervalSelf(90);
}

//==============================================================================
rule removeUnnecessaryDropsites
minInterval 5
inactive
{
   int unitTypeID = cUnitTypeDropsite;
   int numDropsites = kbUnitCount(cMyID, unitTypeID, cUnitStateAlive);

   if (numDropsites < 1)
	return;

	int dsQueryID=kbUnitQueryCreate("dropsiteQuery");
	kbUnitQuerySetPlayerID(dsQueryID, cMyID);
	kbUnitQuerySetUnitType(dsQueryID, unitTypeID);
	kbUnitQuerySetState(dsQueryID, cUnitStateAlive);

	kbUnitQueryResetResults(dsQueryID);
	int numberFound=kbUnitQueryExecute(dsQueryID);

   for (i=0; < numberFound)
   {
	int unitID = kbUnitQueryGetResult(dsQueryID, i);
	vector unitLoc = kbUnitGetPosition(unitID);

	int queryID = getUnitsAtLocQID(cMyID, cUnitStateBuilding, unitTypeID, unitLoc, 8);
	int badDropsites = kbUnitQueryExecute(queryID);
	for (j=0; < badDropsites)
	{
		int badDropsite = kbUnitQueryGetResult(queryID, j);
		if (badDropsite != -1)
		{
			if(
				kbUnitIsType(badDropsite, modFoodDropsiteType)
				||
				kbUnitIsType(badDropsite, modWoodDropsiteType)
				||
				kbUnitIsType(badDropsite, modGoldDropsiteType)
			  )
			{
				aiTaskUnitDelete(badDropsite);
			}
		}
	}
   }
}

//==============================================================================
rule manualDropsitePlacement
minInterval 8	//starts in cAge1
inactive
{
   //Helps new civs with dropsites since auto placement chooses the wrong builder.

   if(gModName == "ROTG-Aztec" || gModName == "AOSW-Standard")	//Skip if not needed.
   {
	int villagerID = findUnitRM(cMyID, cUnitStateAlive, modBuilderType, true);
	if(
		(kbUnitGetActionType(villagerID) != cActionGather)
		&&
		(kbUnitGetActionType(villagerID) != cActionWork)
		&&
		(kbUnitGetActionType(villagerID) != cActionHunting)
	  )
	{
		return;
	}
	int resourceID = findClosestRelTo(villagerID, 0, cUnitStateAny, cUnitTypeResource);

	int buildingTypeID = cUnitTypeDropsite;
	if(kbUnitIsType(resourceID, cUnitTypeFood)) {
		buildingTypeID = cUnitTypeGranary;
	}else if(kbUnitIsType(resourceID, cUnitTypeWood)) {
		buildingTypeID = cUnitTypeStorehouse;
	}else if(kbUnitIsType(resourceID, cUnitTypeGold)) {
		buildingTypeID = cUnitTypeStorehouse;
	}
	if(kbCanAffordUnit(buildingTypeID, cEconomyEscrowID)==false)
	{
		return;
	}
	int dropsiteID = findClosestRelTo(villagerID, 0, cUnitStateAliveOrBuilding, buildingTypeID);
	if(dropsiteID < 0)
	{
		dropsiteID = findUnit(cUnitTypeAbstractSettlement);
	}
	int wipDropsites = kbUnitCount(cMyID, buildingTypeID, cUnitStateBuilding);
	if(calcDistanceToUnit(dropsiteID,resourceID)>15 && wipDropsites<1)	//justified to build a new one
	{
		vector resourceLocation = kbUnitGetPosition(resourceID);
		vector villagerLocation = kbUnitGetPosition(villagerID);
		vector path = xsVectorNormalize(resourceLocation-villagerLocation)*4;
		vector buildPoint = resourceLocation-path;
		aiTaskUnitBuild(villagerID,buildingTypeID,buildPoint);
	}
   }
}

//==============================================================================
rule makeAztecPrisoners
minInterval 36	//starts in cAge2
inactive
{
    if(kbGetAge() < cAge2)
    {
		return;
    }

    int prisonerCount = kbUnitCount(cMyID, modUnitTypePrisonerSmall, cUnitStateAlive);
    if(prisonerCount > 1)
    {
		return;
    }
    int favorTarget = 0;

    int templeCount = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
    int tianguisCount = kbUnitCount(cMyID, modUnitTypeMarketMeso, cUnitStateAlive);
    if(templeCount > 0 && tianguisCount > 0)
    {
	if(kbGetAge() > cAge3)
	{
		favorTarget = 80;
	}else
	if(kbGetAge() > cAge2)
	{
		favorTarget = 40;
	}else
	if(kbGetAge() > cAge1)
	{
		favorTarget = 20;
	}
	if(kbResourceGet(cResourceFavor) < favorTarget)
	{
		if(kbCanAffordUnit(modUnitTypePrisonerSmall, cMilitaryEscrowID))
		{
		    int tianguisID = findUnit(cMyID, cUnitStateAlive, modUnitTypeMarketMeso);
		    if(tianguisID >= 0)
		    {
			aiTaskUnitTrain(tianguisID, modUnitTypePrisonerSmall);
			//Auto sacrifice in temple!
		    }
		}
	}
    }
    xsSetRuleMinIntervalSelf(kbProtoUnitGetTrainPoints(modUnitTypePrisonerSmall) + 5);
}

//==============================================================================
// injectModGodPowers
//==============================================================================
bool injectModGodPowers(int planID = -1, int powerProtoID = -1)
{
    int mainBaseID = kbBaseGetMainID(cMyID);
    vector mainBaseLocation = kbBaseGetLocation(cMyID, mainBaseID);
    int mhpID = aiGetMostHatedPlayerID();

	int queryID = -1;

    if(gModName == "ROTG-Aztec")
    {
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerAbundance) )
	{
		//todo
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerDecoys) )
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerFireStrike) )
	{
		queryID = kbUnitQueryCreate("FireStrikeEval");
		kbUnitQuerySetPlayerID(queryID, mhpID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
		kbUnitQuerySetState(queryID, cUnitStateAlive);
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, mhpID);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMilitary);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 6);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerJaguarNight) )
	{
		queryID = kbUnitQueryCreate("JaguarNightEval");
		kbUnitQuerySetPlayerID(queryID, mhpID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
		kbUnitQuerySetState(queryID, cUnitStateAlive);
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, mhpID);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMilitary);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 35.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerHandOfFire) )
	{
		queryID = kbUnitQueryCreate("HandOfFireEval");
		kbUnitQuerySetPlayerID(queryID, mhpID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
		kbUnitQuerySetState(queryID, cUnitStateAlive);
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, mhpID);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMilitary);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 25.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerWarriorBlessing) )
	{
		queryID = kbUnitQueryCreate("WarriorBlessingEval");
		kbUnitQuerySetPlayerID(queryID, cMyID);
		kbUnitQuerySetUnitType(queryID, modUnitTypeSpearmanAztec);
		kbUnitQuerySetState(queryID, cUnitStateAlive);
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, modUnitTypeSpearmanAztec);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 20.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerEpidemic) )
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, mhpID);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerAmoxForest) )
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, mhpID);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 40.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerDeathsAwaken) )
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID, cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerDeathFromAbove) )
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, mainBaseLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 45.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerVolcanoRotG) )
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeBuilding);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeBuildingsThatShoot);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
		return (true);
	}
	if(powerProtoID == aiGetGodPowerProtoIDForTechID(modPowerTlalocan) )
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
		aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 20.0);
		return (true);
	}
    }
    if(gModName == "HoM")
    {
	if(powerProtoID == cPowerPestilence)
	{
		queryID = kbUnitQueryCreate("PestilenceEval");
		kbUnitQuerySetPlayerID(queryID, mhpID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeLogicalTypeMythUnitNotTitan);
		kbUnitQuerySetState(queryID, cUnitStateAlive);
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, mhpID);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
		aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 250.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
		aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
		return (true);
	}
	if(powerProtoID == cPowerFimbulwinter)
	{
		xsEnableRule("castFimbulHoM");
		return (false);
	}
	if(powerProtoID == cPowerRagnorok)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
		return (true);
	}
    }
	return(false);
}

//==============================================================================
rule buildNorseGreatHall
minInterval 18	//starts in cAge2
inactive
{
      if(kbGetAge() < cAge2)
      {
		return;
      }

      int buildingTypeID = modUnitTypeGreatHall;
      int numBuilders = 1;

      if(kbUnitCount(cMyID, buildingTypeID, cUnitStateAliveOrBuilding) > 0)
      {
		return;
      }
      if(kbCanAffordUnit(buildingTypeID, cMilitaryEscrowID) == false)
      {
		return;
      }

	createSimpleBuildPlan(buildingTypeID, 1, 40, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
	xsSetRuleMinIntervalSelf(50);
}

//==============================================================================
// castFimbulHoM
//==============================================================================
rule castFimbulHoM
   minInterval 26
   inactive
{
	int mhpTC = findUnit(aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeAbstractSettlement, true);
	aiCastGodPowerAtUnit(cTechSnowStorm, mhpTC);
}