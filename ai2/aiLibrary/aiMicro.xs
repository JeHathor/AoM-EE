//==============================================================================
// aiMicroHelp.xs	by JeHathor
//==============================================================================
//||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
//==============================================================================
// ORDER: findUnitRM
//
// Will find a unit of the given playerID
//==============================================================================
int findUnitRM(int playerID=0, int state=cUnitStateAny, int unitTypeID=-1, bool random=true, int actionType=-1)
{
   int count=-1;
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("miscFindUnitQuery");
   
	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
	   if(playerID < 0)	//Whoever owns it (Any)
	   {
		kbUnitQuerySetPlayerRelation(unitQueryID, cPlayerRelationAny);
	   }else{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	   }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);

		if(actionType != -1)
		{
			kbUnitQuerySetActionType(unitQueryID, actionType);
		}
	}
	else
   	return(-1);

   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);
   if(random)
   {
      return(kbUnitQueryGetResult(unitQueryID, aiRandInt(numberFound) ));
   }else{
      return(kbUnitQueryGetResult(unitQueryID, 0)); //Select the first
   }
   return(-1);
}

//==============================================================================
// ORDER: findUnitByIndex
//==============================================================================
int findUnitByIndex(int playerID=0, int state=cUnitStateAny, int unitTypeID=-1, int index=0)
{
   int count=-1;
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("miscFindUnitQuery");
   
	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
	   if(playerID < 0)	//Whoever owns it (Any)
	   {
		kbUnitQuerySetPlayerRelation(unitQueryID, cPlayerRelationAny);
	   }else{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	   }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
	}
	else
   	return(-1);

   kbUnitQueryResetResults(unitQueryID);
   kbUnitQueryExecute(unitQueryID);
   return(kbUnitQueryGetResult(unitQueryID, index));
}

//==============================================================================
// ORDER: getUnitsAtLocQID
//==============================================================================
int getUnitsAtLocQID(int playerID=0, int state=cUnitStateAny, int unitTypeID=-1, vector center=cInvalidVector, int radius=0)
{
   int count=-1;
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("miscFindUnitQuery");
   
	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
	   if(playerID < 0)	//Whoever owns it (Any)
	   {
		kbUnitQuerySetPlayerRelation(unitQueryID, cPlayerRelationAny);
	   }else{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	   }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
      kbUnitQuerySetPosition(unitQueryID, center);
      kbUnitQuerySetMaximumDistance(unitQueryID, radius);
	}
	else
   	return(-1);

   kbUnitQueryResetResults(unitQueryID);
   return(unitQueryID);
}

//==============================================================================
// ORDER: taskEjectAll
//==============================================================================
void taskEjectAll(int buildingID=-1, int unitTypeID=-1)
{
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("miscFindUnitQuery");

    if (unitQueryID != -1)
    {
      kbUnitQuerySetPlayerID(unitQueryID, kbUnitGetOwner(buildingID));	//cMyID
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, cUnitStateAlive);
      kbUnitQuerySetPosition(unitQueryID, kbUnitGetPosition(buildingID));
      kbUnitQuerySetMaximumDistance(unitQueryID, 1);
    }else
	return;

   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);
   for(i=0; < numberFound)
   {
      int garrisonedID = kbUnitQueryGetResult(unitQueryID, i);
      if (garrisonedID > -1)
      {
	aiTaskUnitEject(buildingID,garrisonedID);
      }
   }
}

//==============================================================================
// ORDER: findWeakestUnit
//
// Will find the lowest HP unit of the given playerID
//==============================================================================
int findWeakestUnit(int playerID=0, int state=cUnitStateAny, int unitTypeID=-1, int playerRelation=-1)
{
   int count=-1;
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("miscFindUnitQuery");
   
	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
	   if(playerID < 0)	//-1 for playerRelation
	   {
		//Whatever specified... (at least in theory)
		kbUnitQuerySetPlayerRelation(unitQueryID, playerRelation);
	   }else{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	   }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
	}else{
   		return(-1);	//No match!
	}

   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);

   int weakestID = -1;
   int minHP = 99999;	//This shouldn't be the weakest unit.

   for (i=0; < numberFound)
   {
	int temp = kbUnitGetCurrentHitpoints( kbUnitQueryGetResult(unitQueryID, i) );

	//Compare.
	if(temp < minHP)
	{
		minHP = temp;
		weakestID = kbUnitQueryGetResult(unitQueryID, i);
	}
   }
   return(weakestID);
}

//=============================================================================
//   findWeakestUnitInRadius
//=============================================================================
int findWeakestUnitInRadius(int puid=-1, int playerID=0, int state=cUnitStateAny, int unitTypeID=-1, int radius=10, int playerRelation=-1, bool sameArea=false)
{
   int count=-1;
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("miscFindUnitQuery");
   
	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
	   if(playerID < 0)	//-1 for playerRelation
	   {
		//Whatever specified...
		kbUnitQuerySetPlayerRelation(unitQueryID, playerRelation);
	   }else{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	   }
	   if (sameArea == true)
	   {
		vector center = kbUnitGetPosition(puid);
		kbUnitQuerySetAreaGroupID(unitQueryID, kbAreaGroupGetIDByPosition(center));	
		kbUnitQueryResetResults(unitQueryID);
	   }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
	}
	else
   	return(-1);

   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);

   int weakestID = -1;
   int minHP = 99999;

	vector A = kbUnitGetPosition(puid);

   for (i=0; < numberFound)
   {
	vector B = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i));
	int distance = xsVectorLength(A-B);
	int currentHP = kbUnitGetCurrentHitpoints(kbUnitQueryGetResult(unitQueryID, i));

	if(currentHP < minHP && distance <= radius)	//Compare.
	{
		minHP = currentHP;
		weakestID = kbUnitQueryGetResult(unitQueryID, i);
	}
   }
   return(weakestID);
}

