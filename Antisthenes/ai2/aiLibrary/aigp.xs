//==============================================================================
// AoMXaiGP.xs
//
// This is the basic logic behind the casting of the various god powers
// Although some are rule driven, much of the complex searches and casting logic
// is handled by the C++ code.
//==============================================================================
// *****************************************************************************
//
// An explanation of some of the plan types, etc. in this file:
//
// aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModel...
//   CombatDistance - This is the standard one.  The plan will get attached to an 
//   attack plan, and the attack plan performs a query, and when the number and 
//   type of enemy units you specify are within the specified distance of the 
//   attack plan's location, the god power will go off. 
//
//   CombatDistancePosition - *doesn't* get attached to an attack plan.  
//   You specify a position, and when the number and type of enemy units are within 
//   distance of that position, the power goes off.  This, for instance, could see 
//   if there are many enemy units around your town center. 
//
//   CombatDistanceSelf - this one's kind of particular.  It gets attached to an 
//   attack plan.  The query you specify in the setup determines the number and 
//   type of *friendly* units neccessary to satisfy the evaluation.  Addtionally, 
//   there must be at least 5 (currently hardcoded) enemy units within the distance 
//   value of the attack plan for it to be successful.  Then the power will go off.  
//   This is typicaly used for powers that improve friendly units, like bronze, 
//   flaming weapons, and eclipse.  
//
// 
//
// *****************************************************************************
//==============================================================================
//Globals.
extern int gCeaseFirePlanID=-1;

//==============================================================================
// findHuntableInfluence
//==============================================================================
vector findHuntableInfluence()
{
   vector townLocation=kbGetTownLocation();
   vector best=townLocation;
   float bestDistSqr=0.0;

   //Run a query.
   int queryID=kbUnitQueryCreate("Huntable Units");
   if (queryID < 0)
	  return(best);

   kbUnitQueryResetData(queryID);
   kbUnitQueryResetResults(queryID);
   kbUnitQuerySetPlayerID(queryID, 0);
   kbUnitQuerySetUnitType(queryID, cUnitTypeHuntable);
   kbUnitQuerySetState(cUnitStateAlive);
   int numberFound=kbUnitQueryExecute(queryID);

   for (i=0; < numberFound)
   {
	  vector position=kbUnitGetPosition(kbUnitQueryGetResult(queryID, i));
	  float dx=xsVectorGetX(townLocation)-xsVectorGetX(position);
	  float dz=xsVectorGetZ(townLocation)-xsVectorGetZ(position);

	  float curDistSqr=((dx*dx) + (dz*dz));
	  if (curDistSqr > bestDistSqr)
	  {
		 best=position;
		 bestDistSqr=curDistSqr;
	  }
   }

   return(best);
}

//==============================================================================
// findTownDefenseGP
//==============================================================================
int findTownDefenseGP(int baseID=-1)
{
   int townDefenseGodPowerPlanID=aiFindBestTownDefenseGodPowerPlan();
   if (townDefenseGodPowerPlanID < 0)
   {
	return(-1);
   }
   //Change the evaluation model (and remember it).
   int townDefenseEvalModel=aiPlanGetVariableInt(townDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0);
   aiPlanSetVariableInt(townDefenseGodPowerPlanID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
   //Change the player (and remember it).
   int townDefensePlayerID=aiPlanGetVariableInt(townDefenseGodPowerPlanID, cGodPowerPlanQueryPlayerID, 0);
   //Set the location.
   aiPlanSetVariableVector(townDefenseGodPowerPlanID, cGodPowerPlanQueryLocation, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)) );

   return(townDefenseGodPowerPlanID);
}

