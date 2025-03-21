//=============================================================================
// AoMXaiTech.xs
//
// Handles important upgrades.
//=============================================================================

//=============================================================================
// createSimpleResearchPlan
//=============================================================================
int createSimpleResearchPlan(int techID=-1, int pri=100, int escrowID=cRootEscrowID)
{
    if(techID < 0)
    {
	return(-1);
    }
    if(
	(kbGetTechStatus(techID) < cTechStatusAvailable)
	||
	(kbGetTechStatus(techID) >= cTechStatusActive)
	||
	(aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, true) > -1)
      )
    {
	return(-1);
    }
    int inactivePlanID = aiPlanGetIDByTypeAndVariableType(cPlanResearch, cResearchPlanTechID, techID, false);
    if(inactivePlanID > -1)
    {
	aiPlanSetActive(inactivePlanID);
	return(inactivePlanID);
    }

    int planID = aiPlanCreate("Research "+kbGetTechName(techID), cPlanResearch);
    if(planID != 0)
    {
	aiPlanSetVariableInt(planID, cResearchPlanTechID, 0, techID);
	aiPlanSetDesiredPriority(planID, pri);
	aiPlanSetEscrowID(planID, escrowID);
	aiPlanSetActive(planID);
	//printEcho("Researching "+kbGetTechName(techID));
    }
    return(planID);
}
//=============================================================================
// createSimpleProgressionPlan
//=============================================================================
int createSimpleProgressionPlan(int techID=-1, int pri=100, int escrowID=cRootEscrowID)
{
    if(techID < 0)
    {
	return(-1);
    }
    if(
	(kbGetTechStatus(techID) < cTechStatusAvailable)
	||
	(kbGetTechStatus(techID) >= cTechStatusActive)
	||
	(aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, true) > -1)
      )
    {
	return(-1);
    }
    int inactivePlanID = aiPlanGetIDByTypeAndVariableType(cPlanProgression, cProgressionPlanGoalTechID, techID, false);
    if(inactivePlanID > -1)
    {
	aiPlanSetActive(inactivePlanID);
	return(inactivePlanID);
    }

    int planID = aiPlanCreate("Progression "+kbGetTechName(techID), cPlanProgression);
    if(planID != 0)
    {
	aiPlanSetVariableInt(planID, cProgressionPlanGoalTechID, 0, techID);
	aiPlanSetDesiredPriority(planID, pri);
	aiPlanSetEscrowID(planID, escrowID);
	aiPlanSetActive(planID);
	//printEcho("Progressing "+kbGetTechName(techID));
    }
    return(planID);
}
//=============================================================================
// techResearched
//=============================================================================
bool techResearched(int techID=-1, int playerID=-1)
{
    int myID = cMyID;
    if(playerID >= 0 && playerID != myID)
    {
	xsSetContextPlayer(playerID);
    }
    if(kbGetTechStatus(techID) >= cTechStatusResearching)
    {
	if(xsGetContextPlayer() != myID)
	{
		xsSetContextPlayer(myID);
	}
	return(true);
    }
    if(xsGetContextPlayer() != myID)
    {
	xsSetContextPlayer(myID);
    }
    return(false);
}
//=============================================================================
// RULE getHuntingDogs		[Eco]
//=============================================================================
rule getHuntingDogs
   minInterval 10
   group Age1UpgradesShared
   inactive
{
    if(
	(gHuntMap == true)	//better automatic hunt map detection?
	||
	(kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechHuntingDogs,99,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getHusbandry		[Eco]
//=============================================================================
rule getHusbandry
   minInterval 20
   group Age1UpgradesShared
   inactive
{
    int woodSupply = kbResourceGet(cResourceWood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(woodSupply > 200 && goldSupply > 100)
	&&
	(kbGetTechStatus(cTechPickaxe) >= cTechStatusResearching)
	&&
	(kbGetTechStatus(cTechHandAxe) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechHusbandry,99,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getHandAxe		[Eco]
//=============================================================================
rule getHandAxe
   minInterval 11
   group Age1UpgradesShared
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);
    int goldSupply = kbResourceGet(cResourceGold);

    //Delay until minute 7 if we are going to grab an instant TC.
    if(
	(gEarlySettlementTarget > 1)
	&&
	(cvRushBoomSlider < -0.4)
	&&
	(xsGetTime() < (7*60*1000))
      )
    {
			return;
    }
    if(
	(kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching)
	&&
	(foodSupply > 170 && goldSupply > 100)
	&&
	(cMyCulture != cCultureEgyptian || kbGetTechStatus(cTechPickaxe) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechHandAxe,99,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getPickaxe		[Eco]
//=============================================================================
rule getPickaxe
   minInterval 12
   group Age1UpgradesShared
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching)
	&&
	(foodSupply > 100 && goldSupply > 220)
	&&
	(cMyCulture == cCultureEgyptian || kbGetTechStatus(cTechHandAxe) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechPickaxe,99,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getVaultsofErebus	[Eco]
//=============================================================================
rule getVaultsofErebus
   minInterval 24
   group Age1UpgradesHades
   inactive
{
    if(kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching)
    {
	createSimpleResearchPlan(cTechVaultsofErebus,50,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getFloodoftheNile	[Eco]
//=============================================================================
rule getFloodoftheNile
   minInterval 24
   group Age1UpgradesIsis
   inactive
{
	createSimpleResearchPlan(cTechFloodoftheNile,75,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getPigSticker		[Eco]
//=============================================================================
rule getPigSticker
   minInterval 16
   group Age1UpgradesThor
   inactive
{
	createSimpleResearchPlan(cTechPigSticker,40,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getChannels		[Eco]
//=============================================================================
rule getChannels
   minInterval 24
   group Age1UpgradesGaia
   inactive
{
    if(kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive) > 3)
    {
	createSimpleResearchPlan(cTechChannels,100,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getDomestication	[Eco]
//=============================================================================
rule getDomestication
   minInterval 16
   group Age1UpgradesFuxi
   inactive
{
	createSimpleResearchPlan(cTechDomestication,75,cEconomyEscrowID);	//-todo
	xsDisableSelf();
}
//=============================================================================
// RULE getWheelbarrow		[Eco]
//=============================================================================
rule getWheelbarrow
   minInterval 18
   group Age1UpgradesShennong
   inactive
{
	createSimpleResearchPlan(cTechWheelbarrow,75,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getPlow			[Eco]
//=============================================================================
rule getPlow
   minInterval 14
   group Age2UpgradesShared
   inactive
{
    int woodSupply = kbResourceGet(cResourceWood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(woodSupply > 150 && goldSupply > 150)
	&&
	(kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding) >= 4)
      )
    {
	createSimpleResearchPlan(cTechPlow,95,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getBowSaw		[Eco]
//=============================================================================
rule getBowSaw
   minInterval 11
   group Age2UpgradesShared
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(kbGetTechStatus(cTechHandAxe) >= cTechStatusActive)
	&&
	(foodSupply > 300 && goldSupply > 200)
	&&
	(cMyCulture != cCultureEgyptian || kbGetTechStatus(cTechShaftMine) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechBowSaw,90,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getShaftMine		[Eco]
//=============================================================================
rule getShaftMine
   minInterval 12
   group Age2UpgradesShared
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);
    int woodSupply = kbResourceGet(cResourceWood);

    if(
	(kbGetTechStatus(cTechPickaxe) >= cTechStatusActive)
	&&
	(foodSupply > 200 && woodSupply > 350)
	&&
	(cMyCulture == cCultureEgyptian || kbGetTechStatus(cTechBowSaw) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechShaftMine,85,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getPurseSeine		[Eco]
//=============================================================================
rule getPurseSeine
   minInterval 30
   group Age2UpgradesShared
   inactive
{
    if(
	(gFishMap == true)
	&&
	(kbUnitCount(cMyID, cUnitTypeUtilityShip, cUnitStateAlive) >= 3)
      )
    {
	createSimpleResearchPlan(cTechPurseSeine,80,cEconomyEscrowID);		//was 45
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getNecropolis		[Eco]
//=============================================================================
rule getNecropolis
   minInterval 32
   group Age2UpgradesAnubis
   inactive
{
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(goldSupply > 750)
	&&
	(kbGetTechStatus(gAge3MinorGod) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechNecropolis,10,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getSacredCats		[Eco]
//=============================================================================
rule getSacredCats
   minInterval 18
   group Age2UpgradesBast
   inactive
{
	createSimpleResearchPlan(cTechSacredCats,75,cEconomyEscrowID);		//-todo
	xsDisableSelf();
}
//=============================================================================
// RULE getAdzeofWepwawet	[Eco]
//=============================================================================
rule getAdzeofWepwawet
   minInterval 22
   group Age2UpgradesBast
   inactive
{
	createSimpleResearchPlan(cTechAdzeofWepwawet,50,cEconomyEscrowID);	//-todo
	xsDisableSelf();
}
//=============================================================================
// RULE getShaduf		[Eco]
//=============================================================================
rule getShaduf
   minInterval 16
   group Age2UpgradesPtah
   inactive
{
	createSimpleResearchPlan(cTechShaduf,95,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getFiveGrains		[Eco]
//=============================================================================
rule getFiveGrains
   minInterval 20
   group Age2UpgradesHuangdi
   inactive
{
	createSimpleResearchPlan(cTechFiveGrains,95,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getIrrigation		[Eco]
//=============================================================================
rule getIrrigation
   minInterval 14
   group Age3UpgradesShared
   inactive
{
    int woodSupply = kbResourceGet(cResourceWood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(kbGetTechStatus(cTechPlow) >= cTechStatusActive)
	&&
	(woodSupply > 250 && goldSupply > 300)
	&&
	(kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding) >= 6)
      )
    {
	createSimpleResearchPlan(cTechIrrigation,95,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getCarpenters		[Eco]
//=============================================================================
rule getCarpenters
   minInterval 11
   group Age3UpgradesShared
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(kbGetTechStatus(cTechBowSaw) >= cTechStatusActive)
	&&
	(foodSupply > 350 && goldSupply > 250)
	&&
	(cMyCulture != cCultureEgyptian || kbGetTechStatus(cTechQuarry) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechCarpenters,95,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getQuarry		[Eco]
//=============================================================================
rule getQuarry
   minInterval 12
   group Age3UpgradesShared
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);
    int woodSupply = kbResourceGet(cResourceWood);

    if(
	(kbGetTechStatus(cTechShaftMine) >= cTechStatusActive)
	&&
	(foodSupply > 250 && woodSupply > 400)
	&&
	(cMyCulture == cCultureEgyptian || kbGetTechStatus(cTechCarpenters) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechQuarry,90,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getSaltAmphora		[Eco]
//=============================================================================
rule getSaltAmphora
   minInterval 30
   group Age3UpgradesShared
   inactive
{
    if(
	(kbGetTechStatus(cTechPurseSeine) >= cTechStatusActive)
	&&
	(kbUnitCount(cMyID, cUnitTypeUtilityShip, cUnitStateAlive) >= 3)
      )
    {
	createSimpleResearchPlan(cTechSaltAmphora,75,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getFortifyTownCenter	[Eco]
//=============================================================================
rule getFortifyTownCenter
   minInterval 40
   group Age3UpgradesShared
   inactive
{
    int woodSupply = kbResourceGet(cResourceWood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(woodSupply > 350 && goldSupply > 350)
	||
	(kbUnitCount(cMyID, cUnitTypeAbstractSettlement) > 2)
      )
    {
	createSimpleResearchPlan(cTechFortifyTownCenter,75,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getGoldenApples		[Eco]
//=============================================================================
rule getGoldenApples
   minInterval 29
   group Age3UpgradesAphrodite
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(foodSupply > 400 && goldSupply > 300)
	&&
	(foodSupply < 700 && goldSupply < 700)
      )
    {
	createSimpleResearchPlan(cTechGoldenApples,95,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getDivineBlood		[Eco]
//=============================================================================
rule getDivineBlood
   minInterval 34
   group Age3UpgradesAphrodite
   inactive
{
	createSimpleResearchPlan(cTechDivineBlood,75,cEconomyEscrowID);		//-todo
	xsDisableSelf();
}
//=============================================================================
// RULE getWinterHarvest	[Eco]
//=============================================================================
rule getWinterHarvest
   minInterval 16
   group Age3UpgradesSkadi
   inactive
{
	createSimpleResearchPlan(cTechWinterHarvest,100,cEconomyEscrowID);	//-todo
	xsDisableSelf();
}
//=============================================================================
// RULE getHornsofConsecration	[Eco]
//=============================================================================
rule getHornsofConsecration
   minInterval 28
   group Age3UpgradesRheia
   inactive
{
	createSimpleResearchPlan(cTechHornsofConsecration,20,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getRheiasGift		[Eco]
//=============================================================================
rule getRheiasGift
   minInterval 29
   group Age3UpgradesRheia
   inactive
{
	createSimpleResearchPlan(cTechRheiasGift,25,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getLandlordSpirit	[Eco]
//=============================================================================
rule getLandlordSpirit
   minInterval 45
   group Age3UpgradesDabogong
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);

    if(
	(foodSupply > 600)
	&&
	(kbGetTechStatus(gAge4MinorGod) >= cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechLandlordSpirit,10,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getHouseAltars		[Eco]
//=============================================================================
rule getHouseAltars
   minInterval 27
   group Age3UpgradesDabogong
   inactive
{
	createSimpleResearchPlan(cTechHouseAltars,50,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getSacrifices		[Eco]
//=============================================================================
rule getSacrifices
   minInterval 32
   group Age3UpgradesHebo
   inactive
{
	createSimpleResearchPlan(cTechSacrifices,10,cEconomyEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getFloodControl		[Eco]
//=============================================================================
rule getFloodControl
   minInterval 15
   group Age4UpgradesShared
   inactive
{
    int woodSupply = kbResourceGet(cResourceWood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(kbGetTechStatus(cTechIrrigation) >= cTechStatusActive)
	&&
	(woodSupply > 350 && goldSupply > 400)
	&&
	(kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding) >= 8)
      )
    {
	createSimpleResearchPlan(cTechFloodControl,95,cEconomyEscrowID);
    }
}
//=============================================================================
// RULE getCoinage		[Eco]
//=============================================================================
rule getCoinage
   minInterval 20
   group Age4UpgradesShared
   inactive
{
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(goldSupply > 300)
	&&
	(kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive) >= 4)
      )
    {
	createSimpleResearchPlan(cTechCoinage,100,cEconomyEscrowID);
    }
}
//=============================================================================
// RULE getForgeofOlympus	[Eco]
//=============================================================================
rule getForgeofOlympus
   minInterval 35
   group Age4UpgradesHephaestus
   inactive
{
    if(
	(kbGetTechStatus(cTechIronWeapons) < cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechForgeofOlympus,100,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getNewKingdom		[Eco]
//=============================================================================
rule getNewKingdom
   minInterval 26
   group Age4UpgradesOsiris
   inactive
{
	createSimpleResearchPlan(cTechNewKingdom,100,cEconomyEscrowID);		//-todo
	xsDisableSelf();
}
//=============================================================================
// RULE getBookofThoth		[Eco]
//=============================================================================
rule getBookofThoth
   minInterval 28
   group Age4UpgradesThoth
   inactive
{
	createSimpleResearchPlan(cTechBookofThoth,100,cEconomyEscrowID);	//-todo
	xsDisableSelf();
}
//=============================================================================
// RULE getHeavenlyFire		[Eco]
//=============================================================================
rule getHeavenlyFire
   minInterval 17
   group Age4UpgradesChongli
   inactive
{
    if(
	(kbGetTechStatus(cTechIronWeapons) < cTechStatusResearching)
	||
	(kbGetTechStatus(cTechIronMail) < cTechStatusResearching)
	||
	(kbGetTechStatus(cTechIronShields) < cTechStatusResearching)
      )
    {
	createSimpleResearchPlan(cTechHeavenlyFire,100,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getAncientDestroyer	[Eco]
//=============================================================================
rule getAncientDestroyer
   minInterval 18
   group Age4UpgradesChongli
   inactive
{
    int woodSupply = kbResourceGet(cResourceWood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(woodSupply > 400 && goldSupply > 400)
	&&
	(kbUnitCount(cMyID, cUnitTypeUtilityShip, cUnitStateAlive) >= 6)
      )
    {
	createSimpleResearchPlan(cTechAncientDestroyer,85,cEconomyEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getEastSea		[Eco]
//=============================================================================
rule getEastSea
   minInterval 26
   group Age4UpgradesAokuang
   inactive
{
	createSimpleResearchPlan(cTechEastSea,15,cEconomyEscrowID);	//-todo
	xsDisableSelf();
}
//=============================================================================
// RULE getWatchTower		[Mil]
//=============================================================================
rule getWatchTower
   minInterval 19
   group Age2UpgradesShared
   inactive
{
    if(cMyCulture == cCultureEgyptian)
    {
	xsDisableSelf();
	return;
    }

    int myMilSize = kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive);
    int mhpMilSize = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeMilitary, cUnitStateAlive);

    if(
	(myMilSize < mhpMilSize)
	&&
	(kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding) >= 3)
      )
    {
	createSimpleResearchPlan(cTechWatchTower,100,cMilitaryEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getSundriedMudBrick	[Mil]
//=============================================================================
rule getSundriedMudBrick
   minInterval 26
   group Age3UpgradesHathor
   inactive
{
	createSimpleResearchPlan(cTechSundriedMudBrick,25,cMilitaryEscrowID);
	xsDisableSelf();
}
//=============================================================================
// RULE getEngineers		[Mil]
//=============================================================================
rule getEngineers
   minInterval 20
   group Age4UpgradesShared
   inactive
{
    int foodSupply = kbResourceGet(cResourceFood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(
	(foodSupply > 600 && goldSupply > 800)
	&&
	(kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive) >= 2)
      )
    {
	createSimpleResearchPlan(cTechEngineers,50,cMilitaryEscrowID);
	xsDisableSelf();
    }
}
//=============================================================================
// RULE getBurningPitch		[Mil]
//=============================================================================
rule getBurningPitch
   minInterval 23
   group Age4UpgradesShared
   inactive
{
    int woodSupply = kbResourceGet(cResourceWood);
    int goldSupply = kbResourceGet(cResourceGold);

    if(cMyCiv != cCivThor)
    {
	//Burning Pitch
	if(
		(goldSupply > 600 && woodSupply > 800)
		&&
		(kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive) >= 2)
	  )
	{
		createSimpleResearchPlan(cTechBurningPitch,40,cMilitaryEscrowID);
	}
    }else{
	//Burning Pitch Thor
	if(
		(goldSupply > 500 && woodSupply > 700)
		&&
		(kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive) >= 2)
	  )
	{
		createSimpleResearchPlan(cTechBurningPitchThor,40,cMilitaryEscrowID);
	}
    }
}
//=============================================================================
// ORDER handleAge1Upgrades	[Eco/Mil]
//=============================================================================
void handleAge1Upgrades()
{
    if(aiGetGameMode() == cGameModeDeathmatch)
    {
	return;
    }
    if(kbGetAge() >= cAge1)	//Archaic
    {
	xsEnableRuleGroup("Age1UpgradesShared");

	if(cMyCiv == cCivHades)
	{
		xsEnableRuleGroup("Age1UpgradesHades");
	}
	if(cMyCiv == cCivIsis)
	{
		xsEnableRuleGroup("Age1UpgradesIsis");
	}
	if(cMyCiv == cCivThor)
	{
		xsEnableRuleGroup("Age1UpgradesThor");
	}
	if(cMyCiv == cCivGaia)
	{
		xsEnableRuleGroup("Age1UpgradesGaia");
	}
	if(cMyCiv == cCivFuxi)
	{
		xsEnableRuleGroup("Age1UpgradesFuxi");
	}
	if(cMyCiv == cCivShennong)
	{
		xsEnableRuleGroup("Age1UpgradesShennong");
	}
    }
}
//=============================================================================
// ORDER handleAge2Upgrades	[Eco/Mil]
//=============================================================================
void handleAge2Upgrades()
{
    if(aiGetGameMode() == cGameModeDeathmatch)
    {
	return;
    }
    if(kbGetAge() >= cAge2)	//Classic
    {
	xsEnableRuleGroup("Age2UpgradesShared");

	if(gAge2MinorGod == cTechAge2Anubis)
	{
		xsEnableRuleGroup("Age2UpgradesAnubis");
	}
	if(gAge2MinorGod == cTechAge2Bast)
	{
		xsEnableRuleGroup("Age2UpgradesBast");
	}
	if(gAge2MinorGod == cTechAge2Ptah)
	{
		xsEnableRuleGroup("Age2UpgradesPtah");
	}
	if(gAge2MinorGod == cTechAge2Huangdi)
	{
		xsEnableRuleGroup("Age2UpgradesHuangdi");
	}
    }
}
//=============================================================================
// ORDER handleAge3Upgrades	[Eco/Mil]
//=============================================================================
void handleAge3Upgrades()
{
    if(aiGetGameMode() == cGameModeDeathmatch)
    {
	return;
    }
    if(kbGetAge() >= cAge3)	//Heroic
    {
	xsEnableRuleGroup("Age3UpgradesShared");

	if(gAge3MinorGod == cTechAge3Aphrodite)
	{
		xsEnableRuleGroup("Age3UpgradesAphrodite");
	}
	if(gAge3MinorGod == cTechAge3Hathor)
	{
		xsEnableRuleGroup("Age3UpgradesHathor");
	}
	if(gAge3MinorGod == cTechAge3Skadi)
	{
		xsEnableRuleGroup("Age3UpgradesSkadi");
	}
	if(gAge3MinorGod == cTechAge3Rheia)
	{
		xsEnableRuleGroup("Age3UpgradesRheia");
	}
	if(gAge3MinorGod == cTechAge3Dabogong)
	{
		xsEnableRuleGroup("Age3UpgradesDabogong");
	}
	if(gAge3MinorGod == cTechAge3Hebo)
	{
		xsEnableRuleGroup("Age3UpgradesHebo");
	}
    }
}
//=============================================================================
// ORDER handleAge4Upgrades	[Eco/Mil]
//=============================================================================
void handleAge4Upgrades()
{
    if(aiGetGameMode() == cGameModeDeathmatch)
    {
	return;
    }
    if(kbGetAge() >= cAge4)	//Mythic
    {
	xsEnableRuleGroup("Age4UpgradesShared");

	if(gAge4MinorGod == cTechAge4Hephaestus)
	{
		xsEnableRuleGroup("Age4UpgradesHephaestus");
	}
	if(gAge4MinorGod == cTechAge4Osiris)
	{
		xsEnableRuleGroup("Age4UpgradesOsiris");
	}
	if(gAge4MinorGod == cTechAge4Thoth)
	{
		xsEnableRuleGroup("Age4UpgradesThoth");
	}
	if(gAge4MinorGod == cTechAge4Chongli)
	{
		xsEnableRuleGroup("Age4UpgradesChongli");
	}
	if(gAge4MinorGod == cTechAge4Aokuang)
	{
		xsEnableRuleGroup("Age4UpgradesAokuang");
	}
    }
}