//==============================================================================
// ORDER: findClosestRelTo
//
// Will find the closest unit relative to the given unit
//==============================================================================
int findClosestRelTo(int puid=-1, int playerID=0, int state=cUnitStateAny, int unitTypeID=-1, int playerRelation=-1)
{
   int count=-1;
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("miscFindUnitQuery");
   
	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
	   if(playerID < 0)	//-1 for playerRelation
	   {
		//Whatever specified... (at least in theory)
		kbUnitQuerySetPlayerRelation(unitQueryID, playerRelation);
	   }else{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	   }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
	}
	else
   	return(-1);

   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);

	vector A = kbUnitGetPosition(puid);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

   int closestID = -1;
   int minLength = 99999;

   for (i=0; < numberFound)
   {
	vector B = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i));
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	int temp = xsVectorLength(xsVectorSet(ax-bx,ay-by,az-bz));

	//Compare.
	if(temp < minLength && kbUnitQueryGetResult(unitQueryID, i) != puid)
	{
		minLength = temp;
		closestID = kbUnitQueryGetResult(unitQueryID, i);
	}
   }
   return(closestID);
}

//==============================================================================
// ORDER: findFurthestRelTo
//
// Will find the furthest unit relative to the given unit
//==============================================================================
int findFurthestRelTo(int puid=-1, int playerID=0, int state=cUnitStateAny, int unitTypeID=-1, int playerRelation=-1)
{
   int count=-1;
   static int unitQueryID=-1;

   //If we don't have the query yet, create one.
   if (unitQueryID < 0)
      unitQueryID=kbUnitQueryCreate("miscFindUnitQuery");
   
	//Define a query to get all matching units
	if (unitQueryID != -1)
	{
	   if(playerID < 0)	//-1 for playerRelation
	   {
		//Whatever specified... (at least in theory)
		kbUnitQuerySetPlayerRelation(unitQueryID, playerRelation);
	   }else{
		kbUnitQuerySetPlayerID(unitQueryID, playerID);
	   }
      kbUnitQuerySetUnitType(unitQueryID, unitTypeID);
      kbUnitQuerySetState(unitQueryID, state);
	}
	else
   	return(-1);

   kbUnitQueryResetResults(unitQueryID);
	int numberFound=kbUnitQueryExecute(unitQueryID);

	vector A = kbUnitGetPosition(puid);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

   int furthestID = -1;
   int maxLength = -1;

   for (i=0; < numberFound)
   {
	vector B = kbUnitGetPosition(kbUnitQueryGetResult(unitQueryID, i));
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	int temp = xsVectorLength(xsVectorSet(ax-bx,ay-by,az-bz));

	//Compare.
	if(temp > maxLength)
	{
		maxLength = temp;
		furthestID = kbUnitQueryGetResult(unitQueryID, i);
	}
   }
   return(furthestID);
}

//==============================================================================
// ORDER: calcDistanceToUnit
//==============================================================================
int calcDistanceToUnit(int puidA=-1, int puidB=-1)
{
	vector A = kbUnitGetPosition(puidA);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(puidB);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	return(xsVectorLength(xsVectorSet(ax-bx,ay-by,az-bz)));
}

//==============================================================================
// ORDER: calcDistanceToPos
//==============================================================================
int calcDistanceToPos(vector locA=cInvalidVector, vector locB=cInvalidVector)
{
	int ax = xsVectorGetX(locA);
	int ay = xsVectorGetY(locA);
	int az = xsVectorGetZ(locA);

	int bx = xsVectorGetX(locB);
	int by = xsVectorGetY(locB);
	int bz = xsVectorGetZ(locB);

	return(xsVectorLength(xsVectorSet(ax-bx,ay-by,az-bz)));
}

//==============================================================================
// RULE: convertAnimals
//==============================================================================
rule convertAnimals
   minInterval 5
   active
{
   if (cMyCiv != cCivSet)	//I'm Set, I want animals!!! Very simple...
   {
      xsDisableSelf();
      return;
   }

   int priestID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypePriest, true, cActionIdle);
   int animalID = findClosestRelTo(priestID, 0, cUnitStateAlive, cUnitTypeHuntable);

   if (calcDistanceToUnit(priestID,animalID) < 30)	//was 10
   {
      aiTaskUnitWork(priestID,animalID);
   }
}

//==============================================================================
// RULE: collectHerdables
//==============================================================================
rule collectHerdables
   minInterval 18
   active
{
   int scoutID = findUnitRM(cMyID, cUnitStateAlive, gLandScout, true, cActionIdle);
   int herdID = findClosestRelTo(scoutID, 0, cUnitStateAlive, cUnitTypeHerdable);

   if(herdID < 0)
   {
      xsDisableSelf();
      return;
   }

   if (calcDistanceToUnit(scoutID,herdID) < 40)
   {
      aiTaskUnitMove(scoutID,kbUnitGetPosition(herdID));
   }
}