//==============================================================================
// setupGodPowerPlan
//==============================================================================
bool setupGodPowerPlan(int planID = -1, int powerProtoID = -1)
{
   if (planID == -1)
	  return (false);
   if (powerProtoID == -1)
	  return (false);

   aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));

   //-- setup prosperity
   //-- This sets up the plan to cast itself when there are 5 people working on gold
   if (powerProtoID == cPowerProsperity)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
	  aiPlanSetVariableInt(planID, cGodPowerPlanResourceType, 0, cResourceGold);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
	  return (true);
   }

   //-- setup plenty
   //-- we want this to cast in our town when we have 20 or more workers in the world (?)
   if (powerProtoID == cPowerPlenty)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
	  //-- override the default building placement distance so that plenty has some room to cast
	  //-- it is pretty big..
	  aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 100.0);
	  return (true);
   }

   //-- setup the serpents power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerPlagueofSerpents)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  return (true);
   }

   //-- setup the lure power
   //-- cast this in your town as soon as we have more than 3 huntable resources found, and towards that huntable stuff if we know about it
   if (powerProtoID == cPowerLure)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 

	  //-- create the query used for evaluation
	  int queryID=kbUnitQueryCreate("Huntable Evaluation");
	  if (queryID < 0)
		 return (false);

	  kbUnitQueryResetData(queryID);
	  kbUnitQuerySetPlayerID(queryID, 0);
	  kbUnitQuerySetUnitType(queryID, cUnitTypeHuntable);
	  kbUnitQuerySetState(cUnitStateAlive);

	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, 0);

	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, 0);
	  
	  
	  //-- now set up the targeting and the influences for targeting
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);

	  //-- this one gets special influences (maybe)
	  //-- set up from a simple query
	  //-- we also prevent the default "back of town" placement
	  aiPlanSetVariableInt(planID, cGodPowerPlanBPLocationPreference, 0, cBuildingPlacementPreferenceNone);
			
	  vector v = findHuntableInfluence();
	  aiPlanSetVariableVector(planID, cGodPowerPlanBPInfluence, 0, v);
	  aiPlanSetVariableFloat(planID, cGodPowerPlanBPInfluenceValue, 0, 10.0);
	  aiPlanSetVariableFloat(planID, cGodPowerPlanBPInfluenceDistance, 0, 100.0);
	  return (true);
   }

   //-- setup the pestilence power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 50 meters, and at least 3 buildings must be found
   //-- this works on buildings
   if (powerProtoID == cPowerPestilence)
   {
	if(gModName != "HoM")
	{
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitaryBuilding);
	  return (true);
	}
   }

   //-- setup the bronze power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 10 meters
   if (powerProtoID == cPowerBronze) 
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
	  return (true);
   }

   //-- setup the earthquake power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 40 meters
   if (powerProtoID == cPowerEarthquake)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,cGodPowerPlanDistance, 0, 40.0);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractSettlement);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
	  return (true);
   }

   //-- setup Citadel
   //-- This sets up the plan to cast itself immediately
   if (powerProtoID == cPowerCitadel)
   {
	 
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
	  return (true);
   }

   //-- setup the dwarven mine
   //-- use this when we are going to gather (so we don't allow it to cast right now)
   if (powerProtoID == cPowerDwarvenMine)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
	  //-- set up the global
	  gDwarvenMinePlanID = planID;
	  //-- enable the monitoring rule
	  xsEnableRule("rDwarvenMinePower");
	  return (true);
   }

   //-- setup the curse power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerCurse)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 55.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeAbstractVillager);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  return (true);
   }

   //-- setup the Eclipse power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 50 meters, and at least 4 myth units must be found
   //-- this works on buildings
   if (powerProtoID == cPowerEclipse)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 4);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMythUnit);
	  return (true);
   }

   //-- setup the flaming weapons
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 10 meters
   if (powerProtoID == cPowerFlamingWeapons) 
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeValidFlamingWeaponsTarget);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
	  return (true);
   }

   //-- setup the Forest Fire power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 40 meters
   if (powerProtoID == cPowerForestFire)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,cGodPowerPlanDistance, 0, 40.0);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractSettlement);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  if(gModName == "HoM")
	  {
		aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  }
	  return (true);
   }

   //-- setup the frost power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerFrost)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  return (true);
   }

   //-- setup the healing spring power
   //-- cast this within 50 meters of the military gather 
   if (powerProtoID == cPowerHealingSpring)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelMilitaryGatherPoint);
	  aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 75.0);
	  return (true);
   }

   //-- setup the lightning storm power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerLightningStorm)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 20);
	  return (true);
   }

   //-- setup the locust swarm power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 50 meters, and at least 3 farms must be found
   //-- this works on buildings
   if (powerProtoID == cPowerLocustSwarm)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 7);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractFarm);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeAbstractVillager);
	  return (true);
   }

   //-- setup the Meteor power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerMeteor)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeLogicalTypeBuildingNotTitanGate);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
	  return (true);
   }

   //-- setup the Nidhogg power
   //-- cast this in your town immediately
   if (powerProtoID == cPowerNidhogg)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
	  return (true);
   }

   //-- setup the Restoration power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerRestoration)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  if(gModName == "HoM")
	  {
		aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  }
	  return (true);
   }

   //-- setup the Sentinel power
   //-- cast this in your town immediately
   if (powerProtoID == cPowerSentinel)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTownCenter);
	  return (true);
   }

   //-- setup the Ancestors power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 20 meters
   if (powerProtoID == cPowerAncestors)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  return (true);
   }

   //-- setup the Fimbulwinter power
   //-- cast this in your town immediately
   if (powerProtoID == cPowerFimbulwinter)
   {
	if(gModName != "HoM")
	{
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
	  aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 60.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  return (true);
	}
   }

   //-- setup the Tornado power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 100 meters
   if (powerProtoID == cPowerTornado)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeLogicalTypeBuildingNotTitanGate);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  return (true);
   }

   //-- setup Undermine
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 50 meters, and at least 3 wall segments must be found
   //-- this works on buildings
   if (powerProtoID == cPowerUndermine)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 3);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeAbstractWall);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeBuildingsThatShoot);
	  return (true);
   }

   //-- setup the great hunt
   //-- this power makes use of the KBResource evaluation condition
   //-- to find the best huntable kb resource with more than 600 total food.
   if (powerProtoID == cPowerGreatHunt)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelKBResource);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);

	  aiPlanSetVariableInt(planID,  cGodPowerPlanResourceType, 0, cResourceFood);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanResourceSubType, 0, cAIResourceSubTypeEasy);
	  aiPlanSetVariableBool(planID,  cGodPowerPlanResourceFilterHuntable, 0, true);
	  aiPlanSetVariableFloat(planID, cGodPowerPlanResourceFilterTotal, 0, 450.0);
	  return (true);
   }

   //-- setup the bolt power
   //-- cast this on the first titan or let the rule deal with it
   if (powerProtoID == cPowerBolt)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	 
	   //-- create the query used for evaluation
	  queryID=kbUnitQueryCreate("Bolt Evaluation");
	  if (queryID < 0)
		 return (false);

	  kbUnitQueryResetData(queryID);
	  kbUnitQuerySetPlayerID(queryID, aiGetMostHatedPlayerID());
	  kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
	  kbUnitQuerySetState(cUnitStateAlive);

	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());

	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
	  aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 350.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());

	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
	  return (true);
   }

   //-- setup the spy power
   if (powerProtoID == cPowerSpy)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	 
	   //-- create the query used for evaluation
	  queryID=kbUnitQueryCreate("Spy Evaluation");
	  if (queryID < 0)
		 return (false);

	  kbUnitQueryResetData(queryID);
	  kbUnitQuerySetPlayerRelation(cPlayerRelationEnemy);
	  kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
	  kbUnitQuerySetState(cUnitStateAlive);

	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);

	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
	  return (true);
   }

   //-- setup the Son of Osiris
   if (powerProtoID == cPowerSonofOsiris)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 

	  //-- create the query used for evaluation
	  queryID=kbUnitQueryCreate("Osiris Evaluation");
	  if (queryID < 0)
		 return (false);

	  kbUnitQueryResetData(queryID);
	  kbUnitQuerySetPlayerID(queryID, cMyID);
	  kbUnitQuerySetUnitType(queryID, cUnitTypePharaoh);
	  kbUnitQuerySetState(cUnitStateAlive);

	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);

	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);

	  //-- kill the empower plan and relic gather plans.
	  aiPlanDestroy(gEmpowerPlanID);
	  aiPlanDestroy(gRelicGatherPlanID);

	  return (true);
   }

   //-- setup the vision power
   if (powerProtoID == cPowerVision)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  //-- don't need visiblity to cast this one.
	  aiPlanSetVariableBool(planID, cGodPowerPlanCheckVisibility, 0, false);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	 
	  vector vLoc = vector(-1.0, -1.0, -1.0);

	  //-- calculate the location to vision
	  //-- find the center of the map
	  vector vCenter = kbGetMapCenter();
	  vector vTC = kbGetTownLocation();
	  float centerx = xsVectorGetX(vCenter);
	  float centerz = xsVectorGetZ(vCenter);
	  float xoffset =  centerx - xsVectorGetX(vTC);
	  float zoffset =  centerz - xsVectorGetZ(vTC);

	  //xoffset = xoffset * -1.0;
	  //zoffset = zoffset * -1.0;

	  centerx = centerx + xoffset;
	  centerz = centerz + zoffset;

	  //-- cast this on the newly created location (reflected across the center)
	  vLoc = xsVectorSetX(vLoc, centerx);
	  vLoc = xsVectorSetZ(vLoc, centerz);

	  aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, vLoc);


	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  return (true);
   }

   //-- setup the rain power to cast when we have at least 10 farms
   if (powerProtoID == cPowerRain)
   {
	if(cvMasterDifficulty > cDifficultyHard)
	{
		xsEnableRule("castTacticalRain");	//NEW
	}
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);

	  //-- create the query used for evaluation
	  queryID=kbUnitQueryCreate("Rain Evaluation");
	  if (queryID < 0)
		 return (false);

	  kbUnitQueryResetData(queryID);
	  kbUnitQuerySetPlayerID(queryID, cMyID);
	  kbUnitQuerySetUnitType(queryID, cUnitTypeFarm);
	  kbUnitQuerySetState(cUnitStateAlive);

	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 14);


	  return (true);
   }

   //-- setup Cease Fire
   //-- This sets up the plan to not cast itself
   //-- we also enable a rule that monitors the state of the player's main base
   //-- and waits until the base is under attack and has no defenders
   if (powerProtoID == cPowerCeaseFire)
   { 
	  gCeaseFirePlanID = planID;
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, false); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
	  xsEnableRule("rCeaseFire");
	  return (true);
   }

   //-- setup the Walking Woods power
   //-- this power will cast when it has a valid attack plan within the specified range
   //-- the attack plan is setup in the initializeAttack function  
   //-- the valid distance is 10 meters
   if (powerProtoID == cPowerWalkingWoods) 
   {
	  //-- basic plan type and eval model
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);

	  //-- setup the nearby unit type to cast on
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeTree);

	  //-- finish setup
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  return (true);
   }

   //-- setup the Ragnorok Power
   //-- launch at 50 villagers
   if (powerProtoID == cPowerRagnorok)
   {
	if(gModName != "HoM")
	{
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	 
	   //-- create the query used for evaluation
	  queryID=kbUnitQueryCreate("Ragnorok Evaluation");
	  if (queryID < 0)
		 return (false);

	  kbUnitQueryResetData(queryID);
	  kbUnitQuerySetPlayerID(queryID, cMyID);
	  kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
	  kbUnitQuerySetState(cUnitStateAlive);

	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 50);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);

	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
	  return (true);
	}
   }

   // Set up the Gaia Forest power
   // Just fire and refire whenever we can, in the town.  This will keep a supply of fast-harvesting
   // wood in the well-protected zone around the player's town.
   if (powerProtoID == cPowerGaiaForest)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the Thunder Clap power
   // Logic similar to bronze...look for 5+ enemy units within 30 meters of the attack plan's position
   if (powerProtoID == cPowerTremor)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	//  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMilitary);  // Var 1 is type to target on?
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the deconstruction power
   // Any building over 500 HP counts, cast it on building
   if (powerProtoID == cPowerDeconstruction)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	 
	   //-- create the query used for evaluation
	  queryID=kbUnitQueryCreate("Deconstruction Evaluation");
	  if (queryID < 0)
		 return (false);

	  kbUnitQueryResetData(queryID);
	  kbUnitQuerySetPlayerRelation(queryID, cPlayerRelationEnemy);
	  kbUnitQuerySetUnitType(queryID, cUnitTypeLogicalTypeValidDeconstructionTarget);
	  kbUnitQuerySetState(cUnitStateAlive);

	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	//  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());

	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
	  aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 500.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	//  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());

	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);   
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the Carnivora power
   // Exactly like Serpents
   if (powerProtoID == cPowerCarnivora)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	//  aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the Spiders power
   // Can't be reactive because of time delay.  Would like to place it
   // on gold mines or markets, if we haven't already spidered that location
   //----For now, just copy carnivora
   if (powerProtoID == cPowerSpiders)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the heroize power
   // Any time we have a group of 8 or more military units
   if (powerProtoID == cPowerHeroize)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 20.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 8);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the chaos power
   // 12 enemy mil units within 30m of attack plan
   if (powerProtoID == cPowerChaos)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
	//  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
	//  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMilitary);  // Target on this type
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the Traitors power
   // Same as bolt, anything over 200 HP
   if (powerProtoID == cPowerTraitors)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	 
	   //-- create the query used for evaluation
	  queryID=kbUnitQueryCreate("Traitors Evaluation");
	  if (queryID < 0)
		 return (false);

	  kbUnitQueryResetData(queryID);
	  kbUnitQuerySetPlayerRelation(queryID, cPlayerRelationEnemy);
	  kbUnitQuerySetUnitType(queryID, cUnitTypeMilitary);
	  kbUnitQuerySetState(cUnitStateAlive);

	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
	  aiPlanSetVariableFloat(planID, cGodPowerPlanQueryHitpointFilter, 0, 500.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
	  aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerRelation, 0, cPlayerRelationEnemy);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnit);
	  return (true);
   }
   /*  Replaced 2003/05/08 MK
   if (powerProtoID == cPowerTraitors)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMilitary);  // Target on this type
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }
   */

   // Set up the hesperides power
   // Near the military gather point, for good protection
   if (powerProtoID == cPowerHesperides)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelNone);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelMilitaryGatherPoint);
	  aiPlanSetVariableFloat(planID, cGodPowerPlanBuildingPlacementDistance, 0, 25.0);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the implode power
   // Look for at least a dozen units, target it on a building (to be sure at least one exists)
   if (powerProtoID == cPowerImplode)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelNearbyUnitType);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeUnit);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeBuilding);  // Target on this type
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the tartarian gate power
   // Fire if >= 4 military buildings near my army...will kill my army, but may take out their center, too.
   if (powerProtoID == cPowerTartarianGate)
   {
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
	  aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 40.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeFarm);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 1, cUnitTypeMarket);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 5);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

   // Set up the vortex power
   // If there are at least 15 (count 'em) enemy military units in my town, panic!
   // Screw this, we use vortex to attack the enemy base.
   if (powerProtoID == cPowerVortex)
   {
	if(cvMasterDifficulty > cDifficultyHard)
	{
		xsEnableRule("castAggressiveVortex");	//NEW
	}
	  aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true);
	  aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistancePosition);
	  aiPlanSetVariableVector(planID, cGodPowerPlanTargetLocation, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	  aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
	  aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
	  aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
	  aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
	  aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
	  aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
	  return (true);
   }

//totd DLC
	// Set up the Barrage power
	// 20 enemy military units within 30m of attack plan
	if(powerProtoID == cPowerBarrage)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 12);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);
	}
	// Set up the Call to Arms power
	// If we have a group of 10 or more military units. Lets hope there is a mythunit present
	if(powerProtoID == cPowerCallToArms)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistanceSelf);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 0.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		return (true);
	}
	// Set up the Earth Dragon power
	// Near units or buildings?
	if(powerProtoID == cPowerEarthDragon)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 30.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		//aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeBuildingsThatShoot);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 1);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		aiPlanSetVariableBool(planID, cGodPowerPlanMultiCast, 0, true);
		return (true);
	}
	// Set up the Examination power
	// At least 50 villagers
	if(powerProtoID == cPowerExamination)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 

		 //-- create the query used for evaluation
		queryID = kbUnitQueryCreate("Examination Evaluation");
		if (queryID < 0)
		   return (false);

		kbUnitQueryResetData(queryID);
		kbUnitQuerySetPlayerID(queryID, cMyID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeAbstractVillager);
		kbUnitQuerySetState(cUnitStateAlive);

		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 48);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);

		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		return (true);
	}
	// Set up the Geyser power
	// Atleast 15 enemies lets hope we can get an army at once
	// And we can place it nearby our army as we cannot be damaged by it (range is 10m)
	if(powerProtoID == cPowerGeyser)
	{ 
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 10.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 15);
		aiPlanSetVariableBool(planID, cGodPowerPlanTownDefensePlan, 0, true);
		return (true);
	}
	// Set up the Inferno power
	// Atleast 25 enemies
	// Dangerous for us too (range is 50 and not in our base!)
	if(powerProtoID == cPowerInferno)
	{ 
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 25);
		return (true);
	}
	// Set up the Journey power
	// At least 70 units
	if(powerProtoID == cPowerJourney)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 

		 //-- create the query used for evaluation
		queryID = kbUnitQueryCreate("Journey Evaluation");
		if (queryID < 0)
		   return (false);

		kbUnitQueryResetData(queryID);
		kbUnitQuerySetPlayerID(queryID, cMyID);
		kbUnitQuerySetUnitType(queryID, cUnitTypeLogicalTypeUnitsNotBuildings);
		kbUnitQuerySetState(cUnitStateAlive);

		aiPlanSetVariableInt(planID, cGodPowerPlanQueryID, 0, queryID);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 70);
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelQuery);
		aiPlanSetVariableInt(planID, cGodPowerPlanQueryPlayerID, 0, cMyID);

		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		return (true);
	}
	// Set up the Recreation power
	// Or actually destroy the plan and use painful manual casting
	if(powerProtoID == cPowerRecreation)
	{
		aiPlanDestroy(planID);
		xsEnableRule("rRecreation");
		return (false);
	}
	// Set up the Timber Harvest power
	// We want 10 villagers on wood
	if(powerProtoID == cPowerTimberHarvest)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 10);
		aiPlanSetVariableInt(planID, cGodPowerPlanResourceType, 0, cResourceWood);
		aiPlanSetVariableInt(planID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelWorld);
		return (true);
	}
	// Set up the Tsunami power
	// Or actually destroy the plan and use painful manual casting
	if(powerProtoID == cPowerTsunami)
	{
		xsEnableRule("rTsunami");
		return (false);
	}
	// Set up the Uproot power
	if(powerProtoID == cPowerUproot)
	{
		aiPlanSetVariableBool(planID, cGodPowerPlanAutoCast, 0, true); 
		aiPlanSetVariableInt(planID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
		aiPlanSetVariableInt(planID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
		aiPlanSetVariableInt(planID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelLocation);
		aiPlanSetVariableFloat(planID,  cGodPowerPlanDistance, 0, 50.0);
		aiPlanSetVariableInt(planID, cGodPowerPlanCount, 0, 6);
		aiPlanSetVariableInt(planID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeBuildingNotTitanGate);
		return (true);
	}
	// Set up the Year of the Goat power
	// Or actually destroy the plan and use manual casting
	if(powerProtoID == cPowerYearOfTheGoat)
	{
		xsEnableRule("rYearOfTheGoat");
		return (false);
	}

	//Check for mod god powers.
	bool postInject = false;
	postInject = injectModGodPowers(planID,powerProtoID);

   return (postInject);
}

//==============================================================================
// initGP - initialize the god power module
//==============================================================================
void initGodPowers(void)
{
   printEcho("GP Init.");
}
// Age 4 freeze not caused by the rules below
//==============================================================================
// Age 1 GP Rule
//==============================================================================
rule rAge1FindGP
   minInterval 12
   active
{
	int id=aiGetGodPowerTechIDForSlot(0); 
	if (id == -1)
		return;

	gAge1GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan.
	gAge1GodPowerPlanID=aiPlanCreate("Age1GodPower", cPlanGodPower);
	if (gAge1GodPowerPlanID == -1)
	{
	   //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
	}

	aiPlanSetVariableInt(gAge1GodPowerPlanID,  cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gAge1GodPowerPlanID, 100);
	aiPlanSetEscrowID(gAge1GodPowerPlanID, -1);

   //Setup the god power based on the type.
   if (setupGodPowerPlan(gAge1GodPowerPlanID, gAge1GodPowerID) == false)
   {
	  aiPlanDestroy(gAge1GodPowerPlanID);
	  gAge1GodPowerID=-1;
	  xsDisableSelf();
	  return;
   }

   if (cvOkToUseAge1GodPower == true)
	aiPlanSetActive(gAge1GodPowerPlanID);

	//Kill ourselves if we every make a plan.
	xsDisableSelf();
}


//==============================================================================
// Age 2 GP Rule
//==============================================================================
rule rAge2FindGP
   minInterval 12
   inactive
{
	//Figure out the age2 god power and create the plan.
	int id=aiGetGodPowerTechIDForSlot(1); 
	if (id == -1)
	  return;

	gAge2GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan.
	gAge2GodPowerPlanID=aiPlanCreate("Age2GodPower", cPlanGodPower);
	if (gAge2GodPowerPlanID == -1)
   {
	  //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
   }

	aiPlanSetVariableInt(gAge2GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gAge2GodPowerPlanID, 100);
	aiPlanSetEscrowID(gAge2GodPowerPlanID, -1);

   //Setup the god power based on the type.
   if (setupGodPowerPlan(gAge2GodPowerPlanID, gAge2GodPowerID) == false)
   {
	  aiPlanDestroy(gAge2GodPowerPlanID);
	  gAge2GodPowerID = -1;
	  xsDisableSelf();
	  return;
   }

   printEcho("initializing god power plan for age 2");
   if (cvOkToUseAge2GodPower == true)
	  aiPlanSetActive(gAge2GodPowerPlanID);

	//Kill ourselves if we every make a plan.
	xsDisableSelf();
}


//==============================================================================
// Age 3 GP Rule
//==============================================================================
rule rAge3FindGP
   minInterval 12
   inactive
{
	//Figure out the age3 god power and create the plan.
	int id=aiGetGodPowerTechIDForSlot(2); 
	if (id == -1)
	  return;

	gAge3GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan
	gAge3GodPowerPlanID=aiPlanCreate("Age3GodPower", cPlanGodPower);
	if (gAge3GodPowerPlanID == -1)
	{
	   //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
   }

	aiPlanSetVariableInt(gAge3GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gAge3GodPowerPlanID, 100);
	aiPlanSetEscrowID(gAge3GodPowerPlanID, -1);

   //Setup the god power based on the type.
   if (setupGodPowerPlan(gAge3GodPowerPlanID, gAge3GodPowerID) == false)
   {
	  aiPlanDestroy(gAge3GodPowerPlanID);
	  gAge3GodPowerID = -1;
	  xsDisableSelf();
	  return;
   }

   printEcho("initializing god power plan for age 3");
   if (cvOkToUseAge3GodPower == true)
	  aiPlanSetActive(gAge3GodPowerPlanID);

   //Kill ourselves if we every make a plan.
	xsDisableSelf();
}


//==============================================================================
// Age 4 GP Rule
//==============================================================================
rule rAge4FindGP
   minInterval 12
   inactive
{
	//Figure out the age4 god power and create the plan.
	int id = aiGetGodPowerTechIDForSlot(3); 
	if (id == -1)
	  return;

	gAge4GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan.
	gAge4GodPowerPlanID=aiPlanCreate("Age4GodPower", cPlanGodPower);
	if (gAge4GodPowerPlanID == -1)
   {
	  //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
   }

	aiPlanSetVariableInt(gAge4GodPowerPlanID, cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gAge4GodPowerPlanID, 100);
	aiPlanSetEscrowID(gAge4GodPowerPlanID, -1);

   //Setup the god power based on the type.
   if (setupGodPowerPlan(gAge4GodPowerPlanID, gAge4GodPowerID) == false)
   {
	  aiPlanDestroy(gAge4GodPowerPlanID);
	  gAge4GodPowerID=-1;
	  xsDisableSelf();
	  return;
   }

   printEcho("initializing god power plan for age 4");
   if (cvOkToUseAge4GodPower == true)
	  aiPlanSetActive(gAge4GodPowerPlanID);

   //Kill ourselves if we every make a plan.
	xsDisableSelf();
	return;
}

//==============================================================================
// Cease Fire Rule
//==============================================================================
rule rCeaseFire
   minInterval 41
   inactive
{
   static int defCon=0;
   bool nowUnderAttack=kbBaseGetUnderAttack(cMyID, kbBaseGetMainID(cMyID));

   //Not in a state of alert.
   if (defCon == 0)
   {
	  //Just get out if we are safe.
	  if (nowUnderAttack == false)
		 return;  
	  //Up the alert level and come back later.
	  defCon=defCon+1;
	  return;
   }

   //If we are no longer under attack and below this point, then reset and get out.
   if (nowUnderAttack == false)
   {
	  defCon=0;
	  return;
   }

   //Otherwise handle the different alert levels.
   //Do we have any help in the area that we can use?
   //If we don't have a query ID, create it.
   static int allyQueryID=-1;
   if (allyQueryID < 0)
   {
	  allyQueryID=kbUnitQueryCreate("AllyCount");
	  //If we still don't have one, bail.
	  if (allyQueryID < 0)
		 return;
   }

   //Else, setup the query data.
   kbUnitQuerySetPlayerRelation(cPlayerRelationAlly);
   kbUnitQuerySetUnitType(allyQueryID, cUnitTypeMilitary);
   kbUnitQuerySetState(allyQueryID, cUnitStateAlive);
   //Reset the results.
   kbUnitQueryResetResults(allyQueryID);
   //Run the query. 
   int count=kbUnitQueryExecute(allyQueryID);

   //If there are still allies in the area, then just stay at this alert level.
   if (count > 0)
	  return;

   //Defcon 2.  Cast the god power.
   aiPlanSetVariableBool(gCeaseFirePlanID, cGodPowerPlanAutoCast, 0, true); 
   xsDisableSelf();
}


//==============================================================================
// Unbuild Rule   
//==============================================================================
rule rUnbuild
   minInterval 12
   inactive
{

	//Create the plan.
	gUnbuildPlanID = aiPlanCreate("Unbuild", cPlanGodPower);
	if (gUnbuildPlanID == -1)
	{
	   //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
	}

//  aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gUnbuildPlanID, 100);
	aiPlanSetEscrowID(gUnbuildPlanID, -1);

   //Setup the plan.. 
   // these are first pass.. fix these eventually.. 
   aiPlanSetVariableBool(gUnbuildPlanID, cGodPowerPlanAutoCast, 0, true); 
   aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelCombatDistance);
   aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanQueryPlayerID, 0, aiGetMostHatedPlayerID());