// *****************************************************************************
// ORDER: microHeroesVsMyth [Age2]
// (Only target myth within range and ignore the rest)
//
// *****************************************************************************
void microHeroesVsMyth(void)		//Type: AttackScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeHero, true);
   int counterDistance = 1;	//All non-ranged.
   bool attackFlying = false;

   if(myUnitID > -1)	//If not skip the calculation.
   {
	if (
	    kbUnitIsType(myUnitID, cUnitTypeHeroGreekOdysseus)
	    ||
	    kbUnitIsType(myUnitID, cUnitTypeHeroGreekHippolyta)
	    ||
	    kbUnitIsType(myUnitID, cUnitTypeBogsveigir)
	    ||
	    kbUnitIsType(myUnitID, cUnitTypeArcherAtlanteanHero)
	   )
	{
		counterDistance = 18;
		attackFlying = true;
	}else
	if (
	    kbUnitIsType(myUnitID, cUnitTypeHeroGreekChiron)
	    ||
	    kbUnitIsType(myUnitID, cUnitTypeHeroChineseImmortal)
	    ||
	    kbUnitIsType(myUnitID, cUnitTypeJavelinCavalryHero)
	   )
	{
		counterDistance = 12;
		attackFlying = true;
	}else
	if (
	    kbUnitIsType(myUnitID, cUnitTypePharaoh)
	    ||
	    kbUnitIsType(myUnitID, cUnitTypePharaohSecondary)
	    ||
	    kbUnitIsType(myUnitID, cUnitTypePriest)
	   )
	{
	   if(kbGetAge() <= cAge1)
	   {
		counterDistance = 3;
		attackFlying = false;
	   }
	   else if(kbGetAge() <= cAge2)
	   {
		counterDistance = 12;
		attackFlying = true;
	   }
	   else if(kbGetAge() <= cAge3)
	   {
		counterDistance = 18;
		attackFlying = true;
	   }
	   else if(kbGetAge() <= cAge4)
	   {
		counterDistance = 20;
		attackFlying = true;
	   }
	}else
	if (cMyCulture == cCultureGreek)
	{
		counterDistance = 5;
		attackFlying = false;
	}

   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMythUnit);
   if(mhpUnitID < -1) { return; }	//Nothing found?

   bool isFlying = false;
   if(kbUnitIsType(mhpUnitID, cUnitTypeFlyingUnit))
   {
	isFlying = true;
   }

   //nearest target is close enough?
   if(
	calcDistanceToUnit(myUnitID,mhpUnitID) < counterDistance
	&&
	(isFlying == false || (isFlying && attackFlying))
     )
   {
	aiTaskUnitWork(myUnitID, mhpUnitID);	//Attack!!!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microTitanVsBuildings [Age4]
// (Prefer to attack buildings if they appear to be in range)
//
// *****************************************************************************
void microTitanVsBuildings(void)	//Type: AttackScript
{
   if(kbGetTechStatus(cTechSecretsoftheTitans) < cTechStatusResearching)
   {
	return;		//I don't care about SPC for this...
   }

   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractTitan);

   if(myUnitID > -1)	//If not skip the calculation.
   {

   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeBuilding);
   if(mhpUnitID < -1) { return; }	//Nothing found?

   //nearest target is close enough?
   if(calcDistanceToUnit(myUnitID,mhpUnitID) < 5)
   {
	aiTaskUnitWork(myUnitID, mhpUnitID);	//Attack!!!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microMilitaryVsWalls [Age2]
// (Target walls as long as there is no counter attack)
//
// *****************************************************************************
void microMilitaryVsWalls(void)		//Type: AttackScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeMilitary, true);

   //If not skip the calculation.
   if(myUnitID > -1)
   {

   //No archers - No Scouts!
   if (
	kbUnitIsType(myUnitID, cUnitTypeAbstractArcher) == false
	||
	kbUnitIsType(myUnitID, cUnitTypeAbstractScout) == false
      )
   {
	return;
   }

   int mhpWallID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeAbstractWall);

   //Is it a reasonable target?
   bool conditionA = false;
   if (
	kbUnitIsType(mhpWallID, cUnitTypeGate)	//We want to break into walls
	||
	kbUnitIsType(mhpWallID, cUnitTypeWallLong)
      )
   {
	conditionA = true;
   }

   //nearest target is close enough?
   bool conditionB = false;
   if (calcDistanceToUnit(myUnitID,mhpWallID) < 8)
   {
	conditionB = true;
   }

   //current Hp lower then half of my max?
   bool conditionC = false;
   if (kbUnitGetCurrentHitpoints(myUnitID) <= kbUnitGetMaximumHitpoints(myUnitID)*0.9)
   {
	conditionC = true;
   }

   if(conditionA && conditionB && conditionC)	//All true?
   {
	aiTaskUnitWork(myUnitID, mhpWallID);	//Attack!!!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microSiegeVsBuildings [Age2]
// (Only focus down important buildings and ignore the rest)
//
// *****************************************************************************
void microSiegeVsBuildings(void)	//Type: AttackScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractSiegeWeapon, true);

   if(myUnitID > -1)	//If not skip the calculation.
   {

   int mhpBuildingID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeBuilding);

   //Is it a reasonable target?
   bool conditionA = false;
   if (
	kbUnitIsType(mhpBuildingID, cUnitTypeBuildingsThatShoot)
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeHouse)
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeAbstractSettlement)
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeWonder)
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeManor)	//Never forget Atlantean
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeTitanGate)
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeTunnel)
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeTartarianGate)
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeGate)	//We want to break into walls
	||
	kbUnitIsType(mhpBuildingID, cUnitTypeWallLong)
	||
	kbUnitIsType(cUnitTypeMilitaryBuilding)
      )
   {
	conditionA = true;
   }

   //nearest target is close enough?
   bool conditionB = false;
   if (calcDistanceToUnit(myUnitID,mhpBuildingID) < 34)
   {
	conditionB = true;
   }

   if(conditionA && conditionB)	//Both true?
   {
	aiTaskUnitWork(myUnitID, mhpBuildingID);	//Attack!!!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microAntiSiegeVsSiege [Age2]
// (Try to destroy siege weapons with our siege counter unit)
//
// *****************************************************************************
void microAntiSiegeVsSiege(void)	//Type: AttackScript
{
   int myUnitID = -1;
   int counterDistance = 8;

   if (cMyCulture == cCultureGreek)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeProdromos, true);
	if(myUnitID < 0 && aiRandInt(5)==1)
	{
		myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeHippikon, true);
	}
   }else
   if (cMyCulture == cCultureEgyptian)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeSpearman, true);
	if(myUnitID < 0 && aiRandInt(5)==1)
	{
		myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeCamelry, true);
	}
   }else
   if (cMyCulture == cCultureNorse)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeRaidingCavalry, true);
	if(myUnitID < 0)
	{
		myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeHuskarl, true);
	}
   }else
   if (cMyCulture == cCultureAtlantean)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeMaceman, true);
	if(myUnitID < 0  && aiRandInt(5)==1)
	{
		myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeLancer, true);
	}
   }else
   if (cMyCulture == cCultureChinese)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeCataphractChinese, true);
	if(myUnitID < 0 && aiRandInt(5)==1)
	{
		myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeScoutChinese, true);
	}
   }
   if(myUnitID > -1)	//If not skip the calculation.
   {

   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeAbstractSiegeWeapon);
   if(mhpUnitID < -1){ return; }	//Nothing found?

   //nearest target is close enough?
   if(calcDistanceToUnit(myUnitID,mhpUnitID) < counterDistance)
   {
	aiTaskUnitWork(myUnitID, mhpUnitID);	//Attack!!!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microAntiArcherVsArcher [Age2]
// (Only focus down archers within range and ignore the rest)
//
// *****************************************************************************
void microAntiArcherVsArcher(void)	//Type: AttackScript
{
   int myUnitID = -1;	//Norse
   int counterDistance = 0;

   if (cMyCulture == cCultureGreek)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypePeltast, true);
	counterDistance = 16;
   }else
   if (cMyCulture == cCultureEgyptian)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeSlinger, true);
	counterDistance = 16;
   }else
   if (cMyCulture == cCultureAtlantean)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeJavelinCavalry, true);
	counterDistance = 12;
   }else
   if (cMyCulture == cCultureChinese)
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeFireLance, true);
	counterDistance = 18;
   }
   if(myUnitID > -1)	//If not skip the calculation.
   {

   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeAbstractArcher);
   if(mhpUnitID < -1){ return; }	//Nothing found?

   //nearest target is close enough?
   if(calcDistanceToUnit(myUnitID,mhpUnitID) < counterDistance)
   {
	aiTaskUnitWork(myUnitID, mhpUnitID);	//Attack!!!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microOdin [Age2]
// (Sending damaged soldiers back to a save position to recover health)
//
// *****************************************************************************
void microOdin(void)			//Type: AvoidScript
{
   if(cMyCiv == cCivOdin) //We are not Odin? Skip the calculation.
   {

   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeLogicalTypeOdinRegenerates, true);
   int myBaseID = findClosestRelTo(myUnitID, cMyID, cUnitStateAlive, cUnitTypeBuildingsThatShoot);

   if(kbUnitGetCurrentHitpoints(myUnitID) <= kbUnitGetMaximumHitpoints(myUnitID)*0.2)
   {
	vector A = kbUnitGetPosition(myUnitID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myBaseID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*12;
	int py = xsVectorGetY(path)*12;
	int pz = xsVectorGetZ(path)*12;

	if(xsVectorLength(xsVectorSet(ax-bx,ay-by,az-bz)) <= 15)
	{
		//We are in TC range now. Let it go...
	}else{

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint);

	}
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microArchersVsAll [Age2]
// (Sending damaged archers out of range of hand combative enemies)
//
// *****************************************************************************
void microArchersVsAll(void)		//Type: KitingScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractArcher, true, cActionRangedAttack);

   if(myUnitID > -1)	//Nothing found? Skip the calculation.
   {

   //current Hp lower then half of my max?
   bool conditionA = false;
   if (kbUnitGetCurrentHitpoints(myUnitID) <= kbUnitGetMaximumHitpoints(myUnitID)*0.6)
   {
	conditionA = true;
   }

   //nearest enemy unit closer then 8 feet?
   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMilitary);
   bool conditionB = false;
   if (calcDistanceToUnit(myUnitID,mhpUnitID) < 8)
   {
	conditionB = true;
   }

   //nearest enemy unit is a titan?
   bool conditionC = false;
   if(kbUnitIsType(mhpUnitID, cUnitTypeAbstractTitan))
   {
	conditionC = true;
   }

   //nearest enemy unit far enough?
   bool conditionD = false;
   if (
	calcDistanceToUnit(myUnitID,mhpUnitID) > 8
	&&
	calcDistanceToUnit(myUnitID,mhpUnitID) < 13
      )
   {
	conditionD = true;
   }

   //nearest enemy unit is a tank?
   bool conditionE = true;
   if(
	kbUnitIsType(mhpUnitID, cUnitTypeAbstractTitan)
	||
	kbUnitIsType(mhpUnitID, cUnitTypeAbstractSiegeWeapon)
	||
	kbUnitIsType(mhpUnitID, cUnitTypeColossus)
	||
	kbUnitIsType(mhpUnitID, cUnitTypeScarab)
	||
	kbUnitIsType(mhpUnitID, cUnitTypeBehemoth)
	||
	kbUnitIsType(mhpUnitID, cUnitTypeFrostGiant)
     )
   {
	conditionE = false;
   }

   //Conditions true?
   if(
	conditionA && conditionB	//C can be both
	||
	conditionB && conditionC	//A can be both
     )
   {
	vector A = kbUnitGetPosition(mhpUnitID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*12;
	int py = xsVectorGetY(path)*12;
	int pz = xsVectorGetZ(path)*12;

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint);		//Run!!!
   }
	else if(conditionA && conditionD && conditionE)
	{
		aiTaskUnitWork(myUnitID, mhpUnitID);	//Hit!!!
	}
	else
	{
	   //Search for a better target...
	   int targetUnitID = findWeakestUnitInRadius(myUnitID,aiGetMostHatedPlayerID(),cUnitStateAlive,cUnitTypeUnit,10,-1,true);
	   if(targetUnitID > -1)
	   {
		aiTaskUnitWork(myUnitID, targetUnitID);	//Hit!!!
	   }
	}

   } //End of skipping
}

// *****************************************************************************
// ORDER: microGroups [Age1]
// (Keeping my soldiers in range of their group)
//
// *****************************************************************************
void microGroups(void)			//Type: GroupScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractArcher, true);
   int myMilCount = kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive);

   if(myUnitID > -1 && myMilCount > 1)	//Not the case? Skip the calculation.
   {

   //current Hp not lower then half of my max?
   bool value = true;
   if (kbUnitGetCurrentHitpoints(myUnitID) <= kbUnitGetMaximumHitpoints(myUnitID)*0.2)
   {
	value = false;	//Avoid conflicts with the Odin Rule...
   }

   //are we in range of a military group?
   int myGroupID = findClosestRelTo(myUnitID, cMyID, cUnitStateAlive, cUnitTypeMilitary);
   if (calcDistanceToUnit(myUnitID,myGroupID) > 14 && value != false)
   {
	vector A = kbUnitGetPosition(myGroupID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*12;
	int py = xsVectorGetY(path)*12;
	int pz = xsVectorGetZ(path)*12;

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint); //Do it!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microHumansVsTowers [Age2]
// (Keeping damaged soldiers away from buildings that shoot)
//
// *****************************************************************************
void microHumansVsTowers(void)		//Type: AvoidScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeHumanSoldier, true);

   if(myUnitID > -1)	//Nothing found? Skip the calculation.
   {

	int myMilCount = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
	int mhpMilCount = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);

   //current Hp lower then half of my max?
   bool conditionA = true;
   if (
	kbUnitGetCurrentHitpoints(myUnitID) > kbUnitGetMaximumHitpoints(myUnitID)*0.4
	||
	(
	    mhpMilCount > 9 && myMilCount < 16
	   &&
	    (
		kbUnitCount(cMyID, cUnitTypeMythUnit, cUnitStateAlive) < 2
		||
		kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive) < 1
	    )
	)
	||
	(
	    myMilCount*0.75 < mhpMilCount
	   &&
	    kbUnitIsType(myUnitID, cUnitTypeAbstractArcher)
	)
      )
   {
	conditionA = false;
   }

   //nearest building closer then 20 feet?
   int mhpBuildingID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeBuildingsThatShoot);
   int objectDistance = calcDistanceToUnit(myUnitID,mhpBuildingID);
   bool conditionB = false;
   if (objectDistance <= 22 && objectDistance >= 8)	//Or is it too late?
   {
	conditionB = true;
   }

   if(conditionA && conditionB)	//Both true?
   {
	vector A = kbUnitGetPosition(mhpBuildingID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*30;
	int py = xsVectorGetY(path)*30;
	int pz = xsVectorGetZ(path)*30;

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint); //Do it!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microTowersVsAll [Age2]
// (Shooting buildings focus down the weakest unit in range)
//
// *****************************************************************************
void microTowersVsAll(void)		//Type: AttackScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeBuildingsThatShoot, true);

   if(myUnitID > -1)	//If not skip the calculation.
   {
	int targetUnitID = findWeakestUnitInRadius(myUnitID,aiGetMostHatedPlayerID(),cUnitStateAlive,cUnitTypeUnit,18,-1,true);
	if(targetUnitID > -1)
	{
		aiTaskUnitWork(myUnitID, targetUnitID);
	}
   }
}