//   aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelAttachedPlanLocation);
   aiPlanSetVariableInt(gUnbuildPlanID,  cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelUnbuild);
   aiPlanSetVariableFloat(gUnbuildPlanID,  cGodPowerPlanDistance, 0, 40.0);
   aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanUnitTypeID, 0, cUnitTypeLogicalTypeBuildingsNotWalls);
   aiPlanSetVariableInt(gUnbuildPlanID, cGodPowerPlanCount, 0, 1);


	aiPlanSetActive(gUnbuildPlanID);

	//Kill ourselves if we every make a plan.
	xsDisableSelf();
}

//==============================================================================
// canAffordSpeedUpConstruction(int queryID, int index)
// Function to check whether we can afford a speed up
//==============================================================================
bool canAffordSpeedUpConstruction(int queryID = -1, int index = -1, int escrowID = -1)
{
	int gold  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceGold );
	int wood  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceWood );
	int food  = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceFood );
	int favor = kbBuildingGetSpeedUpConstructionCost(queryID, index, cResourceFavor);
	if(kbEscrowGetAmount(escrowID, cResourceGold)<gold)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceWood)<wood)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceFood)<food)
	{
		return(false);
	}
	if(kbEscrowGetAmount(escrowID, cResourceFavor)<favor)
	{
		return(false);
	}
	return(true);
}

//==============================================================================
// castTacticalRain
//==============================================================================
rule castTacticalRain
minInterval 16
inactive
{
    if(kbGetAge() > cAge1)	//Age2
    {
	int numFarmsNeeded = 12-4*(cvRushBoomSlider+1);	//Wait for more farms when booming.
	int numFarms = kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
	if(numFarms >= numFarmsNeeded)
	{
		aiCastGodPowerAtPosition(cTechRain,kbGetTownLocation() + vector(1,1,1));
		xsDisableSelf();
	}
    }
}
//==============================================================================
// castAggressiveVortex
//==============================================================================
rule castAggressiveVortex
minInterval 34
inactive
{
    int myMilCount = kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive);
    int mySiegeCount = kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
    if(myMilCount > 25 && mySiegeCount > 1)
    {
	int mhpTcID = findUnit(aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeAbstractSettlement, true);
	vector mhpTcLoc = kbUnitGetPosition(mhpTcID) + vector(8,8,8);
	if(mhpTcID >= 0)
	{
/*
		if(kbUnitCount(cMyID, cUnitTypeAttackRevealer, cUnitStateAlive) < 0)	//We need vision!
		{
			//Note: Only spawns in LOS!
			aiUnitCreateCheat(cMyID, cUnitTypeAttackRevealer, mhpTcLoc, "AttackRevealer" + cMyID, 1);
			xsSetRuleMinIntervalSelf(1);
			return;
		}else{
			xsSetRuleMinIntervalSelf(36);
		}
*/
		aiCastGodPowerAtPosition(cTechVortex,mhpTcLoc);
	}
    }
}
//==============================================================================
// rSpeedUpBuilding
// There are some times we want to speed up when possible:
// - economic buildings so we can get an edge over the other players as long as
// it doesn't mess up our age times.
// - military buildings in classical and higher
// Script is somewhat weird atm as the functions require queryID and indices
// We might want to add randomness as now every building is sped up ^^
//==============================================================================
rule rSpeedUpBuilding
minInterval 6
inactive
{
	// Set up a query
	static int queryID = -1;
	if(queryID ==-1)
	{
		queryID = kbUnitQueryCreate("Unit_ID_Query");
	}
	// Look for constructions
	kbUnitQuerySetPlayerID(queryID, cMyID);
	kbUnitQuerySetUnitType(queryID, cUnitTypeBuilding);
	kbUnitQuerySetState(queryID, cUnitStateBuilding);
	int numConstructions = kbUnitQueryExecute(queryID);
	for(i =0; < numConstructions)
	{
		int buildingID = kbUnitQueryGetResult(queryID,i);
		if(kbBuildingCanSpeedUpConstruction(queryID, i))
		{
			// Things we should speed up
			if(kbUnitIsType(buildingID,cUnitTypeEconomicBuilding))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cEconomyEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cEconomyEscrowID);
				}
			}
			else if(kbUnitIsType(buildingID,cUnitTypeAbstractTemple))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cEconomyEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cEconomyEscrowID);
				}
			}
			else if(kbUnitIsType(buildingID,cUnitTypeDropsite))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cEconomyEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cEconomyEscrowID);
				}
			}
			else if(kbUnitIsType(buildingID,cUnitTypeAbstractDock))
			{
				if(canAffordSpeedUpConstruction(queryID,0,cEconomyEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cEconomyEscrowID);
				}
			}
			else if(kbUnitIsType(buildingID,cUnitTypeBuilding)&&kbGetAge()>cAge1)
			{
				if(canAffordSpeedUpConstruction(queryID,0,cMilitaryEscrowID))
				{
					kbBuildingPushSpeedUpConstructionButton(queryID, 0, cMilitaryEscrowID);
				}
			}
		}
	}
}