// *****************************************************************************
// ORDER: microWeakestVsAll [Age2]
// (Sending damaged soldiers away from hand combative enemies)
//
// *****************************************************************************
void microWeakestVsAll(void)		//Type: AvoidScript
{
   int myUnitID = findWeakestUnit(cMyID, cUnitStateAlive, cUnitTypeHumanSoldier);
   int myMilCount = kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive);

   if(myUnitID > -1 && myMilCount > 1)	//Not the case? Skip the calculation.
   {

   //This Unit is not on full Hp anymore?
   bool conditionA = false;
   if (kbUnitGetCurrentHitpoints(myUnitID) <= kbUnitGetMaximumHitpoints(myUnitID)*0.9)
   {
	conditionA = true;
   }

   //nearest enemy unit closer then 4 feet?
   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMilitary);
   bool conditionB = false;
   if (calcDistanceToUnit(myUnitID,mhpUnitID) < 4)
   {
	conditionB = true;
   }

   if(conditionA && conditionB)	//Both true?
   {
	vector A = kbUnitGetPosition(mhpUnitID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*12;
	int py = xsVectorGetY(path)*12;
	int pz = xsVectorGetZ(path)*12;

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint);
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microMythVsHeroes [Age2]
// (Sending damaged mythological units away from heroes)
//
// *****************************************************************************
void microMythVsHeroes(void)		//Type: AvoidScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeMythUnit, true);
   int mythMaxHP = kbUnitGetMaximumHitpoints(myUnitID);	//Make sure this is not a Titan!

   if(myUnitID > -1 && mythMaxHP < 6000)	//Not the case? Skip the calculation.
   {

   //current Hp lower then half of my max?
   bool conditionA = false;
   if (kbUnitGetCurrentHitpoints(myUnitID) <= mythMaxHP*0.8)
   {
	conditionA = true;
   }

   //nearest enemy hero closer then 5 feet?
   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeHero);
   bool conditionB = false;
   if (calcDistanceToUnit(myUnitID,mhpUnitID) < 5)
   {
	conditionB = true;
   }

   if(conditionA && conditionB)	//Both true?
   {
	vector A = kbUnitGetPosition(mhpUnitID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*12;
	int py = xsVectorGetY(path)*12;
	int pz = xsVectorGetZ(path)*12;

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint);
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microCavalryVsInfantry [Age2]
// (Sending damaged cavalry away from infantry)
//
// *****************************************************************************
void microCavalryVsInfantry(void)	//Type: AvoidScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractCavalry, true);

   if(myUnitID > -1 && kbGetAge() < cAge3)	//Not the case? Skip the calculation.
   {

   //current Hp lower then half of my max?
   bool conditionA = false;
   if (kbUnitGetCurrentHitpoints(myUnitID) <= kbUnitGetMaximumHitpoints(myUnitID)*0.6)
   {
	conditionA = true;
   }

   //nearest enemy unit closer then 4 feet?
   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeAbstractInfantry);
   bool conditionB = false;
   if (calcDistanceToUnit(myUnitID,mhpUnitID) <= 4)
   {
	conditionB = true;
   }

   if(conditionA && conditionB)	//Both true?
   {
	vector A = kbUnitGetPosition(mhpUnitID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*10;
	int py = xsVectorGetY(path)*10;
	int pz = xsVectorGetZ(path)*10;

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint); //Do it!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microShipsVsShips [Age2]
// (Sending damaged Ships out of range of enemy military)
//
// *****************************************************************************
void microShipsVsShips(void)		//Type: KitingScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeArcherShip, true, cActionRangedAttack);
   int myNavalCount = kbUnitCount(cMyID, cUnitTypeShip, cUnitStateAlive);

   if(myUnitID > -1 && myNavalCount > 1)	//Not the case? Skip the calculation.
   {

   //current Hp lower then half of my max?
   bool conditionA = false;
   if (kbUnitGetCurrentHitpoints(myUnitID) <= kbUnitGetMaximumHitpoints(myUnitID)*0.5)
   {
	conditionA = true;
   }

   //nearest enemy unit closer then my max fire distance?

	int fireAvoidDistance = 10;

	if(cMyCulture == cCultureGreek)
	{
		fireAvoidDistance = 14;
	}
	if(kbGetTechStatus(cTechCladding) == cTechStatusActive)
	{
		fireAvoidDistance = fireAvoidDistance + 2;
	}

   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMilitary);
   bool conditionB = false;
   if (calcDistanceToUnit(myUnitID,mhpUnitID) < fireAvoidDistance)
   {
	conditionB = true;
   }

   if(conditionA && conditionB)	//Both true?
   {
	vector A = kbUnitGetPosition(mhpUnitID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*30;
	int py = xsVectorGetY(path)*30;
	int pz = xsVectorGetZ(path)*30;

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint);
   }else{
	int targetUnitID = findWeakestUnitInRadius(myUnitID,aiGetMostHatedPlayerID(),cUnitStateAlive,cUnitTypeLogicalTypeNavalMilitary,fireAvoidDistance+5,-1,true);
	aiTaskUnitWork(myUnitID, targetUnitID);
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microFishingBoat [Age1]
// (Sending damaged boats into the closest dock)
//
// *****************************************************************************
void microFishingBoat(void)		//Type: GarrisonScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeUtilityShip, true);
   int retreatUnit = findClosestRelTo(myUnitID, cMyID, cUnitStateAlive, cUnitTypeDock);

   //Are we screwed if we don't take the risk?
   if (
	(kbUnitGetCurrentHitpoints(myUnitID) > kbUnitGetMaximumHitpoints(myUnitID)*0.9)
	&&
	(kbResourceGet(cResourceFood) < 150)	//We need the food!
      )
   {
	return;			//Yes, we are!
   }

   if(myUnitID > -1 && kbGetAge() >= cAge2)	//Not the case? Skip the calculation.
   {

   //nearest enemy unit closer then 20 feet?
   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMilitary);
   if (calcDistanceToUnit(myUnitID,mhpUnitID) < 18)
   {
	aiTaskUnitGarrison(myUnitID, retreatUnit);
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microDockVsFish [Age1]
// (Sending damaged boats back to work)
//
// *****************************************************************************
void microDockVsFish(void)	//Type: EjectScript
{
   int myBuildingID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeDock, true);
   int myBoatID = findClosestRelTo(myBuildingID, cMyID, cUnitStateAlive, cUnitTypeShip);

   if(myBuildingID > -1 && myBoatID > -1)	//Not the case? Skip the calculation.
   {

   //nearest enemy unit further then 20 feet?
   int mhpUnitID = findClosestRelTo(myBuildingID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMilitary);
   if (
	(calcDistanceToUnit(myBuildingID,mhpUnitID) > 26)
	&&
	(calcDistanceToUnit(myBuildingID,myBoatID) < 1)
      )
   {
	aiTaskUnitEject(myBuildingID,myBoatID);
	if(kbUnitIsType(myBoatID, cUnitTypeUtilityShip))
	{
	   //Now send them to work
	   int fishingBoundary = findFurthestRelTo(myBuildingID, cMyID, cUnitStateAlive, cUnitTypeUtilityShip);
	   int fishSpot = findClosestRelTo(fishingBoundary, 0, cUnitStateAlive, cUnitTypeFish);
	   aiTaskUnitWork(myBoatID, fishSpot);
	}
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microVillagerNEW [Age2]
// (Sending damaged villagers out of the danger zone)
//
// *****************************************************************************
void microVillagerNEW(void)		//Type: AvoidScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractVillager, true);
   int myTownID = findClosestRelTo(myUnitID, cMyID, cUnitStateAlive, cUnitTypeAbstractSettlement);
   //Are we screwed if we don't take the risk?
   if (
	(kbUnitGetCurrentHitpoints(myUnitID) > kbUnitGetMaximumHitpoints(myUnitID)*0.9)
	&&
	(
	  (kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive) <= 4)
	  ||
	  (kbUnitGetActionType(myUnitID)==cActionBuild)
	  ||
	  (kbUnitGetActionType(myUnitID)==cActionRepair)
	  ||
	  (kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive) > 50)
	)
      )
   {
	return;			//Yes, we are!
   }

   if(myUnitID > -1 && kbGetAge() >= cAge2)	//Not the case? Skip the calculation.
   {

   //nearest enemy unit closer then 20 feet?
   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMilitary);
   if (
	kbUnitGetCurrentHitpoints(myUnitID) > kbUnitGetMaximumHitpoints(myUnitID)*0.9
	&&
	(
	   kbUnitIsType(mhpUnitID, cUnitTypeScout)
	   ||
	   kbUnitIsType(mhpUnitID, cUnitTypeOracleScout)
	)
      )
   {
	return;		//Don't panic!
   }
   if (calcDistanceToUnit(myUnitID,mhpUnitID) < 18)
   {
	//First move in range of our town, then run away!
	int retreatID = -1;
	if(calcDistanceToUnit(myUnitID,myTownID) > 50 && myTownID > -1)
	{
		retreatID = myTownID;
	}else{
		retreatID = mhpUnitID;
	}
	vector A = kbUnitGetPosition(retreatID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(myUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*20;
	int py = xsVectorGetY(path)*20;
	int pz = xsVectorGetZ(path)*20;

	vector retreatPoint = xsVectorSet(ax-px,ay-py,az-pz);

	aiTaskUnitMove(myUnitID, retreatPoint);		//Run!!!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microVillager [Age2]
// (Sending damaged villagers into the closest building)
//
// *****************************************************************************
void microVillager(void)		//Type: GarrisonScript
{
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractVillager, true);
   int retreatUnit = findClosestRelTo(myUnitID, cMyID, cUnitStateAlive, cUnitTypeBuildingsThatShoot);

   //Are we screwed if we don't take the risk?
   if (
	(kbUnitGetCurrentHitpoints(myUnitID) > kbUnitGetMaximumHitpoints(myUnitID)*0.9)
	&&
	(
	  (kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive) <= 4)
	  ||
	  (kbUnitGetActionType(myUnitID)==cActionBuild)
	  ||
	  (kbUnitGetActionType(myUnitID)==cActionRepair)
	)
      )
   {
	return;			//Yes, we are!
   }

   if(myUnitID > -1 && kbGetAge() >= cAge2)	//Not the case? Skip the calculation.
   {

   //nearest enemy unit closer then 20 feet?
   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMilitary);
   if (calcDistanceToUnit(myUnitID,mhpUnitID) < 18)
   {
	aiTaskUnitGarrison(myUnitID, retreatUnit);
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microBuilder [Age1]
// (Helps to build important buildings at the front)
//
// *****************************************************************************
void microBuilder(void)			//Type: WorkScript
{
   int myBuildingID = findUnitRM(cMyID, cUnitStateBuilding, cUnitTypeBuilding, true);

   if(myBuildingID > -1)	//If not skip the calculation.
   {

   if(kbUnitIsType(myBuildingID, cUnitTypeFarm))
   {
	return;
   }
   int myUnitID = findUnitRM(cMyID, cUnitStateAlive, gBuilderType, true);
   //int myUnitID = findUnitRM(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionBuilder, 0), true);
   if(kbUnitGetActionType(myUnitID) == cActionBuild)
   {
	return;			//No multitasking!
   }

   //Is it save?
   bool conditionA = true;
   if (kbUnitGetCurrentHitpoints(myUnitID) <= kbUnitGetMaximumHitpoints(myUnitID)*0.8)
   {
	conditionA = false;
   }

   //nearest foundation is close enough?
   bool conditionB = false;
   if (calcDistanceToUnit(myUnitID,myBuildingID) < 10)
   {
	conditionB = true;
   }

   if(conditionA && conditionB)	//Both true?
   {
	aiTaskUnitWork(myUnitID, myBuildingID);		//Build it!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microTC [Age1]
// (Sending garrisoned units back to work)
//
// *****************************************************************************
void microTC(void)			//Type: EjectScript
{
   int myBuildingID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeBuildingsThatShoot, true);
   int myVillagerID = findClosestRelTo(myBuildingID, cMyID, cUnitStateAlive, cUnitTypeUnit);

   if(myBuildingID > -1 && myVillagerID > -1)	//Not the case? Skip the calculation.
   {

   //nearest enemy unit further then 20 feet?
   int mhpUnitID = findClosestRelTo(myBuildingID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeMilitary);
   if (calcDistanceToUnit(myBuildingID,mhpUnitID) > 24 || mhpUnitID < 0)
   {
	taskEjectAll(myBuildingID,cUnitTypeUnit);
   }
   else if (
	calcDistanceToUnit(myBuildingID,mhpUnitID) > 18
	&&
	kbUnitGetCurrentHitpoints(myVillagerID) > kbUnitGetMaximumHitpoints(myVillagerID)*0.7
      )
   {
	//take the risk but keep the other units save!
	aiTaskUnitEject(myBuildingID,myVillagerID);
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microMercs [Age2]
// (Task mercs to attack everything in closest range)
//
// *****************************************************************************
void microMercsVsAll(void)		//Type: AttackScript
{
   if(cMyCulture != cCultureEgyptian)
   {
		return;
   }

   int myUnitID = -1;
   if(aiRandInt(2) == 1)	//Both merc types...
   {
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeMercenary, true);
   }else{
	myUnitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeMercenaryCavalry, true);
   }

   if(myUnitID > -1)	//If not skip the calculation.
   {

   int mhpUnitID = findClosestRelTo(myUnitID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeUnit);

   //Is it a reasonable target?
   bool conditionA = true;
   if (
	kbUnitIsType(mhpUnitID, cUnitTypeFlyingUnit)
	||
	kbUnitIsType(mhpUnitID, cUnitTypeShip)
      )
   {
	conditionA = false;
   }

   //nearest target is not in auto attack range?
   bool conditionB = true;
   if (calcDistanceToUnit(myUnitID,mhpUnitID) < 8)
   {
	conditionB = false;
   }

   if(conditionA && conditionB)	//Both true?
   {
	aiTaskUnitWork(myUnitID, mhpUnitID);	//Attack!!!
   }

   } //End of skipping
}

// *****************************************************************************
// ORDER: microIdleMilitary [Age2]
//
// *****************************************************************************
void microIdleMilitary(int unitType=cUnitTypeMilitary)
{
    if(kbUnitCount(cMyID, unitType, cUnitStateAlive) < 4)
    {
	return;
    }

    int idleUnitID = findUnitRM(cMyID, cUnitStateAlive, unitType, true, cActionIdle);
    int frontUnitID = findFurthestRelTo(idleUnitID, cMyID, cUnitStateAlive, unitType);

    if (calcDistanceToUnit(idleUnitID,frontUnitID) > 30)
    {
	vector A = kbUnitGetPosition(frontUnitID);
	int ax = xsVectorGetX(A);
	int ay = xsVectorGetY(A);
	int az = xsVectorGetZ(A);

	vector B = kbUnitGetPosition(idleUnitID);
	int bx = xsVectorGetX(B);
	int by = xsVectorGetY(B);
	int bz = xsVectorGetZ(B);

	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*10;
	int py = xsVectorGetY(path)*10;
	int pz = xsVectorGetZ(path)*10;

	vector frontPoint = xsVectorSet(ax-px,ay-py,az-pz);
	aiTaskUnitMove(idleUnitID, frontPoint);
    }
}

// *****************************************************************************
// RULE: antiIdleCaravans
// (try to declutter our trade route)
//
// *****************************************************************************
rule antiIdleCaravans
   minInterval 45
   active
{
   if (kbGetAge() < cAge3)	//No market.
   {
	return;
   }
   if (kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive) < 0)
   {
	return;
   }
   int caravanID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeAbstractTradeUnit, true, cActionIdle);
   if(caravanID < 0)
   {
	return;
   }
   int buildingID = findClosestRelTo(caravanID, cMyID, cUnitStateAliveOrBuilding, cUnitTypeMilitaryBuilding);

   if (
	(calcDistanceToUnit(buildingID,caravanID) < 4)
	&&
	(kbUnitIsType(buildingID, cUnitTypeAbstractSettlement) == false)
	&&
	(kbUnitIsType(buildingID, cUnitTypeMarket) == false)
      )
   {
      aiTaskUnitDelete(buildingID);
   }
}

// *****************************************************************************
// ORDER: microArmyVSArmy [Age2,Age3]
// (avoid enemy military except inside our base)
//
// *****************************************************************************
void microArmyVSArmy(int planID=-1)	//@attackMonitor
{
	if (planID < 0 || kbGetAge() < cAge2) 	//No military in Age1.
	{
		return;
	}
	//It's quite a heavy function. Don't over do it!
	if (kbGetAge() > cAge3 || cNumberPlayers > 4)
	{
		return;
	}
	vector currentPlanPosition = aiPlanGetLocation(planID);
	int myUnitCount = aiPlanGetNumberUnits(planID, cUnitTypeMilitary);
	if(myUnitCount > 0)
	{
		int planUnit = aiPlanGetUnitByIndex(planID, 0);
		currentPlanPosition = kbUnitGetPosition(planUnit);
	}else{
		return;		//No units in plan.
	}

	int mhpID = aiGetMostHatedPlayerID();
	int mhpUnitList = getUnitsAtLocQID(mhpID,cUnitStateAlive,cUnitTypeMilitary,currentPlanPosition,30);
	int mhpUnitCount = kbUnitQueryExecute(mhpUnitList);

	int mhpUnitID = findClosestRelTo(planUnit, 0, cUnitStateAlive, cUnitTypeMilitary);
	vector path = xsVectorNormalize(kbUnitGetPosition(mhpUnitID)-currentPlanPosition)*20;

	if(mhpUnitCount*0.8 > myUnitCount)	//enemy has more units on the field
	{
	    for (i=0; < myUnitCount)	//Let's dance the engage dance!
	    {
		int myUnitID = aiPlanGetUnitByIndex(planID, i);
		vector retreatPoint = kbUnitGetPosition(myUnitID)-path;

		aiTaskUnitMove(myUnitID, retreatPoint); 	//Retreat!
	    }
	}
}

// *****************************************************************************
// RULE: microHandlerSingle [Age1]
//
// *****************************************************************************
rule microHandlerSingle
   group AttackRules
   inactive
   highFrequency
{
	microTowersVsAll();
	microArchersVsAll();
	microHeroesVsMyth();
	microMilitaryVsWalls();
	microTitanVsBuildings();
	microAntiArcherVsArcher();
	microSiegeVsBuildings();

	microMythVsHeroes();
	microCavalryVsInfantry();
	microHumansVsTowers();
	microWeakestVsAll();

	microAntiSiegeVsSiege();

	microShipsVsShips();
	microVillagerNEW();
	microBuilder();
	microMercsVsAll();

	//microIdleMilitary(cUnitTypeLogicalTypeLandMilitary);
	//microIdleMilitary(cUnitTypeLogicalTypeNavalMilitary);

}

// *****************************************************************************
// RULE: microHandlerMulti [Age1]
//
// *****************************************************************************
rule microHandlerMulti
   group AttackRules
   inactive
   minInterval 1
{
	microTowersVsAll();
	microArchersVsAll();
	microHeroesVsMyth();
	microMilitaryVsWalls();
	microTitanVsBuildings();
	microAntiArcherVsArcher();
	microSiegeVsBuildings();

	microMythVsHeroes();
	microCavalryVsInfantry();
	microHumansVsTowers();
	microWeakestVsAll();

	microAntiSiegeVsSiege();

	microShipsVsShips();
	microVillagerNEW();
	microBuilder();
	microMercsVsAll();

	//microIdleMilitary(cUnitTypeLogicalTypeLandMilitary);
	//microIdleMilitary(cUnitTypeLogicalTypeNavalMilitary);

}

// *****************************************************************************
// RULE: microStarter [Age1]
//
// *****************************************************************************
rule microStarter
   minInterval 5
   active
   runImmediately
{
	//Reduce traffic for online matches
	if(aiIsMultiplayer())
	{
	   if(cNumberPlayers > 2)
	   {
		xsEnableRule("microHandlerMulti");
	   }else{
		xsEnableRule("microHandlerSingle");
	   }
	}else{
		xsEnableRule("microHandlerSingle");
	}

	xsDisableSelf();	//Go away.

}