//==============================================================================
// rRecreation
// There are some times we want to cast recreation:
// - 1 dead villager in archaic -> rule interval is very low, every second counts
// - 2 dead villagers in classical
// - 3 dead villagers in heroic and later
// - No enemy army nearby otherwise they get killed, resurrected and killed again
//==============================================================================
rule rRecreation
minInterval 1
inactive
{
	static int deadQuery = -1;
	static int deadNearbyQuery = -1;
	static int enemyQuery = -1;
	float enemyRange = 20.0;
	int numRequired  = 1;// Early we want every villager to be alive
	if(kbGetAge()==cAge2)
	{
		xsSetRuleMinIntervalSelf(10);// Less important
		numRequired = 2;
	}
	if(kbGetAge()>cAge2)
	{
		xsSetRuleMinIntervalSelf(10);
		numRequired = 3;
	}
	// Set up queries
	if(deadQuery == -1)
	{
		deadQuery = kbUnitQueryCreate("Dead Villager Query");
		kbUnitQuerySetPlayerID(deadQuery, cMyID);
		kbUnitQuerySetUnitType(deadQuery, cUnitTypeVillagerChineseDeadReplacement);
		kbUnitQuerySetState(deadQuery, cUnitStateAny);
	}
	kbUnitQueryResetResults(deadQuery);
	if(deadNearbyQuery == -1)
	{
		deadNearbyQuery = kbUnitQueryCreate("Dead Nearby Villager Query");
		kbUnitQuerySetPlayerID(deadNearbyQuery, cMyID);
		kbUnitQuerySetUnitType(deadNearbyQuery, cUnitTypeVillagerChineseDeadReplacement);
		kbUnitQuerySetState(deadNearbyQuery, cUnitStateAny);
	}
	int numDead = kbUnitQueryExecute(deadQuery);
	if(enemyQuery == -1)
	{
		enemyQuery = kbUnitQueryCreate("Enemy Army Query");
		kbUnitQuerySetPlayerID(enemyQuery, cMyID);
		kbUnitQuerySetPlayerRelation(enemyQuery, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyQuery, cUnitTypeMilitary);
		kbUnitQuerySetState(enemyQuery, cUnitStateAlive);
	}
	// Loop through all the dead villagers we found
	for(i=0;<numDead)
	{
		vector position = kbUnitGetPosition(kbUnitQueryGetResult(deadQuery,i));
		kbUnitQueryResetResults(enemyQuery);
		kbUnitQuerySetPosition(enemyQuery,position);
		kbUnitQuerySetMaximumDistance(enemyQuery,enemyRange);
		// Check for enemies
		if(kbUnitQueryExecute(enemyQuery)==0)
		{
			// We want atleast 2 dead villagers
			kbUnitQueryResetResults(deadNearbyQuery);
			kbUnitQuerySetPosition(deadNearbyQuery,position);
			kbUnitQuerySetMaximumDistance(deadNearbyQuery,10);// GP range
			if(kbUnitQueryExecute(deadNearbyQuery)>1)
			{
				// 2 villagers to be revived lets go!
				if(aiCastGodPowerAtPosition(cTechRecreation,position))
				{
					// Did we make it? Kill the rule if so
					xsDisableSelf();
				}
			}
		}
	}
}

//==============================================================================
// rTsunami
// When to cast Tsunami:
// - Enemy town
// - Enough enemy buildings and units
// Then we want to know how to cast Tsunami:
// - In the direction of the houses
// This is gonna be ugly
//==============================================================================
rule rTsunami
minInterval 5
inactive
{
	static int enemyTownQuery = -1;
	static int enemyUnitsQuery = -1;
	static int directionQuery = -1;
	float townRange = 25;
	int numReqUnits = 25;
	if(enemyTownQuery == -1)
	{
		enemyTownQuery = kbUnitQueryCreate("Enemy Town Query"+cMyID);
		//kbUnitQuerySetPlayerID(enemyTownQuery, cMyID);
		kbUnitQuerySetPlayerRelation(enemyTownQuery, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyTownQuery, cUnitTypeAbstractSettlement);
		kbUnitQuerySetState(enemyTownQuery, cUnitStateAlive);
	}
	if(enemyUnitsQuery == -1)
	{
		enemyUnitsQuery = kbUnitQueryCreate("Enemy Units Query"+cMyID);
		//kbUnitQuerySetPlayerID(enemyUnitsQuery, cMyID);
		kbUnitQuerySetPlayerRelation(enemyUnitsQuery, cPlayerRelationEnemy);
		kbUnitQuerySetUnitType(enemyUnitsQuery, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);
		kbUnitQuerySetState(enemyUnitsQuery, cUnitStateAliveOrBuilding);
	}
	if(directionQuery == -1)
	{
		directionQuery = kbUnitQueryCreate("Enemy Tower Query"+cMyID);
		//kbUnitQuerySetPlayerID(directionQuery, cMyID);
		kbUnitQuerySetPlayerRelation(directionQuery, cPlayerRelationEnemy);
		kbUnitQuerySetState(directionQuery, cUnitStateAlive);
	}
	int numTowns = kbUnitQueryExecute(enemyTownQuery);
	for(i=0;< numTowns)
	{
		vector position = kbUnitGetPosition(kbUnitQueryGetResult(enemyTownQuery,i));
		kbUnitQueryResetResults(enemyUnitsQuery);
		kbUnitQuerySetPosition(enemyUnitsQuery, position);
		kbUnitQuerySetMaximumDistance(enemyUnitsQuery,townRange);
		if(kbUnitQueryExecute(enemyUnitsQuery)>=numReqUnits)
		{
			// Valid town
			// Now get a good direction... I guess players and AI all love towers so lets try and nuke those
			kbUnitQueryResetResults(directionQuery);
			kbUnitQuerySetUnitType(directionQuery, cUnitTypeTower);
			kbUnitQuerySetPosition(directionQuery, position);
			kbUnitQuerySetMaximumDistance(directionQuery,townRange);
			int numBuildings = kbUnitQueryExecute(directionQuery);
			if(numBuildings==0)// Try other military buildings :/
			{
				kbUnitQueryResetResults(directionQuery);
				kbUnitQuerySetUnitType(directionQuery, cUnitTypeMilitaryBuilding);
				numBuildings = kbUnitQueryExecute(directionQuery);
			}
			if(numBuildings==0)// Still nothing
			{
				// This should never happen as we already checked for this but maybe in the nanosecond all the buildings died...
				continue;// Better luck next town
			}
			// Okay now the shit that is super easy but is always done in the wrong order... Even by the devs so we have to fix that too
			// aiCastGodPowerAtPositionFacingPosition() basically faces in the opposite direction because the dev rushed it.
			vector startPosition = kbUnitGetPosition(kbUnitQueryGetResult(directionQuery,0));
			// So uhm get the distance between the start and end position do that 2x and subtract it from the realfinalposition
			vector finalPosition = position - (position-startPosition)*2;
			if(aiCastGodPowerAtPositionFacingPosition(cTechTsunami,startPosition,finalPosition))
			{
				// Yay we did it!
				printEcho("Thanks WarriorMario for helping me out here ;)");
			}
			
		}
	}
	
}

//==============================================================================
// rYearOfTheGoat 
//==============================================================================
rule rYearOfTheGoat
minInterval 12
inactive
{
	vector position = kbGetTownLocation()+ vector(2,2,2);// Little bit off the town position
	// Cast in archaic because we're rushing
	if(cvRushBoomSlider>0.5)
	{
		aiCastGodPowerAtPosition(cTechYearoftheGoat,position);
	}
	else if(cvRushBoomSlider>0.0&&kbGetAge()>cAge1)
	{
		aiCastGodPowerAtPosition(cTechYearoftheGoat,position);
	}
	else if(kbGetAge()>cAge2)
	{
		aiCastGodPowerAtPosition(cTechYearoftheGoat,position);
	}
	
}
//==============================================================================
// Age 2 Handler
//==============================================================================
void gpAge2Handler(int age=1)
{
   xsEnableRule("rAge2FindGP");
}

//==============================================================================
// Age 3 Handler
//==============================================================================
void gpAge3Handler(int age=2)
{
	xsEnableRule("rAge3FindGP");  
}

//==============================================================================
// Age 4 Handler
//==============================================================================
void gpAge4Handler(int age=3)
{
	xsEnableRule("rAge4FindGP");
}

//==============================================================================
// Dwarven Mine Rule
//==============================================================================
rule rDwarvenMinePower
   minInterval 59
   inactive
{
   if (gDwarvenMinePlanID == -1)
   {
	  xsDisableSelf();
	  return;
   }

   //Are we in the third age yet??
   if (kbGetAge() < 2)
	  return;

   //Are we gathering gold?  If so, then enable the gold mine to be cast.
   float fPercent=aiGetResourceGathererPercentage(cResourceGold, cRGPActual);
   if (fPercent <= 0.0)
	  return;
	   
   aiPlanSetVariableBool(gDwarvenMinePlanID, cGodPowerPlanAutoCast, 0, true);
   
   //Finished.
   gDwarvenMinePlanID=-1;
   xsDisableSelf();
}

//==============================================================================
// unbuildHandler
//==============================================================================
void unbuildHandler(void)
{
   xsEnableRule("rUnbuild");
}

//==============================================================================
// Titan Gate Rule
//==============================================================================
rule rPlaceTitanGate
   minInterval 12
   inactive
{

	//Figure out the age 5 (yes, 5) god power and create the plan.
	int id = aiGetGodPowerTechIDForSlot(4); 
	if (id == -1)
	  return;

	gAge5GodPowerID=aiGetGodPowerProtoIDForTechID(id);

	//Create the plan.
	gPlaceTitanGatePlanID = aiPlanCreate("PlaceTitanGate", cPlanGodPower);
	if (gPlaceTitanGatePlanID == -1)
	{
	   //This is bad, and we most likely can never build a plan, so kill ourselves.
	   xsDisableSelf();
	   return;
	}

	// Set the Base
	aiPlanSetBaseID(gPlaceTitanGatePlanID, kbBaseGetMainID(cMyID));

	aiPlanSetVariableInt(gPlaceTitanGatePlanID,  cGodPowerPlanPowerTechID, 0, id);
	aiPlanSetDesiredPriority(gPlaceTitanGatePlanID, 100);
	aiPlanSetEscrowID(gPlaceTitanGatePlanID, -1);

	//Setup the plan.. 
	aiPlanSetVariableBool(gPlaceTitanGatePlanID, cGodPowerPlanAutoCast, 0, true); 
	aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanEvaluationModel, 0, cGodPowerEvaluationModelWorkers);
	aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanCount, 0, 6);
	aiPlanSetVariableInt(gPlaceTitanGatePlanID, cGodPowerPlanTargetingModel, 0, cGodPowerTargetingModelTown);
	//-- override the default building placement distance so that plenty has some room to cast
	//-- it is pretty big..
	aiPlanSetVariableFloat(gPlaceTitanGatePlanID, cGodPowerPlanBuildingPlacementDistance, 0, 100.0);

	aiPlanSetActive(gPlaceTitanGatePlanID);

	//Kill ourselves if we ever make a plan.
	xsDisableSelf();
}
