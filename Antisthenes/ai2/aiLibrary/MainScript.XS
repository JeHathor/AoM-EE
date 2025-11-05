//==============================================================================
// MainScript.xs			by JeHathor
//
//==============================================================================

include "aiLibrary/aiCV.xs";		// The control variable definitions

//==============================================================================
// printEcho		//aiEcho control in aiCV.
//==============================================================================
void printEcho(String text="")
{
   if(cvShowAiEcho) {
   			aiEcho(text);
		//aiChat(cMyID,text);
   }
}
//==============================================================================
// setParameters()
//
// Do most of the control variable (cv) initial declarations here.
//
//==============================================================================
void setParameters(void)   // This function is called from main() before init() is run.
{
   printEcho("Starting setParameters()");
   cvDoAutoSaves = true;

   if(cvFixedStrategy == false)
   {
	xsEnableRule("adaptivePersonality");
   }
      //Advanced Difficulty Settings
      if (cvMasterDifficulty < cDifficultyEasy)
      {
	cvMasterDifficulty = aiGetWorldDifficulty();
      }
      if (cvMasterDifficulty > cDifficultyNightmare)
      {
	cvMasterDifficulty = cDifficultyNightmare;
      }

   //Let's assign the handicap bonus...
   float generalHandicap = 2.00;	//Antisthenes [GS]

   if (cvMasterDifficulty == cDifficultyEasy)
   {
		generalHandicap = 1.00;		//+0%
   }else
   if (cvMasterDifficulty == cDifficultyModerate)
   {
		generalHandicap = 1.00;		//+0%
   }else
   if (cvMasterDifficulty == cDifficultyHard)
   {
		generalHandicap = 1.00;		//+0%
   }else
   if (cvMasterDifficulty == cDifficultyNightmare)
   {
	bool isHumanGame = false;	//Any Human players around?
	for (i=1; < cNumberPlayers)
	{
	    //It's not always the first one...
	    if(kbIsPlayerHuman(i))
	    {
		isHumanGame = true;
		break;
	    }
	}
	//No? Use default value (+100%) in AI vs AI!
	if(isHumanGame == true)
	{
		generalHandicap = 1.50;		//+50%
	}
   }
   if (cvMasterHandicap > 0.00)		//Custom Handicap
   {
	generalHandicap = cvMasterHandicap;
   }
   //We don't want any desync to occur in MP! (apply in Singleplayer only)
   //It looks like handicap changes will also break recorded games...
   if(aiGetWorldDifficulty() != cDifficultyNightmare)
   {
	//We have determined our final value by now.
	cvMasterHandicap = generalHandicap;
	xsEnableRule("compensateMultiplayerHandicap");
   }else{
		aiErrorMessage("Difficulty Titan");
   }
}

//==============================================================================
// finalInitSlider()		//NEW
//==============================================================================
void finalInitSlider(int teamSize=1)
{
   //Start with blank sliders.
   cvMilitaryEconSlider = 0;
   cvRushBoomSlider = 0;
   cvOffenseDefenseSlider = 0;

   //Take account for our starting position.
   if(cvIsPocket == true && teamSize > 1)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider + 0.0;
	cvRushBoomSlider = cvRushBoomSlider - 1.5;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 1.0;
   }else
   if(cvIsFlank == true && teamSize > 1)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider + 0.5;
	cvRushBoomSlider = cvRushBoomSlider - 0.5;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.0;
   }else{
	cvMilitaryEconSlider = cvMilitaryEconSlider + 0.0;
	cvRushBoomSlider = cvRushBoomSlider + 0.0;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.5;
   }

   //Modify based on our culture or civilization.
   if(cMyCulture == cCultureGreek)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider - 0.5;
	cvRushBoomSlider = cvRushBoomSlider - 0.5;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.5;
   }else
   if(cMyCulture == cCultureEgyptian)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider - 1.0;
	cvRushBoomSlider = cvRushBoomSlider + 0.0;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider - 1.0;
   }else
   if(cMyCulture == cCultureNorse)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider - 0.5;
	cvRushBoomSlider = cvRushBoomSlider + 0.5;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.5;
   }else
   if(cMyCulture == cCultureAtlantean)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider + 0.0;
	cvRushBoomSlider = cvRushBoomSlider + 0.5;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 1.0;
   }else
   if(cMyCulture == cCultureChinese)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider + 0.5;
	cvRushBoomSlider = cvRushBoomSlider + 0.5;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.0;
   }

   //Mirror match?
   if(cMyCiv == kbGetCivForPlayer(aiGetMostHatedPlayerID()) && teamSize < 3)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider * (-1);
	cvRushBoomSlider = cvRushBoomSlider * (-1);
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.0;
   }

   if(aiGetGameMode() == cGameModeDeathmatch)	//DM starts at maximum aggression!
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider + 2;
	cvRushBoomSlider = cvRushBoomSlider + 2;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 2;
   }

   //Adjust control variable sliders by random amount
   cvRushBoomSlider = (cvRushBoomSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvRushBoomSlider > 1.0) cvRushBoomSlider = 1.0;
   if (cvRushBoomSlider < -1.0) cvRushBoomSlider = -1.0;
   cvMilitaryEconSlider = (cvMilitaryEconSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvMilitaryEconSlider > 1.0) cvMilitaryEconSlider = 1.0;
   if (cvMilitaryEconSlider < -1.0) cvMilitaryEconSlider = -1.0;
   cvOffenseDefenseSlider = (cvOffenseDefenseSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvOffenseDefenseSlider > 1.0) cvOffenseDefenseSlider = 1.0;
   if (cvOffenseDefenseSlider < -1.0) cvOffenseDefenseSlider = -1.0;
   printEcho("Sliders are...RushBoom "+cvRushBoomSlider+", MilitaryEcon "+cvMilitaryEconSlider+", OffenseDefense "+cvOffenseDefenseSlider);
}

//==============================================================================
// applySliderNoise()
//==============================================================================
void applySliderNoise(void)
{
   //The following civs should pressure early. Let's give them a little slider boost!
   if(cMyCiv == cCivOuranos || cMyCiv == cCivKronos || cMyCiv == cCivLoki)
   {
	cvRushBoomSlider = cvRushBoomSlider + 0.1;
	cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.1;
   }
   //All Egyptians want to boom a lot at first.
   if(cMyCulture == cCultureEgyptian)
   {
	cvMilitaryEconSlider = cvMilitaryEconSlider - 0.1;
	cvRushBoomSlider = cvRushBoomSlider + 0.1;
   }
   //Adjust control variable sliders by random amount
   cvRushBoomSlider = (cvRushBoomSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvRushBoomSlider > 1.0) cvRushBoomSlider = 1.0;
   if (cvRushBoomSlider < -1.0) cvRushBoomSlider = -1.0;
   cvMilitaryEconSlider = (cvMilitaryEconSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvMilitaryEconSlider > 1.0) cvMilitaryEconSlider = 1.0;
   if (cvMilitaryEconSlider < -1.0) cvMilitaryEconSlider = -1.0;
   cvOffenseDefenseSlider = (cvOffenseDefenseSlider - cvSliderNoise) + (cvSliderNoise * (aiRandInt(201))/100.0);
   if (cvOffenseDefenseSlider > 1.0) cvOffenseDefenseSlider = 1.0;
   if (cvOffenseDefenseSlider < -1.0) cvOffenseDefenseSlider = -1.0;
   printEcho("Sliders are...RushBoom "+cvRushBoomSlider+", MilitaryEcon "+cvMilitaryEconSlider+", OffenseDefense "+cvOffenseDefenseSlider);
}

//==============================================================================
//Map-Related Globals.
extern bool gFishMap=false;		// Set true if fishing is likely to be good.
extern bool gTransportMap=false;	// Set true if transports are needed or very useful, i.e. island and shallow-chokepoint maps.
extern bool gHuntMap=false;		// Set true if (early) hunting is likely to be key.
extern bool gNoRushMap=false;		// Set true if map prevents rushing.
extern bool gNomadMap=false;		// Set true if map starts without TC.
extern bool gMigrationMap=false;	// Set true if we need to find the mainland early.
extern bool gExpansionMap=false;	// Set true if we need to find the mainland later.

//==============================================================================
//Escrow stuff.
extern int gEconomyUnitEscrowID=-1;		// Identifies which escrow account is used to pay for economic units 
extern int gEconomyTechEscrowID=-1;		// Identifies which escrow account is used for economic research
extern int gEconomyBuildingEscrowID=-1;		// Ditto buildings
extern int gMilitaryUnitEscrowID=-1;		// etc.
extern int gMilitaryTechEscrowID=-1;
extern int gMilitaryBuildingEscrowID=-1;

//==============================================================================
//Housing & PopCap.
extern int gHouseBuildLimit=-1;
extern int gHouseAvailablePopRebuild=10;	// Build a house when pop is within this amount of the current pop limit
extern int gBuildersPerHouse=1;
extern int gHardEconomyPopCap=-1;		// Sets an absolute upper limit on the number of villagers maintained in the updateEM rules
extern int gEarlySettlementTarget = 1;		// How many age 1/2 settlements do we want?
extern int gMaxHouseTracker = 0;		// How many houses did we accumulate so far?

//==============================================================================
//Econ Globals.
extern int   gBuilderType = -1;
extern int   gGatherGoalPlanID=-1;
extern int   gCivPopPlanID=-1;
extern int   gMaxVilPop=-1;
extern int   gNumBoatsToMaintain=12;		// Target number of fishing boats
extern int   gAgeToStartFarming=2;		// Obsolete
extern bool  gAgeCapHouses=false;
extern float gMaxFoodImbalance=1500.0;		// Obsolete
extern float gMaxWoodImbalance=1500.0;		// Obsolete
extern float gMaxGoldImbalance=1500.0;		// Obsolete
extern float gMinWoodMarketSellCost=20.0;	// Obsolete
extern float gMinFoodMarketSellCost=20.0;	// Obsolete
extern bool  gFarming=false;			// Set true when a farming plan is created, used to forecast farm resource needs.
extern bool  gFishing=false;			// Set true when a fishing plan is created, used to forecast fish boat wood demand
extern float gGoldForecast = 0.0;		// Forecasted demand over the next few minutes
extern float gWoodForecast = 0.0;
extern float gFoodForecast = 0.0;
extern int   gStartTime = 0;			// Time game started in milliseconds...reset if cvDelayStart is used
extern int   gHerdPlanID = -1;			// Herds animals to base
extern float gGlutRatio = 0.0;			// 1.0 indicates all resources at 3 min forecast.  2.0 means all at least double.  Used to trim econ pop.
extern int   gLastAgeHandled = cAge1;		// Set to cAge2..cAge5 as the age handlers run. Used to detect age-ups granted via triggers and starting conditions, 
						// ensures age handlers get run properly.
extern int   gGardenBuildLimit = 0;

//==============================================================================
//Handicap related
float gTotalFood = 0;
float gTotalWood = 0;
float gTotalGold = 0;

//==============================================================================
//Trade globals
extern int   gMaxTradeCarts=30;				// Max trade carts in 4th age on an excellent route.  Half that in third age.  Less if route isn't good.
extern int   gTradePlanID=-1;
extern int   gTradeMaintainPlanID=-1;			// Makes the trade carts
extern bool  gExtraMarket=false;			// Used to indicate if an extra (non-trade) market has been requested, i.e. for DM speed reasons
extern int   gTradeMarketUnitID=-1;			// Used to identify the market being used in our trade plan.
extern vector gTradeMarketLocation=cInvalidVector;	// Tracks requested trade market location, used to decide which market is the trade market.

//==============================================================================
//Military Globals.
extern vector gMilitaryGatherPoint = cInvalidVector;
extern bool gBuildWalls = false;
extern int  gWallPlanID = -1;
extern int  gFrontWallPlanID = -1;
extern bool gBuildTowers = false;
extern int gTowerEscrowID = cMilitaryEscrowID;
extern int gLandUPID=-1;			// Unit picker for age 2/3/4 (cAge2, cAge3 and cAge4).
extern int gNavalUPID=-1;
extern int gNumberBuildings=3;			// Number of buildings requested for late unit picker
extern int gNavalAttackGoalID=-1;
extern int gLandAttackGoalID=-1;
extern int gIdleAttackGID=-1;			// Attack goal, inactive, used to maintain mil pop after rush and/or before age 3 (cAge3) attack.
extern int gSiegeUnitReserveSize = 2;		// Number of siege units to keep on hand in cAge3, doubled in cAge4
extern int gSiegeUnitType = -1;
extern int gSiegeReservePlanID = -1;
extern int gDefendPlanID = -1;			// Uses military units to defend main base while waiting to mass an attack army
extern int gObeliskClearingPlanID = -1;		// Small attack plan used to remove enemy obelisks
extern int gMostRecentAttackPlanID = -1;	// Used by attackMonitor rule
extern int gTargetNavySize = 0;			// Set periodically based on difficulty, enemy navy/fish boat count. Units, not pop slots.
extern int gTargetMilitarySize = 300;		// Maximum size of land military units.
extern int gOtherBaseAttackPlan = -1;		// Uber-plan to attack other TCs (new)
extern int gSettlementGuardPlan = -1;		// Try to disrupt our opponent from building settlements.
extern int gNumberMilitaryUnitTypes = 2;
extern bool gFowardBuildings = false;		//Is this strategy active?
extern bool gPeriodicAttackTimeOut = false;
extern int gAssaultStartTime = -1;

//==============================================================================
//Defend Plan Locations.
extern vector gGuardSettlementPos = cInvalidVector;
extern vector gGuardGoldPos = cInvalidVector;
extern vector gGuardHuntPos = cInvalidVector;

//==============================================================================
//Dedicated Wonder Globals.
extern bool gWonderAttackPlan = false;		// Uber-plan to attack enemy wonder
extern int gWonderDefendPlan = -1;		// Uber-plan to defend my wonder
extern int gOtherWonderDefendPlan = -1;		// Uber-uber-plan to attack or defend other wonder
extern int gFirstWonderID = -1;

//==============================================================================
//Minor Gods.
extern int gAge2MinorGod = -1;
extern int gAge3MinorGod = -1;
extern int gAge4MinorGod = -1;

extern int gAge1MajorGod = -1;

//==============================================================================
//God Powers
extern int gAge1GodPowerID = -1;
extern int gAge2GodPowerID = -1;
extern int gAge3GodPowerID = -1;
extern int gAge4GodPowerID = -1;
extern int gAge5GodPowerID = -1;
extern int gAge1GodPowerPlanID = -1;
extern int gAge2GodPowerPlanID = -1;
extern int gAge3GodPowerPlanID = -1;
extern int gAge4GodPowerPlanID = -1;
extern int gAge5GodPowerPlanID = -1;
extern int gUnbuildPlanID = -1;
extern int gPlaceTitanGatePlanID = -1;

//==============================================================================
//Special Case Stuff
extern int gDwarvenMinePlanID = -1;
extern int gLandScout = -1;
extern int gAirScout = -1;
extern int gWaterScout = -1;
extern int gMaintainNumberLandScouts = 1;
extern int gMaintainNumberAirScouts = 1;
extern int gMaintainNumberWaterScouts = 1;
extern int gEmpowerPlanID = -1;
extern int gRelicGatherPlanID = -1;
extern int gMaintainWaterXPortPlanID=-1;
extern int gResignType = -1;
extern int gVinlandsagaTransportExplorePlanID=-1;
extern int gVinlandsagaInitialBaseID=-1;
extern int gNomadExplorePlanID1=-1;
extern int gNomadExplorePlanID2=-1;
extern int gNomadExplorePlanID3=-1;
extern int gNomadSettlementBuildPlanID=-1;
extern int gSettlersTargetAreaGroupID=-1;
extern int gKOTHPlentyUnitID=-1;
extern int gDwarfMaintainPlanID=-1;
extern int gLandExplorePlanID=-1;
extern int gFarmBaseID = -1;
extern int gTargetNumTowers = 0;		// Set to a positive int if towering is activated
extern int gUlfsarkMaintainPlanID = -1;		// Used to maintain a small pop of ulfsarks for building
extern int gUlfsarkMaintainMilPlanID = -1;	// Shadow plan, used in case main plan is econ pop-capped
extern bool gFakeDeathmatch = false;		//Enough resources for instant age up?

//==============================================================================
//tracking expansion
extern int gTrackingPlayer = -1;
extern int gNumberTrackedPlayerSettlements=-1;
extern int gNumberMySettlements=-1;
extern int gGuardSettlementID =-1;
extern int gSettlementHighScoreID =-1;		//Needed for more cool stuff.

extern int gMyTeamSize = 0;

extern int glastRemoteSettlementTargetID = -1;
extern int gRemoteSettlementBuildPlan = -1;
extern int gRemoteSettlementTransportPlan = -1;
extern int gRemoteSettlementExplorePlan = -1;

//==============================================================================
//Base Globals.
extern int gGoldBaseID=-1;		// Base used for gathering gold, although main base is used if gold exists there
extern int gWoodBaseID=-1;		// Ditto for wood
extern float gMaximumBaseResourceDistance=85.0;
extern float gMainBaseAreaWallRadius = -1;
extern int gMainBaseID=-1;		// Well... that's our main tc.
extern int gWallBaseID=-1;		// Base used for our new fortification system
extern int gWallUpgradeID = 0;		//I love this global stuff!!!
extern int gMilBaseID=-1;		//Used for other forward buildings...
extern int gEnemyMainBaseID=-1;		//Used as reference point
extern vector gMainBaseLoc = cInvalidVector;

//==============================================================================
//Age Progression Plan IDs.
extern int gAge2ProgressionPlanID = -1;
extern int gAge3ProgressionPlanID = -1;
extern int gAge4ProgressionPlanID = -1;

//==============================================================================
//Forward declarations.
//==============================================================================
mutable void setMilitaryUnitPrefs(int primaryType = -1, int secondaryType = -1, int tertiaryType = -1) {}   // Used by loader to override unitPicker choices
mutable void age2Handler(int age=1) { }
mutable void age3Handler(int age=2) { }
mutable void age4Handler(int age=3) { }
mutable void towerInBase( string planName="BUG", bool los = true, int numTowers = 6, int escrowID=-1 ) { }
mutable int createSimpleMaintainPlan(int puid=-1, int number=1, bool economy=true, int baseID=-1) { }
mutable bool createSimpleBuildPlan(int puid=-1, int number=1, int pri=100,
   bool military=false, bool economy=true, int escrowID=-1, int baseID=-1, int numberBuilders=1) { }
mutable void buildHandler(int protoID=-1) { }
mutable void gpHandler(int powerID=-1)    { }
mutable void wonderDeathHandler(int playerID=-1) { }
mutable void retreatHandler(int planID=-1) {}
mutable void relicHandler(int relicID=-1) {}
mutable int createBuildSettlementGoal(string name="BUG", int minAge=-1, int maxAge=-1, int baseID=-1, int numberUnits=1, int builderUnitTypeID=-1, bool autoUpdate=true, int pri=90) { }
mutable int getEconPop(int playerID=-1) {}
mutable int getMilPop(void) {}
mutable int getSoftPopCap(void) {}
mutable void unbuildHandler() { }
mutable void age5Handler(int age=4) { }
mutable int findTownDefenseGP(int baseID=-1) {}

//==============================================================================
// Game mode data
include "aiLibrary/aimode.xs";
include "aiLibrary/aiWonder.xs";

//==============================================================================
//Map Detection Include.
include "aiLibrary/aiMapSupport.xs";

//==============================================================================
//Micro Include.
include "aiLibrary/aiMicro.xs";	// Contains the micro functions.

//==============================================================================
//Mod Detection Include.
extern bool gNewCivMod = false;
extern bool gModDelayStart = false;
include "aiLibrary/aiModSupport.xs";

//==============================================================================
//Economy Include.
//-- The Econ module needs to define these things:
// void econAge1Handler( int age = 0 )
// void econAge2Handler( int age = 0 )
// void econAge3Handler( int age = 0 )
// void econAge4Handler( int age = 0 )
// void initEcon()
include "aiLibrary/aiEcon.xs";

//==============================================================================
//Progress Include.
//-- The Progress module needs to define these things:
// void progressAge2Handler( int age = 0 )
// void progressAge3Handler( int age = 0 )
// void progressAge4Handler( int age = 0 )
// void initProgress()
include "aiLibrary/aiProg.xs";

//==============================================================================
//Research Include.
include "aiLibrary/aiTech.xs";

//==============================================================================
//Military Include.
include "aiLibrary/aiMil.xs";
include "aiLibrary/aiUnitPick.xs";

//==============================================================================
//God Powers Include.
//-- The GP module needs to define these things:
// void gpAge2Handler( int age = 0 )
// void gpAge3Handler( int age = 0 )
// void gpAge4Handler( int age = 0 )
// void initGodPowers()
include "aiLibrary/aiGP.xs";
//==============================================================================
//Chat Include.
include "aiLibrary/aiChat.xs";

//==============================================================================
//   - - - Ai Functions - - -
//==============================================================================
// Called by trigger when the cinematics are done
void fish(int parm=-1)
{gFishMap=true;}

void transport(int parm=-1)
{gTransportMap=true;}

void nomad(int parm=-1)
{gNomadMap=true;}

void migration(int parm=-1)
{gMigrationMap=true;}

void expansion(int parm=-1)
{gExpansionMap=true;}

void scenario(int parm=-1)
{
   cvOkToChat=false;
}
void hunt(int parm=-1)	//HuntingDogs
{gHuntMap=true;}

void modeTiny(int parm=-1)
{gFakeDeathmatch=true;}

void noRush(int parm=-1)
{gNoRushMap=true;}

void maxMilPop(int parm=-1)
{cvMaxMilPop=parm;}

//==============================================================================
// compensateMultiplayerHandicap
//==============================================================================
rule compensateMultiplayerHandicap
minInterval 4
inactive
{
    if(cvMasterHandicap <= 1.00)	//more than +0%
    {
	xsDisableSelf();
	return;
    }
    //initialize vars with our starting resources!
    if(gTotalFood+gTotalWood+gTotalGold <= 0)
    {
	//last resources in the bank.
	gTotalFood = kbTotalResourceGet(cResourceFood);
	gTotalWood = kbTotalResourceGet(cResourceWood);
	gTotalGold = kbTotalResourceGet(cResourceGold);

	return;		//wait.
    }

    //get the resource income since the last iteration.
    int foodIncome = kbTotalResourceGet(cResourceFood)-gTotalFood;
    int woodIncome = kbTotalResourceGet(cResourceWood)-gTotalWood;
    int goldIncome = kbTotalResourceGet(cResourceGold)-gTotalGold;

    //always sync total resources before we add some!
    gTotalFood = kbTotalResourceGet(cResourceFood);
    gTotalWood = kbTotalResourceGet(cResourceWood);
    gTotalGold = kbTotalResourceGet(cResourceGold);

    float handicapModifier = cvMasterHandicap - 1.00;

    //scale the extra resources according to our handicap.
    int extraFood = foodIncome*handicapModifier;
    int extraWood = woodIncome*handicapModifier;
    int extraGold = goldIncome*handicapModifier;

    if(extraFood < 0)
	{extraFood = 0;}
    if(extraWood < 0)
	{extraWood = 0;}
    if(extraGold < 0)
	{extraGold = 0;}

    //assign the extra resources.
    aiResourceCheat(cMyID,cResourceFood,extraFood);
    aiResourceCheat(cMyID,cResourceWood,extraWood);
    aiResourceCheat(cMyID,cResourceGold,extraGold);

    //add extra resources in the bank to the total.
    gTotalFood = gTotalFood + extraFood;
    gTotalWood = gTotalWood + extraWood;
    gTotalGold = gTotalGold + extraGold;
}

//==============================================================================
// RULE: handicapAutobalance
//==============================================================================
rule handicapAutobalance
   minInterval 2
   active
{
    if(cvAiAutoBalance == false)
    {
	xsDisableSelf();
	return;
    }

    int mhpID = aiGetMostHatedPlayerID();
    if(mhpID <= 0 || kbGetAge() < cAge2)
    {
	return;
    }
    kbLookAtAllUnitsOnMap();	//Literally used to keep it fair!
    int myStuff = kbUnitCount(cMyID, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings, cUnitStateAlive) + getEconPop(cMyID);
    int mhpStuff = kbUnitCount(mhpID, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings, cUnitStateAlive) + getEconPop(mhpID);

    if(myStuff < mhpStuff*0.9 && cvMasterHandicap < 3.00)
    {
	cvMasterHandicap = cvMasterHandicap + 0.10;
    }else
    if(myStuff*0.8 > mhpStuff && cvMasterHandicap > 1.00)
    {
	cvMasterHandicap = cvMasterHandicap - 0.05;
    }

    if(myStuff < mhpStuff*0.5)	//We need more?
    {
	xsEnableRule("resourceAutobalance");
    }else{
	xsDisableRule("resourceAutobalance");
    }
}

//==============================================================================
// RULE: resourceAutobalance
//==============================================================================
rule resourceAutobalance
   minInterval 1
   active
{
	if(kbResourceGet(cResourceFood) < 400)
	{
	    aiResourceCheat(cMyID,cResourceFood,20);
	}
	if(kbResourceGet(cResourceWood) < 400)
	{
	    aiResourceCheat(cMyID,cResourceWood,20);
	}
	if(kbResourceGet(cResourceGold) < 400)
	{
	    aiResourceCheat(cMyID,cResourceGold,20);
	}
}

//==============================================================================
// RULE: safeAge1UpTiming
//==============================================================================
rule safeAge1UpTiming
   minInterval 5
   active
{
   //Since we can't control whether the plan takes hunt or berries
   //at the beginning, this simply provides a bit of consistency.
   if(kbGetAge() > cAge1)
   {
	xsDisableSelf();
	return;
   }
   if(xsGetTime() > 4*60*1000)
   {
	int templeCount = kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAlive);
	if(templeCount > 0 && kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching)
	{
		int myFood = kbResourceGet(cResourceFood);
		if(myFood < 400)
		{
			int foodNeed = 400-myFood;
			aiResourceCheat(cMyID, cResourceFood, foodNeed);
			xsDisableSelf();
		}
	}
   }
}

//==============================================================================
// getBigBuildingID	//Major defense building
//==============================================================================
int getBigBuildingID(void)
{
	int bigBuildingID = cUnitTypeTower;

	if(cMyCulture == cCultureGreek)
	{
		bigBuildingID = cUnitTypeFortress;
	}else
	if(cMyCulture == cCultureEgyptian)
	{
		bigBuildingID = cUnitTypeMigdolStronghold;
	}else
	if(cMyCulture == cCultureNorse)
	{
		bigBuildingID = cUnitTypeHillFort;
	}else
	if(cMyCulture == cCultureAtlantean)
	{
		bigBuildingID = cUnitTypePalace;
	}else
	if(cMyCulture == cCultureChinese)
	{
		bigBuildingID = cUnitTypeCastle;
	}
	//Overwrite if needed.
	if(getModFortType() > 0)
	{
		bigBuildingID = getModFortType();
	}
	return(bigBuildingID);
}

//==============================================================================
// isPlayerTeamPocket	//Identifies the Pocket/SuperPocket
//==============================================================================
bool isPlayerTeamPocket(int playerID=cMyID)
{
   int teamSize = 0;

   for (i=1; < cNumberPlayers)
   {
	if(i == cMyID || kbIsPlayerAlly(i))
	{
		teamSize++;
	}
   }
   gMyTeamSize = teamSize;
   printEcho("Players in team: "+teamSize);
   if(teamSize%2 == 0)	//2,4,6,...
   {
		return(false);
   }

   //The player with the shortest distance to his team members is the pocket.
   int minDistanceScore = -1;
   int minDistanceID = -1;

   for (pID1=1; < cNumberPlayers)
   {
	if(pID1 == cMyID || kbIsPlayerAlly(pID1))
	{
	    int currentDistanceScore = -1;

	    int mainTC = findUnit(pID1, cUnitStateAlive, cUnitTypeAbstractSettlement);

	    for(pID2=1; < cNumberPlayers)
	    {
		if(pID2 != pID1 && (pID2 == cMyID || kbIsPlayerAlly(pID2)))
		{
		    int allyTC = findUnit(pID2, cUnitStateAlive, cUnitTypeAbstractSettlement);

			currentDistanceScore = currentDistanceScore + calcDistanceToUnit(mainTC,allyTC);
		}
	    }

	    if(currentDistanceScore < minDistanceScore || minDistanceScore < 0)
	    {
		minDistanceScore = currentDistanceScore;
		minDistanceID = pID1;
	    }
	}
   }

   if(playerID == minDistanceID)	//Is this player the pocket?
   {
	return(true);
   }else{
	return(false);
   }
}

//==============================================================================
// ORDER: setTargetEnemy()
//==============================================================================
void setTargetEnemy(int pID=-1, bool autoUpdate=true)	//Update mhp globals
{
   if(kbIsPlayerEnemy(pID) == false || pID <= 0)	//Must not be Gaia!
   {
		return;
   }
   gEnemyMainBaseID = findUnit(pID, cUnitStateAlive, cUnitTypeAbstractSettlement);
   aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanAttackPlayerID, 0, pID);	//Write to attack Plan!
   aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanAutoUpdateAttackPlayerID, 0, autoUpdate);
   if(gTransportMap == false)	//We need a transport?
   {
	int myArea = kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	int mhpArea = kbAreaGroupGetIDByPosition(kbBaseGetLocation(pID, kbBaseGetMainID(pID)));
	if (myArea != mhpArea && myArea >= 0 && mhpArea >= 0)
	{
		gTransportMap = true;
		aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanSetAreaGroups, 0, true);
		aiSetWaterMap(gTransportMap);	//Transport doesn't work without this!
	}
   }
   aiSetMostHatedPlayerID(pID);
}

//==============================================================================
// RULE: updatePlayerToAttack.  Updates the player we should be attacking.
//==============================================================================
rule updatePlayerToAttack
   minInterval 40
   group AttackRules
   active
   runImmediately
{
   //Gaia is index 0, but counts as player. This means
   //if there are 4 players in the game then cNumberPlayers is set to 5.

   if(cNumberPlayers <= 3)	//instant love?
   {
	if(cMyID == 2)
	{
	    setTargetEnemy(aiCalculateMostHatedPlayerID(1));
	   }else{
	    setTargetEnemy(aiCalculateMostHatedPlayerID(2));
	}
		return;
   }

   //Our wonder plan does the work?
   if(gFirstWonderID >= 0)
   {
		setTargetEnemy(aiGetMostHatedPlayerID());
		return;
   }

   //Run this until we get a result.
   if(cvIsPocket == false && cvIsFlank == false)
   {
	if(isPlayerTeamPocket(cMyID))
	{
		printEcho("Player"+cMyID+": I'm Pocket!");
		cvIsPocket = true;
		if(gMyTeamSize > 1 && aiGetPersonality() != "Apocalypse Bot")
		{
			//Pocket's play boomy!
			cvIsFlank = false;
		}else{
			//Start balanced in 1v1!
			cvIsFlank = true;
		}
		xsSetRuleMinIntervalSelf(27);
	}else{
		//Flank's play aggressive!
		printEcho("Player"+cMyID+": I'm Flank!");
		cvIsFlank = true;
		cvIsPocket = false;
		xsSetRuleMinIntervalSelf(31);
	}
	if(cvFixedStrategy == false)
	{
		cvSliderNoise = 0.2;
		finalInitSlider(gMyTeamSize);			//Update our game plan!
	}
   }

   //We no longer need to determine a random start index,
   //since we calculate the opponents accurately.
   int comparePlayerID=-1;
   int comparePower=-1;

   for (actualIndex=1; < cNumberPlayers)
   {
      if ((kbIsPlayerEnemy(actualIndex) == true) &&
	 (kbIsPlayerResigned(actualIndex) == false) &&
	 (kbHasPlayerLost(actualIndex) == false))
      {
	if(cvIsPocket == false)
	{
		//Focus on the closest player as flank.
		int myTC = findUnit(cMyID, cUnitStateAlive, cUnitTypeAbstractSettlement);
		int actualUnitID = findClosestRelTo(myTC, actualIndex, cUnitStateAliveOrBuilding, cUnitTypeBuildingsThatShoot);
		int actualDistance = calcDistanceToUnit(myTC,actualUnitID);
		if(actualDistance < comparePower || comparePower < 0)
		{
			comparePlayerID=actualIndex;
			comparePower=actualDistance;
		}
	}else{
		//Target the player with the most power as pocket.
		int actualTC = kbUnitCount(actualIndex, cUnitTypeAbstractSettlement, cUnitStateAlive);
		int actualEco = getEconPop(actualIndex);
		int actualMil = kbUnitCount(actualIndex, cUnitTypeMilitary, cUnitStateAlive);
		int actualPower = 20*actualTC + 3*actualEco + 1*actualMil;
		if(kbUnitCount(actualIndex, cUnitTypeWonder, cUnitStateAliveOrBuilding) > 0)
		{
			actualPower = actualPower + 50;		//wonder bonus.
		}
		if(actualPower < 0)
		{
			actualPower=0;		//makes sure we pick someone.
		}
		if(actualPower > comparePower)
		{
			comparePlayerID=actualIndex;
			comparePower=actualPower;
		}
	}
      }
   }

   //Pass the comparePlayerID into the AI to see what he thinks.
   //He'll take care of modifying the player in the event of wonders, etc.
   //But I don't trust this guy so... let's put it as fail safe only.
   int actualPlayerID = -1;

   if (cvPlayerToAttack == -1) {
      if(
		kbIsPlayerEnemy(comparePlayerID) == true
		&&
		kbIsPlayerResigned(comparePlayerID) == false
	)
      {
	actualPlayerID = comparePlayerID;
      }
      if(actualPlayerID < 1)
      {
	actualPlayerID = aiCalculateMostHatedPlayerID();
      }
   }else{
      actualPlayerID = cvPlayerToAttack;
   }
   //Default us off.
   setTargetEnemy(actualPlayerID);
}

//==============================================================================
// ORDER: adjustStrategy
//==============================================================================
void adjustStrategy(void)
{
	if(kbGetAge() < cAge2)	//Wait until it's ready to be evaluated.
	{
		return;
	}

	int myEcoValue = getEconPop(cMyID);
	int mhpEcoValue = getEconPop(aiGetMostHatedPlayerID());

	int myMilValue = getMilPop();
	int mhpMilValue = getEstimatedMilPop(aiGetMostHatedPlayerID());

	//MHP has a wonder - We need to attack!
	if(kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeWonder, cUnitStateAliveOrBuilding) > 0)
	{
			cvMilitaryEconSlider = cvMilitaryEconSlider + 0.2;
			cvRushBoomSlider = cvRushBoomSlider - 0.1;
			cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.2;
	}else
	if(myEcoValue < mhpEcoValue)	//Boom?
	{
		cvRushBoomSlider = cvRushBoomSlider - 0.1;
		//Balance the rest a bit.
		if(cvMilitaryEconSlider > 0.4)
		{
			cvMilitaryEconSlider = cvMilitaryEconSlider - 0.1;
		}
		if(cvMilitaryEconSlider < -0.4)
		{
			cvMilitaryEconSlider = cvMilitaryEconSlider + 0.1;
		}
		if(cvOffenseDefenseSlider > 0.4)
		{
			cvOffenseDefenseSlider = cvOffenseDefenseSlider - 0.1;
		}
		if(cvOffenseDefenseSlider < -0.4)
		{
			cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.1;
		}
	}else{
		if(myMilValue > mhpMilValue)	//Attack?
		{
			cvMilitaryEconSlider = cvMilitaryEconSlider + 0.1;
			cvRushBoomSlider = cvRushBoomSlider - 0.1;
			cvOffenseDefenseSlider = cvOffenseDefenseSlider + 0.1;
		}
		if(myMilValue < mhpMilValue)	//Turtle?
		{
			cvMilitaryEconSlider = cvMilitaryEconSlider - 0.1;
			cvRushBoomSlider = cvRushBoomSlider + 0.1;
			cvOffenseDefenseSlider = cvOffenseDefenseSlider - 0.1;
		}
	}
	//Update all sliders!
	if (cvMilitaryEconSlider > 1.0) cvMilitaryEconSlider = 1.0;
	if (cvMilitaryEconSlider < -1.0) cvMilitaryEconSlider = -1.0;
	printEcho("MilitaryEconSlider: "+cvMilitaryEconSlider);

	if (cvRushBoomSlider > 1.0) cvRushBoomSlider = 1.0;
	if (cvRushBoomSlider < -1.0) cvRushBoomSlider = -1.0;
	printEcho("RushBoomSlider: "+cvRushBoomSlider);

	if (cvOffenseDefenseSlider > 1.0) cvOffenseDefenseSlider = 1.0;
	if (cvOffenseDefenseSlider < -1.0) cvOffenseDefenseSlider = -1.0;
	printEcho("OffenseDefenseSlider: "+cvOffenseDefenseSlider);
}

//==============================================================================
// RULE: adaptivePersonality
//==============================================================================
rule adaptivePersonality
   minInterval 52
   inactive
{
	xsSetRuleMinIntervalSelf(18);	//Let's make it more adaptive!

	if(cvMasterDifficulty >= cDifficultyNightmare)
	{
		kbLookAtAllUnitsOnMap();	//Maybe needed too??
	}
	adjustStrategy();
	updateUnitPreference(gLandUPID,-1);	//Finally, update our unit picker!
}

//==============================================================================
// RULE: checkEscrow
//==============================================================================
rule checkEscrow     // Verify that escrow totals and real inventory are in sync
   minInterval 6
   active
{
   static int failCount = 0;
   static bool initialResetDone = false;

   if (initialResetDone == false)
   {
      initialResetDone = true;
      kbEscrowAllocateCurrentResources();
      return;
   }

   bool fishingReset = false;    // Special reset in first 5 minutes for wood imbalance while fishing
				 // (Every fishing boat trained gets double-billed.)
   bool needReset = false;
   int res = -1;
   for (res=0; <3)		//Once each.
   {
      int escrowQty = -1;
      int actualQty = -1;
      int delta = -1;
      escrowQty = kbEscrowGetAmount(cEconomyEscrowID, res);
      escrowQty = escrowQty + kbEscrowGetAmount(cMilitaryEscrowID, res);
      escrowQty = escrowQty + kbEscrowGetAmount(cRootEscrowID, res);
      actualQty = kbResourceGet(res);
      delta = actualQty - escrowQty;
      if (delta < 0)
	 delta = delta * -1;
      if ( (delta > 20) && (delta > actualQty/5) ) // Off by at least 20, and 20%
      {
	 needReset = true;
	 if (res == cResourceGold)
	    printEcho("Gold imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
	 if (res == cResourceWood)
	 {
	    printEcho("Wood imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
	    if ( (gFishing == true) && (xsGetTime()<(8*60*1000)) )
	       fishingReset = true; // We're fishing, it's in the first 8 min, and wood is off.
	 }
	 if (res == cResourceFood)
	    printEcho("Food imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
	 if (res == cResourceFavor)
	    printEcho("Favor imbalance.  Escrow says "+escrowQty+", actual is "+actualQty);
      }
   }
   
   if (fishingReset == true)
   {
      kbEscrowAllocateCurrentResources();
      return;
   }
   if (needReset == true)
   {
      failCount = failCount+1;
      if ( (failCount > 5) || ( (failCount>0)&&(xsGetTime()<30000) ) )
      {
	 printEcho("ERROR:  Escrow balances invalid.  Reallocating");
	 kbEscrowAllocateCurrentResources();
      }
   }
   else
      failCount = 0;
}

//==============================================================================
// setTownLocation
//==============================================================================
void setTownLocation(void)
{
   static int tcQueryID=-1;
   //If we don't have a query ID, create it.
   if (tcQueryID < 0)
   {
      tcQueryID=kbUnitQueryCreate("TownLocationQuery");
      //If we still don't have one, bail.
      if (tcQueryID < 0)
	 return;
      //Else, setup the query data.
      kbUnitQuerySetPlayerID(tcQueryID, cMyID);
      kbUnitQuerySetUnitType(tcQueryID, cUnitTypeAbstractSettlement);
      kbUnitQuerySetState(tcQueryID, cUnitStateAlive);
   }

   //Reset the results.
   kbUnitQueryResetResults(tcQueryID);
   //Run the query.  Be dumb and just take the first TC for now.
   if (kbUnitQueryExecute(tcQueryID) > 0)
   {
      int tcID=kbUnitQueryGetResult(tcQueryID, 0);
      vector tcLoc=kbUnitGetPosition(tcID);

      kbSetTownLocation(tcLoc);
      gMainBaseID = tcID;
      gMainBaseLoc = tcLoc;
   }
}

//==============================================================================
//createSimpleMaintainPlan
//==============================================================================
int createSimpleMaintainPlan(int puid=-1, int number=1, bool economy=true, int baseID=-1)
{
   //Create a the plan name.
   string planName="Military";
   if (economy == true)
      planName="Economy";
   planName=planName+kbGetProtoUnitName(puid)+"Maintain";
   int planID=aiPlanCreate(planName, cPlanTrain);
   if (planID < 0)
      return(-1);

   //Economy or Military.
   if (economy == true)
      aiPlanSetEconomy(planID, true);
   else
      aiPlanSetMilitary(planID, true);
   //Unit type.
   aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
   //Number.
   aiPlanSetVariableInt(planID, cTrainPlanNumberToMaintain, 0, number);

   //If we have a base ID, use it.
   if (baseID >= 0)
   {
      aiPlanSetBaseID(planID, baseID);
      if  (economy == false)
	 aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, baseID));
   }

   aiPlanSetActive(planID);

   //Done.
   return(planID);
}

//==============================================================================
//createSimpleBuildPlan
//==============================================================================
bool createSimpleBuildPlan(int puid=-1, int number=1, int pri=100,
   bool military=false, bool economy=true, int escrowID=-1, int baseID=-1, int numberBuilders=1)
{
   //Create the right number of plans.
   for (i=0; < number)
   {
      int planID=aiPlanCreate("SimpleBuild"+kbGetUnitTypeName(puid)+" "+number, cPlanBuild);
      if (planID < 0){return(false);}

      aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, puid);
      //Border layers.
      aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 2, kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, baseID)) );
      //Priority.
      aiPlanSetDesiredPriority(planID, pri);
      //Mil vs. Econ.
      aiPlanSetMilitary(planID, military);
      aiPlanSetEconomy(planID, economy);
      //Escrow.
      aiPlanSetEscrowID(planID, escrowID);
      //Builders.
      aiPlanAddUnitType(planID, getBuilderType(), numberBuilders, numberBuilders, numberBuilders);
      //Base ID.
      aiPlanSetBaseID(planID, baseID);

      //Go.
      aiPlanSetActive(planID);
   }
}

//==============================================================================
//getSoftPopLimit    Calculate our pop limit if we had all houses built
//==============================================================================
int getSoftPopCap(void)
{
   int houseProtoID = cUnitTypeHouse;
   if (cMyCulture == cCultureAtlantean)
   {
       houseProtoID = cUnitTypeManor;
   }
   int maxHouses = 10;
   int popPerHouse = 10;
   if (cMyCulture == cCultureAtlantean)
   {
       maxHouses = 5;
       popPerHouse = 20;
   }

   int houseCount = -1;
   houseCount = kbUnitCount(cMyID, houseProtoID, cUnitStateAlive); // Do not count houses being built

   int retVal = -1;
   retVal = kbGetPopCap();
   retVal = retVal + (maxHouses-houseCount)*popPerHouse;  // Add pop for missing houses
   return(retVal);
}

//==============================================================================
// updateEM
//==============================================================================
void updateEM(int econPop=-1, int milPop=-1, float econPercentage=0.5,
   float rootEscrow=0.2, float econFoodEscrow=0.5, float econWoodEscrow=0.5,
   float econGoldEscrow=0.5, float econFavorEscrow=0.5)
{
   if (cMyCulture == cCultureNorse)	// Make room for at least 3 oxcarts
   {
      if (econPop < 25)
	 econPop = econPop + 3;
   }
   int plentyCount = kbUnitCount(cMyID, cUnitTypePlentyVault, cUnitStateAlive);
   if (plentyCount > 0)
   {
      econPop = econPop - 6*plentyCount;	// Make room for more military
      if(econPop < 10)
      {
		econPop = 10;
      }
   }

   //Econ Pop (if we're allowed to change it).
   if ((gHardEconomyPopCap > 0) && (econPop > gHardEconomyPopCap))
      econPop=gHardEconomyPopCap;
   if ( (econPop > cvMaxGathererPop)  && (cvMaxGathererPop >= 0) )
      econPop = cvMaxGathererPop;

   // Check if we're second age.  If so, consider capping the mil lower for boomers
   if ((kbGetAge() == cAge2) && (milPop >= 0))
   {
      int myFakeMilCount = 1.4 * kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive);
      int mHpMilCount = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeMilitary, cUnitStateAlive);

      if (mHpMilCount < myFakeMilCount)		//Only decrease if we can defend.
      {
	 // Let's decrease our military pop
	 float milPopDelta = (cvRushBoomSlider*4.0)/5.0;    // Zero for balanced, -.80 for extreme boom
	 if (milPopDelta > 0) 
	    milPopDelta = 0;  // Don't increase for rushers
	 // Adjust it for econ/mil scale.  If military, soften the decrease, if economic, preserve full.
	 milPopDelta = milPopDelta / (2.0 + cvMilitaryEconSlider);
	 milPop = milPop + (milPop * milPopDelta);
	 if (milPop < 10) 
	    milPop = 10;
      }
   }

   if ((milPop < 0) && (cvMaxMilPop >= 0))      // milPop says no limit, but cvMaxMilPop has one
      milPop = cvMaxMilPop;      
   if ((milPop > cvMaxMilPop) && (cvMaxMilPop >= 0))  // cvMaxMilPop has limit and milPop is over it
      milPop = cvMaxMilPop;

   aiSetEconomyPop(econPop);
   aiSetMilitaryPop(milPop);

   gTargetMilitarySize = milPop;

   // Check to make sure attack goals have ranges below our milPop limit
   int upID = gLandUPID;

   int milMin = kbUnitPickGetMinimumPop(upID);
   int milMax = kbUnitPickGetMaximumPop(upID);
   if (milMax > milPop) // We have a problem
   {
      printEcho("***** MilPop is "+milPop+", resetting military goals.");
      kbUnitPickSetMaximumPop(upID,(milPop*4)/5);
      kbUnitPickSetMinimumPop(upID,(milPop*3)/5);
   }


   //Percentages.
   aiSetEconomyPercentage(1.0);
   aiSetMilitaryPercentage(1.0);

   //Get the amount of the non-root pie.
   float nonRootEscrow=1.0-rootEscrow;
   //Track whether or not we need to redistribute the resources.
   //Econ Food Escrow.
   float v=nonRootEscrow*econFoodEscrow;
   kbEscrowSetPercentage(cEconomyEscrowID, cResourceFood, v);
   //Econ Wood Escrow
   v=nonRootEscrow*econWoodEscrow;
   kbEscrowSetPercentage(cEconomyEscrowID, cResourceWood, v);
   //Econ Gold Escrow
   v=nonRootEscrow*econGoldEscrow;
   kbEscrowSetPercentage(cEconomyEscrowID, cResourceGold, v);
   //Econ Favor Escrow
   v=nonRootEscrow*econFavorEscrow;
   kbEscrowSetPercentage(cEconomyEscrowID, cResourceFavor, v);
   //Military Escrow.
   kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFood, nonRootEscrow*(1.0-econFoodEscrow));
   kbEscrowSetPercentage(cMilitaryEscrowID, cResourceWood, nonRootEscrow*(1.0-econWoodEscrow));
   kbEscrowSetPercentage(cMilitaryEscrowID, cResourceGold, nonRootEscrow*(1.0-econGoldEscrow));
   kbEscrowSetPercentage(cMilitaryEscrowID, cResourceFavor, nonRootEscrow*(1.0-econFavorEscrow));


   int vilPop = aiGetEconomyPop();      // Total econ
   if (gFishing == true)
   {
      int boatCount = gNumBoatsToMaintain;
      if ( (aiGetGameMode() == cGameModeLightning) && (boatCount > 5) )
	 boatCount = 5;
      int fishCount = kbUnitCount(0, cUnitTypeFish, cUnitStateAlive);
      if (boatCount > fishCount && fishCount >= 0)
	 boatCount = fishCount;
      vilPop = vilPop - boatCount; // Less fishing
   }
   if (gTradeMaintainPlanID >= 0)	    // Less trade units
   {
      int tradeCount = aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0);
      if ( (aiGetGameMode() == cGameModeLightning) && (tradeCount > 5) )
	 tradeCount = 5;
      vilPop = vilPop - tradeCount;     // Vils = total-trade
   }
   if (cMyCulture == cCultureAtlantean)
      vilPop = vilPop / 3;

   // Brutal hack to make Lightning work.
   if (aiGetGameMode() == cGameModeLightning)
   {     // Make sure we don't try to overtrain villagers
      int lightningLimit = 25;      // Greek/Egyptian;
      if (cMyCulture == cCultureNorse)
	 lightningLimit = 20;
      if (cMyCulture == cCultureAtlantean)
	 lightningLimit = 6;
      if (vilPop > lightningLimit)
	 vilPop = lightningLimit;
   }
   if (vilPop > 80) { vilPop = 80; }	//Not really needed.

	gMaxVilPop = vilPop;

   //Update the number of vils to maintain.
   aiPlanSetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0, vilPop);
}

//==============================================================================
// adjustSigmoid
//==============================================================================
float adjustSigmoid(float var=0.0, float fraction=0.0,  float lowerLimit=0.0, float upperLimit=1.0)
{  // Adjust the variable by fraction amount.  Dampen it for movement near the limits like a sigmoid curve. 
   // A fraction of +.5 means increase it by the lesser of 50% of its original value, or 50% of the space remaining.
   // A fraction of -.5 means decrease it by the lesser of 50% of its original value, or 50% of the distance from the upper limit.

   float spaceAbove = upperLimit - var;

   float adjustRaw = var * fraction;	    // .8 at -.5 gives -.4  // .8 at .5 gives 1.2
   float adjustLimit = spaceAbove * fraction;   // .2 at -.5 gives -.1  // .2 at .5 gives .1
   float retVal = 0.0;
   if (fraction > 0) // increasing it
   {
      // choose the smaller of the two
      if (adjustRaw < adjustLimit)
	 retVal = var + adjustRaw;
      else
	 retVal = var + adjustLimit;
   }
   else  // decreasing it
   {
      // The "smaller" adjustment is the higher number, i.e. -.1 is a smaller adjustment than -.4
      if (adjustRaw < adjustLimit)
	 retVal = var + adjustLimit;
      else
	 retVal = var + adjustRaw;
   }
   return(retVal);
}

//==============================================================================
// updateTargetPop
//==============================================================================
rule updateTargetPop
   minInterval 12
   active
{
  static int civPopTarget=-1;
  static int milPopTarget=-1;

    float econPercent = 0;	// Econ priority rating, range 0..1
    float econEscrow = 0;	// Economy's share of non-root escrow, range 0..1

  if(kbGetAge() == cAge1)
  {
	gNumberMilitaryUnitTypes = 1;

	civPopTarget = 25;
	milPopTarget = 0;

	econPercent = 1.00;
	econEscrow = 1.00;
  }else{

    if(kbGetAge() == cAge2) {
	gNumberMilitaryUnitTypes = 2;

	econPercent = 0.50;
	econEscrow = 0.50;

	//egyptians try to skip the second age.
	if(cMyCulture == cCultureEgyptian)
	{
		econPercent = 0.75;
		econEscrow = 0.75;
	}
	//Against eggy norse needs age3 too!
	if(cMyCulture == cCultureNorse && kbGetCultureForPlayer(aiGetMostHatedPlayerID()) == cCultureEgyptian)
	{
		econPercent = 0.80;
		econEscrow = 0.80;
	}

    }else if(kbGetAge() == cAge3) {
	gNumberMilitaryUnitTypes = 3;

	econPercent = 0.30;
	econEscrow = 0.30;

	//greeks try to skip the third age.
	if(cMyCulture == cCultureGreek)
	{
		econPercent = 0.40;
		econEscrow = 0.40;
	}

    }else if(kbGetAge() == cAge4) {
	gNumberMilitaryUnitTypes = 3;

	econPercent = 0.20;
	econEscrow = 0.20;

    }else if(
		(kbGetAge() >= cAge5 || kbTechTreeGetRandomUnitUpgrade() < 0)
		&&
		(aiGetGameMode() != cGameModeSupremacy)		//-> Wonder
	    )
    {
	gNumberMilitaryUnitTypes = 3;

	econPercent = 0.15;
	econEscrow = 0.15;
    }

    if(kbGetAge() >= cAge2 && aiGetPersonality() == "Apocalypse Bot")
    {
	econPercent = econPercent - 0.05;
	econEscrow = econEscrow - 0.05;
    }

    civPopTarget = 60 - (cvRushBoomSlider*5.99);	// +/- 5
    if (gGlutRatio > 1.0)
    {
	civPopTarget = civPopTarget / gGlutRatio;
    }
    if ( (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 60*8*1000) )
    {
	civPopTarget = 20;	// limited for first 10 minutes while resource glut remains
    }
    if (getSoftPopCap() > 115)	// Plus 20% over 115
    {
	civPopTarget = civPopTarget + 0.2 * (getSoftPopCap()-115);
    }
    if (civPopTarget > 80)	// Don't overboom!
    {
	civPopTarget = 80;
    }
    // Can't use more than 35 in lightning.
    if ( (aiGetGameMode() == cGameModeLightning) && (civPopTarget > 35) )
    {
	civPopTarget = 35;
    }
    milPopTarget = getSoftPopCap() - civPopTarget;

    if (cvMasterDifficulty == cDifficultyEasy)
    {
	civPopTarget = civPopTarget * 0.4;
	milPopTarget = milPopTarget * 0.5;
    }else
    if (cvMasterDifficulty == cDifficultyModerate)
    {
	civPopTarget = civPopTarget * 0.6;
	milPopTarget = milPopTarget * 0.6;
    }else
    if (cvMasterDifficulty == cDifficultyHard)
    {
	civPopTarget = civPopTarget * 0.8;
	milPopTarget = milPopTarget * 0.8;
    }
    kbUnitPickSetMinimumPop(gLandUPID, milPopTarget*.5);
    kbUnitPickSetMaximumPop(gLandUPID, milPopTarget*.75);

    // For econ purist, do lesser of 50% econ boost or 50% mil cut. (For mil, vice versa)
    float econAdjust = -.5 * cvMilitaryEconSlider;

    // Check and see if we're way below our target econ pop.  If so, boost the econ.
    float econShortage = aiGetAvailableEconomyPop();      // i.e., target minus actual
    float econTarget = aiGetEconomyPop();		 // i.e. our script-defined limit.
    econShortage = econShortage / econTarget;    // i.e. 1.0 means we have no villagers, 0.0 means we're at target
    econAdjust = econAdjust + econShortage;      // if we're 30% low, boost it 30%

    if (econAdjust > 1.0) { econAdjust = 1.0; }
    if (econAdjust < -1.0) { econAdjust = -1.0; }

    econPercent = adjustSigmoid(econPercent, econAdjust, 0.0, 1.0);   // Adjust econ up or mil down by econAdjust amount, whichever is smaller
    econEscrow = econPercent;
   }
   updateEM(civPopTarget, milPopTarget, econPercent, 0.2, econEscrow, econEscrow, econEscrow, econEscrow);
}

//==============================================================================
// updatePrices
// 
// This rule constantly compares actual supply vs. forecast, updates AICost 
// values (internal resource prices), and buys/sells at the market as appropriate
//==============================================================================
rule updatePrices
active
minInterval 6
{
	// check for valid forecasts, exit if not ready
	if ( (gGoldForecast + gWoodForecast + gFoodForecast) < 100 )
		return;
	float scaleFactor = 5.0;      // Higher values make prices more volatile
	float goldStatus = 0.0;
	float woodStatus = 0.0;
	float foodStatus = 0.0;
	float minForecast = 200.0 * (1+kbGetAge());	// 200, 400, 600, 800 in ages 1-4, prevents small amount from looking large if forecast is very low
	if (gGoldForecast > minForecast)
		goldStatus = scaleFactor * kbResourceGet(cResourceGold)/gGoldForecast;
	else
		goldStatus = scaleFactor * kbResourceGet(cResourceGold)/minForecast;
	if (gFoodForecast > minForecast)
		foodStatus = scaleFactor * kbResourceGet(cResourceFood)/gFoodForecast;
	else
		foodStatus = scaleFactor * kbResourceGet(cResourceFood)/minForecast;
	if (gWoodForecast > minForecast)
		woodStatus = scaleFactor * kbResourceGet(cResourceWood)/gWoodForecast;
	else
		woodStatus = scaleFactor * kbResourceGet(cResourceWood)/minForecast;
		
	// Status now equals inventory/forecast
	// Calculate value rate of wood:gold and food:gold.  1.0 means they're of the same status, 2.0 means 
	// that the resource is one forecast more scarce, 0.5 means one forecast more plentiful, i.e. lower value.
	float woodRate = (1.0 + goldStatus)/(1.0 + woodStatus);
	float foodRate = (1.0 + goldStatus)/(1.0 + foodStatus);
	
	// The rates are now the instantaneous price for each resource.  Set the long-term prices by averaging this in
	// at a 5% weight.
	
	float cost = 0.0;

	// Wood
	cost = kbGetAICostWeight(cResourceWood);
	cost = (cost * 0.95) + (woodRate * .05);
	kbSetAICostWeight(cResourceWood, cost);

	// Food
	cost = kbGetAICostWeight(cResourceFood);
	cost = (cost * 0.95) + (foodRate * .05);
	kbSetAICostWeight(cResourceFood, cost);

	// Gold
	kbSetAICostWeight(cResourceGold, 1.00);	// gold always 1.0, others relative to gold

	// Favor
	float favorCost = 15.0 - (14.0*(kbResourceGet(cResourceFavor)/100.0));     // 15 when empty, 2.0 when full
	if (favorCost < 1.0)
	{
	    favorCost = 1.0;
	}
	kbSetAICostWeight(cResourceFavor, favorCost);

	// Compare that to the market price.
	// Buy if the market price is lower and we have at least 1/3 forecast of gold.
	// Sell if market price is higher and we have at least 1/3 forecast of the resource.
	// Don't sell if we have enough - prevents market inflation.
	if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) > 0)
	{
		if ( (goldStatus > 0.33) && (kbResourceGet(cResourceGold) > 200) )	// We have one minute's worth of gold (at scale 1.0), OK to buy
		{
			if (
				(aiGetMarketBuyCost(cResourceFood)/100.0) < kbGetAICostWeight(cResourceFood)	// Market cheaper than our rate?
				&&
				(kbResourceGet(cResourceFood) < minForecast*0.5)		// Do we really need to buy Food?
			   )
			{
				aiBuyResourceOnMarket(cResourceFood);
				printEcho("Buying food.");
			}
			if (
				(aiGetMarketBuyCost(cResourceWood)/100.0) < kbGetAICostWeight(cResourceWood)	// Market cheaper than our rate?
				&&
				(kbResourceGet(cResourceWood) < minForecast*0.5)		// Do we really need to buy Wood?
			   )
			{
				aiBuyResourceOnMarket(cResourceWood);
				printEcho("Buying wood.");
			}
		}
		if ( (woodStatus > 0.33) && (kbResourceGet(cResourceWood) > 200) )	// We have one minute's worth of wood, OK to sell
		{
			if (
				(aiGetMarketSellCost(cResourceWood)/100.0) > kbGetAICostWeight(cResourceWood)	// Market rate higher??
				&&
				(kbResourceGet(cResourceGold) < minForecast*0.5)		// Do we really need to sell Wood?
			   )
			{
				aiSellResourceOnMarket(cResourceWood);
				printEcho("Selling wood.");
			}
		}
		if ( (foodStatus > 0.33) && (kbResourceGet(cResourceFood) > 200) )	// We have one minute's worth of food, OK to sell
		{
			if (
				(aiGetMarketSellCost(cResourceFood)/100.0) > kbGetAICostWeight(cResourceFood)	// Market rate higher??
				&&
				(kbResourceGet(cResourceGold) < minForecast*0.5)		// Do we really need to sell Food?
			   )
			{
				aiSellResourceOnMarket(cResourceFood);
				printEcho("Selling food.");
			}
		}
		// Gold from trade...
		int fwMix = kbResourceGet(cResourceFood) + kbResourceGet(cResourceWood);
		if (
			( kbResourceGet(cResourceGold) > fwMix )
			&&
			( kbResourceGet(cResourceGold) > 10000 )
		   )
		{
				aiBuyResourceOnMarket(cResourceFood);
				aiBuyResourceOnMarket(cResourceWood);
				printEcho("Buying food and wood.");
		}else
		if (
			( kbResourceGet(cResourceFood) > kbResourceGet(cResourceWood) )
			&&
			( kbResourceGet(cResourceGold) > 10000 )
		   )
		{
				aiBuyResourceOnMarket(cResourceWood);
				aiBuyResourceOnMarket(cResourceWood);
				printEcho("Buying double wood.");
		}else
		if (
			( kbResourceGet(cResourceWood) > kbResourceGet(cResourceFood) )
			&&
			( kbResourceGet(cResourceGold) > 10000 )
		   )
		{
				aiBuyResourceOnMarket(cResourceFood);
				aiBuyResourceOnMarket(cResourceFood);
				printEcho("Buying double food.");
		}
	}
	// Update the gather plan goal
	int i=0;
	for (i=0; < 3)
	{
		aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, i, kbGetAICostWeight(i));
	}
}

//==============================================================================
// updateGathererRatios()
//==============================================================================
// Check the forecast variables, check inventory, set assignments
void updateGathererRatios(void)
{
	float goldSupply = kbResourceGet(cResourceGold);
	float woodSupply = kbResourceGet(cResourceWood);
	float foodSupply = kbResourceGet(cResourceFood);

   float foodMultiplier = 1.2;      // Because food is so much slower to gather, inflate need
   gFoodForecast = gFoodForecast * foodMultiplier;

	float goldShortage = gGoldForecast - goldSupply;
	if (goldShortage < 0)
		goldShortage = 0;
	float woodShortage = gWoodForecast - woodSupply;
	if (woodShortage < 0)
		woodShortage = 0;
	float foodShortage = gFoodForecast - foodSupply;
	if (foodShortage < 0)
		foodShortage = 0;

   gGlutRatio = 100.0;     // ludicrously high
   if ( (goldSupply/gGoldForecast) < gGlutRatio )
      gGlutRatio = goldSupply/gGoldForecast;
   if ( (woodSupply/gWoodForecast) < gGlutRatio )
      gGlutRatio = woodSupply/gWoodForecast;
   if ( (foodSupply/gFoodForecast) < gGlutRatio )
      gGlutRatio = foodSupply/gFoodForecast;
   gGlutRatio = gGlutRatio * 2.0;   // Double it, i.e. start reducing civ pop when all resources are > 50% of forecast.
   if (gGlutRatio > 3.0)
      gGlutRatio = 3.0;    // Never cut econ below 1/3 of normal
   if (gGlutRatio > 1)
      printEcho("Glut ratio = "+gGlutRatio);
//   printEcho("Forecast/supply  Gold:"+gGoldForecast+"/"+goldSupply+" Wood:"+gWoodForecast+"/"+woodSupply+" Food:"+gFoodForecast+"/"+foodSupply);

   float totalShortage = goldShortage + woodShortage + foodShortage;
   if (totalShortage < 1)
      totalShortage = 1;

   float worstShortageRatio = goldShortage/(gGoldForecast+1);
   if ( (woodShortage/(gWoodForecast+1)) > worstShortageRatio)
      worstShortageRatio = woodShortage/(gWoodForecast+1);
   if ( (foodShortage/(gFoodForecast+1)) > worstShortageRatio)
      worstShortageRatio = foodShortage/(gFoodForecast+1);

		
	float totalForecast = gGoldForecast + gWoodForecast + gFoodForecast;
	if (totalForecast < 1)
		totalForecast = 1;	// Avoid div by 0.
	
	
	float numGatherers = kbUnitCount(cMyID,cUnitTypeAbstractVillager, cUnitStateAlive);
   if (cMyCulture == cCultureAtlantean)
      numGatherers = numGatherers * 3;    // Account for pop slots
	
	float numTradeCarts = kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0), cUnitStateAlive);
	
	float numFishBoats = kbUnitCount(cMyID,kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0), cUnitStateAlive);
   if (numFishBoats >= 1 && gTransportMap == true && cvMasterDifficulty < cDifficultyHard)
      numFishBoats = numFishBoats - 1; // Ignore scout
	
	float civPopTotal = numGatherers + numTradeCarts + numFishBoats;

   int doomedID = -1;   // Who to kill...
   if (civPopTotal > (aiGetEconomyPop()+5) && kbGetAge() > cAge1)
   {  // We need to delete something
      if ( numGatherers > numTradeCarts ) // Gatherer or fish boat
      {
	 if (numGatherers > numFishBoats)
	 {
	    doomedID = findUnit(cMyID, cUnitStateAlive, cUnitTypeAbstractVillager);
	    printEcho("Deleting a villager. "+doomedID);
	 }
	 else
	 {
	    doomedID = findUnit(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0));
	    printEcho("Deleting a fishing boat. "+doomedID);
	 }
      }
      else  // Trade cart or fish boat
      {
	 if (numTradeCarts > numFishBoats)
	 {
	    doomedID = findUnit(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0));
	    printEcho("Deleting a trade cart. "+doomedID);
	 }
	 else
	 {
	    doomedID = findUnit(cMyID, cUnitStateAlive, kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish, 0));
	    printEcho("Deleting a fishing boat. "+doomedID);
	 }
      }
      if (cMyCulture == cCultureAtlantean && kbUnitIsType(doomedID, cUnitTypeAbstractVillager))
      {
	 numGatherers = numGatherers - 3;
      }else{
	 numGatherers = numGatherers - 1;
      }
      aiTaskUnitDelete(doomedID);
   }
	
	// Figure out what percent of our total civ pop we want working on each resource.  To do that,
	// figure out what the percentages would be to match our shortages, and the percents to match
	// our forecast, and come up with a weighted average of the two.  That way, if we don't have a wood shortage
	// at the moment, but we do expect to keep using wood, we'll keep some villagers on wood.
	
		// This much (forecastWeight) of the allocation is based on forecast, the rest on shortages.
		// If the biggest shortage is nearly equal to the forecast (nothing on hand), let
		// the shortage dominate.  If the shortage is relatively small, let the
		// forecast dominate
	float forecastWeight = 1.0 - worstShortageRatio;	
	float goldForecastRatio = gGoldForecast / totalForecast;
	float woodForecastRatio = gWoodForecast / totalForecast;
	float foodForecastRatio = gFoodForecast / totalForecast;
	
	float goldShortageRatio = 0.0;
	if (totalShortage > 0)
		goldShortageRatio = goldShortage / totalShortage;
	float woodShortageRatio = 0.0;
	if (totalShortage > 0)
		woodShortageRatio = woodShortage / totalShortage;
	float foodShortageRatio = 0.0;
	if (totalShortage > 0)
		foodShortageRatio = foodShortage / totalShortage;
		
	float desiredGoldRatio = forecastWeight*goldForecastRatio + (1.0-forecastWeight)*goldShortageRatio;
	float desiredWoodRatio = forecastWeight*woodForecastRatio + (1.0-forecastWeight)*woodShortageRatio;
	float desiredFoodRatio = forecastWeight*foodForecastRatio + (1.0-forecastWeight)*foodShortageRatio;
	
	// We now have the desired ratios, which can be converted to total civilian units, but then need to be adjusted for trade
	// carts and fishing boats.
	float desiredGoldUnits = desiredGoldRatio * civPopTotal;
	float desiredWoodUnits = desiredWoodRatio * civPopTotal;
	float desiredFoodUnits = desiredFoodRatio * civPopTotal;
	
	float neededGoldGatherers = desiredGoldUnits - numTradeCarts;
	float neededFoodGatherers = desiredFoodUnits - numFishBoats;
	float neededWoodGatherers = desiredWoodUnits;
	
	printEcho("Forecast ratios:  Gold "+goldForecastRatio+", Wood "+woodForecastRatio+", Food "+foodForecastRatio);
	printEcho("Shortage ratios:  Gold "+goldShortageRatio+", Wood "+woodShortageRatio+", Food "+foodShortageRatio);
	printEcho("Forecast weight:  "+forecastWeight);
   int intGather = numGatherers;
   int intFish = numFishBoats;
   int intFood = neededFoodGatherers + 0.5;
   int intWood = neededWoodGatherers + 0.5;
   int intGold = neededGoldGatherers + 0.5;
   int intTrade = numTradeCarts;
   printEcho(">>> "+intGather+" villagers:  "+"Food "+intFood+", Wood "+intWood+", Gold "+intGold+"  (Fish "+intFish+", Trade "+intTrade+") <<<");
		
	if (neededGoldGatherers < 0)
		neededGoldGatherers = 0;
	if (neededFoodGatherers < 0)
		neededFoodGatherers = 0;
	if (neededWoodGatherers < 0)
		neededWoodGatherers = 0;
		
	float totalNeededGatherers = neededGoldGatherers + neededFoodGatherers + neededWoodGatherers;
	// Note, this total may be different than the total gatherers, if the trade carts are more than needed, or if
	// the fishing boats supply more food than we need, so this number may be lower...and should be used as the basis
	// for assigning villager percentages.
	
	float goldAssignment = neededGoldGatherers / totalNeededGatherers;
	float woodAssignment = neededWoodGatherers / totalNeededGatherers;
	float foodAssignment = neededFoodGatherers / totalNeededGatherers;
	
	aiSetResourceGathererPercentageWeight( cRGPScript, 1.0);
	aiSetResourceGathererPercentageWeight( cRGPCost, 0.0);
	aiSetResourceGathererPercentage( cResourceGold, goldAssignment, false, cRGPScript);
	aiSetResourceGathererPercentage( cResourceWood, woodAssignment, false, cRGPScript);
	aiSetResourceGathererPercentage( cResourceFood, foodAssignment, false, cRGPScript);
	if ( (cMyCulture == cCultureGreek) && (kbGetAge() > cAge1) )
		aiSetResourceGathererPercentage( cResourceFavor, 0.08, false, cRGPScript);
	aiNormalizeResourceGathererPercentages( cRGPScript );
	aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, aiGetResourceGathererPercentage(cResourceGold, cRGPScript));
	aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, aiGetResourceGathererPercentage(cResourceWood, cRGPScript));
	aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, aiGetResourceGathererPercentage(cResourceFood, cRGPScript));
	aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, aiGetResourceGathererPercentage(cResourceFavor, cRGPScript));
}

//==============================================================================
// setMilitaryUnitCostForecast
// Checks the current age, looks into the appropriate unit picker,
// calculates approximate resource needs for the next few (3?) minutes,
// adds this amount to the global vars.
//==============================================================================
void setMilitaryUnitCostForecast(void)
{
	int upID = gLandUPID;		// ID of the unit picker to query
	float totalAmount = 0.0;	// Total resources to be spent in near future
	if (kbGetAge() == cAge2)
	{
		totalAmount = 1200;

	    if(cMyCulture == cCultureEgyptian)
	    {
		totalAmount = 800;
	    }
	    if(cMyCulture == cCultureAtlantean)
	    {
		totalAmount = 1500;
	    }
	}
	if (kbGetAge() == cAge3)
	{
		totalAmount = 3000;

	    if(cMyCulture == cCultureEgyptian)
	    {
		totalAmount = 4000;
	    }
	}
	if (kbGetAge() >= cAge4)
	{
		totalAmount = 5000;
	}

   int origGold = gGoldForecast;
   int origWood = gWoodForecast;
   int origFood = gFoodForecast;
		

   float goldCost = 0.0;
   float woodCost = 0.0;
   float foodCost = 0.0;
   float totalCost = 0.0;

	int unitID = kbUnitPickGetResult( upID, 0);	// Primary unit
	float weight = 1.0;
   int numUnits = kbUnitPickGetDesiredNumberUnitTypes(upID);

   if (numUnits == 2)
      weight = 0.67; // 2/3 and 1/3
   if (numUnits >= 3)
      weight = 0.50; // 1/2, 1/3, 1/6
   printEcho("Military Unit Cost Forecast:");
   printEcho("       Main unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
   
   goldCost = kbUnitCostPerResource(unitID, cResourceGold);
   woodCost = kbUnitCostPerResource(unitID, cResourceWood);
   foodCost = kbUnitCostPerResource(unitID, cResourceFood);
   totalCost = goldCost+woodCost+foodCost;
	
	gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
	gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
	gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);

   if (numUnits > 1)
   {  // Do second unit
      unitID = kbUnitPickGetResult(upID, 1);
      weight = 0.33;    // Second is 1/3 regardless 
      printEcho("       Secondary unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
      goldCost = kbUnitCostPerResource(unitID, cResourceGold);
      woodCost = kbUnitCostPerResource(unitID, cResourceWood);
      foodCost = kbUnitCostPerResource(unitID, cResourceFood);
      totalCost = goldCost+woodCost+foodCost;
	   
	   gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
	   gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
	   gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
   }

   if (numUnits > 2)
   {  // Do third unit
      unitID = kbUnitPickGetResult(upID, 2);
      weight = 0.167;    // Third unit, if used, is 1/6
      printEcho("       Tertiary unit is "+unitID+" "+ kbGetProtoUnitName(unitID)+", weight "+weight);
      goldCost = kbUnitCostPerResource(unitID, cResourceGold);
      woodCost = kbUnitCostPerResource(unitID, cResourceWood);
      foodCost = kbUnitCostPerResource(unitID, cResourceFood);
      totalCost = goldCost+woodCost+foodCost;
	   
	   gGoldForecast = gGoldForecast + goldCost * (totalAmount*weight/totalCost);
	   gWoodForecast = gWoodForecast + woodCost * (totalAmount*weight/totalCost);
	   gFoodForecast = gFoodForecast + foodCost * (totalAmount*weight/totalCost);
   }
   printEcho("       Mil forecast gold: "+(gGoldForecast-origGold)+", wood: "+(gWoodForecast-origWood)+", food: "+(gFoodForecast-origFood));
}

//==============================================================================
// addUnitForecast()
//==============================================================================
void addUnitForecast(int unitTypeID=-1, int qty=1)
{
   if (unitTypeID < 0)
      return;
   gGoldForecast = gGoldForecast + kbUnitCostPerResource(unitTypeID, cResourceGold)*qty;
   gWoodForecast = gWoodForecast + kbUnitCostPerResource(unitTypeID, cResourceWood)*qty;
   gFoodForecast = gFoodForecast + kbUnitCostPerResource(unitTypeID, cResourceFood)*qty;
}

//==============================================================================
// addTechForecast()
//==============================================================================
void addTechForecast(int techID=-1)
{
   if (techID < 0)
      return;
   gGoldForecast = gGoldForecast + kbTechCostPerResource(techID, cResourceGold);
   gWoodForecast = gWoodForecast + kbTechCostPerResource(techID, cResourceWood);
   gFoodForecast = gFoodForecast + kbTechCostPerResource(techID, cResourceFood);
}

//==============================================================================
// econForecastAge4
//==============================================================================
rule econForecastAge4		// Rule activates when age 4 research begins
minInterval 11
inactive
runImmediately
{	
	if ( (kbGetAge() == cAge3) && (kbGetTechStatus(gAge4MinorGod) < cTechStatusResearching) )	// Upgrade failed, revert
	{
		printEcho("Age 4 upgrade failed.");
		xsDisableSelf();
		xsEnableRule("econForecastAge3Mid");
		return;
	}
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;

	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = 900;
		gWoodForecast = 500;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureNorse)
	{
		gGoldForecast = 800;
		gWoodForecast = 800;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureGreek)
	{
		gGoldForecast = 800;
		gWoodForecast = 800;
		gFoodForecast = 300;
	}
	if (cMyCulture == cCultureAtlantean)
	{
		gGoldForecast = 700;
		gWoodForecast = 800;
		gFoodForecast = 400;
	}
	if (cMyCulture == cCultureChinese)
	{
		gGoldForecast = 700;
		gWoodForecast = 800;
		gFoodForecast = 400;
	}

	
	int temp = 0;
	// Assume all towers built.  Since we don't replace towers, doing a count is dangerous.
	
	// tower upgrades
	if (gBuildTowers == true)
	{
		// BallistaTower
		if ( (cMyCulture == cCultureEgyptian) && (kbGetTechStatus(cTechBallistaTower) < cTechStatusResearching) )
		{
			addTechForecast(cTechBallistaTower);
		}
	}
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);	// How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Number of villagers we have, including dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);		// Makes up for counting dwarves toward our villager total
	if (temp > 12)
		temp = 12;		// Just 3 minutes worth, please.
   if (temp < 0)
      temp = 0;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);
	
	// Farms...assume we need to have 1 farm per food gatherer
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);		// Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
      if (temp > 8 )
	 temp = 8;      // more than we'll build in 3 minutes

		if (temp > 0)
			addUnitForecast(cUnitTypeFarm, temp);
	}
	
	// Market
	if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 2)
		addUnitForecast(cUnitTypeMarket, 1);
	
   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
      temp = 0;
   if (temp > 0)
   {
      gWoodForecast = gWoodForecast + 100*temp;
      gGoldForecast = gGoldForecast + 50*temp;
   }

	// Trade carts
	if (gTradeMaintainPlanID >= 0)
	{	// We're making trade carts
		int cartsNeeded = aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0);
		cartsNeeded = cartsNeeded - kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
		if (cartsNeeded > 0)
		   addUnitForecast(aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanUnitType, 0),cartsNeeded);
	}

	// Fortress, etc.
	int bigBuildingID = getBigBuildingID();
	if (kbUnitCount(cMyID, bigBuildingID, cUnitStateAliveOrBuilding) < 1) 
      addUnitForecast(bigBuildingID, 1);
   
	setMilitaryUnitCostForecast();   // Get the estimate of military needs
		
	printEcho("Age 4 Forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios();
}

//==============================================================================
// econForecastAge3Mid
//==============================================================================
rule econForecastAge3Mid		// Rule activates when 2 minutes into age 3, turns off when age 4 research begins
minInterval 11
inactive
runImmediately
{
	if ( kbGetTechStatus(gAge4MinorGod) >=  cTechStatusResearching )	// On our way to age 4, hand off...
	{
		xsEnableRule("econForecastAge4");
		econForecastAge4();
		xsDisableSelf();
		return;		// We're done
	}
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;

	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = 2035;
		gWoodForecast = 600;
		gFoodForecast = 1400;
	}
	if (cMyCulture == cCultureNorse)
	{
		gGoldForecast = 1800;
		gWoodForecast = 990;
		gFoodForecast = 1300;
	}
	if (cMyCulture == cCultureGreek)
	{
		gGoldForecast = 1800;
		gWoodForecast = 1050;
		gFoodForecast = 1300;
	}
	if (cMyCulture == cCultureAtlantean)
	{
		gGoldForecast = 1725;
		gWoodForecast = 975;
		gFoodForecast = 1400;
	}
	if (cMyCulture == cCultureChinese)
	{
		gGoldForecast = 1725;
		gWoodForecast = 975;
		gFoodForecast = 1400;
	}
	
	int temp = 0;

   // Fortified TC
   if ( kbGetTechStatus(cTechFortifyTownCenter) < cTechStatusResearching) 
      addTechForecast(cTechFortifyTownCenter);

	// towers
	temp = 0;
	if (gTargetNumTowers > 0)
		temp = (4 + gTargetNumTowers) - kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
	if (temp < 0)
		temp = 0;
   if (temp > 0)
      addUnitForecast(cUnitTypeTower, temp);
 
	// tower upgrades
	if (gBuildTowers == true)
	{
		// GuardTower
		if ( (cMyCulture != cCultureNorse) &&(kbGetTechStatus(cTechGuardTower) < cTechStatusResearching) )
		{
			addTechForecast(cTechGuardTower);	
		}
		// Carrier Pigeons
		if ( kbGetTechStatus(cTechCarrierPigeons) < cTechStatusResearching)
		{
			addTechForecast(cTechCarrierPigeons);
		}
		if(cvMasterDifficulty < cDifficultyNightmare)
		{
			// Boiling Oil
			if ( kbGetTechStatus(cTechBoilingOil) < cTechStatusResearching)
			{
				addTechForecast(cTechBoilingOil);
			}
		}
	}
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);	// How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Number of villagers we have, including dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);		// Makes up for counting dwarves toward our villager total
	if (temp > 12)
		temp = 12;		// Just 3 minutes worth, please.
   if (cMyCulture == cCultureAtlantean)
      if (temp > 4)
	 temp = 4;
 	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);
	
	// Farms...assume we need to have 1 farm per food gatherer
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);		// Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
      if (temp > 8 )
	 temp = 8;      // more than we'll build in 3 minutes

		if (temp > 0)
	 addUnitForecast(cUnitTypeFarm, temp);
	}
	
   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
      temp = 0;
   if (temp > 0)
   {
      gWoodForecast = gWoodForecast + 100*temp;
      gGoldForecast = gGoldForecast + 50*temp;
   }

	// Market
	if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 1)
	{
		addUnitForecast(cUnitTypeMarket, 1);
	}
	
	// Trade carts
	if (gTradeMaintainPlanID >= 0)
	{	// We're making trade carts
		int cartsNeeded = aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0);
		cartsNeeded = cartsNeeded - kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);
		if (cartsNeeded > 0)
		   addUnitForecast(aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanUnitType, 0),cartsNeeded);
	}

	// Fortress, etc.
	int bigBuildingID = getBigBuildingID();
	if (kbUnitCount(cMyID, bigBuildingID, cUnitStateAliveOrBuilding) < 1) 
      addUnitForecast(bigBuildingID, 1);
	
	setMilitaryUnitCostForecast();		
	
	printEcho("Age 3 (mid) Forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios();
}

//==============================================================================
// econForecastAge3Early
//==============================================================================
rule econForecastAge3Early		// Rule activates when age3 research begins, turns off when we've been in age 3 for 2 minutes
minInterval 11
inactive
runImmediately
{
	static int	ageStartTime = -1;
	
	if ( (kbGetAge() == cAge2) && (kbGetTechStatus(gAge3MinorGod) < cTechStatusResearching) )	// Upgrade failed, revert
	{
		//printEcho("Age 3 upgrade failed.");
		xsDisableSelf();
		xsEnableRule("econForecastAge2Mid");
		return;
	}
	
	if ( (kbGetAge() >= cAge3) && (ageStartTime == -1))
		ageStartTime = xsGetTime();
		
	if ( (kbGetAge() >= cAge3) && ((xsGetTime() - ageStartTime) > 120000) )	// more than 2 minutes in third age?
	{
		//printEcho("Enabling econForecastAge3Mid.");
		xsEnableRule("econForecastAge3Mid");
		econForecastAge3Mid();
		xsDisableSelf();
		return;		// We're done
	}
	
	// If we've made it here, we're in researching age 3, or we're in the first
	// 2 minutes of age 3.  Let's see what we need.
		
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;

	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = 1485;
		gWoodForecast = 800;
		gFoodForecast = 1300;
	}
	if (cMyCulture == cCultureNorse)
	{
		gGoldForecast = 1000;
		gWoodForecast = 1300;
		gFoodForecast = 1310;
	}
	if (cMyCulture == cCultureGreek)
	{
		gGoldForecast = 1100;
		gWoodForecast = 1300;
		gFoodForecast = 1600;
	}
	if (cMyCulture == cCultureAtlantean)
	{
		gGoldForecast = 1325;
		gWoodForecast = 1400;
		gFoodForecast = 1575;
	}
	if(cMyCulture == cCultureChinese)
	{
		gGoldForecast = 1325;
		gWoodForecast = 1400;
		gFoodForecast = 1575;
	}
	int temp = 0;
	
	// towers
	temp = 0;
	if (gTargetNumTowers > 0)
		temp = (4 + gTargetNumTowers) - kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
	if (temp < 0)
		temp = 0;
   if (temp>0)
      addUnitForecast(cUnitTypeTower, temp);

	// tower upgrades
	if (gBuildTowers == true)
	{
		// GuardTower
		if ( (cMyCulture != cCultureNorse) &&(kbGetTechStatus(cTechGuardTower) < cTechStatusResearching) )
	 addTechForecast(cTechGuardTower);	

		// Carrier Pigeons
		if ( kbGetTechStatus(cTechCarrierPigeons) < cTechStatusResearching)
	 addTechForecast(cTechCarrierPigeons);
	}
		
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);	// How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Number of villagers we need, ignoring dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);		// Makes up for counting dwarves toward our villager total
	if (cMyCulture != cCultureAtlantean)
   {
      if (temp > 12)
	   	temp = 12;		// Just 3 minutes worth, please.
   }
   else
      if (temp > 4)
	 temp = 4;
   
	if (cMyCulture != cCultureAtlantean)
   {
   	if (temp < 8)
		   temp = 8;		// In transition, we won't have the age 2 villie target, so assume at least 8 more.
   }
   else
      if (temp < 3)
	 temp = 3;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);

   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
      temp = 0;
   if (temp > 0)
   {
      gWoodForecast = gWoodForecast + 100*temp;
      gGoldForecast = gGoldForecast + 50*temp;
   }

	// Farms...assume we need to have 1 farm per food gatherer
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);		// Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
      if (temp > 8 )
	 temp = 8;      // more than we'll build in 3 minutes

		if (temp > 0)
	 addUnitForecast(cUnitTypeFarm, temp);
	}
   // 1 Settlement for atlanteans
   if ((cMyCulture == cCultureAtlantean || cvRushBoomSlider < -0.5) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) <= 3))
      addUnitForecast(cUnitTypeSettlementLevel1, 1);

	setMilitaryUnitCostForecast();		
	printEcho("Age 3 (early) forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");

	updateGathererRatios();
}

//==============================================================================
// econForecastAge2Mid
//==============================================================================
rule econForecastAge2Mid		// Rule activates when 2 minutes into age 2, turns off when age 3 research begins
minInterval 11
inactive
runImmediately
{
	if ( kbGetTechStatus(gAge3MinorGod) >=  cTechStatusResearching) 	// On our way to age 3, hand off...
	{
		//printEcho("Enabling econForecastAge3Early.");
		xsEnableRule("econForecastAge3Early");
		econForecastAge3Early();
		xsDisableSelf();
		return;		// We're done
	}
	
	// If we've made it here, we're in mid age 2.
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;

	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = 935;
		gWoodForecast = 150;
		gFoodForecast = 1200;
	}
	if (cMyCulture == cCultureNorse)
	{
		gGoldForecast = 700;
		gWoodForecast = 490;
		gFoodForecast = 1150;
	}
	if (cMyCulture == cCultureGreek)
	{
		gGoldForecast = 800;
		gWoodForecast = 550;
		gFoodForecast = 950;
	}
   if (cMyCulture == cCultureAtlantean)
   {
      gGoldForecast = 895;
      gWoodForecast = 315;
      gFoodForecast = 1000;
   }
  if(cMyCulture == cCultureChinese)
  {
	  gGoldForecast = 895;
	  gWoodForecast = 315;
	  gFoodForecast = 1000;
  }
	
	int temp = 0;

	// towers
	temp = 0;
	if (gTargetNumTowers > 0)
		temp = (4 + gTargetNumTowers/2) - kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
	if (temp < 0)
		temp = 0;
   if (temp > 0)
      addUnitForecast(cUnitTypeTower, temp);

	// tower upgrades
	if (gBuildTowers == true)
	{
		// Watchtower
		if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) <= cTechStatusResearching))
	 addTechForecast(cTechWatchTower);

		// Crenallations
		if ( kbGetTechStatus(cTechCrenellations) < cTechStatusResearching)
	 addTechForecast(cTechCrenellations);

		// Signal Fires
		if ( kbGetTechStatus(cTechSignalFires) < cTechStatusResearching)
	 addTechForecast(cTechSignalFires);
	}

   // Settlements
   int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);  // Settlements paid for
   temp = (gEarlySettlementTarget + 1) - numberSettlements;       // To be paid for
   if (temp <= 0)
      temp = 0;
   if (temp > 0)
      addUnitForecast(cUnitTypeSettlementLevel1, temp);
   printEcho("Adding forecast for "+temp+" early settlements.");

	// outposts
	if (cMyCulture == cCultureEgyptian)
	{
		temp = 10 - kbUnitCount(cMyID, cUnitTypeOutpost, cUnitStateAliveOrBuilding);
		if (temp > 0)
	 addUnitForecast(cUnitTypeOutpost, temp);
	}	

   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
      temp = 0;
   if (temp > 0)
   {
      gWoodForecast = gWoodForecast + 100*temp;
      gGoldForecast = gGoldForecast + 50*temp;
   }
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);	// How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Number of villagers we have, including dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);		// Makes up for counting dwarves toward our villager total
	if (temp > 12)
		temp = 12;		// Just 3 minutes worth, please.
   if (cMyCulture == cCultureAtlantean)
      if (temp > 4)
	 temp = 4;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);
	
	// Farms...assume we need to have 1 farm per food gatherer
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);		// Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
      if (temp > 8 )
	 temp = 8;      // more than we'll build in 3 minutes

		if (temp > 0)
	 addUnitForecast(cUnitTypeFarm, temp);
	}	
   // 1 Settlement for atlanteans
   if ((cMyCulture == cCultureAtlantean) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) <= 3))
      addUnitForecast(cUnitTypeSettlementLevel1, 1);

	setMilitaryUnitCostForecast();		
	
	printEcho("Age 2 (mid) forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios();
}

//==============================================================================
// econForecastAge2Early
//==============================================================================
rule econForecastAge2Early		// Rule activates when age2 research begins, turns off when we've been in age 2 for 2 minutes
minInterval 11
inactive
runImmediately
{
    static int ageStartTime = -1;
	
    if ( (kbGetAge() == cAge1) && (kbGetTechStatus(gAge2MinorGod) < cTechStatusResearching) )	// Upgrade failed, revert
    {
	//printEcho("Age 2 upgrade failed.");
	xsDisableSelf();
	xsEnableRule("econForecastAge1Mid");
	return;
    }
	
	if ( (kbGetAge() >= cAge2) && (ageStartTime == -1))
		ageStartTime = xsGetTime();
		
	if ( (kbGetAge() >= cAge2) && ((xsGetTime() - ageStartTime) > 120000) )	// more than 2 minutes in second age?
	{
		//printEcho("Enabling econForecastAge2Mid.");
		xsEnableRule("econForecastAge2Mid");
		econForecastAge2Mid();
		xsDisableSelf();
		return;			// We're done
	}
	
	// If we've made it here, we're in researching age 2, or we're in the first
	// 2 minutes of age 2.  Let's see what we need.
	
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 200.0;     // Keep a bit of extra food around
		
   int temp=0;

	// Houses...assume we'll need a total of 2 more
   if (cMyCulture == cCultureAtlantean)
      addUnitForecast(cUnitTypeManor, 2);
   else
      addUnitForecast(cUnitTypeHouse, 2);

   // fish boats
   if (gFishing == true)
   {
      // get current fish boat count
      int fishBoatType = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
      int boatCount = kbUnitCount(cMyID, fishBoatType, cUnitStateAlive);
      int fishCount = kbUnitCount(0, cUnitTypeFish, cUnitStateAlive);
      temp = gNumBoatsToMaintain - boatCount;
      if (temp > fishCount && fishCount >= 0)
	 temp = fishCount;
      if (temp > 0) {
	 addUnitForecast(fishBoatType, temp);
	 printEcho("Need "+temp+" fishing boats.");
      }

      // do we need a dock?
      temp = 1 - kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding);
      if (temp < 0)
	 temp = 0;
      if (temp > 0)
	 addUnitForecast(cUnitTypeDock, 1);
   }
   // Guild
   if (cMyCulture == cCultureAtlantean)
   {
      if(kbUnitCount(cMyID,cUnitTypeGuild, cUnitStateAliveOrBuilding) <= 0)
	 addUnitForecast(cUnitTypeGuild, 1);
   }

	// towers
	temp = 0;
	if (gTargetNumTowers > 0)
		temp = (4 + gTargetNumTowers/2) - kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAliveOrBuilding);
	if (temp < 0)
		temp = 0;

   if (temp > 0)
      addUnitForecast(cUnitTypeTower, temp);

	// first tower upgrade
	if (gBuildTowers == true)
	{
		if ((cMyCulture != cCultureEgyptian) && (kbGetTechStatus(cTechWatchTower) <= cTechStatusResearching))
	 addTechForecast(cTechWatchTower);
	}

   // Settlements
   int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);  // Settlements paid for
   temp = (gEarlySettlementTarget + 1) - numberSettlements;       // To be paid for
   if (temp <= 0)
      temp = 0;
   if (temp > 0)
      addUnitForecast(cUnitTypeSettlementLevel1, temp);
   printEcho("Adding forecast for "+temp+" early settlements.");
	// outposts
	if (cMyCulture == cCultureEgyptian)
	{
		temp = 10 - kbUnitCount(cMyID, cUnitTypeOutpost, cUnitStateAliveOrBuilding);
		if (temp > 0)
	 addUnitForecast(cUnitTypeOutpost, temp);
	}	
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);	// How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Number of villagers we need, ignoring dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);		// Makes up for counting dwarves toward our villager total
	if (cMyCulture != cCultureAtlantean)
   {
      if (temp > 12)
	   	temp = 12;		// Just 3 minutes worth, please.
   }
   else
      if (temp > 4)
	 temp = 4;
   
	if (cMyCulture != cCultureAtlantean)
   {
   	if (temp < 8)
		   temp = 8;		// In transition, we won't have the age 2 villie target, so assume at least 8 more.
   }
   else
      if (temp < 3)
	 temp = 3;
	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);

	
	// dropsites, assume 1 for norse, 2 for greek.
	if (cMyCulture == cCultureGreek)
	{
		temp = 2;
		gWoodForecast = gWoodForecast + 50*temp;
	}
	if (cMyCulture == cCultureNorse)
	{
		temp = 1;
		gWoodForecast = gWoodForecast + 50*temp;
		gFoodForecast = gFoodForecast + 50*temp;
	}
	
	// military buildings, assume 1 needed regardless of how many we have
	if (cMyCulture == cCultureGreek)
	{
		gWoodForecast = gWoodForecast + 100;
	}
	if (cMyCulture == cCultureNorse)
	{
		gWoodForecast = gWoodForecast + 110;
	}
	if (cMyCulture == cCultureEgyptian)
	{
		gGoldForecast = gGoldForecast + 75;
	}
	if (cMyCulture == cCultureAtlantean)
	{
		gWoodForecast = gWoodForecast + 75;
		gGoldForecast = gGoldForecast + 25;
	}
	if(cMyCulture == cCultureChinese)
	{
		gWoodForecast = gWoodForecast + 75;
		gGoldForecast = gGoldForecast + 25;
	}

	//Greek Heroes
	if (cMyCiv == cCivZeus)
	{
	    addUnitForecast(cUnitTypeHeroGreekJason, 1);
	    addUnitForecast(cUnitTypeHeroGreekOdysseus, 1);

	    createSimpleTrainPlan(cUnitTypeHeroGreekJason, 1, false, kbBaseGetMainID(cMyID), 10000);
	}else
	if (cMyCiv == cCivPoseidon)
	{
	    addUnitForecast(cUnitTypeHeroGreekTheseus, 1);
	    addUnitForecast(cUnitTypeHeroGreekHippolyta, 1);

	    createSimpleTrainPlan(cUnitTypeHeroGreekTheseus, 1, false, kbBaseGetMainID(cMyID), 10000);
	}else
	if (cMyCiv == cCivHades)
	{
	    addUnitForecast(cUnitTypeHeroGreekAjax, 1);
	    addUnitForecast(cUnitTypeHeroGreekChiron, 1);

	    createSimpleTrainPlan(cUnitTypeHeroGreekAjax, 1, false, kbBaseGetMainID(cMyID), 10000);
	}

	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);		// Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
      if (temp > 8 )
	 temp = 8;      // more than we'll build in 3 minutes
		if (temp > 0)
	 addUnitForecast(cUnitTypeFarm, temp);
	}
	
   // Ships
   int myShips = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
   temp = gTargetNavySize - myShips;   // How many yet to train
   if (temp < 0)
      temp = 0;
   if (temp > 0)
   {
      gWoodForecast = gWoodForecast + 100*temp;
      gGoldForecast = gGoldForecast + 50*temp;
   }

	// Techs
	if ( kbGetTechStatus(cTechPlow) < cTechStatusResearching)
      addTechForecast(cTechPlow);
   if ( kbGetTechStatus(cTechHusbandry) < cTechStatusResearching)
      addTechForecast(cTechHusbandry);
	if ( kbGetTechStatus(cTechHuntingDogs) < cTechStatusResearching)
      addTechForecast(cTechHuntingDogs);
	if ( kbGetTechStatus(cTechHandAxe) < cTechStatusResearching)
      addTechForecast(cTechHandAxe);	
	if ( kbGetTechStatus(cTechPickaxe) < cTechStatusResearching)
      addTechForecast(cTechPickaxe);


   // 1 Settlement for atlanteans
   if ((cMyCulture == cCultureAtlantean) && (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) <= 1))
   {
		gGoldForecast = gGoldForecast + 200;
		gWoodForecast = gWoodForecast + 200;
		gFoodForecast = gFoodForecast + 100;
   }
	printEcho("Age 2 (early) forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	updateGathererRatios();
}

//==============================================================================
// econForecastAge1Mid
//==============================================================================
rule econForecastAge1Mid		// Rule active for mid age 1 (cAge1), starting 2 minutes in age, ending when next age upgrade starts
minInterval 11
inactive
{
	static int ageStartTime = -1;
	
	int age = kbGetAge();
	if (age > cAge1)
	{
		xsDisableSelf();
		xsEnableRule("econForecastAge2Early");
		return;
	}
	
	if (ageStartTime == -1)
		ageStartTime = xsGetTime();
		

	if ( kbGetTechStatus(gAge2MinorGod) >= cTechStatusResearching )	
	{	// Next age upgrade is on the way
		xsDisableSelf();
		xsEnableRule("econForecastAge2Early");
		econForecastAge2Early();	// Since runImmediately doesn't seem to be working
		return;
	}
	
	// If we've made it here, we're in age 1 (cAge1), we've been in the age at least 2 minutes,
	// and we haven't started the age 3 upgrade.  Let's see what we need.
	
	gGoldForecast = 0.0;
	gWoodForecast = 0.0;
	gFoodForecast = 0.0;
			
	// Houses...assume we'll need 2
	int temp = 2;
	if (cMyCulture == cCultureAtlantean)
	{
	    addUnitForecast(cUnitTypeManor, 2);
	}else{
	    addUnitForecast(cUnitTypeHouse, 3);
	}

	// temple
	temp = 1 - kbUnitCount(cMyID, cUnitTypeTemple, cUnitStateAliveOrBuilding);
	if (temp > 0)
	{
	    addUnitForecast(cUnitTypeTemple, temp);
	    if (xsGetTime() > 3*60*1000) {
		addUnitForecast(cUnitTypeTemple, 1);      // Add an extra, we need it soon!
	    }
	}

	if (cMyCiv == cCivThor)  // add 100 to cover early dwarfage
	{
	    gGoldForecast = gGoldForecast + 100*temp;
	}


	// Settlements, even if we won't build them until age 2...
	int numberSettlements=getNumberUnits(cUnitTypeAbstractSettlement, cMyID, cUnitStateAliveOrBuilding);  // Settlements paid for
	temp = gEarlySettlementTarget - numberSettlements;       // To be paid for
	if (temp < 0)
	    temp = 0;
	if ( (temp > 0) && (cMyCulture == cCultureAtlantean) )
	{
	    addUnitForecast(cUnitTypeSettlementLevel1, temp);
	    printEcho("Adding forecast for "+temp+" early settlements.");
	}

	// outposts
	if (cMyCulture == cCultureEgyptian)
	{
		addUnitForecast(cUnitTypeOutpost, 4);  // Assume we'll need a few more
	}	
	
	// villagers
	temp = aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanNumberToMaintain, 0);	// How many we want
	temp = temp - 1;	// Assume 1 in production
	temp = temp - kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Number of villagers we need, ignoring dwarves
	temp = temp + kbUnitCount(cMyID, cUnitTypeDwarf, cUnitStateAlive);		// Makes up for counting dwarves toward our villager total

   if (cMyCulture == cCultureAtlantean)
   {
      if(temp > 5)
	 temp = 5;      // Just a few minutes' worth
   }
   else
   {
      if(temp > 13)
	 temp = 13;      // Just a few minutes' worth
   }

	addUnitForecast(aiPlanGetVariableInt(gCivPopPlanID, cTrainPlanUnitType, 0), temp);

   // fish boats
   if (gFishing == true)
   {
      // get current fish boat count
      int fishBoatType = kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
      int boatCount = kbUnitCount(cMyID, fishBoatType, cUnitStateAlive);
      int fishCount = kbUnitCount(0, cUnitTypeFish, cUnitStateAlive);
      temp = gNumBoatsToMaintain - boatCount;
      if (temp > fishCount && fishCount >= 0)
	 temp = fishCount;
      gWoodForecast = gWoodForecast + 50*temp;
      if (temp > 0)
	 printEcho("Need "+temp+" fishing boats.");

      temp = 1 - kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding);
      if (temp < 0)
	 temp = 0;
      if (temp > 0)
	 addUnitForecast(cUnitTypeDock, 1);
   }
	
	// Age 2 upgrade
	gFoodForecast = gFoodForecast + 400;
	
	// dropsites
	if (cMyCulture == cCultureGreek)
	{
		temp = 2;
		gWoodForecast = gWoodForecast + 50*temp;
	}
	if (cMyCulture == cCultureNorse)
	{
		temp = 1;
		gWoodForecast = gWoodForecast + 50*temp;
		gFoodForecast = gFoodForecast + 50*temp;
	}
	if (gFarming == true)
	{
		float foodGatherersWanted = aiPlanGetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood);		// Percent food gatherers
		foodGatherersWanted = foodGatherersWanted * kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);	// Actual count
		temp = foodGatherersWanted - kbUnitCount(cMyID, cUnitTypeFarm, cUnitStateAliveOrBuilding);
		if (temp < 0)
			temp = 0;
      if (temp > 5)
	 temp = 5;
		if (temp > 0)
	 addUnitForecast(cUnitTypeFarm, temp);
	}
	printEcho("Age 1 (mid) forecast:  Gold "+gGoldForecast+", wood "+gWoodForecast+", food "+gFoodForecast+".");
	if(gNewCivMod || cvRandomMapName == "vinlandsaga" || xsGetTime() > 5*60*1000)
	{
		updateGathererRatios();		//Keep room for our Age1 BO!
	}
}

//==============================================================================
// ageUpBuildingMonitor	(NEW)
//==============================================================================
rule ageUpBuildingMonitor
minInterval 130
active
{
   int mainID = findUnit(cMyID, cUnitStateAlive, cUnitTypeAbstractSettlement);
   int buildingTypeID = getModAgeUpBuildingType();
   int buildingCount = kbUnitCount(cMyID, buildingTypeID, cUnitStateAliveOrBuilding);
   if(buildingCount < 1 && kbCanAffordUnit(buildingTypeID, cEconomyEscrowID) && mainID >= 0)
   {
	printEcho("Constructing AgeUpBuilding_"+kbGetAge()+1);
	createSimpleBuildPlan(getModAgeUpBuildingType(), 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
   }
}

//==============================================================================
//initGreek
//==============================================================================
void initGreek(void)
{
   printEcho("GREEK Init:");

   //Modify our favor need.  A pseudo-hack.
   aiSetFavorNeedModifier(10.0);

   //Greek scout types.
   gLandScout=cUnitTypeScout;
   gAirScout=cUnitTypePegasus;
   gWaterScout=cUnitTypeFishingShipGreek;
   //Create the Greek scout plan.

   int exploreID=aiPlanCreate("Explore_SpecialGreek", cPlanExplore);
   if (exploreID >= 0)
   {
      aiPlanAddUnitType(exploreID, cUnitTypeScout, 1, 1, 1);
      aiPlanSetActive(exploreID);
   }

   //Train before age up!
   if (gFakeDeathmatch == true && aiGetGameMode() != cGameModeDeathmatch)
   {
      int heroType = -1;
      if (cMyCiv == cCivZeus)
      {
	 heroType = cUnitTypeHeroGreekJason;
      }
      else if (cMyCiv == cCivPoseidon)
      {
	 heroType = cUnitTypeHeroGreekTheseus;
      }
      else if (cMyCiv == cCivHades)
      {
	 heroType = cUnitTypeHeroGreekAjax;
      }
      int dmHeroPlan=aiPlanCreate("dm hero", cPlanTrain);
      if (dmHeroPlan >= 0)
      {
	 aiPlanSetVariableInt(dmHeroPlan, cTrainPlanUnitType, 0, heroType);
	 //Train off of economy escrow.
	 aiPlanSetEscrowID(dmHeroPlan, cMilitaryEscrowID);
	 aiPlanSetVariableInt(dmHeroPlan, cTrainPlanNumberToTrain, 0, 1);
	 aiPlanSetVariableInt(dmHeroPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement);
	 aiPlanSetDesiredPriority(dmHeroPlan, 200);
	 aiPlanSetActive(dmHeroPlan);
      }
   }

   //Zeus.
   if (cMyCiv == cCivZeus)
   {
      //Create a simple plan to maintain 1 water scout.
      if (gTransportMap == true && cvMasterDifficulty < cDifficultyHard)
	 createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

      //Random Age2 God.
      if(kbGetCivForPlayer(aiGetMostHatedPlayerID()) == cCivZeus)
      {
	 gAge2MinorGod=cTechAge2Hermes;
      }else{
	if(aiRandInt(3)==1)	//More likely to choose Athena.
	{
	 gAge2MinorGod=cTechAge2Hermes;
	}else{
	 gAge2MinorGod=cTechAge2Athena;
	}
      }
      //Get Underworld Passage if we have a transport map.  Else, random.
      if (gTransportMap == true)
      {
	 gAge3MinorGod=cTechAge3Apollo;
      }else{
	if(aiRandInt(3)==1)	//More likely to choose Dionysos.
	{
	 gAge3MinorGod=cTechAge3Apollo;
	}else{
	 gAge3MinorGod=cTechAge3Dionysos;
	}
      }
      //Get Lightning if we're rushing.  Else, random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge4MinorGod=cTechAge4Hera;
      }else{
	 gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
      }
   }
   //Poseidon.
   else if (cMyCiv == cCivPoseidon)
   {
      //Give him the hippocampus as his water scout.
      gWaterScout=cUnitTypeHippocampus;
      printEcho("Poseidon's water scout is the "+kbGetUnitTypeName(gWaterScout)+".");

      //Random Age2 God.
      if (aiRandInt(3)==1)	//More likely to choose Hermes.
      {
	 gAge2MinorGod=cTechAge2Ares;
      }else{
	 gAge2MinorGod=cTechAge2Hermes;
      }
      //Random Age3 God.
      gAge3MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
      //Get EQ if we're rushing.  Else, random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge4MinorGod=cTechAge4Artemis;
      }else{
	 gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
      }
   }
   //Hades.
   else if (cMyCiv == cCivHades)
   {
      //Create a simple plan to maintain 1 water scout.
      if (gTransportMap == true && cvMasterDifficulty < cDifficultyHard)
	 createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

      //Random Age2 God.
      if (aiRandInt(3)==1)	//More likely to choose Ares.
      {
	 gAge2MinorGod=cTechAge2Athena;
      }else{
	 gAge2MinorGod=cTechAge2Ares;
      }
      //Get Underworld Passage if we have a transport map.  Else, random.
      if (gTransportMap == true)
	 gAge3MinorGod=cTechAge3Apollo;
      else
	 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
      //Get EQ if we're rushing.  Else, random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge4MinorGod=cTechAge4Artemis;
      }else{
	 gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
      }
   }
   if (cvAge2GodChoice != -1)
      gAge2MinorGod = cvAge2GodChoice;
   if (cvAge3GodChoice != -1)
      gAge3MinorGod = cvAge3GodChoice;
   if (cvAge4GodChoice != -1)
      gAge4MinorGod = cvAge4GodChoice;

}

//==============================================================================
//initEgyptian
//==============================================================================
void initEgyptian(void)
{
   printEcho("EGYPTIAN Init:");

   //Create a simple TC empower plan if we're not on Vinlandsaga.
   if (gMigrationMap == false)
   {
      gEmpowerPlanID=aiPlanCreate("Pharaoh Empower", cPlanEmpower);
      if (gEmpowerPlanID >= 0)
      {
	 aiPlanSetEconomy(gEmpowerPlanID, true);
	 aiPlanAddUnitType(gEmpowerPlanID, cUnitTypePharaoh, 1, 1, 1);
	 aiPlanSetVariableInt(gEmpowerPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeGranary);
	 aiPlanSetActive(gEmpowerPlanID);
      }
   }

   //Egyptian scout types.
   gLandScout=cUnitTypePriest;
   gAirScout=-1;
   gWaterScout=cUnitTypeFishingShipEgyptian;
   //Create a simple plan to maintain Priests for land exploration.
   createSimpleMaintainPlan(cUnitTypePriest, gMaintainNumberLandScouts, true, kbBaseGetMainID(cMyID));
   //Create a simple plan to maintain 1 water scout.
   if (gTransportMap == true && cvMasterDifficulty < cDifficultyHard)
      createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

   //Turn off auto favor gather.
   aiSetAutoFavorGather(false);


   if (aiGetGameMode() == cGameModeDeathmatch || (gFakeDeathmatch == true))
   {
      int dmPriestPlan=aiPlanCreate("dm priests", cPlanTrain);
      if (dmPriestPlan >= 0)
      {
	 aiPlanSetVariableInt(dmPriestPlan, cTrainPlanUnitType, 0, cUnitTypePriest);
	 //Train off of economy escrow.
	 aiPlanSetEscrowID(dmPriestPlan, cMilitaryEscrowID);
	 aiPlanSetVariableInt(dmPriestPlan, cTrainPlanNumberToTrain, 0, 4);
	 aiPlanSetVariableInt(dmPriestPlan, cTrainPlanBuildFromType, 0, cUnitTypeTemple);
	 aiPlanSetDesiredPriority(dmPriestPlan, 80);
	 aiPlanSetActive(dmPriestPlan);
      }
      if (
	  (gFishMap != true) && (gTransportMap != true)	//Only for land maps!
	  && (cvMasterDifficulty > cDifficultyEasy)
	 )
      {
	createSimpleTrainPlan(cUnitTypeMercenaryCavalry, 5, false, kbBaseGetMainID(cMyID), 30*1000);
      }
   }

   //Set the build limit for Outposts.
   aiSetMaxLOSProtoUnitLimit(4);

   //Isis.
   if (cMyCiv == cCivIsis)
   {
      //Random Age2 God.
      if (aiRandInt(3)==1)	//More likely to choose Bast.
      {
	 gAge2MinorGod=cTechAge2Anubis;
      }else{
	 gAge2MinorGod=cTechAge2Bast;
      }
      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge3MinorGod=cTechAge3Nephthys;
      }else{
	if(aiRandInt(3)==1)	//More likely to choose Nephthys.
	{
	 gAge3MinorGod=cTechAge3Hathor;
	}else{
	 gAge3MinorGod=cTechAge3Nephthys;
	}
      }
      //Random Age4 God.
      if (aiRandInt(3)==1)	//More likely to choose Thoth.
      {
	 gAge4MinorGod=cTechAge4Osiris;
      }else{
	 gAge4MinorGod=cTechAge4Thoth;
      }
   }
   //Ra.
   else if (cMyCiv == cCivRa)
   {
      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge2MinorGod=cTechAge2Ptah;
      }else{
	if(aiRandInt(3)==1)	//More likely to choose Ptah.
	{
	 gAge2MinorGod=cTechAge2Bast;
	}else{
	 gAge2MinorGod=cTechAge2Ptah;
	}
      }
      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge3MinorGod=cTechAge3Hathor;
      }else{
	 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
      }
      //Random Age4 God.
      if (aiRandInt(3)==1)	//More likely to choose Osiris.
      {
	 gAge4MinorGod=cTechAge4Horus;
      }else{
	 gAge4MinorGod=cTechAge4Osiris;
      }
   }
   //Set.
   else if (cMyCiv == cCivSet)
   {
      //Create air explore plans for the hyena.
      int explorePID=aiPlanCreate("Explore_SpecialSetHyena", cPlanExplore);
      if (explorePID >= 0)
      {
	 aiPlanAddUnitType(explorePID, cUnitTypeHyenaofSet, 1, 1, 1);
	 aiPlanSetActive(explorePID);
      }
      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge2MinorGod=cTechAge2Anubis;
      }else{
	 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
      }
      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge3MinorGod=cTechAge3Nephthys;
      }else{
	 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
      }
      //Random Age4 God.
      if (aiRandInt(2)==1)	//Most likely to choose one of them...
      {
	 gAge4MinorGod=cTechAge4Horus;
      }else{
	 gAge4MinorGod=cTechAge4Thoth;
      }
   }
   if (cvAge2GodChoice != -1)
      gAge2MinorGod = cvAge2GodChoice;
   if (cvAge3GodChoice != -1)
      gAge3MinorGod = cvAge3GodChoice;
   if (cvAge4GodChoice != -1)
      gAge4MinorGod = cvAge4GodChoice;
}

//==============================================================================
// ulfsarkMaintain
//==============================================================================
rule ulfsarkMaintain
inactive
mininterval 15
group Norse
{
   if (cMyCulture != cCultureNorse)
   {
      xsDisableSelf();
      return;
   }
   if (gUlfsarkMaintainPlanID >= 0)
      return;  // already exists
   gUlfsarkMaintainPlanID = createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, true, kbBaseGetMainID(cMyID));
   aiPlanSetDesiredPriority(gUlfsarkMaintainPlanID, 98); // Outrank civPopPlanID for villagers
   gUlfsarkMaintainMilPlanID = createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, false, kbBaseGetMainID(cMyID));
   aiPlanSetDesiredPriority(gUlfsarkMaintainMilPlanID, 98); // Outrank civPopPlanID for villagers
   xsDisableSelf();
}

//==============================================================================
//initNorse
//==============================================================================
void initNorse(void)
{
   printEcho("NORSE Init:");

   //Set our trained dropsite PUID.
   aiSetTrainedDropsiteUnitTypeID(cUnitTypeOxCart);

   //Create a reserve plan for our main base for some Ulfsarks if we're not on VS, TM, or Nomad.
   if (gNomadMap == false && gMigrationMap == false)
   {
      int ulfsarkReservePlanID=aiPlanCreate("UlfsarkBuilderReserve", cPlanReserve);
      if (ulfsarkReservePlanID >= 0)
      {
	 aiPlanSetDesiredPriority(ulfsarkReservePlanID, 49);
	 aiPlanSetBaseID(ulfsarkReservePlanID, kbBaseGetMainID(cMyID));
	 aiPlanAddUnitType(ulfsarkReservePlanID, cUnitTypeAbstractInfantry, 1, 1, 1);
	 aiPlanSetVariableInt(ulfsarkReservePlanID, cReservePlanPlanType, 0, cPlanBuild);
	 aiPlanSetActive(ulfsarkReservePlanID);
      }

      //Create a simple plan to maintain X Ulfsarks.
      xsEnableRule("ulfsarkMaintain");
   }

   // Get two extra oxcarts ASAP before we're at econ pop cap
   if ( aiGetGameMode() != cGameModeDeathmatch )
   {
      int easyOxPlan=aiPlanCreate("First Oxcarts", cPlanTrain);
      if (easyOxPlan >= 0)
      {
	 aiPlanSetVariableInt(easyOxPlan, cTrainPlanUnitType, 0, cUnitTypeOxCart);
	 //Train off of economy escrow.
	 aiPlanSetEscrowID(easyOxPlan, cEconomyEscrowID);
	 aiPlanSetVariableInt(easyOxPlan, cTrainPlanNumberToTrain, 0, 2);
	 aiPlanSetVariableInt(easyOxPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement);
	 aiPlanSetDesiredPriority(easyOxPlan, 98);	//above villager prio.
	 aiPlanSetActive(easyOxPlan);
      }
   }

   //Turn off auto favor gather.
   aiSetAutoFavorGather(false);

   if (aiGetGameMode() == cGameModeDeathmatch || (gFakeDeathmatch == true))
   {
      int dmUlfPlan=aiPlanCreate("dm ulfsarks", cPlanTrain);
      if (dmUlfPlan >= 0)
      {
	 aiPlanSetVariableInt(dmUlfPlan, cTrainPlanUnitType, 0, cUnitTypeUlfsark);
	 //Train off of economy escrow.
	 aiPlanSetEscrowID(dmUlfPlan, cEconomyEscrowID);
	 aiPlanSetVariableInt(dmUlfPlan, cTrainPlanNumberToTrain, 0, 5);
	 aiPlanSetVariableInt(dmUlfPlan, cTrainPlanBuildFromType, 0, cUnitTypeAbstractSettlement);
	 aiPlanSetDesiredPriority(dmUlfPlan, 99);
	 aiPlanSetActive(dmUlfPlan);
      }
   }

   if (aiGetGameMode() == cGameModeDeathmatch || (gFakeDeathmatch == true))
   {
      int dmHersirPlan=aiPlanCreate("dm hersirs", cPlanTrain);
      if (dmHersirPlan >= 0)
      {
	 aiPlanSetVariableInt(dmHersirPlan, cTrainPlanUnitType, 0, cUnitTypeHeroNorse);
	 //Train off of economy escrow.
	 aiPlanSetEscrowID(dmHersirPlan, cMilitaryEscrowID);
	 aiPlanSetVariableInt(dmHersirPlan, cTrainPlanNumberToTrain, 0, 4);
	 aiPlanSetVariableInt(dmHersirPlan, cTrainPlanBuildFromType, 0, cUnitTypeTemple);
	 aiPlanSetDesiredPriority(dmHersirPlan, 80);
	 aiPlanSetActive(dmHersirPlan);
      }
   }


   //Norse scout types.
   gLandScout=cUnitTypeUlfsark;
   gAirScout=-1;
   gWaterScout=cUnitTypeFishingShipNorse;
   //Create a simple plan to maintain 1 water scout.
   if (gTransportMap == true && cvMasterDifficulty < cDifficultyHard)
      createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

   //Odin.
   if (cMyCiv == cCivOdin)
   {
      //Create air explore plans for the ravens.
      int explorePID=aiPlanCreate("Explore_SpecialOdinAir1", cPlanExplore);
      if (explorePID >= 0)
      {
	 aiPlanAddUnitType(explorePID, cUnitTypeRaven, 1, 1, 1);
	 aiPlanSetActive(explorePID);
      }
      explorePID=aiPlanCreate("Explore_SpecialOdinAir2", cPlanExplore);
      if (explorePID >= 0)
      {
	 aiPlanAddUnitType(explorePID, cUnitTypeRaven, 1, 1, 1);
	 aiPlanSetVariableBool(explorePID, cExplorePlanDoLoops, 0, false);
	 aiPlanSetActive(explorePID);
      }

      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge2MinorGod=cTechAge2Heimdall;
      }else{
	if(aiRandInt(3)==1)	//More likely to choose Freyja.
	{
	 gAge2MinorGod=cTechAge2Heimdall;
	}else{
	 gAge2MinorGod=cTechAge2Freyja;
	}
      }
      //Random Age3 God.
      gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
      //Random Age4 God.
      if (gFishMap && gTransportMap)	//Choose Tyr on water.
      {
	 gAge4MinorGod=cTechAge4Tyr;
      }else{
	 gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
      }

   }
   //Thor.
   else if (cMyCiv == cCivThor)
   {
      //Random Age2 God.
      if(kbGetCivForPlayer(aiGetMostHatedPlayerID()) == cCivRa)
      {
	 gAge2MinorGod = cTechAge2Forseti;	//Trolls vs. Rocs
      }else{
	 gAge2MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
      }
      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge3MinorGod=cTechAge3Bragi;
      }else{
	 gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
      }
      //Random Age4 God.
      if (aiRandInt(5) > 2)	//More likely to choose Baldr.
      {
	 gAge4MinorGod=cTechAge4Tyr;
      }else{
	 gAge4MinorGod=cTechAge4Baldr;
      }

      //Thor likes dwarves.
      if (aiGetGameMode() != cGameModeLightning)
	 gDwarfMaintainPlanID=createSimpleMaintainPlan(cUnitTypeDwarf, 2, true, -1);
   }
   //Loki.
   else if (cMyCiv == cCivLoki)
   {
      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge2MinorGod=cTechAge2Heimdall;
      }else{
	if(aiRandInt(3)==1)	//More likely to choose Forseti.
	{
	 gAge2MinorGod=cTechAge2Heimdall;
	}else{
	 gAge2MinorGod=cTechAge2Forseti;
	}
      }
      //Get X if we're rushing, else random.
      if (cvRushBoomSlider > 0.6)	//defaultRush
      {
	 gAge3MinorGod=cTechAge3Bragi;
      }else{
	if(gFishMap && gTransportMap)	//Choose Njord on water.
	{
	 gAge3MinorGod=cTechAge3Njord;
	}else{
	 gAge3MinorGod=cTechAge3Bragi;
	}
      }
      //Random Age4 God.
      if (gFishMap && gTransportMap)	//Choose Tyr on water.
      {
	 gAge4MinorGod=cTechAge4Tyr;
      }else{
	 gAge4MinorGod=cTechAge4Hel;
      }
   }
   if (cvAge2GodChoice != -1)
      gAge2MinorGod = cvAge2GodChoice;
   if (cvAge3GodChoice != -1)
      gAge3MinorGod = cvAge3GodChoice;
   if (cvAge4GodChoice != -1)
      gAge4MinorGod = cvAge4GodChoice;

   //Enable our no-infantry check.
   xsEnableRule("norseInfantryCheck");
}

//==============================================================================
//initAtlantean
//==============================================================================
void initAtlantean(void)
{
   printEcho("ATLANTEAN Init:");

   // Atlantean

   gLandScout=cUnitTypeOracleScout;
   gWaterScout=cUnitTypeFishingShipAtlantean;
   aiSetMinNumberNeedForGatheringAggressvies(3);      // Rather than 8

   //Create the atlantean scout plans.
   int exploreID=-1;
   int i = 0;
   for (i=0; <3)
   {
      exploreID = aiPlanCreate("Explore_SpecialAtlantean"+i, cPlanExplore);
      if (exploreID >= 0)
      {
	 aiPlanAddUnitType(exploreID, cUnitTypeOracleScout, 0, 1, 1);
	 aiPlanAddUnitType(exploreID, cUnitTypeOracleHero, 0, 1, 1);    // Makes sure the relic plan sees this plan as a hero source.
	 aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
	 aiPlanSetVariableBool(exploreID, cExplorePlanOracleExplore, 0, true);
	 aiPlanSetDesiredPriority(exploreID, 25);  // Allow oracleHero relic plan to steal one
	 aiPlanSetActive(exploreID);
      }
   }  

   // Make sure we always have at least 2 oracles
   int oracleMaintainPlanID = createSimpleMaintainPlan(cUnitTypeOracleScout, 2, true, kbBaseGetMainID(cMyID));


   // Special emergency manor build for Lightning
   if (aiGetGameMode() == cGameModeLightning)
   {
      // Build a manor, just one, ASAP, not military, economy, economy escrow, my main base, 1 builder please.
      createSimpleBuildPlan(cUnitTypeManor, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
   }

   aiSetAutoFavorGather(false);

   // Default to random minor god choices, override below if needed
   gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
   //Random Age3 God.
   gAge3MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);
   //Random Age4 God.
   gAge4MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);

   if (cMyCiv == cCivGaia)
   {
      // Age 2 is a toss up, both are good for defense/boomer
      if(kbGetCivForPlayer(aiGetMostHatedPlayerID()) == cCivLoki)
      {
	 gAge2MinorGod = cTechAge2Okeanus;
      }
      // Age3Theia for military-oriented players
      if (cvMilitaryEconSlider > 0.3)
      {
	 gAge3MinorGod = cTechAge3Theia;
      }
      if(kbGetCivForPlayer(aiGetMostHatedPlayerID()) == cCivIsis)
      {
	 gAge3MinorGod = cTechAge3Rheia;
      }
      // Age4...atlas for Defense/Econ (buildings), Hekate for offense/mil
      if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) > 0.6 )
      {
	 gAge4MinorGod = cTechAge4Hekate;
      }
      if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) < -0.6 )
      {
	 gAge4MinorGod = cTechAge4Atlas;
      }
   }


   if (cMyCiv == cCivKronos)
   {
      // Age 2 Leto for defense/boomer
      if ( (cvRushBoomSlider + cvOffenseDefenseSlider) > -0.6)
      {
	 gAge2MinorGod = cTechAge2Leto;
      }
      if(kbGetCivForPlayer(aiGetMostHatedPlayerID()) == cCivLoki)
      {
	 gAge2MinorGod = cTechAge2Prometheus;
      }
      if(aiGetGameMode() != cGameModeDeathmatch && aiRandInt(4) > 1)
      {
	// Age4 is a toss up
	// Kronos likes siege - So Helios can be a good choice as well...
	// Age4...atlas for Offense/mil (implode), Helios (vortex) for defense/econ
	if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) > 0.8 )
	{
		gAge4MinorGod = cTechAge4Atlas;
	}
	if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) < -0.6 )
	{
		gAge4MinorGod = cTechAge4Helios;
	}
      }
   }

   if (cMyCiv == cCivOuranos)
   {
      // Age 2 oceanus for defense (carnivora)
      if (cvOffenseDefenseSlider < -0.3)
      {
	 gAge2MinorGod = cTechAge2Okeanus;
      }
      // Age3Theia for military-oriented players
      if (cvMilitaryEconSlider > 0.3)
      {
	 gAge3MinorGod = cTechAge3Theia;
      }
      // Age4...Helios for Defense/Econ (vortex), Hekate for offense/mil
      if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) > 0.6 )
      {
	 gAge4MinorGod = cTechAge4Hekate;
      }
      if ( (cvMilitaryEconSlider + cvOffenseDefenseSlider) < -0.5 )
      {
	 gAge4MinorGod = cTechAge4Helios;
      }
   }

   // Control variable overrides
   if (cvAge2GodChoice != -1)
      gAge2MinorGod = cvAge2GodChoice;
   if (cvAge3GodChoice != -1)
      gAge3MinorGod = cvAge3GodChoice;
   if (cvAge4GodChoice != -1)
      gAge4MinorGod = cvAge4GodChoice;

   // If I'm Kronos.. turn on unbuild..
   if (cMyCiv == cCivKronos)
       unbuildHandler();

   if (cMyCiv == cCivOuranos)
      xsEnableRule("buildSkyPassages");

}

//==============================================================================
//initChinese
//==============================================================================
void initChinese(void)
{
	printEcho("CHINESE Init:");

	//Modify our favor need.  A pseudo-hack.
	aiSetFavorNeedModifier(10.0);

	//Greek scout types.
	gLandScout  = cUnitTypeScoutChinese;
	gAirScout   = -1;
	gWaterScout = cUnitTypeFishingShipChinese;
	//Create the Chinese scout plan.

	//Create a simple plan to maintain 1 water scout.
	if (gTransportMap == true && cvMasterDifficulty < cDifficultyHard)
	   createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

	int exploreID = aiPlanCreate("Explore_SpecialChineseA", cPlanExplore);
	if (exploreID >= 0)
	{
		aiPlanAddUnitType(exploreID, cUnitTypeScoutChinese, 1, 1, 1);
		aiPlanSetActive(exploreID);
	}
	exploreID = aiPlanCreate("Explore_SpecialChineseB", cPlanExplore);
	if (exploreID >= 0)
	{
		aiPlanAddUnitType(exploreID, cUnitTypeScoutChinese, 1, 1, 1);
		aiPlanSetActive(exploreID);
	}

	//Fuxi
	if (cMyCiv == cCivFuxi)
	{
	   //Random Age2 God.
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
		  gAge3MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);

		  gAge4MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
		  // Special speed construction speed up
		  xsEnableRule("rSpeedUpBuilding");
	}
	//Nuwa
	else if (cMyCiv == cCivNuwa)
	{
	   //Random Age2 God.
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
		  gAge3MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);

		if (aiRandInt(3)==1)	//More likely to choose Xi Wangmu.
		{
		   gAge4MinorGod=cTechAge4Chongli;
		}else{
		   gAge4MinorGod=cTechAge4Xiwangmu;
		}
	}
	//Shennong
	else if (cMyCiv == cCivShennong)
	{
	   //Random Age2 God.
		 gAge2MinorGod=kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge2);
		  gAge3MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge3);

		  gAge4MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	}
	if(cvAge2GodChoice != -1)
		gAge2MinorGod = cvAge2GodChoice;
	if(cvAge3GodChoice != -1)
		gAge3MinorGod = cvAge3GodChoice;
	if(cvAge4GodChoice != -1)
		gAge4MinorGod = cvAge4GodChoice;
	   
	xsEnableRule("chooseGardenResource");
}

//==============================================================================
// norseMiniRag		-- todo
//==============================================================================
rule norseMiniRag
   minInterval 25
   inactive
   group Norse
{
   if(cMyCulture != cCultureNorse)
   {
	xsDisableSelf();
	return;
   }
   if(kbGetAge() < cAge4)	//Norse lategame boost only.
   {
	return;
   }

   static int ragQID=-1;
   if(
	   (kbResourceGet(cResourceFood) >= 8000)
	&&
	   (kbResourceGet(cResourceWood) >= 8000)
	&&
	   (kbResourceGet(cResourceGold) >= 8000)
     )
	{
	    int reserveVills = 30 + aiRandInt(10);
	    int numVillagers = kbUnitCount(cMyID,cUnitTypeAbstractVillager, cUnitStateAlive);
	    if(numVillagers > reserveVills)
	    {
		if (ragQID < 0)
		{
		    ragQID=kbUnitQueryCreate("NorseMiniRagQuery");
		    if (ragQID < 0)
		    {
			xsDisableSelf();
			return;
		    }
		}
		kbUnitQuerySetPlayerID(ragQID, cMyID);
		kbUnitQuerySetUnitType(ragQID, cUnitTypeAbstractVillager);
		kbUnitQuerySetState(ragQID, cUnitStateAlive);
		kbUnitQuerySetActionType(ragQID, cActionIdle);
		kbUnitQueryResetResults(ragQID);

		int numberVillagers=kbUnitQueryExecute(ragQID);
		printEcho("***** Transforming "+numberVillagers+" villagers");
		for (i=0; < numberVillagers)
		{
		    int villagerID=kbUnitQueryGetResult(ragQID, i);
		    //aiTaskUnitTransform(villagerID);
		}
	    }
	}
}

//==============================================================================
// norseInfantryCheck
//==============================================================================
rule norseInfantryCheck
   minInterval 10
   inactive
   group Norse
{
   //Get a count of our ulfsarks.
   int ulfCount=kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive);
   if (ulfCount > 1)     
      return;

   if (xsGetTime() < 90000)
      return;     // Don't do it in first 90 seconds

   //If we're low on infantry, make sure we have at least X pop slots free.
   int availablePopSlots=kbGetPopCap()-kbGetPop();
   if (availablePopSlots >= 3)      // Room for current vil-in-training and ulfsark
      return;

   //Else, find a villager to delete.
   //Create/get our query.
   static int vQID=-1;
   if (vQID < 0)
   {
      vQID=kbUnitQueryCreate("NorseInfantryCheckVillagers");
      if (vQID < 0)
      {
	 xsDisableSelf();
	 return;
      }
   }
	kbUnitQuerySetPlayerID(vQID, cMyID);
   kbUnitQuerySetUnitType(vQID, cUnitTypeAbstractVillager);
   kbUnitQuerySetState(vQID, cUnitStateAlive);
   kbUnitQueryResetResults(vQID);
	int numberVillagers=kbUnitQueryExecute(vQID);
   for (i=0; < numberVillagers)
   {
      int villagerID=kbUnitQueryGetResult(vQID, i);
      printEcho("***** Deleting villager "+villagerID);
      if (aiTaskUnitTransform(villagerID) == true)
      {
	 availablePopSlots = availablePopSlots+1;
	 if (availablePopSlots >= 3)
	    return;
      }else{
		if(aiTaskUnitDelete(villagerID) == true)
	 availablePopSlots = availablePopSlots+1;
      }
   }
}

//==============================================================================
// init( void )
//==============================================================================
void init(void)
{
   gStartTime = xsGetTime();	//Delayed? Sync.
   applySliderNoise();

   xsEnableRule("updateWoodBreakdown");
   xsEnableRule("updateFoodBreakdown");
   xsEnableRule("updateGoldBreakdown");

   //We're in a random map.
   aiSetRandomMap(true);
   if (cvRandomMapName == "None")
   {
      cvRandomMapName = cRandomMapName;
   }

   initMap();	//fish?,transport?,hunt?,etc...
   if(gNoRushMap && cvRushBoomSlider > 0)
   {
	cvRushBoomSlider = 0.0;		//Don't rush on this map!
   }
   //Startup messages.
   printEcho("Init(): AI Player Name is "+cMyName+".");
   printEcho("AI Filename='"+cFilename+"'.");
   printEcho("Map size is ("+kbGetMapXSize()+", "+kbGetMapZSize()+").");
   printEcho("MapName="+cvRandomMapName+".");
   printEcho("FirstRand="+aiRandInt(10000000)+".");
   printEcho("Civ="+kbGetCivName(cMyCiv)+".");
   printEcho("Culture="+kbGetCultureName(cMyCulture)+".");
   printEcho("DifficultyLevel="+aiGetWorldDifficultyName(cvMasterDifficulty)+".");
   printEcho("Personality="+aiGetPersonality()+".");
   printEcho("Game mode is "+aiGetGameMode());

   if(aiGetGameMode() == cGameModeTreaty)
   {
	// Set our Treaty attack transition time
	// At least 2 mins
	int transitionTime = 120;
	// Rushes want more transition time, boomers want less
	transitionTime = transitionTime + (cvRushBoomSlider*60);
	// Mil wants more time, econ wants less
	transitionTime = transitionTime + (cvMilitaryEconSlider*40);
	// Offense wants more time, defense wants less
	transitionTime = transitionTime + (cvOffenseDefenseSlider*40);
	printEcho("Transition time: + " + transitionTime);
	SetTreatyTransitionTime(transitionTime);
   }

   // In any case, scale down fishing to match difficulty
   if (cvMasterDifficulty == cDifficultyEasy)
      gNumBoatsToMaintain = gNumBoatsToMaintain/4;	//3 Ships
   if (cvMasterDifficulty == cDifficultyModerate)
      gNumBoatsToMaintain = gNumBoatsToMaintain/3;	//4 Ships
   if (cvMasterDifficulty == cDifficultyHard)
      gNumBoatsToMaintain = gNumBoatsToMaintain/2;	//6 Ships

   if (cvPlayerToAttack < 1)	//Find someone to hate.
   {
		updatePlayerToAttack();		//Finalizes the personality.
   }else{
		setTargetEnemy(cvPlayerToAttack);
   }
   printEcho("MostHatedPlayer is Player #"+aiGetMostHatedPlayerID()+".");

   //Bind our age handlers.
   aiSetAgeEventHandler(cAge2, "age2Handler");
   aiSetAgeEventHandler(cAge3, "age3Handler");
   aiSetAgeEventHandler(cAge4, "age4Handler");
   // Something new... an Age5 handler.
   aiSetAgeEventHandler(cAge5, "age5Handler");

   // Are we starting at or beyond our max age?
   if (cvMaxAge <= kbGetAge())
   {
      printEcho("Suspending age upgrades.");
      aiSetPauseAllAgeUpgrades(true);
   }

   //Setup god power handler
   aiSetGodPowerEventHandler("gpHandler");
   //Setup build handler
   aiSetBuildEventHandler("buildHandler");
   //Setup the wonder handler
   aiSetWonderDeathEventHandler("wonderDeathHandler");
   //Setup the retreat handler
   aiSetRetreatEventHandler("retreatHandler");
   //Setup the relic handler
   aiSetRelicEventHandler("relicHandler");
   //Setup the resign handler
   aiSetResignEventHandler("resignHandler");

   //Set our town location.
   setTownLocation();

   //Economy.
   initEcon();
   //Progress.
   initProgress();
   //Tech.
   handleAge1Upgrades();
   //God Powers.
   initGodPowers();

   //Various map overrides.
   if(kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAlive) > 0)
   {
	gMigrationMap = true;
   }
   if(kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) < 1)
   {
	gNomadMap = true;
   }
   //Erebus and River Styx.
   if ((cvRandomMapName == "erebus") || (cvRandomMapName == "river styx"))
   {
      aiSetMinNumberNeedForGatheringAggressvies(2);
      kbBaseSetMaximumResourceDistance(cMyID, kbBaseGetMainID(cMyID), 85.0);
   }
   if (gExpansionMap == true)	//River Styx, Yellow River.
   {
		xsEnableRule("lateFindMainland");
   }
   //Vinlandsaga.
   if (gMigrationMap && gNomadMap == false)
   {
      //Enable the rule that looks for the mainland.
      xsEnableRule("findVinlandsagaBase");
      //Turn off auto dropsite building.
      aiSetAllowAutoDropsites(false);
      aiSetAllowBuildings(false);

      // Move the transport toward map center to find continent quickly.
      int transportID = findUnit(cMyID, cUnitStateAlive, cUnitTypeTransport);
      vector nearCenter = kbGetMapCenter();
      nearCenter = (nearCenter + kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) / 2.0;    // Halfway between start and center
      nearCenter = (nearCenter + kbGetMapCenter()) / 2.0;   // 3/4 of the way to map center
      aiTaskUnitMove(transportID, nearCenter);
      printEcho("Sending transport "+transportID+" to near map center at "+nearCenter);

      xsEnableRule("vinlandsagaFailsafe");  // In case something prevents transport from reaching, turn on the explore plan.

      //Turn off fishing.
      xsDisableRule("fishing");
      //Pause the age upgrades.
      aiSetPauseAllAgeUpgrades(true);
   }
   //Nomad.
   else if (gNomadMap && gMigrationMap == false)
   {
      xsEnableRule("nomadSearchMode");

   }
   //Settlers.
   else if (gNomadMap && gMigrationMap)
   {
      //Enable the rule that looks for the mainland.
      xsEnableRule("handleMigration");
   }
   //Unknown, or unspecified
   else if ((cvRandomMapName == "the unknown") || (cvRandomMapName == "None") )
   {
      xsEnableRule("findFish");
   }
   //Make a scout plan to find the plenty vault.
   else if (cvRandomMapName == "king of the hill")
   {
      printEcho("looking for KOTH plenty Vault");
      int KOTHunitQueryID = kbUnitQueryCreate("findPlentyVault");
      kbUnitQuerySetPlayerRelation(KOTHunitQueryID, cPlayerRelationAny);
      kbUnitQuerySetUnitType(KOTHunitQueryID, cUnitTypePlentyVaultKOTH);
      kbUnitQuerySetState(KOTHunitQueryID, cUnitStateAny);
	   kbUnitQueryResetResults(KOTHunitQueryID);
	   int numberFound = kbUnitQueryExecute(KOTHunitQueryID);
      gKOTHPlentyUnitID = kbUnitQueryGetResult(KOTHunitQueryID, 0);
      kbSetForwardBasePosition(kbUnitGetPosition(gKOTHPlentyUnitID));

      xsEnableRule("findFish");
   }
   if(gFishMap == false)	//really no fish?
   {
	if(kbUnitCount(0, cUnitTypeFish, cUnitStateAlive) > 4)
	{
		gFishMap = true;	//found some!
		xsEnableRule("fishing");
	}else{
		      xsEnableRule("findFish");
	}
   }

   //Check initial resources
   if ( (aiGetGameMode() != cGameModeDeathmatch)	//We don't need this. Go away!
	&&(kbResourceGet(cResourceFood) >= 15000)
	&&(kbResourceGet(cResourceWood) >= 15000)
	&&(kbResourceGet(cResourceGold) >= 15000)
      ) { gFakeDeathmatch = true; }			//Play like this is DM!

   //Or is it - Tiny! Freak Style?
   if (   (kbResourceGet(cResourceFood) < -1)
	&&(kbResourceGet(cResourceWood) < -1)
	&&(kbResourceGet(cResourceGold) < -1)
      ) {
		gFakeDeathmatch = true;			//Play like this is DM!
		gMaxTradeCarts = 0;
	}
/*
   int mhpBaseID = findClosestRelTo(kbBaseGetMainID(cMyID), aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeAbstractSettlement);
   if(calcDistanceToUnit(kbBaseGetMainID(cMyID),mhpBaseID) < 80)
   {
	gFakeDeathmatch = true;		//Also, no villager evacuation, please!
   }
*/
	//Only Deathmatch...
	   xsEnableRule("dockMonitorDM");

   //Create bases for all of our settlements.  Ignore any that already have
   //bases set.  If we have an invalid main base, the first base we create
   //will be our main base.
   int settlementQueryID=kbUnitQueryCreate("MySettlements");
   if (settlementQueryID >= 0)
   {
		kbUnitQuerySetPlayerID(settlementQueryID, cMyID);
      kbUnitQuerySetUnitType(settlementQueryID, cUnitTypeAbstractSettlement);
      kbUnitQuerySetState(settlementQueryID, cUnitStateAlive);
      kbUnitQueryResetResults(settlementQueryID);
	   int numberSettlements=kbUnitQueryExecute(settlementQueryID);
      for(i=0; < numberSettlements)
      {
	 int settlementID=kbUnitQueryGetResult(settlementQueryID, i);
	 //Skip this settlement if it already has a base.
	 if (kbUnitGetBaseID(settlementID) >= 0)
	    continue;

	 vector settlementPosition=kbUnitGetPosition(settlementID);
	 //Create a new base.
	 int newBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), settlementPosition, 75.0);
	 if (newBaseID >= 0)
	 {
	    //Figure out the front vector.
	    vector baseFront=xsVectorNormalize(kbGetMapCenter()-settlementPosition);
	    kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
	    //Military gather point.
	    vector militaryGatherPoint=settlementPosition+baseFront*40.0;
	    kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
	    gMilitaryGatherPoint = militaryGatherPoint;
	    //Set the other flags.
	    kbBaseSetMilitary(cMyID, newBaseID, true);
	    kbBaseSetEconomy(cMyID, newBaseID, true);
	    //Set the resource distance limit.
	    kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
	    //Add the settlement to the base.
	    kbBaseAddUnit(cMyID, newBaseID, settlementID);
	    kbBaseSetSettlement(cMyID, newBaseID, true);
	    //Set the main-ness of the base.
	    kbBaseSetMain(cMyID, newBaseID, true);
	 }
      }
   }

   if(cvOkToChat == true)
   {
	//We usually won't chat in scenarios.
	xsEnableRule("DONATEFood");
	xsEnableRule("DONATEWood");
	xsEnableRule("DONATEGold");
   }

   if(gNewCivMod == false)
   {
	   //Culture setup.
	   switch (cMyCulture)
	   {
	      case cCultureGreek:
	      {
		 initGreek();
		 break;
	      }
	      case cCultureEgyptian:
	      {
		 initEgyptian();
		 break;
	      }
	      case cCultureNorse:
	      {
		 initNorse();
		 break;
	      }
	      // dlm xpack mod
	      case cCultureAtlantean:
	      {
		 initAtlantean();
		 break;
	      }
		 case cCultureChinese:
		 {
			 initChinese();
			 break;
		 }
	      // dlm xpack mod end
	   }
   }else{
		initMod();	//Custom Setup.
   }

   //This needs to wait until initMod is done!
   xsEnableRule("trainGatherers");

   //Setup the progression to follow these minor gods.
   kbTechTreeAddMinorGodPref(gAge2MinorGod);
   kbTechTreeAddMinorGodPref(gAge3MinorGod);
   kbTechTreeAddMinorGodPref(gAge4MinorGod);
   printEcho("Minor god plan is "+kbGetTechName(gAge2MinorGod)+", "+kbGetTechName(gAge3MinorGod)+", "+kbGetTechName(gAge4MinorGod));

   //Set the Explore Danger Threshold.
   aiSetExploreDangerThreshold(300.0);
   //Auto gather our military units.
   aiSetAutoGatherMilitaryUnits(true);

   //If we're on easy, set our default stance to defensive.
   if ((cvMasterDifficulty == cDifficultyEasy) && (cvRandomMapName != "king of the hill"))   
      aiSetDefaultStance(cUnitStanceDefensive);

   //Set the default attack response distance.
   if (cvMasterDifficulty == cDifficultyEasy)
      aiSetAttackResponseDistance(14.0);
   else if (cvMasterDifficulty == cDifficultyModerate)
      aiSetAttackResponseDistance(30.0);
   else
      aiSetAttackResponseDistance(65.0);

   //Get our house build limit.
   gHouseBuildLimit=kbGetBuildLimit(cMyID, cUnitTypeHouse);
   if (cMyCulture == cCultureAtlantean)
   {
      gHouseBuildLimit = kbGetBuildLimit(cMyID, cUnitTypeManor);
   }

   //Set the housing rebuild bound to 4 for the first age.
   gHouseAvailablePopRebuild=4;
   if (cMyCulture == cCultureEgyptian)
      gHouseAvailablePopRebuild=8;
   if (cMyCulture == cCultureAtlantean)
      gHouseAvailablePopRebuild=8;

   //Set the hard pop caps.
   if (aiGetGameMode() == cGameModeLightning)
   {
      gHardEconomyPopCap=35;
      //If we're Norse, get our 5 dwarfs.
      if (cMyCulture == cCultureNorse)
	 createSimpleMaintainPlan(cUnitTypeDwarf, 5, true, -1);
   }
   else if (aiGetGameMode() == cGameModeDeathmatch)
   {
      if(cMyCulture != cCultureAtlantean)
      {
	gHardEconomyPopCap=8;   // Essentially shut off vill production until age 4.
      }else{
	gHardEconomyPopCap=15;   // Atlantean players need a bit more!
      }
   }
   else
   {
      if (cvMasterDifficulty == cDifficultyEasy)
	 gHardEconomyPopCap=20;
      else if (cvMasterDifficulty == cDifficultyModerate)
	 gHardEconomyPopCap=40;
      else
	 gHardEconomyPopCap=-1;
   }
   if ( cvOffenseDefenseSlider < 0.0 )		//todo
   {
      // Consider towering if we're defensive.
      float towerOdds = -1.0 * cvOffenseDefenseSlider;    // Now 1 for def, -1 for off
      towerOdds = towerOdds + 0.4;		 // Now -.6 to 1.4
      if (towerOdds < 0.0)
	 towerOdds = 0.0;			    // Now 0 - 1.4, won't be considered if more than 40% offensive
	    
      towerOdds = (towerOdds * 100.0);	 // Now 0.0 - 140.0, numbers over 100 guarantee towering

      int result = -1;
      result = aiRandInt(101) -1;   //-1..99
      // i.e. 100% chance for cvOffenseDefenseSlider below -.6, and linear odds from 
      // 0% at cvOffenseDefenseSlider +.4 to 100% at -0.6
      // Net result:  Heavy defenders always tower, lite defenders usually do, mildly aggressives sometimes do.
      printEcho("Tower odds: "+towerOdds);
      if ( result < towerOdds )  
      {
	 gBuildTowers = true;
	 gTargetNumTowers = towerOdds/10;    // Up to 14 for a mil/econ balanced player
	 gTargetNumTowers = gTargetNumTowers * (1+(cvMilitaryEconSlider/2));  // +/- 50% based on mil/econ
	if ( gBuildWalls == true)
	    gTargetNumTowers = gTargetNumTowers / 2;     // Halve the towers if we're doing walls
	if ( cvMasterDifficulty == cDifficultyEasy )
	   gTargetNumTowers = gTargetNumTowers / 2;      // Not so many on easy
      }
      if ( (cvOffenseDefenseSlider < 0.6) && (gBuildTowers == false) )  // If we're not totally offensive, get upgrades
      {
	 gBuildTowers = true;
	 gTargetNumTowers = 0;   // Just do some upgrades
      }
      if (cvOkToBuildTowers == false)
      {
	 gBuildTowers = false;
	 gTargetNumTowers = 0;
      }
      printEcho("Decided to build "+gTargetNumTowers+" towers.");
   }

   //Decide whether or not we're doing a rush/raid.
   // Rushers will use a smaller econ to age up faster, send more waves and larger waves.
   // Boomers will use a larger econ, hit age 2 later, make smaller armies, and send zero or few waves, hitting age 3 much sooner.

   //Enable the rule that monitors our main base for being under attack before we're ready.
   xsEnableRule("townDefense");

      int minPop = 8;
      int maxPop = 16;

   if(aiGetGameMode() == cGameModeDeathmatch)	// DM, double number of buildings
   {
	gNumberBuildings = gNumberBuildings*2;
   }

   //Create our late age attack goal.
   if (cvMasterDifficulty <= cDifficultyEasy)
   {
      maxPop=16+aiRandInt(9);
      gLandUPID=initUnitPicker("Late", 1, -1, -1, minPop, maxPop, gNumberBuildings, false);
   }
   else if (cvMasterDifficulty == cDifficultyModerate)
   {
      maxPop=36+aiRandInt(14);
      gLandUPID=initUnitPicker("Late", 2, -1, -1, minPop, maxPop, gNumberBuildings, true);
   }
   else if (cvMasterDifficulty == cDifficultyHard)
   {
      maxPop=70;
      gLandUPID=initUnitPicker("Late", 3, -1, -1, minPop, maxPop, gNumberBuildings, true);
   }
   else if (cvMasterDifficulty >= cDifficultyNightmare)
   {
      maxPop = 120;
      gLandUPID=initUnitPicker("Late", 3, -1, -1, minPop, maxPop, gNumberBuildings, true);
   }
   int lateAttackAge=cAge2;
   if (gLandUPID >= 0)
   {
      if (aiGetGameMode() == cGameModeDeathmatch || cvMasterDifficulty <= cDifficultyEasy)
      {
	 lateAttackAge=cAge3;
      }

      //Setup the retreat to only be allowed on non-transport maps.
      bool allowRetreat = true;
      if (gTransportMap)
      {
	    allowRetreat = false;
      }

      //Setup for all future attacks!
      gLandAttackGoalID=createSimpleAttackGoal("Main Land Attack", -1, gLandUPID, -1, lateAttackAge, -1, kbBaseGetMainID(cMyID), allowRetreat);

      //-- attach a callbackgoal to this attack goal
      if (gLandAttackGoalID >= 0)
      {
	 int callbackGID=createCallbackGoal("Attack Callback", "attackChatCallback", 1, 0, lateAttackAge, false);
	 if (callbackGID >= 0)
	 {
	       aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanExecuteGoal, 0, callbackGID);
	 }
	 //Always get the unit line upgrades first.
	 aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanUpgradeFilterType, 0, cUpgradeTypeHitpoints);
      }
   }

   //Create our naval attack starter if we're on a water map.
   if ((gFishMap == true) || (gTransportMap == true))
   {
      xsEnableRule("NavalGoalMonitor");
   }

   //If we're going to build walls, we have a 50% chance to build a wonder.
   if (
	(aiGetGameMode() == cGameModeSupremacy)
	&&
	(
	  (gBuildWalls == true && aiRandInt(2) == 0)
	  ||
	  (aiGetPersonality() == "Apocalypse Bot")
	)
      )
   {
      //-- reserve some building space in the base for the wonder.
      int wonderBPID = kbBuildingPlacementCreate( "WonderBP" );
      if(wonderBPID != -1)
      {
	 kbBuildingPlacementSetBuildingType( cUnitTypeWonder );
	 kbBuildingPlacementSetBaseID( kbBaseGetMainID(cMyID), cBuildingPlacementPreferenceBack );
	 kbBuildingPlacementStart();
      }
      
      createBuildBuildingGoal("Wonder Goal", cUnitTypeWonder, 1, 3, 4, kbBaseGetMainID(cMyID),
	 50, cUnitTypeAbstractVillager, true, 100, wonderBPID);
   }


   //Create our econ goal (which is really just to store stuff together).
   gGatherGoalPlanID=aiPlanCreate("GatherGoals", cPlanGatherGoal);
   if (gGatherGoalPlanID >= 0)
   {
      //Overall percentages.
      aiPlanSetDesiredPriority(gGatherGoalPlanID, 90);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanScriptRPGPct, 0, 1.0);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanCostRPGPct, 0, 0.0);
      aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanGathererPct, 4, true);
      //Egyptians like gold.
      if (cMyCulture == cCultureEgyptian)
      {
	 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, 0.0);
	 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, 0.0);
	 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, 1.00);
	 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, 0.0);
	 if (gMigrationMap)
	 {
	    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, 0.10);
	    aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, 0.15);
	 }
      }
      else
      {
	 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceGold, 0.0);
	 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceWood, 0.0);
	 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFood, 1.0);
	 aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanGathererPct, cResourceFavor, 0.0);
      }

      //Standard RB setup.
      aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, 5, true);
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 1);
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt, 1);
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 0);
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFarm, 0);
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeFish, 0);
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumWoodPlans, 0, 0);
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumGoldPlans, 0, 0);
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 0);
      //Hunt on Erebus and River Styx.
      if (gHuntMap)
      {
	 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeEasy, 0);
	 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHuntAggressive, 2);
	 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFoodPlans, cAIResourceSubTypeHunt, 1);
      }

      //Min resource amounts.
      aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, 4, true);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceGold, 500.0);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceWood, 500.0);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceFood, 500.0);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanMinResourceAmt, cResourceFavor, 50.0);
      //Resource skew.
      aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, 4, true);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceGold, 1000.0);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceWood, 1000.0);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceFood, 1000.0);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceSkew, cResourceFavor, 100.0);
      //Cost weights.
      aiPlanSetNumberVariableValues(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, 4, true);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceGold, 1.5);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceWood, 1.0);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFood, 1.5);
      aiPlanSetVariableFloat(gGatherGoalPlanID, cGatherGoalPlanResourceCostWeight, cResourceFavor, 10.0);

      //Set our farm limits.
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0, 20);  //  Up from 4
      aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanMaxFarmLimit, 0, 40);     //  Up from 24
      aiSetFarmLimit(aiPlanGetVariableInt(gGatherGoalPlanID, cGatherGoalPlanFarmLimitPerPlan, 0));
      //Do our late econ init.
      postInitEcon();
      //Lastly, update our EM.
      updateTargetPop();
   }

  // Add an emergency temple, and 10 houses
   if ( (aiGetGameMode() == cGameModeDeathmatch) || (aiGetGameMode() == cGameModeLightning) || (gFakeDeathmatch == true) )
   {
      if (cMyCulture == cCultureAtlantean)
      {
	 createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
	 if (aiGetGameMode() == cGameModeDeathmatch || gFakeDeathmatch == true)
	    createSimpleBuildPlan(cUnitTypeManor, 2, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
      }
      else
      {
	 createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 3);
	 if (aiGetGameMode() == cGameModeDeathmatch || gFakeDeathmatch == true)
	 {
	    createSimpleBuildPlan(cUnitTypeHouse, 4, 95, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
	    if(cMyCulture == cCultureNorse && (gFakeDeathmatch == true || cMyCiv == cCivLoki))
	    {
		createSimpleBuildPlan(cUnitTypeTemple, 1, 80, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 2);
	    }
	 }
      }
   }

   xsEnableRule("postInitOverrides");	// Allow the mod support to override anything it needs to.
}

//==============================================================================
// nomadSearchMode
//==============================================================================
rule nomadSearchMode
inactive
minInterval 1
{
      //Enable the rule that looks for a settlement.
      //Make plans to explore with the initial villagers and goats.
      printEcho("Making nomad explore plans.");
	   gNomadExplorePlanID1=aiPlanCreate("Nomad Explore 1", cPlanExplore);
	   if (gNomadExplorePlanID1 >= 0)
	   {
		aiPlanAddUnitType(gNomadExplorePlanID1, getBuilderType(), 1, 1, 1);
		aiPlanSetDesiredPriority(gNomadExplorePlanID1, 90);
		aiPlanSetVariableBool(gNomadExplorePlanID1, cExplorePlanDoLoops, 0, false);
		aiPlanSetActive(gNomadExplorePlanID1);
		aiPlanSetEscrowID(gNomadExplorePlanID1);
	   }
	   gNomadExplorePlanID2=aiPlanCreate("Nomad Explore 2", cPlanExplore);
	   if (gNomadExplorePlanID2 >= 0)
	   {
		aiPlanAddUnitType(gNomadExplorePlanID2, getBuilderType(), 1, 1, 1);
		aiPlanSetDesiredPriority(gNomadExplorePlanID2, 90);
		aiPlanSetVariableBool(gNomadExplorePlanID2, cExplorePlanDoLoops, 0, false);
		aiPlanSetActive(gNomadExplorePlanID2);
		aiPlanSetEscrowID(gNomadExplorePlanID2);
	   }
	   gNomadExplorePlanID3=aiPlanCreate("Nomad Explore 3", cPlanExplore);
	   if (gNomadExplorePlanID3 >= 0)
	   {
		aiPlanAddUnitType(gNomadExplorePlanID3, cUnitTypeAbstractVillager, 1, 2, 2);   // Grab last Egyptian
		aiPlanSetDesiredPriority(gNomadExplorePlanID3, 90);
		aiPlanSetVariableBool(gNomadExplorePlanID3, cExplorePlanDoLoops, 0, false);
		aiPlanSetActive(gNomadExplorePlanID3);
		aiPlanSetEscrowID(gNomadExplorePlanID3);
	   }

      //Turn off fishing.
      xsDisableRule("fishing");
      //Turn off buildhouse.
      xsDisableRule("buildHouse");
      //Pause the age upgrades.
      //aiSetPauseAllAgeUpgrades(true);

      xsDisableRule("earlySettlementTracker");  // Normal settlement-building rule

      xsEnableRule("nomadBuildMode");
      xsDisableSelf();
      printEcho("Enabling nomadBuildMode");

}

//==============================================================================
// nomadBuildMode
//==============================================================================
rule nomadBuildMode	// Go to build mode when a suitable settlement is found
inactive
minInterval 1
{
   int count = -1;   // How many settlements found?

   static int settlementQuery = -1;    // All gaia settlements
   if (settlementQuery < 0)
   {
      settlementQuery = kbUnitQueryCreate("Nomad Settlement");
      kbUnitQuerySetPlayerID(settlementQuery, 0);
      kbUnitQuerySetUnitType(settlementQuery, cUnitTypeSettlement);
      if(gSettlersTargetAreaGroupID >= 0)
      {
	kbUnitQuerySetAreaGroupID(settlementQuery, gSettlersTargetAreaGroupID);
      }
   }

   //The map might give us builders from other civs!
   int builderTypeID = getBuilderType();
   if(kbUnitCount(cMyID, builderTypeID, cUnitStateAlive) < 1)
   {
	builderTypeID = cUnitTypeAbstractVillager;
   }else
   if(kbUnitCount(cMyID, builderTypeID, cUnitStateAlive) < 1)
   {
	builderTypeID = cUnitTypeAbstractInfantry;	//Norse
   }
   static int builderQuery = -1;      // All builders within 20 meters of a gaia settlement
   if (builderQuery < 0)
   {
      builderQuery = kbUnitQueryCreate("Nomad Builder");
      kbUnitQuerySetPlayerID(builderQuery, cMyID);
      kbUnitQuerySetUnitType(builderQuery, builderTypeID);
      kbUnitQuerySetState(builderQuery, cUnitStateAlive);
      kbUnitQuerySetMaximumDistance(builderQuery, 30.0);
      kbUnitQuerySetAscendingSort(builderQuery, true);
   }

   kbUnitQueryResetResults(settlementQuery);
   count = kbUnitQueryExecute(settlementQuery);
   if (count < 1)
      return;     // No settlements seen, give up

   // Settlements seen, check if you have a builder close by
   printEcho("Found "+count+" settlements.");
   int i = -1;
   int settlement = -1;
   int foundSettlement = -1;

   for (i=0; < count)
   {
      settlement = kbUnitQueryGetResult(settlementQuery, i);
      printEcho("    Checking settlement "+settlement+" at "+kbUnitGetPosition(settlement));
      kbUnitQuerySetPosition(builderQuery, kbUnitGetPosition(settlement));
      kbUnitQueryResetResults(builderQuery);
      if ( kbUnitQueryExecute(builderQuery) > 0)   // Builder nearby
      {
	 foundSettlement = settlement;
	 printEcho("	Builder found, we'll use "+settlement);
	 break;
      }
      printEcho("	No builders nearby.");
   }
   
   // If we found a usable settlement, build on it.  Otherwise, keep this rule active
   if (foundSettlement < 0)
      return;

   // We have one, let's use it and monitor for completion
   vector settleLoc = kbUnitGetPosition(foundSettlement);

   if(gVinlandsagaInitialBaseID >= 0)	//fakeBase
   {
	kbBaseDestroy(cMyID, gVinlandsagaInitialBaseID);
   }
   printEcho("Making main base.");
   int newBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), settleLoc, 75.0);
   if (newBaseID >= 0)
   {
      //Figure out the front vector.
      vector baseFront=xsVectorNormalize(kbGetMapCenter()-settleLoc);
      kbBaseSetFrontVector(cMyID, newBaseID, baseFront);
      printEcho("Setting front vector to "+baseFront);
      //Military gather point.
      vector militaryGatherPoint=settleLoc+baseFront*40.0;
      kbBaseSetMilitaryGatherPoint(cMyID, newBaseID, militaryGatherPoint);
      //Set the other flags.
      kbBaseSetMilitary(cMyID, newBaseID, true);
      kbBaseSetEconomy(cMyID, newBaseID, true);
      //Set the resource distance limit.
      kbBaseSetMaximumResourceDistance(cMyID, newBaseID, gMaximumBaseResourceDistance);
      //Add the settlement to the base.
      kbBaseSetSettlement(cMyID, newBaseID, true);
      //Set the main-ness of the base.
      kbBaseSetMain(cMyID, newBaseID, true);
   }
//EnableRule("buildSettlements");

   printEcho("Main base is "+newBaseID+" "+kbBaseGetMainID(cMyID));

   printEcho("Killing explore plans.");
   aiPlanDestroy(gNomadExplorePlanID1);
   aiPlanDestroy(gNomadExplorePlanID2);
   aiPlanDestroy(gNomadExplorePlanID3);

   int numberFound=kbUnitQueryExecute(builderQuery);
   for(i=0; < numberFound)
   {
	aiTaskUnitMove(i,settleLoc);	//Go there!
   }

   printEcho("Creating simple build plan");

	gNomadSettlementBuildPlanID=aiPlanCreate("Nomad settlement build", cPlanBuild);
   if (gNomadSettlementBuildPlanID < 0)
      return;
   //Puid.
   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSettlementLevel1);
   //Priority.
   aiPlanSetDesiredPriority(gNomadSettlementBuildPlanID, 100);
   //Mil vs. Econ.
   aiPlanSetMilitary(gNomadSettlementBuildPlanID, false);
   aiPlanSetEconomy(gNomadSettlementBuildPlanID, true);
   //Escrow.
   aiPlanSetEscrowID(gNomadSettlementBuildPlanID, cEconomyEscrowID);
   //Builders.
   aiPlanAddUnitType(gNomadSettlementBuildPlanID, getBuilderType(), 1, 4, 4);
   aiPlanAddUnitType(gNomadSettlementBuildPlanID, cUnitTypeAbstractVillager, 0, 1, 8);
   //Base ID.
   aiPlanSetBaseID(gNomadSettlementBuildPlanID, kbBaseGetMainID(cMyID));
   aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanCenterPosition, 0, settleLoc);
   aiPlanSetVariableFloat(gNomadSettlementBuildPlanID, cBuildPlanCenterPositionDistance, 0, 2.0);
//   aiPlanSetVariableInt(gNomadSettlementBuildPlanID, cBuildPlanFoundationID, 0, foundSettlement);
   aiPlanSetVariableVector(gNomadSettlementBuildPlanID, cBuildPlanSettlementPlacementPoint, 0, settleLoc);
   //Go.
   aiPlanSetActive(gNomadSettlementBuildPlanID);

   xsEnableRule("nomadMonitor");
   xsDisableSelf();
   printEcho("Activating nomad monitor rule");
}

//==============================================================================
// nomadMonitor
//==============================================================================
rule nomadMonitor    // Watch the build goal.  When a settlement is up, turn on normal function.  If goal fails, restart.
inactive
minInterval 1
{
   if ( (aiPlanGetState(gNomadSettlementBuildPlanID) >= 0) && (aiPlanGetState(gNomadSettlementBuildPlanID) != cPlanStateDone) )
      return;     // Plan exists, is not finished

   // plan is done or died.  Check if we have a settlement
   if (kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding) > 0) // AliveOrBuilding in case state isn't updated instantly
   {  // We have a settlement, go normal
      printEcho("Settlement is finished, normal start.");
      xsDisableSelf();
      xsEnableRule("earlySettlementTracker");
      //Turn on fishing.
      //xsEnableRule("fishing");
      //Turn off buildhouse.
      xsEnableRule("buildHouse");

      int tc = findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement);
      if ( tc >= 0)   
      {

	 // Set main base
	 int oldMainBase = kbBaseGetMainID(cMyID);
	 printEcho("Old main base was "+oldMainBase);
	    printEcho("Killing early gather plans.");
	    aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, oldMainBase);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, oldMainBase);
	    aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, oldMainBase);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, oldMainBase);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, oldMainBase);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, oldMainBase);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, oldMainBase);
	    aiRemoveResourceBreakdown(cResourceWood, cAIResourceSubTypeEasy, -1);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeEasy, -1);
	    aiRemoveResourceBreakdown(cResourceGold, cAIResourceSubTypeEasy, -1);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFish, -1);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeFarm, -1);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHuntAggressive, -1);
	    aiRemoveResourceBreakdown(cResourceFood, cAIResourceSubTypeHunt, -1);
	    aiRemoveResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, -1);
	    aiSetResourceBreakdown( cResourceFavor, cAIResourceSubTypeEasy, 0, 48, 0.00, kbBaseGetMainID(cMyID));

	 if ( kbUnitGetBaseID(tc) != oldMainBase )
	 {
	    kbBaseDestroy(cMyID, oldMainBase);
	    kbBaseSetMain(cMyID, kbUnitGetBaseID(tc),true);
	 }
	 printEcho("TC is in base "+kbUnitGetBaseID(tc));
	 printEcho("New main base is "+kbBaseGetMainID(cMyID));
	 vector front = cInvalidVector;
	 front = xsVectorNormalize(kbGetMapCenter()-kbUnitGetPosition(tc));
	 kbBaseSetFrontVector(cMyID, kbBaseGetMainID(cMyID), front);
	 printEcho("Front vector is "+front);
	 gFarmBaseID = kbBaseGetMainID(cMyID);
	 // Fix herdable plans
	      aiPlanDestroy(gHerdPlanID);
	 gHerdPlanID=aiPlanCreate("GatherHerdable Plan Nomad", cPlanHerd);
	 if (gHerdPlanID >= 0)
	 {
	    aiPlanAddUnitType(gHerdPlanID, cUnitTypeHerdable, 0, 100, 100);
	    aiPlanSetBaseID(gHerdPlanID, kbBaseGetMainID(cMyID));
	    aiPlanSetVariableInt(gHerdPlanID, cHerdPlanBuildingID, 0, tc);
	    aiPlanSetActive(gHerdPlanID);
	 }
	 aiSetResourceBreakdown( cResourceFavor, cAIResourceSubTypeEasy, 0, 48, 0.00, kbBaseGetMainID(cMyID));
	 updateFoodBreakdown();

      }

      // Fix god power plan for age 1
      aiPlanSetBaseID(gAge1GodPowerPlanID, kbBaseGetMainID(cMyID));

      // force the temple soon
      createSimpleBuildPlan(cUnitTypeTemple, 1, 100, false, true, cEconomyEscrowID, kbBaseGetMainID(cMyID), 1);
      //Unpause the age upgrades.
      aiSetPauseAllAgeUpgrades(false);
      //Unpause the pause kicker.
      xsEnableRule("unPauseAge2");
      xsSetRuleMinInterval("unPauseAge2", 15);

   }
   else
   {  // No settlement, restart chain
      printEcho("No settlement exists, restart nomad chain.");
      xsEnableRule("nomadSearchMode");
      xsDisableSelf();
   }
}

//==============================================================================
// nomadBuildSettlementCallBack
//==============================================================================
void nomadBuildSettlementCallBack(int parm1=-1)
{
   printEcho("nomadBuildSettlementCallBack:");

   //Find our one settlement.and make it the main base.
   int settlementID=findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement);
   if (settlementID < 0)
   {
      //Enable the rule that looks for a settlement.
	  int nomadSettlementGoalID = -1;
      nomadSettlementGoalID=createBuildSettlementGoal("BuildNomadSettlement", 0, -1, -1, 1, getBuilderType(), true, 100);
      if (nomadSettlementGoalID != -1)
      {
	 //Create the callback goal.
	 int nomadCallbackGID=createCallbackGoal("Nomad BuildSettlement Callback", "nomadBuildSettlementCallBack", 1, 0, -1, false);
	 if (nomadCallbackGID >= 0)
	    aiPlanSetVariableInt(nomadSettlementGoalID, cGoalPlanDoneGoal, 0, nomadCallbackGID);
      }
      return;
   }

   //Kill the villie explore plan.
   aiPlanDestroy(gNomadExplorePlanID1);

   //Find our one settlement and make it the main base.
   int newBaseID=kbUnitGetBaseID(findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement));
   aiSwitchMainBase(newBaseID, true);
   kbBaseSetMain(cMyID, newBaseID, true);

   //Unpause the age upgrades.
   aiSetPauseAllAgeUpgrades(false);
   //Unpause the pause kicker.
   xsEnableRule("unPauseAge2");
   xsSetRuleMinInterval("unPauseAge2", 15);

   //Turn on buildhouse.
   xsEnableRule("buildHouse");
   xsDisableSelf();
}

//==============================================================================
// Age 2 Handler
//==============================================================================
void age2Handler(int age=1)
{
   gLastAgeHandled = cAge2;
   printEcho("I'm now in Age "+age+".");
   if (cvMaxAge == age)
   {
      printEcho("Suspending age upgrades.");
      aiSetPauseAllAgeUpgrades(true);
   }

   //xsEnableRule("expandGatherPlans");
   xsEnableRule("defendPlanRule");
   xsEnableRule("buildForwardTowers");
   xsEnableRule("destroyOtherBases");
   xsEnableRule("wallsAroundTowers");
   xsEnableRule("towerSettlements");

   if(cMyCulture == cCultureAtlantean && cvRushBoomSlider > 0.8)
   {
	xsEnableRule("buildForwardBuildings");
   }

   //add a settlement to the early age forecast.
   if (gEarlySettlementTarget < 1)
   {
	//econForecastAge2Early
	  addUnitForecast(cUnitTypeSettlementLevel1,1);
	  gEarlySettlementTarget++;
   }

   //Econ.
   econAge2Handler(age);
   //Progress.
   progressAge2Handler(age);
   //GP.
   gpAge2Handler(age);
   //Tech.
   handleAge2Upgrades();
   printEcho("  Done with misc handlers.");

   //Set the housing rebuild bound.
   gHouseAvailablePopRebuild=20;
   if (cMyCulture == cCultureEgyptian)
      gHouseAvailablePopRebuild=30;
   if (cMyCulture == cCultureAtlantean)
      gHouseAvailablePopRebuild=30;

   //Run the EM rule.
   updateTargetPop();

   //Enable building repair.
   if (cvMasterDifficulty != cDifficultyEasy)
   {
      xsEnableRule("repairBuildings");
      xsEnableRule("emergencyHouses");	//fast pop rebuild.
   }
   //Misc Econ.
   if (gGatherGoalPlanID >= 0)
   {
      //Greeks need favor.
      if (cMyCulture == cCultureGreek)
      {
	 aiPlanSetVariableInt(gGatherGoalPlanID, cGatherGoalPlanNumFavorPlans, 0, 1);
	 aiSetResourceBreakdown(cResourceFavor, cAIResourceSubTypeEasy, 1, 40, 1.0, kbBaseGetMainID(cMyID));
      }
   }

   //If we're building towers, do that.
   if (gBuildTowers == true && gFowardBuildings == false) {
      towerInBase("Age2TowerBuild", false, gTargetNumTowers/(2.0 + (-1.0*cvRushBoomSlider)), cMilitaryEscrowID);     // If rusher, all now, if boomer, 1/3 now
   }

   //Maintain a water transport, if this is a transport map.
   if ((gTransportMap == true) && (gMaintainWaterXPortPlanID < 0))
   {
	// Make sure we have a dock
	if(kbUnitCount(cMyID,cUnitTypeDock) == 0)
	{
		int areaID = kbAreaGetClosetArea(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), cAreaTypeWater);
		int buildDock = aiPlanCreate("BuildDock", cPlanBuild);
		if (buildDock >= 0)
		{
		   printEcho("Building dock for scouting.");
		   //BP Type and Priority.
		   aiPlanSetVariableInt(buildDock, cBuildPlanBuildingTypeID, 0, cUnitTypeDock);
		   aiPlanSetDesiredPriority(buildDock, 100);
		   aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
		   aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 1, kbAreaGetCenter(areaID));
		   aiPlanAddUnitType(buildDock, getBuilderType(), 1, 1, 1);
		   aiPlanSetEscrowID(buildDock, cEconomyEscrowID);
		   aiPlanSetActive(buildDock);
		}
	}
      	gMaintainWaterXPortPlanID=createSimpleMaintainPlan(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 2, false, -1);
      	aiPlanSetDesiredPriority(gMaintainWaterXPortPlanID, 95);
   }

   if (gBuildTowers == true)
      xsEnableRule("towerUpgrade");

   //Store our relic gatherer type.
   int gatherRelicType=-1;

   //Init our myth unit rule.
   xsEnableRule("trainMythUnit");

   //Greek.
   if (cMyCulture == cCultureGreek)
   {
      //Greeks gather with heros.
      gatherRelicType=cUnitTypeHero;

      //Always want 4 toxotes.
      //createSimpleMaintainPlan(cUnitTypeToxotes, 4, false, kbBaseGetMainID(cMyID));

      //Fits well with a defensive mentality.
      int healerPlanID = createSimpleMaintainPlan(cUnitTypePhysician, 1, false, kbBaseGetMainID(cMyID));
      aiPlanSetDesiredPriority(healerPlanID, 20);

      //Create our hero maintain plans.  These do first and second age heroes.
      int heroPlanID = -1;
      if (cMyCiv == cCivZeus)
      {
	 heroPlanID = createSimpleMaintainPlan(cUnitTypeHeroGreekJason, 1, false, kbBaseGetMainID(cMyID));
	 aiPlanSetDesiredPriority(heroPlanID, 100);
	 heroPlanID = createSimpleMaintainPlan(cUnitTypeHeroGreekOdysseus, 1, false, kbBaseGetMainID(cMyID));
	 aiPlanSetDesiredPriority(heroPlanID, 80);
      }
      else if (cMyCiv == cCivPoseidon)
      {
	 heroPlanID = createSimpleMaintainPlan(cUnitTypeHeroGreekTheseus, 1, false, kbBaseGetMainID(cMyID));
	 aiPlanSetDesiredPriority(heroPlanID, 100);
	 heroPlanID = createSimpleMaintainPlan(cUnitTypeHeroGreekHippolyta, 1, false, kbBaseGetMainID(cMyID));
	 aiPlanSetDesiredPriority(heroPlanID, 80);
      }
      else if (cMyCiv == cCivHades)
      {
	 heroPlanID = createSimpleMaintainPlan(cUnitTypeHeroGreekAjax, 1, false, kbBaseGetMainID(cMyID));
	 aiPlanSetDesiredPriority(heroPlanID, 100);
	 heroPlanID = createSimpleMaintainPlan(cUnitTypeHeroGreekChiron, 1, false, kbBaseGetMainID(cMyID));
	 aiPlanSetDesiredPriority(heroPlanID, 80);
      }
   }
   if (cMyCiv == cCivHades)
   {
      //Get VOE.
      int voePID=aiPlanCreate("HadesVaultsOfErebus", cPlanProgression);
	   if (voePID != 0)
      {
	 aiPlanSetVariableInt(voePID, cProgressionPlanGoalTechID, 0, cTechVaultsofErebus);
	      aiPlanSetDesiredPriority(voePID, 25);
	      aiPlanSetEscrowID(voePID, cEconomyEscrowID);
	      aiPlanSetActive(voePID);
      }
   }
   //Egyptian.
   else if (cMyCulture == cCultureEgyptian)
   {
      //Egyptians gather relics with their Pharaoh.
      gatherRelicType=cUnitTypePharaoh;

      //Move our pharaoh empower to a generic "dropsite"
      if (gEmpowerPlanID >= 0)
	 aiPlanSetVariableInt(gEmpowerPlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeDropsite);

      //Always want 4 axeman.
      //createSimpleMaintainPlan(cUnitTypeAxeman, 4, false, kbBaseGetMainID(cMyID));

      //If we're Ra, create some more priests and empower with them.
      if (cMyCiv == cCivRa)
      {
	 createSimpleMaintainPlan(cUnitTypePriest, 4, true, -1);
	 int ePlanID=aiPlanCreate("Mining Camp Empower", cPlanEmpower);
	 if (ePlanID >= 0)
	 {
	    aiPlanSetEconomy(ePlanID, true);
	    aiPlanAddUnitType(ePlanID, cUnitTypePriest, 1, 1, 1);
	    aiPlanSetVariableInt(ePlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeMiningCamp);
	    aiPlanSetActive(ePlanID);
	 }
	 ePlanID=aiPlanCreate("Lumber Camp Empower", cPlanEmpower);
	 if (ePlanID >= 0)
	 {
	    aiPlanSetEconomy(ePlanID, true);
	    aiPlanAddUnitType(ePlanID, cUnitTypePriest, 1, 1, 1);
	    aiPlanSetVariableInt(ePlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeLumberCamp);
	    aiPlanSetActive(ePlanID);
	 }
	 ePlanID=aiPlanCreate("Monument Empower", cPlanEmpower);
	 if (ePlanID >= 0)
	 {
	    aiPlanSetEconomy(ePlanID, true);
	    aiPlanAddUnitType(ePlanID, cUnitTypePriest, 1, 1, 1);
	    aiPlanSetVariableInt(ePlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeAbstractMonument);
	    aiPlanSetActive(ePlanID);
	 }
      }

      //Up the build limit for Outposts.
      aiSetMaxLOSProtoUnitLimit(8);
   }
   //Norse.
   else if (cMyCulture == cCultureNorse)
   {
      // add and extra ulfsark builder
      aiPlanSetVariableInt(gUlfsarkMaintainPlanID, cTrainPlanNumberToMaintain, 0, 
	 aiPlanGetVariableInt(gUlfsarkMaintainPlanID, cTrainPlanNumberToMaintain, 0)+1);
      aiPlanSetVariableInt(gUlfsarkMaintainMilPlanID, cTrainPlanNumberToMaintain, 0, 
	 aiPlanGetVariableInt(gUlfsarkMaintainMilPlanID, cTrainPlanNumberToMaintain, 0)+1);      //Norse gather with their heros.
      gatherRelicType=cUnitTypeHeroNorse;

      //We always want 2 Norse heroes.
      createSimpleMaintainPlan(cUnitTypeHeroNorse, 2, false, kbBaseGetMainID(cMyID));

      //Force a long house to go down.
	   int longhousePlanID=aiPlanCreate("NorseBuildLonghouse", cPlanBuild);
      if (longhousePlanID >= 0)
      {
	 aiPlanSetVariableInt(longhousePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeLonghouse);
		   aiPlanSetVariableInt(longhousePlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());
	 aiPlanSetDesiredPriority(longhousePlanID, 100);
		   aiPlanAddUnitType(longhousePlanID, getBuilderType(), gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
	 aiPlanSetEscrowID(longhousePlanID, cMilitaryEscrowID);
	 aiPlanSetBaseID(longhousePlanID, kbBaseGetMainID(cMyID));
	 aiPlanSetActive(longhousePlanID);
      }

      //Up our Thor dwarf count.
      if (gDwarfMaintainPlanID >= 0)
	 aiPlanSetVariableInt(gDwarfMaintainPlanID, cTrainPlanNumberToMaintain, 0, 4);

      if (gBuildWalls == true)
      {
	// Add 2 ulfsarks from econ budget for walling
	int planID=aiPlanCreate("Wall Ulfsarks", cPlanTrain);
	if (planID >= 0)
	{
	    printEcho("Adding two ulfsarks for walling.");
	    aiPlanSetEconomy(planID, true);
	    aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, cUnitTypeUlfsark);
	    aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 2);
	    aiPlanSetDesiredPriority(planID, 98);
	    aiPlanSetActive(planID);
	}
	printEcho("Wall planning complete.");
      }
   }
   else if (cMyCulture == cCultureAtlantean)
   {
      //Always want 4 Swordsman
      //createSimpleMaintainPlan(cUnitTypeSwordsman, 4, false, kbBaseGetMainID(cMyID));

      // Use hero oracle for gathering relics
      gatherRelicType = cUnitTypeOracleHero;
      xsEnableRule("makeOracleHero");  // Keep at least one oracle hero around

      // Build a guild
	   int guildPlanID=aiPlanCreate("BuildGuild", cPlanBuild);
      if (guildPlanID >= 0)
      {
	 aiPlanSetVariableInt(guildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeGuild);
		   aiPlanSetVariableInt(guildPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());
	 aiPlanSetDesiredPriority(guildPlanID, 100);
		   aiPlanAddUnitType(guildPlanID, getBuilderType(), gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
	 aiPlanSetEscrowID(guildPlanID, cEconomyEscrowID);
	 aiPlanSetBaseID(guildPlanID, kbBaseGetMainID(cMyID));
	 aiPlanSetActive(guildPlanID);
      }
      //Force a counter barracks to go down.
	   int barracksPlanID=aiPlanCreate("AtlanteanBuildCounterBarracks", cPlanBuild);
      if (barracksPlanID >= 0)
      {
	 aiPlanSetVariableInt(barracksPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeCounterBuilding);
		   aiPlanSetVariableInt(barracksPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());
	 aiPlanSetDesiredPriority(barracksPlanID, 80);
		   aiPlanAddUnitType(barracksPlanID, getBuilderType(), gBuildersPerHouse, gBuildersPerHouse, gBuildersPerHouse);
	 aiPlanSetEscrowID(barracksPlanID, cMilitaryEscrowID);
	 aiPlanSetBaseID(barracksPlanID, kbBaseGetMainID(cMyID));
	 aiPlanSetActive(barracksPlanID);
      }
   }
	else if(cMyCulture == cCultureChinese)
	{   
		//Chinese gather with immortals and monks.
		gatherRelicType=cUnitTypeHero;
		createSimpleMaintainPlan(cUnitTypeHeroChineseImmortal, 2, false, kbBaseGetMainID(cMyID));
	}

   //Relics:  Always on Hard or Nightmare, 50% of the time on Moderate, Never on Easy.
   bool gatherRelics=true;
   if ((cvMasterDifficulty == cDifficultyEasy) ||
      ((cvMasterDifficulty == cDifficultyModerate) && (aiRandInt(2) == 0)) )
      gatherRelics=false;
   //If we're going to gather relics, do it.
   if (cvOkToGatherRelics == false)
      gatherRelics = false;
   if (gatherRelics == true)
   {
      printEcho("Creating relic gathering plan with unit type "+gatherRelicType);
      gRelicGatherPlanID=aiPlanCreate("Relic Gather", cPlanGatherRelic);
      if (gRelicGatherPlanID >= 0)
      {
	 aiPlanAddUnitType(gRelicGatherPlanID, gatherRelicType, 1, 1, 1);
	 aiPlanSetVariableInt(gRelicGatherPlanID, cGatherRelicPlanTargetTypeID, 0, cUnitTypeRelic);
		   aiPlanSetVariableInt(gRelicGatherPlanID, cGatherRelicPlanDropsiteTypeID, 0, cUnitTypeTemple);
	 aiPlanSetBaseID(gRelicGatherPlanID, kbBaseGetMainID(cMyID));
	 aiPlanSetDesiredPriority(gRelicGatherPlanID, 100);
		   aiPlanSetActive(gRelicGatherPlanID);
      }
   }

// Real deathmatch is handled in econ file
   //If we're in deathmatch, immediately build our armory.
   if (gFakeDeathmatch == true && (aiGetGameMode() != cGameModeDeathmatch))
   {
      gHardEconomyPopCap=15;
      if (cMyCiv == cCivThor)
	 createSimpleBuildPlan(cUnitTypeDwarfFoundry, 1, 100, false, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 5);
      else
	 createSimpleBuildPlan(cUnitTypeArmory, 1, 100, false, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 5);
      createSimpleBuildPlan(cUnitTypeHouse, 3, 90, false, false, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
   }
	if(aiGetGameMode() == cGameModeDeathmatch)	//activate tc rule!
	{
			xsEnableRule("buildSettlements");
	}

   xsEnableRule("dockMonitorDM");	//Make sure it really works!
}

//==============================================================================
// RULE rebuildMarket
//==============================================================================
rule rebuildMarket      // If market dies, restart
minInterval 19
inactive		// activated in tradeWithCaravans, after market is built
{
   //if (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAlive) < 1)
   if (kbUnitGetCurrentHitpoints(gTradeMarketUnitID) <= 0)
   {
      xsEnableRule("tradeWithCaravans");
      xsDisableSelf();
      gTradeMarketUnitID = -1;
      printEcho("***** Restarting market trade rule.");
   }
}

//==============================================================================
// RULE monitorTrade
//==============================================================================
rule monitorTrade
inactive
minInterval 27
{
  // Set the number of trade carts based on age and quality of trade route.
   int destID = aiPlanGetVariableInt(gTradePlanID,cTradePlanTargetUnitID, 0);
   int marketID = aiPlanGetVariableInt(gTradePlanID, cTradePlanMarketID, 0);
   int oldTradePop = aiPlanGetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0);
   int tradeTargetPop = gMaxTradeCarts;		//was 20 traders - now 30
   if (aiGetPersonality() == "Apocalypse Bot" && kbResourceGet(cResourceGold)>500)
      tradeTargetPop = 8;
   if ( (cvMaxTradePop >= 0) && (tradeTargetPop > cvMaxTradePop))    // Stay under control variable limit
      tradeTargetPop = cvMaxTradePop;
   if (kbGetAge() < cAge4)		// Ramp up in age 3, not too many...
   {
      if(cResourceGold < 400 && cResourceFood > 900)
      {
		tradeTargetPop = tradeTargetPop/1.5;	//Rebalance by having a bit more trade.
      }else{
		tradeTargetPop = tradeTargetPop/2;
      }
      if(cMyCulture == cCultureEgyptian)
      {
		tradeTargetPop = tradeTargetPop + 5;	//Eggy want a lot of gold!
      }
   }
   if ( (destID >= 0) && (marketID >= 0) ) // Have dest and a market
   {
      float routeLength = xsVectorLength( kbUnitGetPosition(destID) -  kbUnitGetPosition(marketID));
      float routeRatio = (routeLength*2) / (kbGetMapXSize() + kbGetMapZSize());
      float routeQuality = routeRatio / .75;       // Define 75% of map length as "perfect".
      if (routeQuality > 1.0)
	 routeQuality = 1.0;
      tradeTargetPop = tradeTargetPop * routeQuality;
      aiPlanSetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0, tradeTargetPop);
   }
   else
   {  // No market, or no destination
      tradeTargetPop = 0;
      aiPlanSetVariableInt(gTradeMaintainPlanID, cTrainPlanNumberToMaintain, 0, tradeTargetPop);    // Don't make trade carts
   }
   if (oldTradePop != tradeTargetPop)
   {
      printEcho("Trade:  Route quality is "+routeQuality);
      printEcho("Changing target number of trade units from "+oldTradePop+" to "+tradeTargetPop+".");
   } 
}

//==============================================================================
// RULE makeExtraMarket
//
// If it takes more than 5 minutes to place our trade market, throw down a local one
//==============================================================================
rule makeExtraMarket
inactive
minInterval 10
{
   static int endTime = -1;

   if (endTime < 0)
      endTime = xsGetTime() + 300000;	// Five minutes later

   if (xsGetTime() < endTime)
      return;

   vector backVector = kbBaseGetBackVector(cMyID, kbBaseGetMainID(cMyID));

	  xsVectorSetX(backVector,xsVectorGetX(backVector)*70);		//was 40
	  xsVectorSetX(backVector,xsVectorGetZ(backVector)*70);

	  int areaGroup1 = kbAreaGroupGetIDByPosition(backVector);

   vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)) + backVector;

	  int areaGroup2 = kbAreaGroupGetIDByPosition(location);

   if (areaGroup1 != areaGroup2)
      location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));

   // Time has expired, add another market.
   int marketPlanID=aiPlanCreate("BuildNearbyMarket", cPlanBuild);
   if (marketPlanID >= 0)
   {
      aiPlanSetVariableInt(marketPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
      aiPlanSetVariableInt(marketPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());
      aiPlanSetDesiredPriority(marketPlanID, 100);
      aiPlanAddUnitType(marketPlanID, getBuilderType(), 1, 1, 1);
      aiPlanSetEscrowID(marketPlanID, cEconomyEscrowID);
      aiPlanSetBaseID(marketPlanID, kbBaseGetMainID(cMyID));

      aiPlanSetVariableVector(marketPlanID, cBuildPlanInfluencePosition, 0, location);
      aiPlanSetVariableFloat(marketPlanID, cBuildPlanInfluencePositionDistance, 0, 20.0);
      aiPlanSetVariableFloat(marketPlanID, cBuildPlanInfluencePositionValue, 0, 5.0);

      aiPlanSetActive(marketPlanID);
   }
   gExtraMarket = true;	// Set the global so we know to look for SECOND market before trading.
   xsDisableSelf();
}

//==============================================================================
// RULE goAge4
//==============================================================================
rule goAge4
minInterval 10
inactive
{
   if ( (gAge4ProgressionPlanID < 0) && (kbGetAge() < cAge4) )
   {
      static bool age4started = false;
      if (age4started == false)
      {
	 updateAge4Options();	//Check our situation!

	 gAge4ProgressionPlanID=aiPlanCreate("Age 4", cPlanProgression);
	 printEcho("***** Age 4 progression is plan ID "+gAge4ProgressionPlanID);
	 printEcho("Age 4 minor god is "+gAge4MinorGod);
	 if (gAge4MinorGod == -1)
	 {
		gAge4MinorGod=chooseMinorGod(cAge4, -1, -1);
	 }
	 if ((gAge4ProgressionPlanID >= 0) && (gAge4MinorGod != -1))
	 {
	    aiPlanSetVariableInt(gAge4ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge4MinorGod);
	    aiPlanSetDesiredPriority(gAge4ProgressionPlanID, 100);
		      aiPlanSetEscrowID(gAge4ProgressionPlanID, cEconomyEscrowID);
	    aiPlanSetBaseID(gAge4ProgressionPlanID, kbBaseGetMainID(cMyID));
	    aiPlanSetActive(gAge4ProgressionPlanID);
	    age4started = true;		//Only get here once.
	 }else{
		aiPlanDestroy(gAge4ProgressionPlanID);
		gAge4ProgressionPlanID = -1;
		age4started = false;	//Try again, later.
	 }
      }
   }
   if ( (gAge4ProgressionPlanID >= 0) || (kbGetAge() > cAge3))
   {
	xsDisableSelf();	//Otherwise repeat.
   }
}

//==============================================================================
// RULE tradeWithCaravans
//==============================================================================
rule tradeWithCaravans
   minInterval 11
   inactive
{
   //Force build a market.
   static int failedBase = -1;  // Set to the main base ID if no valid market position exists, so we don't retry forever.

   if (failedBase == kbBaseGetMainID(cMyID))  // We've failed at this spot before
   {
      xsSetRuleMinInterval("tradeWithCaravans", 180);
      printEcho("Failed base = "+failedBase+", base = "+kbBaseGetMainID(cMyID));
      printEcho("Can't position a trade market for this base.");
      return;
   }

   static bool builtMarket=false;
   static int marketTime = -1;   // Set when we create the build plan
   static int buildPlanID = -1;
   int targetNumMarkets = 1;
   if (gExtraMarket == true)
      targetNumMarkets = 2;      // One near main base, one for trade

//   if ( (marketTime < (xsGetTime()-300000) ) && (kbUnitCount(cMyID, cUnitTypeMarket, cUnitStateAliveOrBuilding) < 1) )
//      builtMarket = false;    // It's been 5 minutes, and I still don't have a market.
			      // Either it failed, or it's been destroyed.

   if (builtMarket == false)
   {
      string buildPlanName="BuildMarket";
      buildPlanID=aiPlanCreate(buildPlanName, cPlanBuild);
      if (buildPlanID < 0)
	 return;

      vector location = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));  // my base location
      vector allyLocation = cInvalidVector;
      vector marketLocation = cInvalidVector;

      // Since we can't specify a target TC, if we have allies, we'll build in the corner
      // that is nearest the most distant ally TC, which should give us a good run back
      // to our TCs.  If no allies, or if ally corner == our corner, choose the
      // corner that is second closest to our base.

      // MK: This is *really* an ugly process in XS without arrays or trig calls.  Would be a good
      // candidate to push down to C++.

      // Do simple dx+dz distance check for each corner
      float bottom = -1;
      float top = -1;
      float right = -1;
      float left = -1;
      int closestToMe = -1;
      int closestToAlly = -1;
      int secondClosestToMe = -1;
      float min = -1.0;

      bottom = xsVectorGetX(location) + xsVectorGetZ(location);    // dist to bottom
      left = xsVectorGetX(location) + (kbGetMapZSize() - xsVectorGetZ(location));
      right = (kbGetMapXSize() - xsVectorGetX(location)) + xsVectorGetZ(location);
      top = (kbGetMapXSize() - xsVectorGetX(location)) + (kbGetMapZSize() - xsVectorGetZ(location));

      // Find closest corner, and mark it as distant so we can then find the second closest
      if ( xsVectorGetX(location) < (kbGetMapXSize()/2) )
      {  // we're on bottom left half
	 if ( xsVectorGetZ(location) < (kbGetMapZSize()/2) )
	 {  // we're lower right half ergo bottom corner
	    bottom = 10000;     // Won't be closest
	    closestToMe = 0;  // x0,z0
	 }
	 else
	 {  // we're on upper left half, ergo left
	    left = 10000;
	    closestToMe = 1;  // x0, z1
	 }
      }
      else
      {  // we're on upper right half
	 if ( xsVectorGetZ(location) > (kbGetMapZSize()/2) )
	 {  // we're upper left half ergo top corner
	    top = 10000;     // Won't be closest
	    closestToMe = 3;  // x1, z1
	 }
	 else
	 {  // we're on bottom right half, ergo right
	    right = 10000;
	    closestToMe = 2;  // x1, z0
	 }
      }
      
      // Find second closest to me.
      min = 9000.0;
      if ( bottom < min )
      {
	 min = bottom;
	 secondClosestToMe = 0;
	 printEcho("Bottom is second closest to me.");
      }
      if ( top < min )
      {
	 min = top;
	 secondClosestToMe = 3;
	 printEcho("Top is second closest to me.");
      }
      if ( left < min )
      {
	 min = left;
	 secondClosestToMe = 1;
	 printEcho("Left is second closest to me.");
      }
      if ( right < min )
      {
	 min = right;
	 secondClosestToMe = 2;
	 printEcho("Right is second closest to me.");
      }
 
      // We've found the closest and second closest corners.  If we have an ally, find its closest corner

      // Look for an ally TC.  If we find one, use it to determine position.  
      //If we don't have a query ID, create it.
      static int distantAllyTCQuery=-1;
      if (distantAllyTCQuery < 0)
      {
	 distantAllyTCQuery=kbUnitQueryCreate("MarketQuery");
	 //If we still don't have one, bail.
	 if (distantAllyTCQuery < 0)
	    return;
	 //Else, setup the query data.
	 kbUnitQuerySetPlayerRelation(distantAllyTCQuery, cPlayerRelationAlly);
	 kbUnitQuerySetUnitType(distantAllyTCQuery, cUnitTypeAbstractSettlement);
	 kbUnitQuerySetState(distantAllyTCQuery, cUnitStateAlive);
	 kbUnitQuerySetPosition(distantAllyTCQuery, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	 kbUnitQuerySetAscendingSort(distantAllyTCQuery, true);
	 if(gTransportMap)
	 {
		//We can't trade through water, therefore stay on mainland.
		kbUnitQuerySetAreaGroupID(distantAllyTCQuery, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))));
	 }
      }
      kbUnitQueryResetResults(distantAllyTCQuery);
      int tcCount = kbUnitQueryExecute(distantAllyTCQuery);
      int tcID = -1;
      if (tcCount > 0)
      {
	 tcID = kbUnitQueryGetResult(distantAllyTCQuery, tcCount-1);
	 allyLocation = kbUnitGetPosition(tcID);
      }

      if ( xsVectorGetX(allyLocation) < (kbGetMapXSize()/2) )
      {  // we're on bottom left half
	 if ( xsVectorGetZ(allyLocation) < (kbGetMapZSize()/2) )
	 {  // we're lower right half ergo bottom corner
	    closestToAlly = 0;  // x0,z0
	 }
	 else
	 {  // we're on upper left half, ergo left
	    closestToAlly = 1;  // x0, z1
	 }
      }
      else
      {  // we're on upper right half
	 if ( xsVectorGetZ(allyLocation) > (kbGetMapZSize()/2) )
	 {  // we're upper left half ergo top corner
	    closestToAlly = 3;  // x1, z1
	 }
	 else
	 {  // we're on bottom right half, ergo right
	    closestToAlly = 2;  // x1, z0
	 }
      }

      // Now, sort it all out...
      // Since we can't override the tendency to trade with our own settlements, this is what we'll do.
      // If the most distant ally's closest corner is not the same as ours, we'll go there.  
      // If we don't have an ally, or the ally's closest corner is the same as ours, we'll use our 
      // second closest corner.

      int chosenCorner = -1;

      printEcho("Closest to me "+closestToMe+", second "+secondClosestToMe+", ally "+closestToAlly);

      if ( (tcID < 0) || (closestToAlly == closestToMe))
      {
	 chosenCorner = secondClosestToMe;
	 printEcho("Choosing second closest to me "+secondClosestToMe);
      }
      else
      {
	 chosenCorner = closestToAlly;
	 printEcho("Choosing closest to ally "+closestToAlly);
      }

      switch(chosenCorner)
      {
      case 0:
	 {  // X and Z low
	    marketLocation = xsVectorSetX(marketLocation, 2);
	    marketLocation = xsVectorSetZ(marketLocation, 2);
	    break;
	 }
      case 1:
	 {  // X low, Z hi
	    marketLocation = xsVectorSetX(marketLocation, 2);
	    marketLocation = xsVectorSetZ(marketLocation, kbGetMapZSize()-2);
	    break;
	 }
      case 2:
	 {  // X hi, Z lo
	    marketLocation = xsVectorSetX(marketLocation, kbGetMapXSize()-2);
	    marketLocation = xsVectorSetZ(marketLocation, 2);
	    break;
	 }
      case 3:
	 {  // X hi, Z hi
	    marketLocation = xsVectorSetX(marketLocation, kbGetMapXSize()-2);
	    marketLocation = xsVectorSetZ(marketLocation, kbGetMapZSize()-2);
	    break;
	 }
      }

      marketLocation = xsVectorSetY(marketLocation, 0);

      // Figure out if it's on our areaGroup.  If not, step 5% closer until it is.
      int homeAreaGroup = -1;
      int marketAreaGroup = -1;
      homeAreaGroup = kbAreaGroupGetIDByPosition(location);
      printEcho("Home location "+location+" is in areaGroup "+homeAreaGroup);

      int i = -1;
      vector towardHome = cInvalidVector;
      towardHome = location - marketLocation;
      towardHome = towardHome / 20;    // 5% of distance from market to home
      bool success = false;

      for (i=0; <18)    // Keep testing until areaGroups match
      {
	 marketAreaGroup = kbAreaGroupGetIDByPosition(marketLocation);
	 if (marketAreaGroup == homeAreaGroup)
	 {
	    success = true;
	    printEcho("Market location "+marketLocation+" is in areaGroup "+marketAreaGroup);
	    break;
	 }
	 else
	 {
	    printEcho("Market location "+marketLocation+" is in areaGroup "+marketAreaGroup);
	    marketLocation = marketLocation + towardHome;   // Try a bit closer
	 }
      }
   
      if (success == false)
      {
	 printEcho("Can't find a market spot, we'll give up and let the age4 plan build one.");
	 failedBase = kbBaseGetMainID(cMyID);
	 xsEnableRule("goAge4");
	 return;
      }

      printEcho("Market target location is "+marketLocation+" in areaGroup "+kbAreaGroupGetIDByPosition(marketLocation));
      gTradeMarketLocation = marketLocation; // Set the global var for later reference in identifying the trade market.

      //Setup the build plan.
      aiPlanSetVariableInt(buildPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
      aiPlanSetVariableVector(buildPlanID, cBuildPlanInfluencePosition, 0, marketLocation);
      aiPlanSetVariableFloat(buildPlanID, cBuildPlanInfluencePositionDistance, 0, 30.0);
      aiPlanSetVariableFloat(buildPlanID, cBuildPlanInfluencePositionValue, 0, 100.0);
      aiPlanSetVariableInt(buildPlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(marketLocation));
      aiPlanSetVariableInt(buildPlanID, cBuildPlanNumAreaBorderLayers, 0, 2);
      aiPlanSetDesiredPriority(buildPlanID, 100);
      aiPlanAddUnitType(buildPlanID, getBuilderType(), 1, 1, 1);
      aiPlanSetEscrowID(buildPlanID, cEconomyEscrowID);
      aiPlanSetActive(buildPlanID);
     
      builtMarket = true;
      marketTime = xsGetTime();
      xsEnableRule("makeExtraMarket");	  // Will build a local market in 5 minutes if this one isn't done
   }  // Force-build market
   
   //If we don't have a query ID, create it.
   static int marketQueryID=-1;
   if (marketQueryID < 0)
   {
      marketQueryID=kbUnitQueryCreate("MarketQuery");
      //If we still don't have one, bail.
      if (marketQueryID < 0)
	 return;
      //Else, setup the query data.
      kbUnitQuerySetPlayerID(marketQueryID, cMyID);
      kbUnitQuerySetUnitType(marketQueryID, cUnitTypeMarket);
      kbUnitQuerySetState(marketQueryID, cUnitStateAlive);
   }
   kbUnitQuerySetPosition(marketQueryID, gTradeMarketLocation);
   kbUnitQuerySetAscendingSort(marketQueryID, true);

   //Reset the results.
   kbUnitQueryResetResults(marketQueryID);
   //Run the query.  
   int numMarkets = kbUnitQueryExecute(marketQueryID);
   printEcho("***** Market plan ("+buildPlanID+") status is "+aiPlanGetState(buildPlanID));
   printEcho("  We have "+numMarkets+" markets out of "+targetNumMarkets+" planned.");
   if (numMarkets <= 0)
   {
      if(aiPlanGetState(buildPlanID) < 0)   // No market, and not building or placing
      {  
	 aiPlanDestroy(buildPlanID);	 // Scrap it an start over
	 buildPlanID = -1;
	 builtMarket = false;
	 printEcho("***** Market build failed, restarting");
      }
      return;	// No market at all, bail
   }
   // At least one market exists
   xsDisableRule("makeExtraMarket");      // If it hasn't run already, we don't need it
   xsEnableRule("goAge4");



   if (numMarkets < targetNumMarkets)    // Trade market not done yet
   {
      if(aiPlanGetState(buildPlanID) < 0)   // No trade market, and not building or placing
      {  
	 aiPlanDestroy(buildPlanID);	 // Scrap it and start over
	 buildPlanID = -1;
	 builtMarket = false;
	 printEcho("***** Market build failed, restarting");
      }
      return;
   }

   // We have our target number of markets
   printEcho("***** We have our target number of markets, starting trade plan.");

   int marketUnitID=kbUnitQueryGetResult(marketQueryID, 0);    // Closest to target point
   if (marketUnitID == -1)
      return;
   gTradeMarketLocation = kbUnitGetPosition(marketUnitID);
   gTradeMarketUnitID = marketUnitID;

    // We have a market for trade, activate the rule to rebuild if lost
   xsEnableRule("rebuildMarket");      // Will restart process if market is lost

   //Create the market trade plan.
   if (gTradePlanID >= 0)
      aiPlanDestroy(gTradePlanID);  // Delete old one based on previous market, if any.
   string planName="MarketTrade";
   gTradePlanID=aiPlanCreate(planName, cPlanTrade);
   if (gTradePlanID < 0)
      return;

   //Get our cart PUID.
   int tradeCartPUID=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionTrade, 0);
   aiPlanSetVariableInt(gTradePlanID, cTradePlanTargetUnitTypeID, 0, cUnitTypeAbstractSettlement);
   aiPlanSetDesiredPriority(gTradePlanID, 100);
   aiPlanSetInitialPosition(gTradePlanID, kbUnitGetPosition(marketUnitID));
   aiPlanSetVariableVector(gTradePlanID, cTradePlanStartPosition, 0, kbUnitGetPosition(marketUnitID));
   aiPlanSetVariableInt(gTradePlanID, cTradePlanTradeUnitType, 0, tradeCartPUID);

   aiPlanSetVariableInt(gTradePlanID, cTradePlanMarketID, 0, marketUnitID);
   aiPlanAddUnitType(gTradePlanID, tradeCartPUID, 1, 1, 100);     // Just one to start, maintain plan will adjust later based on route quality

   aiPlanSetEconomy(gTradePlanID, true);
   aiPlanSetActive(gTradePlanID);

   // Activate the rule to monitor it
   xsEnableRule("monitorTrade");

   gTradeMaintainPlanID = createSimpleMaintainPlan(tradeCartPUID, 1, true);   // Just one to start, monitorTrade rule will adjust as needed
   aiPlanSetVariableBool(gTradeMaintainPlanID, cTrainPlanUseMultipleBuildings, 0, true);

   //Go away.
   xsDisableSelf();
}

//==============================================================================
// RULE DONATEFood
//==============================================================================
rule DONATEFood
   minInterval 30
   maxInterval 80
   inactive
   Group Donations
{
    if  (aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy)
    {
	xsDisableSelf();
	return;
    }
    for(i=0; < 4)	//Try a few times.
    {
	int pID = 1 + aiRandInt(cNumberPlayers-1);
	float foodSupply = kbResourceGet(cResourceFood);
	if(pID != cMyID && kbIsPlayerAlly(pID) == true && kbIsPlayerResigned(pID) == false && kbHasPlayerLost(pID) == false && foodSupply > 1500)
	{
	   int donationAmount = 100*(aiRandInt(5)+1);
	   if((foodSupply-donationAmount) > 2000 && kbGetAge() >= cAge4)
	   {
		printEcho("Tributing "+donationAmount+" food to one of my allies!");
		aiTribute(pID, cResourceFood, donationAmount);
	   }else{
		printEcho("Tributing 100 food to one of my allies!");
		aiTribute(pID, cResourceFood, 100);
	   }
	}
    }
}

//==============================================================================
// RULE DONATEWood
//==============================================================================
rule DONATEWood
   minInterval 30
   maxInterval 80
   inactive
   Group Donations
{
    if  (aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy)
    {
	xsDisableSelf();
	return;
    }
    for(i=0; < 4)	//Try a few times.
    {
	int pID = 1 + aiRandInt(cNumberPlayers-1);
	float woodSupply = kbResourceGet(cResourceWood);
	if(pID != cMyID && kbIsPlayerAlly(pID) == true && kbIsPlayerResigned(pID) == false && kbHasPlayerLost(pID) == false && woodSupply > 1500)
	{
	   int donationAmount = 100*(aiRandInt(5)+1);
	   if((woodSupply-donationAmount) > 2000 && kbGetAge() >= cAge4)
	   {
		printEcho("Tributing "+donationAmount+" wood to one of my allies!");
		aiTribute(pID, cResourceWood, donationAmount);
	   }else{
		printEcho("Tributing 100 wood to one of my allies!");
		aiTribute(pID, cResourceWood, 100);
	   }
	}
    }
}

//==============================================================================
// RULE DONATEGold
//==============================================================================
rule DONATEGold
   minInterval 30
   maxInterval 80
   inactive
   Group Donations
{
    if  (aiGetGameMode() != cGameModeConquest && aiGetGameMode() != cGameModeSupremacy)
    {
	xsDisableSelf();
	return;
    }
    for(i=0; < 4)	//Try a few times.
    {
	int pID = 1 + aiRandInt(cNumberPlayers-1);
	float goldSupply = kbResourceGet(cResourceGold);
	if(pID != cMyID && kbIsPlayerAlly(pID) == true && kbIsPlayerResigned(pID) == false && kbHasPlayerLost(pID) == false && goldSupply > 1500)
	{
	   int donationAmount = 100*(aiRandInt(5)+1);
	   if((goldSupply-donationAmount) > 2000 && kbGetAge() >= cAge4)
	   {
		printEcho("Tributing "+donationAmount+" gold to one of my allies!");
		aiTribute(pID, cResourceGold, donationAmount);
	   }else{
		printEcho("Tributing 100 gold to one of my allies!");
		aiTribute(pID, cResourceGold, 100);
	   }
	}
    }
}

//==============================================================================
// Age 3 Handler
//==============================================================================
void age3Handler(int age=2)
{
   printEcho("I'm now in Age "+age+".");
   gLastAgeHandled = cAge3;
   if (cvMaxAge == age)
   {
      printEcho("Suspending age upgrades.");
      aiSetPauseAllAgeUpgrades(true);
   }
   //Econ.
   econAge3Handler(age);
   //Progress.
   progressAge3Handler(age);
   //GP.
   gpAge3Handler(age);
   //Tech.
   handleAge3Upgrades();
   printEcho("  Done with misc handlers.");

    xsEnableRule("goAge4");	//Mythic Age

   if (gBuildTowers == true && gFowardBuildings == false) {
      towerInBase("Age3TowerBuild", false, gTargetNumTowers -  (gTargetNumTowers/(2.0 + (-1.0*cvRushBoomSlider))), cMilitaryEscrowID); // Whatever not done in age 2
   }

   //Disable town defense (in case it's active).
   xsDisableRule("townDefense");
     xsEnableRule("UpdateMainBase");
   //Shorten our walking time by building support buildings at the front.
   xsEnableRule("buildForwardBuildings");

   if((aiGetGameMode() == cGameModeDeathmatch || aiGetGameMode() == cGameModeTreaty) && gFakeDeathmatch == false)
   {
	xsEnableRule("isolationWalls");
   }

   //Run the EM rule.
   updateTargetPop();
	
   //We can trade now.
   xsEnableRule("tradeWithCaravans");

   //Up the number of water transports to maintain.
   if (gMaintainWaterXPortPlanID >= 0)
   {
      aiPlanSetVariableInt(gMaintainWaterXPortPlanID, cTrainPlanNumberToMaintain, 0, 2);
      xsEnableRule("claimRemoteSettlement");
   }

   //Create new greek hero maintain plans.
   if (cMyCulture == cCultureGreek)
   {
      if (cMyCiv == cCivZeus)
	 createSimpleMaintainPlan(cUnitTypeHeroGreekHeracles, 1, false, kbBaseGetMainID(cMyID));
      else if (cMyCiv == cCivPoseidon)
	 createSimpleMaintainPlan(cUnitTypeHeroGreekAtalanta, 1, false, kbBaseGetMainID(cMyID));
      else if (cMyCiv == cCivHades)
	 createSimpleMaintainPlan(cUnitTypeHeroGreekAchilles, 1, false, kbBaseGetMainID(cMyID));

      //Build a fortress and train some catapults.
      if (cvMasterDifficulty != cDifficultyEasy)
      {
	 gSiegeUnitType = cUnitTypePetrobolos;
      }
   }
   else if (cMyCulture == cCultureEgyptian)
   {
      //Build a siege workshop.
      if (cvMasterDifficulty != cDifficultyEasy)
      {
	      int siegeCampPlanID=aiPlanCreate("BuildSiegeCamp", cPlanBuild);
	 if (siegeCampPlanID >= 0)
	 {
	    aiPlanSetVariableInt(siegeCampPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSiegeCamp);
		      aiPlanSetVariableInt(siegeCampPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());
	    aiPlanSetDesiredPriority(siegeCampPlanID, 100);
		      aiPlanAddUnitType(siegeCampPlanID, getBuilderType(), 1, 1, 1);
	    aiPlanSetEscrowID(siegeCampPlanID, cMilitaryEscrowID);
	    aiPlanSetBaseID(siegeCampPlanID, kbBaseGetMainID(cMyID));
	    aiPlanSetActive(siegeCampPlanID);
	 }
	 //Maintain a couple of siege towers.
	 gSiegeUnitType = cUnitTypeSiegeTower;
     }
	xsEnableRule("trainMercs");

      //Set the build limit for Outposts.
      aiSetMaxLOSProtoUnitLimit(9);
   }
   else if (cMyCulture == cCultureNorse)
   {
      if (cvMasterDifficulty != cDifficultyEasy)
	 gSiegeUnitType = cUnitTypePortableRam;

      //Up our Thor dwarf count.
      if (gDwarfMaintainPlanID >= 0)
	 aiPlanSetVariableInt(gDwarfMaintainPlanID, cTrainPlanNumberToMaintain, 0, 6);

	kbUnitPickSetPreferenceFactor(gLandUPID, cUnitTypeAbstractArcher, 0.5);
   }
   else if (cMyCulture == cCultureAtlantean)
   {
      if (cvMasterDifficulty != cDifficultyEasy)
	 gSiegeUnitType = cUnitTypeChieroballista; // For age 3.  We'll use the fire siphon for age 4.
   }
   else if(cMyCulture == cCultureChinese)
   {
	gGardenBuildLimit = 6;

	if (cvMasterDifficulty != cDifficultyEasy)
	{
	    if (cMyCiv == cCivShennong)
	    {
		gSiegeUnitType = cUnitTypeFireLanceShennong;
	    }else{
		gSiegeUnitType = cUnitTypeFireLance;
	    }
	}
   }
   if(cvMasterDifficulty > cDifficultyEasy)
   {
	//We need one to make siege or better units.
	addUnitForecast(getBigBuildingID(), 1);
   }
   if(cvMasterDifficulty > cDifficultyModerate)
   {
		xsEnableRule("buildOtherBaseBuildings");
   }

      // Build a fortress/palace/whatever...or 4 in DM
   int buildingType = -1;
   int numBuilders = -1;
   switch(cMyCulture)
   {
      case cCultureGreek:
	 {
	    buildingType = cUnitTypeFortress;
	    numBuilders = 3;
	    break;
	 }
      case cCultureEgyptian:
	 {
	    buildingType = cUnitTypeMigdolStronghold;
	    numBuilders = 5;
	    break;
	 }
      case cCultureNorse:
	 {
	    buildingType = cUnitTypeHillFort;
	    numBuilders = 2;
	    break;
	 }
      case cCultureAtlantean:
	 {
	    buildingType = cUnitTypePalace;
	    numBuilders = 1;
	    break;
	 }
		case cCultureChinese:
		{
			buildingType = cUnitTypeCastle;
			numBuilders  = 3;
		}
   }
	int strongBuildPlanID=aiPlanCreate("Build Strong Building ", cPlanBuild);
   if (strongBuildPlanID >= 0)
   {
      aiPlanSetVariableInt(strongBuildPlanID, cBuildPlanBuildingTypeID, 0, buildingType);
		aiPlanSetVariableInt(strongBuildPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());
      aiPlanSetDesiredPriority(strongBuildPlanID, 90);
		aiPlanAddUnitType(strongBuildPlanID, getBuilderType(), 1, numBuilders, numBuilders);
      aiPlanSetEscrowID(strongBuildPlanID, cMilitaryEscrowID);
      aiPlanSetBaseID(strongBuildPlanID, kbBaseGetMainID(cMyID));
      aiPlanSetActive(strongBuildPlanID);
   }

   if (cvMasterDifficulty >= cDifficultyNightmare)
   {
	gSiegeUnitReserveSize = 3;
   }
   if (gSiegeUnitType != -1)
   {
      gSiegeReservePlanID = createSimpleMaintainPlan(gSiegeUnitType, gSiegeUnitReserveSize, false, kbBaseGetMainID(cMyID));
   }

   tradeWithCaravans();    // Call to get it going ASAP.
// Real deathmatch is handled in econ file
   //If we're in deathmatch, immediately build some more houses and build a market.  
   if (gFakeDeathmatch == true && (aiGetGameMode() != cGameModeDeathmatch))
   {
      gHardEconomyPopCap=20;
      createSimpleBuildPlan(cUnitTypeHouse, 2, 99, false, false, cEconomyEscrowID, kbBaseGetMainID(cMyID), 2);
	   int marketPlanID=aiPlanCreate("BuildNearbyMarket", cPlanBuild);
      if (marketPlanID >= 0)
      {
	 aiPlanSetVariableInt(marketPlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeMarket);
		   aiPlanSetVariableInt(marketPlanID, cBuildPlanNumAreaBorderLayers, 2, kbGetTownAreaID());
	 aiPlanSetDesiredPriority(marketPlanID, 100);
		   aiPlanAddUnitType(marketPlanID, getBuilderType(), 1, 1, 1);
	 aiPlanSetEscrowID(marketPlanID, cEconomyEscrowID);
	 aiPlanSetBaseID(marketPlanID, kbBaseGetMainID(cMyID));
	 aiPlanSetActive(marketPlanID);
      }
      gExtraMarket = true; // Set the global so we know to look for SECOND market before trading.
   }
}

//==============================================================================
// Age 4 Handler
//==============================================================================
void age4Handler(int age=3)
{
   printEcho("I'm now in Age "+age+".");
   if (cvMaxAge == age)
   {
      printEcho("Suspending age upgrades.");
      aiSetPauseAllAgeUpgrades(true);
   }
   gLastAgeHandled = cAge4;
   //Econ.
   econAge4Handler(age);
   //Progress.
   progressAge4Handler(age);
   //GP.
   gpAge4Handler(age);
   //Tech.
   handleAge4Upgrades();
   printEcho("  Done with misc handlers.");

   if ( (aiGetGameMode() != cGameModeConquest) && (aiGetGameMode() != cGameModeDeathmatch) )
   {
      if (cvMasterDifficulty > cDifficultyEasy || aiRandInt(5) == 0)
      {
	xsEnableRule("makeWonder");      // Make a wonder if you have spare resources
      }
   }

   //Up the number of forward buildings.
   xsSetRuleMinInterval("buildForwardBuildings", 20);

   //Run the EM rule.
   updateTargetPop();

   if(gFakeDeathmatch == false)
   {
	xsEnableRule("isolationWalls");
   }

   //Enable our omniscience rule.
   xsEnableRule("getOmniscience");

   // Double the siege reserve
   if (gSiegeReservePlanID >= 0)
   {
      aiPlanSetVariableInt(gSiegeReservePlanID, cTrainPlanNumberToMaintain, 0, 2*gSiegeUnitReserveSize);
   }

   if (cMyCulture == cCultureAtlantean)   // Change the siege type
   {
      gSiegeUnitType = cUnitTypeFireSiphon;
      aiPlanSetVariableInt(gSiegeReservePlanID, cTrainPlanUnitType, 0, gSiegeUnitType);
      if (cvMasterDifficulty != cDifficultyEasy)
      {
	 createSimpleMaintainPlan(cUnitTypeOnager, 3, false, kbBaseGetMainID(cMyID));
	 createSimpleMaintainPlan(cUnitTypeFireSiphon, 1, false, kbBaseGetMainID(cMyID));
      }
      if (gAge4MinorGod == cTechAge4Helios)
      {
	 // Build us some mirrortowers if we have the skills to do...
	 createSimpleBuildPlan(cUnitTypeTowerMirror, 0, 80, false, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
      }
   }
   if(cMyCulture==cCultureNorse)		//Ballista
   {
      if (cvMasterDifficulty != cDifficultyEasy)
      {
	 createSimpleMaintainPlan(cUnitTypeBallista, 3, false, kbBaseGetMainID(cMyID));
	 createSimpleMaintainPlan(cUnitTypePortableRam, 2, false, kbBaseGetMainID(cMyID));
      }
      gSiegeUnitType = cUnitTypeBallista;
      aiPlanSetVariableInt(gSiegeReservePlanID, cTrainPlanUnitType, 0, gSiegeUnitType);
      if (cvMasterDifficulty > cDifficultyHard)
      {
		xsEnableRule("norseMiniRag");	//transform vills to ulfs.
      }
   }
   if(cMyCulture == cCultureChinese)		//Add a General
   {
      if (cvMasterDifficulty != cDifficultyEasy)
      {
	if (cMyCiv == cCivShennong)
	{
	 createSimpleMaintainPlan(cUnitTypeSittingTigerShennong, 1, false, kbBaseGetMainID(cMyID));
	 createSimpleMaintainPlan(cUnitTypeFireLanceShennong, 7, false, kbBaseGetMainID(cMyID));
	}else{
	 createSimpleMaintainPlan(cUnitTypeSittingTiger, 2, false, kbBaseGetMainID(cMyID));
	 createSimpleMaintainPlan(cUnitTypeFireLance, 5, false, kbBaseGetMainID(cMyID));
	}
      }
      gGardenBuildLimit = 10;
      createSimpleMaintainPlan(cUnitTypeHeroChineseGeneral, 1, false, kbBaseGetMainID(cMyID));
   }
   //Create new greek hero maintain plans.
   if (cMyCulture == cCultureGreek)		//Helepolis + Heroes
   {
      if (cMyCiv == cCivZeus)
      {
	 createSimpleMaintainPlan(cUnitTypeHeroGreekBellerophon, 1, false, kbBaseGetMainID(cMyID));
      }
      else if (cMyCiv == cCivPoseidon)
	 createSimpleMaintainPlan(cUnitTypeHeroGreekPolyphemus, 1, false, kbBaseGetMainID(cMyID));
      else if (cMyCiv == cCivHades)
	 createSimpleMaintainPlan(cUnitTypeHeroGreekPerseus, 1, false, kbBaseGetMainID(cMyID));

      if (cvMasterDifficulty != cDifficultyEasy)
      {
	 createSimpleMaintainPlan(cUnitTypeHelepolis, 1, false, kbBaseGetMainID(cMyID));
	 createSimpleMaintainPlan(cUnitTypePetrobolos, 3, false, kbBaseGetMainID(cMyID));
      }
      gSiegeUnitType = cUnitTypeHelepolis;
      aiPlanSetVariableInt(gSiegeReservePlanID, cTrainPlanUnitType, 0, gSiegeUnitType);
   }
   else if (cMyCulture == cCultureEgyptian)
   {
      //Catapults.
      if (cvMasterDifficulty != cDifficultyEasy)
      {
	 createSimpleMaintainPlan(cUnitTypeCatapult, 2, false, kbBaseGetMainID(cMyID));
	 createSimpleMaintainPlan(cUnitTypeSiegeTower, 1, false, kbBaseGetMainID(cMyID));
      }
      //Set the build limit for Outposts.
      aiSetMaxLOSProtoUnitLimit(11);
      
      //If we're Ra, use a priest to empower our market.
      if (cMyCiv == cCivRa)
      {
	 int ePlanID=aiPlanCreate("Market Empower", cPlanEmpower);
	 if (ePlanID >= 0)
	 {
	    aiPlanSetEconomy(ePlanID, true);
	    aiPlanAddUnitType(ePlanID, cUnitTypePriest, 1, 1, 1);
	    aiPlanSetVariableInt(ePlanID, cEmpowerPlanTargetTypeID, 0, cUnitTypeMarket);
	    aiPlanSetDesiredPriority(ePlanID, 75);
	    aiPlanSetActive(ePlanID);
	 }
      }
      if(gAge4MinorGod == cTechAge4Thoth)
      {
	 int botPID=aiPlanCreate("GetBookOfThoth", cPlanProgression);
	      if (botPID != 0)
	 {
	    aiPlanSetVariableInt(botPID, cProgressionPlanGoalTechID, 0, cTechBookofThoth);
		 aiPlanSetDesiredPriority(botPID, 25);
		 aiPlanSetEscrowID(botPID, cMilitaryEscrowID);
		 aiPlanSetActive(botPID);
	 }
      }
      else if(gAge4MinorGod == cTechAge4Osiris)
      {
	 int nkPID=aiPlanCreate("GetNewKingdom", cPlanProgression);
	      if (nkPID != 0)
	 {
	    aiPlanSetVariableInt(nkPID, cProgressionPlanGoalTechID, 0, cTechNewKingdom);
		 aiPlanSetDesiredPriority(nkPID, 25);
		 aiPlanSetEscrowID(nkPID, cMilitaryEscrowID);
		 aiPlanSetActive(nkPID);
	 }
      }
   }

   // Get speed upgrade
   int tradeUpgradePlanID=aiPlanCreate("coinageUpgrade", cPlanProgression);
   if (tradeUpgradePlanID != 0)   //Econ.
   {
      aiPlanSetVariableInt(tradeUpgradePlanID, cProgressionPlanGoalTechID, 0, cTechCoinage);
      aiPlanSetDesiredPriority(tradeUpgradePlanID, 100);      // Do it ASAP!
      aiPlanSetEscrowID(tradeUpgradePlanID, cEconomyEscrowID);
      aiPlanSetActive(tradeUpgradePlanID);
      printEcho("Getting coinage upgrade.");
   }

   //If we're in deathmatch, no more hard pop cap.
   if (aiGetGameMode() == cGameModeDeathmatch  || (gFakeDeathmatch == true))
   {
      gHardEconomyPopCap=-1;
      kbEscrowAllocateCurrentResources();

      //Always build some towers in Age4 DM
      if (cvOkToBuildTowers && gBuildTowers == false)
      {
	gBuildTowers = true;
	gTargetNumTowers = 5;
      }
   }
      xsEnableRule("buildMirrorTowers");

   // Make a progression to get Titan
   int titanPID=aiPlanCreate("GetTitan", cPlanProgression);
   if (titanPID != 0 && gTransportMap == false)
   {
      aiPlanSetVariableInt(titanPID, cProgressionPlanGoalTechID, 0, cTechSecretsoftheTitans);
	   aiPlanSetDesiredPriority(titanPID, 80);		//was 50
	   aiPlanSetEscrowID(titanPID, cMilitaryEscrowID);
	   aiPlanSetActive(titanPID);
   }
}

//==============================================================================
// Age 5 Handler
//==============================================================================
void age5Handler(int age=4)
{
   printEcho("I'm now in Age "+age+".");
   gLastAgeHandled = cAge5;

   // Just do one thing.. enable the titanplacement rule..
   xsEnableRule("rPlaceTitanGate");

   // Set Escrow back to normal.
   kbEscrowSetCap(cEconomyEscrowID, cResourceFood, 300.0);
   kbEscrowSetCap(cEconomyEscrowID, cResourceWood, 300.0);
   kbEscrowSetCap(cEconomyEscrowID, cResourceGold, 300.0);
   kbEscrowSetCap(cEconomyEscrowID, cResourceFavor, 40.0);
   kbEscrowSetCap(cMilitaryEscrowID, cResourceFood, 700.0);
   kbEscrowSetCap(cMilitaryEscrowID, cResourceWood, 700.0);
   kbEscrowSetCap(cMilitaryEscrowID, cResourceGold, 700.0);
   kbEscrowSetCap(cMilitaryEscrowID, cResourceFavor, 50.0);
}

//==============================================================================
// towerUpgrade
//==============================================================================
rule towerUpgrade
   minInterval 31
   inactive
   runImmediately
{
   //Must be setup for wood before we do any of this.
   if (cMyCulture != cCultureAtlantean)   // A non-issue for Atlanteans...
      if (kbSetupForResource(kbBaseGetMainID(cMyID), cResourceWood, 25.0, 400) == false)
	 return;
      
   //Start upgrading my defenses.
   int pid=aiPlanCreate("towerUpgrade", cPlanProgression);
   if (pid >= 0)
   { 
      aiPlanSetVariableBool(pid, cProgressionPlanRunInParallel, 0, true);
      aiPlanSetDesiredPriority(pid, 30);
		aiPlanSetEscrowID(pid, gTowerEscrowID);
      aiPlanSetBaseID(pid, kbBaseGetMainID(cMyID));
      
      if(cMyCulture == cCultureGreek)
      {
	 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 6, true);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechWatchTower);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechCrenellations);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechSignalFires);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechGuardTower);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechCarrierPigeons);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 5, cTechBoilingOil);
	 aiPlanSetActive(pid);
      }
      else if(cMyCulture == cCultureEgyptian)
      {
	 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 6, true);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechSignalFires);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechCrenellations);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechGuardTower);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechCarrierPigeons);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechBallistaTower);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 5, cTechBoilingOil);
	 aiPlanSetActive(pid);
      }
      else if(cMyCulture == cCultureNorse)
      {
	 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 5, true);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechWatchTower);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechCrenellations);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechSignalFires);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechCarrierPigeons);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechBoilingOil);
	 aiPlanSetActive(pid);
      }
      else if(cMyCulture == cCultureAtlantean)
      {
	 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 6, true);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechWatchTower);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechCrenellations);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechSignalFires);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechGuardTower);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechCarrierPigeons);
	 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 5, cTechBoilingOil);
	 printEcho("**** Activating tower upgrades.");
	 aiPlanSetActive(pid);
      }
	 else if(cMyCulture == cCultureChinese)
	 {
		 aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalTechID, 6, true);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 0, cTechWatchTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 1, cTechCrenellations);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 2, cTechSignalFires);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 3, cTechGuardTower);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 4, cTechCarrierPigeons);
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalTechID, 5, cTechBoilingOil);
		 printEcho("**** Activating tower upgrades.");
		 aiPlanSetActive(pid);
	 }
      else
	 aiPlanDestroy(pid);

      xsDisableSelf();
   }
}

//==============================================================================
// wallUpgrade
//==============================================================================
rule wallUpgrade
   minInterval 30
   inactive
   runImmediately
{
	int techID = cTechStoneWall; //dummy
	int maxUpgrades = 4;

	int modUpgradeID = getModWallUpgradeID();

	if (cMyCulture == cCultureAtlantean)
	{
		if (gWallUpgradeID == 0)
		{
			printEcho("getStoneWall:");
			techID = cTechStoneWall;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 1)
		{
			printEcho("getBronzeWall:");
			techID = cTechBronzeWall;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 2)
		{
			printEcho("getIronWall:");
			techID = cTechIronWall;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 3)
		{
			printEcho("getOreichalkosWall:");
			techID = cTechOreichalkosWall;
			//gWallUpgradeID++;
			maxUpgrades = 4;
		}
	}
	if (cMyCulture == cCultureChinese)
	{
		if (gWallUpgradeID == 0)
		{
			printEcho("getEarthenWall:");
			techID = cTechEarthenWall;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 1)
		{
			printEcho("getStoneWallChinese:");
			techID = cTechStoneWallChinese;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 2)
		{
			printEcho("getFortifiedWall:");
			techID = cTechFortifiedWall;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 3)
		{
			printEcho("getGreatWall:");
			techID = cTechGreatWall;
			//gWallUpgradeID++;
			maxUpgrades = 4;
		}
	}
	if (cMyCulture == cCultureEgyptian)
	{
		if (gWallUpgradeID == 0)
		{
			printEcho("getStoneWall:");
			techID = cTechStoneWall;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 1)
		{
			printEcho("getFortifiedWall:");
			techID = cTechFortifiedWall;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 2)
		{
			printEcho("getCitadelWall:");
			techID = cTechCitadelWall;
			//gWallUpgradeID++;
			maxUpgrades = 3;
		}
	}
	if (cMyCulture == cCultureGreek)
	{
		if (gWallUpgradeID == 0)
		{
			printEcho("getStoneWall:");
			techID = cTechStoneWall;
			//gWallUpgradeID++;
		}else
		if (gWallUpgradeID == 1)
		{
			printEcho("getFortifiedWall:");
			techID = cTechFortifiedWall;
			//gWallUpgradeID++;
			maxUpgrades = 2;
		}
	}
	if (cMyCulture == cCultureNorse)
	{
		if (gWallUpgradeID == 0)
		{
			printEcho("getStoneWall:");
			techID = cTechStoneWall;
			//gWallUpgradeID++;
			maxUpgrades = 1;
		}
	}
	if (modUpgradeID >= 0)	//Mod Support.
	{
		techID = modUpgradeID;
		gWallUpgradeID = gWallUpgradeID + 1;
		maxUpgrades = gWallUpgradeID;
	}
	if (gWallUpgradeID >= maxUpgrades)
	{
		xsDisableSelf();  //wall upgrades done...
	}

    if (kbGetTechStatus(techID) == cTechStatusAvailable)
    {
	gWallUpgradeID++;
	int pid = aiPlanCreate("WallUpgrade", cPlanResearch);
	aiPlanSetVariableInt(pid, cResearchPlanTechID, 0, techID);
	aiPlanSetDesiredPriority(pid, 48);
	aiPlanSetEscrowID(pid, cMilitaryEscrowID);
	aiPlanSetActive(pid);
	printEcho("GettingWallUpgrade"+techID); //new plan
    }
}

//==============================================================================
// RULE: wallsAroundTowers
//==============================================================================
rule wallsAroundTowers
   minInterval 18
   inactive
{
    if (cvOkToBuildWalls == false)	    //Walls are disabled?
    {
	xsDisableSelf();
	return;
    }

    if (cvMasterDifficulty <= cDifficultyHard)
    {
	xsSetRuleMinInterval("removeUnnecessaryChips", 36);
	xsDisableSelf();
	return;
    }

    //Good idea, but a waste of time in the initial phase.
    if(kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive) < 12)
    {
	return;
    }
    int wallProtoID = cUnitTypeWallConnector;
    if(kbResourceGet(cResourceGold) > 80 && kbCanAffordUnit(wallProtoID, cMilitaryEscrowID))
    {
	int towerID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeTower, true);
	if(towerID < 0) { return; }

	vector towerLoc = kbUnitGetPosition(towerID);

	//This tower still needs walls?
	int closeWalls = getUnitsAtLocQID(cMyID, cUnitStateAliveOrBuilding, wallProtoID, towerLoc, 5);
	closeWalls = kbUnitQueryExecute(closeWalls);
	if(kbUnitQueryExecute(closeWalls) < 4)
	{
	   int vilID = findClosestRelTo(towerID, cMyID, cUnitStateAlive, getBuilderType());
	   if(vilID < 0) { return; }

	   //towers have a diameter of 2 (one tile on the grid equals two world meters)
	   vector towerWallA = xsVectorSet(xsVectorGetX(towerLoc)+2,xsVectorGetY(towerLoc),xsVectorGetZ(towerLoc));
	   vector towerWallB = xsVectorSet(xsVectorGetX(towerLoc)-2,xsVectorGetY(towerLoc),xsVectorGetZ(towerLoc));
	   vector towerWallC = xsVectorSet(xsVectorGetX(towerLoc),xsVectorGetY(towerLoc),xsVectorGetZ(towerLoc)+2);
	   vector towerWallD = xsVectorSet(xsVectorGetX(towerLoc),xsVectorGetY(towerLoc),xsVectorGetZ(towerLoc)-2);

	   aiTaskUnitBuild(vilID, wallProtoID, towerWallA);
	   aiTaskUnitBuild(vilID, wallProtoID, towerWallB);
	   aiTaskUnitBuild(vilID, wallProtoID, towerWallC);
	   aiTaskUnitBuild(vilID, wallProtoID, towerWallD);
	}
    }
}

//==============================================================================
// RULE: removeUnnecessaryChips
//==============================================================================
rule removeUnnecessaryChips
minInterval 5
active
{
   int unitTypeID=cUnitTypeWallConnector;
   if(kbUnitCount(cMyID, unitTypeID, cUnitStateAliveOrBuilding) < 1)
   {
	return;		//We don't have any.
   }

   //First, prevent dublicate placement around towers.
   int UnitsFound = kbUnitCount(cMyID, unitTypeID, cUnitStateBuilding);
   for (i=0; < UnitsFound)
   {
	int unitID = findUnitByIndex(cMyID, cUnitStateBuilding, unitTypeID, i);
	vector unitLoc = kbUnitGetPosition(unitID);

	int closeWallsA = getUnitsAtLocQID(cMyID, cUnitStateAlive, unitTypeID, unitLoc, 1);
	closeWallsA = kbUnitQueryExecute(closeWallsA);

	int closeWallsB = getUnitsAtLocQID(cMyID, cUnitStateAlive, unitTypeID, unitLoc, 5);
	closeWallsB = kbUnitQueryExecute(closeWallsB);

	int closeTowers = getUnitsAtLocQID(cMyID, cUnitStateAlive, cUnitTypeTower, unitLoc, 4);
	closeTowers = kbUnitQueryExecute(closeTowers);

	if ( (closeWallsA > 0) || (closeWallsB > 3 && closeTowers < 1) )
	{
				aiTaskUnitDelete(unitID);
	}
   }
   //Also, purge lost wall segments once needed!
   UnitsFound = kbUnitCount(cMyID, unitTypeID, cUnitStateAlive);
   if(UnitsFound > 20)
   {
	unitID = findUnitRM(cMyID, cUnitStateAlive, unitTypeID, true);
	unitLoc = kbUnitGetPosition(unitID);

	closeWallsA = getUnitsAtLocQID(cMyID, cUnitStateAlive, unitTypeID, unitLoc, 5);
	closeWallsA = kbUnitQueryExecute(closeWallsA);

	closeWallsB = getUnitsAtLocQID(cMyID, cUnitStateAlive, cUnitTypeAbstractWall, unitLoc, 5);
	closeWallsB = kbUnitQueryExecute(closeWallsB);

	closeTowers = getUnitsAtLocQID(cMyID, cUnitStateAlive, cUnitTypeTower, unitLoc, 4);
	closeTowers = kbUnitQueryExecute(closeTowers);

	bool notPartOfWall = true;
	if(closeWallsB > 0 && (closeWallsB-closeWallsA) > 0)
	{
		notPartOfWall = false;
	}
	if (notPartOfWall && closeTowers < 1)
	{
			aiTaskUnitDelete(unitID);
	}
   }
}

//==============================================================================
// RULE: removeWallsInGates
//==============================================================================
rule removeWallsInGates
minInterval 8
active
{
   int unitTypeID=cUnitTypeGate;
   int UnitsFound = kbUnitCount(cMyID, unitTypeID, cUnitStateAlive);

   if (UnitsFound < 1)
	return;

   for (i=0; < UnitsFound)
   {
	int unitID = findUnitByIndex(cMyID, cUnitStateAlive, cUnitTypeGate, i);
	vector unitLoc = kbUnitGetPosition(unitID);

	for (k=0; < 4)
	{
				unitTypeID=cUnitTypeWallConnector;
		if (k==1)
				unitTypeID=cUnitTypeWallMedium;
		else if (k==2)
				unitTypeID=cUnitTypeWallShort;
		else if (k==3)
				unitTypeID=cUnitTypeWallLong;

		int QueryID = getUnitsAtLocQID(cMyID, cUnitStateAliveOrBuilding, unitTypeID, unitLoc, 4);
		int BadWalls = kbUnitQueryExecute(QueryID);
		for (j=0; < BadWalls)
		{
			int WallPiece = kbUnitQueryGetResult(QueryID, j);
			if (WallPiece != -1)
			{
				aiTaskUnitDelete(WallPiece);
			}
		}
	}
   }
}

//==============================================================================
// RULE: buildOtherBaseBuildings
//==============================================================================
rule buildOtherBaseBuildings
   minInterval 56
   inactive
{
 if((kbGetAge() < cAge3) || (aiGetPersonality() == "Apocalypse Bot" && kbGetAge() < cAge2))
 {
	return;		//Wait...
 }
 int tcCount = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
   if(tcCount < 2 || cvRandomMapName == "king of the hill")
   {
	return;		//We don't have an other base yet.
   }

   int count=-1;
   static int milBaseQueryID=-1;

   //If we don't have the query yet, create one.
   if (milBaseQueryID < 0)
      milBaseQueryID=kbUnitQueryCreate("selectMilitaryBaseQuery");
   
	//Define a query to get all matching units
	if (milBaseQueryID == -1)
	{
		return;
	}
		kbUnitQuerySetPlayerID(milBaseQueryID, cMyID);
      kbUnitQuerySetUnitType(milBaseQueryID, cUnitTypeAbstractSettlement);
      kbUnitQuerySetState(milBaseQueryID, cUnitStateAlive);

   kbUnitQueryResetResults(milBaseQueryID);
	int numberFound=kbUnitQueryExecute(milBaseQueryID);

   //Alright, We have our query. Now find the best spot!

	vector LocA = kbUnitGetPosition(gMainBaseID);
	int ax = xsVectorGetX(LocA);
	int ay = xsVectorGetY(LocA);
	int az = xsVectorGetZ(LocA);

   int furthestID = -1;
   int maxLength = -1;

   for (i=0; < numberFound)
   {
	vector LocB = kbUnitGetPosition(kbUnitQueryGetResult(milBaseQueryID, i));
	int bx = xsVectorGetX(LocB);
	int by = xsVectorGetY(LocB);
	int bz = xsVectorGetZ(LocB);

	int temp = xsVectorLength(xsVectorSet(ax-bx,ay-by,az-bz));

	//Compare.
	if(temp > maxLength)
	{
		maxLength = temp;
		furthestID = kbUnitQueryGetResult(milBaseQueryID, i);
	}
   }
   if(gMilBaseID == -1)	//assign something to make it work.
   {
	gMilBaseID = gMainBaseID;
   }
   int oldMilBaseID = gMilBaseID;  //Only once per base...
   gMilBaseID = kbUnitGetBaseID(furthestID);
   //kbSetForwardBasePosition(kbUnitGetPosition(gMilBaseID));

   if(gMilBaseID != oldMilBaseID)   //Let's setup our plan!
   {
   //gWallBaseID = gMilBaseID;
   //gMainBaseAreaWallRadius = 20;
   int numBuilders = 0;
   int bigBuildingType = 0;
   int littleBuildingType = 0;

   switch(cMyCulture)		// Add 2 extra big buildings and 3 little buildings
   {
	 case cCultureGreek:
	    {
	       bigBuildingType = cUnitTypeFortress;
	       numBuilders = 3;
	       createSimpleBuildPlan(cUnitTypeBarracks, 1, 80, true, false, cMilitaryEscrowID, gMilBaseID, 1);
	       createSimpleBuildPlan(cUnitTypeStable, 1, 80, true, false, cMilitaryEscrowID, gMilBaseID, 1);
	       createSimpleBuildPlan(cUnitTypeArcheryRange, 1, 80, true, false, cMilitaryEscrowID, gMilBaseID, 1);
	       break;
	    }
	 case cCultureEgyptian:
	    {
	       bigBuildingType = cUnitTypeMigdolStronghold;
	       numBuilders = 5;
	       createSimpleBuildPlan(cUnitTypeBarracks, 3, 80, true, false, cMilitaryEscrowID, gMilBaseID, 2);
	       break;
	    }
	 case cCultureNorse:
	    {
	       bigBuildingType = cUnitTypeHillFort;
	       numBuilders = 2;
	       createSimpleBuildPlan(cUnitTypeLonghouse, 3, 80, true, false, cMilitaryEscrowID, gMilBaseID, 2);
	       break;
	    }
	 case cCultureAtlantean:
	    {
	       bigBuildingType = cUnitTypePalace;
	       numBuilders = 1;
	       createSimpleBuildPlan(cUnitTypeBarracksAtlantean, 2, 80, true, false, cMilitaryEscrowID, gMilBaseID, 1);
	       createSimpleBuildPlan(cUnitTypeCounterBuilding, 1, 80, true, false, cMilitaryEscrowID, gMilBaseID, 1);
	       break;
	    }
	 case cCultureChinese:
	    {
	       bigBuildingType = cUnitTypeCastle;
	       numBuilders = 3;
	       createSimpleBuildPlan(cUnitTypeBarracksChinese, 1, 80, true, false, cMilitaryEscrowID, gMilBaseID, 1);
	       createSimpleBuildPlan(cUnitTypeStableChinese, 2, 80, true, false, cMilitaryEscrowID, gMilBaseID, 1);
	       break;
	    }
      }
      createSimpleBuildPlan(bigBuildingType, 2, 80, true, false, cMilitaryEscrowID, gMilBaseID, numBuilders);
      createSimpleBuildPlan(cUnitTypeTemple, 1, 80, true, false, cMilitaryEscrowID, gMilBaseID, 1);

   }	//Done.
}

//==============================================================================
// Rule: UpdateMainBase
//==============================================================================
rule UpdateMainBase
 inactive
 minInterval 75		//was 105
{
 bool baseUpdate = false;	//Do we have something to update?

 int tcCount = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
 int newTC = findUnitRM(cMyID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement, false);
 if(newTC <= 0)		//Nothing found.
 {
	return;
 }
 vector newTcLoc = kbUnitGetPosition(newTC);
 if(gMainBaseID < 0)	//This is the first time we get here.
 {
	gMainBaseID = newTC;
	gWallBaseID = newTC;

	gMainBaseLoc = newTcLoc;
 }
 //Do I need a new Mainbase?
 if (gMainBaseLoc != newTcLoc && tcCount < 1)   //Is it new and the only one I have?
 {
	//For this it's crucial that we do not switch as long as it's the same spot.
	//It seems ID's can shift sometimes - therefore we go by location now.
	printEcho("changeMainBase");
	kbBaseDestroy(cMyID, gMainBaseID);		//might cancel tc in progress?
	aiSwitchMainBase(kbUnitGetBaseID(newTC),true);
	kbBaseSetMain(cMyID, kbUnitGetBaseID(newTC),true);
	kbSetTownLocation(kbUnitGetPosition(newTC));
	gMainBaseID = newTC;
	gMainBaseLoc = newTcLoc;
	gWallBaseID = newTC;		//wall my new main base!

	baseUpdate = true;	//Do it.

 }
 else if(tcCount >= 1)		//Ok, can I find a new wallbase instead then?
 {
	newTC = findUnitRM(cMyID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement, true);
	if (gWallBaseID != newTC)   //is it really new?
	{
	    printEcho("protectOuterBase");	//prepare this base for a switch
	    gWallBaseID = newTC;		//upgrade defense

	    if(gWallBaseID != gMainBaseID)
	    {
		baseUpdate = true;	//Do it.
	    }
	}
 }
//------------------------------------------------------------------------------
 if(baseUpdate == true)			//Now for the upgrades...
 {
      if (cvOkToBuildWalls)
      {
	printEcho("We try to build some walls now.");
    	gBuildWalls = true;				//More safety first!!!
	gMainBaseAreaWallRadius = 20;		//was 26
      }

   // Build a fortress/palace/whatever... just keep it up.
   int buildingType = -1;
   int numBuilders = -1;
   switch(cMyCulture)
   {
      case cCultureGreek:
	 {
	    buildingType = cUnitTypeFortress;
	    numBuilders = 3;
	    break;
	 }
      case cCultureEgyptian:
	 {
	    buildingType = cUnitTypeMigdolStronghold;
	    numBuilders = 5;
	    break;
	 }
      case cCultureNorse:
	 {
	    buildingType = cUnitTypeHillFort;
	    numBuilders = 2;
	    break;
	 }
      case cCultureAtlantean:
	 {
	    buildingType = cUnitTypePalace;
	    numBuilders = 1;
	    break;
	 }
      case cCultureChinese:
	 {
	    buildingType = cUnitTypeCastle;
	    numBuilders = 3;
	    break;
	 }
   }
   //don't build it just yet if it's behind our main base.
   int wallbaseDistance=xsVectorLength(kbGetMapCenter()-kbUnitGetPosition(gWallBaseID));
   int mainbaseDistance=xsVectorLength(kbGetMapCenter()-kbUnitGetPosition(gMainBaseID));
   if(kbCanAffordUnit(buildingType, cMilitaryEscrowID) && wallbaseDistance < mainbaseDistance)
   {
	int strongBuildPlanID=aiPlanCreate("Build Strong Building ", cPlanBuild);
     if (strongBuildPlanID >= 0)
     {
      int mainAreaID = kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gWallBaseID));
      aiPlanSetVariableInt(strongBuildPlanID, cBuildPlanBuildingTypeID, 0, buildingType);
		aiPlanSetVariableInt(strongBuildPlanID, cBuildPlanNumAreaBorderLayers, 2, mainAreaID);
      aiPlanSetDesiredPriority(strongBuildPlanID, 90);
		aiPlanAddUnitType(strongBuildPlanID, getBuilderType(), 1, numBuilders, numBuilders);
      aiPlanSetEscrowID(strongBuildPlanID, cMilitaryEscrowID);
      aiPlanSetBaseID(strongBuildPlanID, kbBaseGetMainID(cMyID));
      aiPlanSetActive(strongBuildPlanID);
     }
   }
      if (cvOkToBuildTowers && gBuildTowers == false)
      {
	 gBuildTowers = true;
	 gTargetNumTowers = 2;

	 if (kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAlive) > 3)
	 {
		xsEnableRule("towerUpgrade");
	 }
      }
	//This should be enough to do at the moment...
//------------------------------------------------------------------------------
  }else{
      //Still the same? Just check the radius.
      gMainBaseAreaWallRadius = 32.0 - (11.0*cvOffenseDefenseSlider);
      if(cvRandomMapName == "sudden death" && gMainBaseAreaWallRadius < 34)
      {
		gMainBaseAreaWallRadius = 34;
      }
      printEcho("keepMainBase");
 }
	//Always figure out the front vector.
	vector settlementPosition=kbUnitGetPosition(newTC);
	vector baseFront=xsVectorNormalize(kbGetMapCenter()-settlementPosition);
	kbBaseSetFrontVector(cMyID, kbUnitGetBaseID(newTC), baseFront);
	//Military gather point.
	kbBaseSetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID), gMilitaryGatherPoint);

   printEcho("MainBase update done");
}

//==============================================================================
// RULE: Train Gatherers
//==============================================================================
rule trainGatherers
   minInterval 15
   group MaintainRules
   inactive
   runImmediately
{
    if ( (aiGetGameMode() == cGameModeDeathmatch) && (xsGetTime() < 60*8*1000) )
    {
	return;		//DM needs no more yet.
    }
    if (kbGetPop()+2 > kbGetPopCap())
    {
	return;		//Overshoot - don't queue any more.
    }
    //Hack to queue villagers from multiple(!) bases.
    int numTC = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    if(numTC < 1 || getGathererType() < 0)
    {
	return;		//Not enough TC's or no valid ID.
    }
    if(kbGetAge() == cAge1 && kbResourceGet(cResourceFood) > 350)
    {
	return;		//Prioritize Age-Up!
    }
    if(numTC < 2 && kbGetTechStatus(gAge2MinorGod) == cTechStatusResearching)
    {
	return;		//Not now, please.
    }
    int customInterval = ( kbProtoUnitGetTrainPoints( getGathererType(0) )+1);
    xsSetRuleMinIntervalSelf(customInterval);
    if(kbGetAge() >= cAge2 && (cMyCulture == cCultureGreek || cMyCulture == cCultureChinese))
    {
	int rangedHeroID = -1;

	if(gNewCivMod == false)
	{
	    if(cMyCiv == cCivZeus)
	    {
		rangedHeroID = cUnitTypeHeroGreekOdysseus;
	    }
	    if(cMyCiv == cCivPoseidon)
	    {
		rangedHeroID = cUnitTypeHeroGreekHippolyta;
	    }
	    if(cMyCiv == cCivHades)
	    {
		rangedHeroID = cUnitTypeHeroGreekChiron;
	    }
	    if(cMyCulture == cCultureChinese)
	    {
		rangedHeroID = cUnitTypeHeroChineseImmortal;
	    }
	}
	if(rangedHeroID >= 0)	//Egyptian and Norse can train in temple.
	{
	    if(kbCanAffordUnit(rangedHeroID, cMilitaryEscrowID) && kbUnitCount(cMyID, rangedHeroID, cUnitStateAlive) < 1)
	    {
		//Make sure we have the chance to get at least one hero of any kind.
		if(cMyCulture == cCultureGreek && kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive) < 2)
		{
			return;		//Don't block the queue until we have two.
		}else
		if(kbUnitCount(cMyID, cUnitTypeHero, cUnitStateAlive) < 1)	//Chinese.
		{
			return;		//Don't block the queue until we have one.
		}
	    }
	}
    }else
    if(cMyCulture == cCultureNorse && kbUnitCount(cMyID, cUnitTypeOxCart, cUnitStateAlive) < 2)
    {
		return;		//We need an empty queue for oxcarts!
    }
    int tcQueryID=kbUnitQueryCreate("findTcQuery");
    kbUnitQuerySetPlayerID(tcQueryID, cMyID);
    kbUnitQuerySetUnitType(tcQueryID, cUnitTypeAbstractSettlement);
    kbUnitQuerySetState(tcQueryID, cUnitStateAlive);
    kbUnitQuerySetActionType(tcQueryID, cActionIdle);

    kbUnitQueryResetResults(tcQueryID);
    int numberFound=kbUnitQueryExecute(tcQueryID);

    int currentVilPop = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
    for(i=0; < numberFound)
    {
	int futureVilPop = currentVilPop+(i+1);
	if(futureVilPop < gMaxVilPop)	//global is set with updateEM
	{
	    int myTC = kbUnitQueryGetResult(tcQueryID, i);
	    aiTaskUnitTrain(myTC, getGathererType());
	}else{
		break;		//Don't train more.
	}
    }
}

//==============================================================================
// RULE: TrainFishingShips
//==============================================================================
rule TrainFishingShips
   minInterval 20
   group MaintainRules
   inactive
   runImmediately
{
    if(gFishMap == false)	//Don't fish!
    {
	xsDisableSelf();
	return;
    }
    if (kbGetPop()+1 > kbGetPopCap())
    {
	return;		//Overshoot - don't queue any more.
    }

    int myDock = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeDock, true);
    int areaID = kbAreaGetClosetArea(kbUnitGetPosition(myDock), cAreaTypeWater);

    int fishQueryID = kbUnitQueryCreate("findFishQuery");

    if(fishQueryID < 0)
	return;

    kbUnitQuerySetPlayerID(fishQueryID, 0);
    kbUnitQuerySetUnitType(fishQueryID, cUnitTypeFish);
    kbUnitQuerySetState(fishQueryID, cUnitStateAlive);
    kbUnitQuerySetAreaID(fishQueryID, areaID);
    kbUnitQueryResetResults(fishQueryID);

    int fishCount = kbUnitQueryExecute(fishQueryID);
    int maxNumBoatsInArea = gNumBoatsToMaintain;
    if (maxNumBoatsInArea > fishCount && fishCount >= 0)
    {
	maxNumBoatsInArea = fishCount;
    }

    //Get our fish gatherer.
    int fishGatherer=kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionFish,0);
    int globalShips = kbUnitCount(cMyID, fishGatherer, cUnitStateAlive);
    if(
	kbCanAffordUnit(fishGatherer, cEconomyEscrowID)
	&& globalShips < maxNumBoatsInArea
	&& globalShips < gNumBoatsToMaintain
      )
    {
	aiTaskUnitTrain(myDock, fishGatherer);
	xsSetRuleMinIntervalSelf(4);
    }else{
		xsSetRuleMinIntervalSelf(20);
    }
}

//==============================================================================
// RULE: Train Mercs
//==============================================================================
rule trainMercs
minInterval 18
inactive
{
    if (xsGetTime() < 5*60*1000 && kbResourceGet(cResourceGold) > 500)
    {
	return;		//don't risk to lose so much gold.
    }
    int numSettles = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
    for (i=0; < numSettles)
    {
	int settleID = findUnitByIndex(cMyID, cUnitStateAlive, cUnitTypeAbstractSettlement, i);
	int settleBaseID = kbUnitGetBaseID(settleID);
		
	int numberEnemyUnits = kbBaseGetNumberUnits(cMyID, settleBaseID, cPlayerRelationEnemy, cUnitTypeLogicalTypeLandMilitary);
	int numberAlliedUnits = kbBaseGetNumberUnits(cMyID, settleBaseID, cPlayerRelationAlly, cUnitTypeLogicalTypeLandMilitary);
	int numberMyUnits = kbBaseGetNumberUnits(cMyID, settleBaseID, cPlayerRelationSelf, cUnitTypeLogicalTypeLandMilitary);
		
	int secondsUnderAttack = kbBaseGetTimeUnderAttack(cMyID, settleBaseID);
	if (secondsUnderAttack > 10)
	{
	    //Destroy the plan if there are twice as many enemies as my units plus allied units
	    if ((numberEnemyUnits > 2 * (numberAlliedUnits + numberMyUnits)) && (numberEnemyUnits > 2))
	    {
		//float goldSupply = kbResourceGet(cResourceGold);
		int numMercs = numberEnemyUnits / 3;
		if (numMercs > 3)	{numMercs = 3;}
		if (gGlutRatio > 1.5)	{numMercs = numberEnemyUnits;}
		if (numMercs > 12)	{numMercs = 12;}
		int MercInf = createSimpleTrainPlan(cUnitTypeMercenary, numMercs, false, settleBaseID, 20*1000);
		if ((gGlutRatio > 1.5) && (aiRandInt(3) == 0))
		{
			int MercCav = createSimpleTrainPlan(cUnitTypeMercenaryCavalry, 2, false, settleBaseID, 20*1000);
		}
	    }
	}
    }
}

//==============================================================================
// makeAtlanteanHeroes
//==============================================================================
rule makeAtlanteanHeroes
   minInterval 127
   active
{
   if (cMyCulture != cCultureAtlantean)
   {
      xsDisableSelf();
      return;
   }
   if ( kbResourceGet(cResourceFavor) < 60 )
      return;

   if (gDefendPlanID < 0)
      return;  // No defend plan units to upgrade

   int numUnits = aiPlanGetNumberUnits(gDefendPlanID, cUnitTypeLogicalTypeLandMilitary);
   printEcho("***** Defend plan ("+gDefendPlanID+") has "+numUnits+" units.");

   if (numUnits < 4)
      return;

   // The defend plan has at least 4 units, and we have at least 50 favor.  Let's try to uprade a bunch of them
   int firstIndex = aiRandInt(1 + (numUnits-4));   // Rand int from 0 to numInts-5
   int unit = -1;
   int i=0;
   for (i=firstIndex; < (firstIndex+4))
   {
      unit = aiPlanGetUnitByIndex(gDefendPlanID, i);
      if(
	    kbUnitGetCurrentHitpoints(unit)>=kbUnitGetMaximumHitpoints(unit)
	    ||
	    kbGetTechStatus(cTechHeroicRenewal) >= cTechStatusResearching
	)
      {
	aiTaskUnitTransform(unit);
      }
   }

}

//==============================================================================
// makeAtlanteanVillagerHeroes - maintain 3 villager heroes for atlantean on lightning
//==============================================================================
// 225/45/3
rule makeAtlanteanVillagerHeroes
   minInterval 36
   active
{
   if ( (cMyCulture != cCultureAtlantean)
	||
	(aiGetGameMode() != cGameModeLightning && aiGetGameMode() != cGameModeDeathmatch)
      )
   {
      xsDisableSelf();
      return;
   }

   if (kbUnitCount(cMyID, cUnitTypeVillagerAtlanteanHero, cUnitStateAlive) >= 2)
      return;     // At max

   if ( (kbResourceGet(cResourceFood)<225) || (kbResourceGet(cResourceWood)<45) || (kbResourceGet(cResourceFavor)<3) )
      return;     // Can't afford it

   int villagerID = findUnit(cMyID, cUnitStateAlive, cUnitTypeVillagerAtlantean);
   if (villagerID >= 0)
   {
      printEcho("Upgrading atlantean villager "+villagerID+" to hero status for lightning mode.");
      aiTaskUnitTransform(villagerID);
   }
}

//==============================================================================
// makeOracleHero
//==============================================================================
rule makeOracleHero
   minInterval 65
   inactive
{
   if (kbUnitCount(cMyID, cUnitTypeOracleHero, cUnitStateAlive) > 0)
      return;     // Already have a hero

   if (kbUnitCount(cMyID, cUnitTypeOracleScout, cUnitStateAlive) < 1)
      return;     // No oracles to upgrade

   int targetUnit = findUnit(cMyID, cUnitStateAliveOrBuilding, cUnitTypeOracleScout);
   if (targetUnit < 0)
      return;  // failed

   aiTaskUnitTransform(targetUnit); // Become a hero
   printEcho("***** Attempting to upgrade oracle "+targetUnit+" to hero status.");
}

//==============================================================================
// periodicSaveGames
//==============================================================================
rule periodicSaveGames
   minInterval 5
   active
{
   //Dont save if we are told not to.
   if (aiGetAutosaveOn() == false)
   {
      xsDisableSelf();
      return;
   }

   int firstCPPlayerID = -1;
   for(i=1; < cNumberPlayers)
   {
      if(kbIsPlayerHuman(i) == true)
	 continue;

      firstCPPlayerID = i;
   }
   if (cMyID != firstCPPlayerID)
      return;

   //Create the savegame name.
   static int psCount=0;
   //Save it.
   if (cvDoAutoSaves == true)
   {
      aiQueueAutoSavegame(psCount);
      //Inc our count.
      psCount=psCount+1;
   }

   //After the first time, set it to every five minutes.
   xsSetRuleMinIntervalSelf(300);
}

//==============================================================================
// towerInBase
//==============================================================================
void towerInBase(string planName="BUG", bool los = true, int numTowers = 6, int escrowID=-1)
{
   printEcho("Starting plan to build "+numTowers+" towers.");
   int baseID = kbBaseGetMainID(cMyID);
   int planID=aiPlanCreate(planName, cPlanTower);
   if (planID >= 0)
   {

      //Save the escrow ID.
      if (escrowID == -1)
	 escrowID = cMilitaryEscrowID;
      gTowerEscrowID=escrowID;

      float spacing = 0.9;
      if (kbGetAge() > cAge2)
	 spacing = 1.8;
      aiPlanSetVariableFloat(planID, cTowerPlanDistanceFromCenter, 0, 120.0);    // Absolute max?

      aiPlanSetVariableVector(planID, cTowerPlanCenterLocation, 0, kbBaseGetLocation(cMyID, baseID) );
      if(los == true)
      {
	 aiPlanSetVariableBool(planID, cTowerPlanMaximizeLOS, 0, true);
	 aiPlanSetVariableBool(planID, cTowerPlanMaximizeAttack, 0, false);
	 aiPlanSetVariableFloat(planID, cTowerPlanLOSModifier, 0, spacing);
	 aiPlanSetVariableFloat(planID, cTowerPlanAttackLOSModifier, 0, spacing);
      }
      else
      {
	 aiPlanSetVariableBool(planID, cTowerPlanMaximizeLOS, 0, false);
	 aiPlanSetVariableBool(planID, cTowerPlanMaximizeAttack, 0, true);
	 aiPlanSetVariableFloat(planID, cTowerPlanAttackLOSModifier, 0, spacing);
	 aiPlanSetVariableFloat(planID, cTowerPlanLOSModifier, 0, spacing);
      }
      
      aiPlanSetVariableInt(planID, cTowerPlanNumberToBuild, 0, numTowers);
      aiPlanSetVariableInt(planID, cTowerPlanProtoIDToBuild, 0, cUnitTypeTower);
      
      aiPlanSetDesiredPriority(planID, 100);
      aiPlanSetEscrowID(planID, gTowerEscrowID);
      aiPlanSetBaseID(planID, baseID);
      aiPlanSetActive(planID);
   }
}

//==============================================================================
// ShouldIResign
//==============================================================================
rule ShouldIResign
   minInterval 7
   active
{
   if(cvOkToResign == false)
   {
      xsDisableSelf();     // Must be re-enabled if cvOkToResign is set true.
      return;
   }
   if(aiIsMultiplayer() == true)	//Simple resign rules for MP games.
   {
      bool mpResign = true;

      for(i=1; < cNumberPlayers)	//We still have an active human ally?
      {
	if (kbIsPlayerMutualAlly(i) && kbIsPlayerHuman(i) && kbIsPlayerResigned(i)==false && kbHasPlayerLost(i)==false)
	{
	    if(kbUnitCount(i, cUnitTypeAbstractSettlement, cUnitStateAlive) > 0)
	    {
		mpResign = false;
	    }
	}
      }
      int checkSettlements = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive);
      if(mpResign && checkSettlements < 1)	//There is no way to come back?
      {
	int checkMilitary = kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive);
	int checkVillagers = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);
	if(cMyCulture == cCultureAtlantean)
	{
		checkVillagers = checkVillagers * 3;
	}
	if(
	    (cMyCulture == cCultureNorse && checkMilitary > 20 && checkVillagers > 5)
	    ||
	    (cMyCulture != cCultureNorse && checkMilitary > 10 && checkVillagers > 15)
	  )
	{
		mpResign = false;
	}
      }else{
		mpResign = false;
      }
      //Nomad gets some extra time to hold on.
      if(gNomadMap && xsGetTime() < 8*60*1000)
      {
		mpResign = false;
      }
      if(mpResign && xsGetTime() > 5*60*1000)	//Stay in the game for at least 5 minutes!
      {
	if(cvOkToChat == true)
	{
		//aiSendChatToEveryone("gg");
		//aiChat(aiGetMostHatedPlayerID(),"wp");
	}
		aiResign();		//Done.
		xsDisableSelf();
      }
      return;
   }

   //Singleplayer Resign
   //------------------------------------------------------

   //Don't resign if you're teamed with a human.
   static bool checkTeamedWithHuman=true;
   if (checkTeamedWithHuman == true)
   {
      for (i=1; < cNumberPlayers)
      {
	 if (i == cMyID)
	    continue;
	 //Skip if not human.
	 if (kbIsPlayerHuman(i) == false)
	    continue;
	 //If this is a mutually allied human, go away.
	 if (kbIsPlayerMutualAlly(i) == true)
	 {
	    xsDisableSelf();
	    return;
	 }
      }
      //Don't check again.
      checkTeamedWithHuman=false;
   }

   //Don't resign too soon.
   if (xsGetTime() < 600000)	//10 min.
     return;

   int numSettlements=kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
   int builderUnitID=getBuilderType();
   int numBuilders=kbUnitCount(cMyID, builderUnitID, cUnitStateAliveOrBuilding);

   //If on easy, don't only resign if you have no settlements.
   if (cvMasterDifficulty == cDifficultyEasy)
   {
      if (numSettlements > 0 || (numBuilders > 0 && kbCanAffordUnit(cUnitTypeSettlementLevel1, cEconomyEscrowID)) )
      {
	      return;	//Check again
      }
   }

   //If below hard, don't only resign if you have no pop.
   if (cvMasterDifficulty <= cDifficultyModerate)
   {
	//Trade is not relevant here unless we still have a tc.
	int numTrade = kbUnitCount(cMyID, cUnitTypeAbstractTradeUnit, cUnitStateAlive);

	//Don't resign if we have over 30 active pop slots.
	if (
	    (kbGetPop() >= (30+numTrade) && numSettlements < 1)
	    ||
	    (kbGetPop() >= 40 && numSettlements > 0)
	   )
	{
	      return;	//Check again
	}
   }

   //If below nightmare, don't only resign if you are alone.
   if (cvMasterDifficulty <= cDifficultyHard)
   {
	if(numSettlements > 2 || kbGetPop() >= (70+numTrade))
	{
	      return;	//Check again
	}
   }

   //------------------------------------------------------

   //1. If we don't have any builders, we're not Norse, and we cannot afford anymore, try to resign.
   if ((numBuilders <= 0) && (cMyCulture != cCultureNorse))
   {
      if (kbCanAffordUnit(builderUnitID, cEconomyEscrowID) == false)
      {
	printEcho("Resign: numBuilders("+numBuilders+")");
	gResignType=cResignGatherers;
	aiAttemptResign(cAICommPromptResignQuestion);	//Ask the player - Yes/No?

	xsDisableSelf();	//continue.
	return;
      }
   }

   //2. If we lost all our settlements and aren't supposed to rebuild them.
   if (numSettlements <= 0 && cvRandomMapName != "sudden death")
   {
	printEcho("Resign: numSettlements("+numSettlements+"): numBuilders("+numBuilders+")");
	gResignType = cResignSettlements;
	aiAttemptResign(cAICommPromptResignQuestion);	//Ask the player - Yes/No?

	xsDisableSelf();	//continue.
	return;
   }

   //3. If all of my teammates have left the game.
   int activeEnemies=0;
   int activeTeammates=0;
   int deadTeammates=0;
   float currentEnemyMilPop=0.0;
   float currentMilPop=0.0;
   for (i=1; < cNumberPlayers)
   {
      if (i == cMyID)
      {
	 currentMilPop=currentMilPop+kbUnitCount(i, cUnitTypeMilitary, cUnitStateAlive);
	 continue;
      }

      if (kbIsPlayerAlly(i) == false)
      {
	 //Increment the active number of enemies there currently are.
	 if (kbIsPlayerResigned(i) == false)
	 {
	    activeEnemies=activeEnemies+1;
	    currentEnemyMilPop=currentEnemyMilPop+kbUnitCount(i, cUnitTypeMilitary, cUnitStateAlive);
	 }
	 continue;
      }
     
      //If I still have an active teammate, don't resign.
      //Only count as active, if he has at least one tc left!
      if (kbIsPlayerResigned(i) == false && kbUnitCount(i, cUnitTypeAbstractSettlement, cUnitStateAlive) > 0)
      {
	 activeTeammates=activeTeammates+1;
       }else{
	 deadTeammates=deadTeammates+1;
      }
   }
   //  I am the only player left on my team and at least one teammate died, 
   //  and the other team(s) have 2 or more players in the game.
   if ((activeEnemies >= 2) && (activeTeammates <= 0) && (deadTeammates > 0) && (numSettlements < 5))
   {
      printEcho("Resign: activeEnemies ("+activeEnemies +"): activeTeammates ("+activeTeammates +"), deadTeammates ("+deadTeammates +")");
      gResignType=cResignTeammates;
      aiAttemptResign(cAICommPromptResignQuestion);	//Ask the player - Yes/No?

      xsDisableSelf();		//continue.
      return;
   }
   
   //4. my mil pop is low and the enemy's mil pop is high,
   //Don't do this eval until 4th age and at least 30 min. into the game.
   if ((xsGetTime() < 1800000) || (kbGetAge() < 3))
     return;
   
   static float enemyMilPopTotal=0.0;
   static float myMilPopTotal=0.0;
   static float count=0.0;
   count=count+1.0;
   enemyMilPopTotal=enemyMilPopTotal+currentEnemyMilPop;
   myMilPopTotal=myMilPopTotal+currentMilPop;
   if (count >= 10.0)
   {
      if ((enemyMilPopTotal > (7.0*myMilPopTotal)) || (myMilPopTotal <= count))
      {
	 printEcho("Resign: Count("+count+"): EMP Total("+enemyMilPopTotal+"), MMP Total("+myMilPopTotal+")");
	 printEcho("Resign: EMP Current("+currentEnemyMilPop+"), MMP Current("+currentMilPop+")");
	
	 gResignType=cResignMilitaryPop;
	 aiAttemptResign(cAICommPromptResignQuestion);	//Ask the player - Yes/No?

	 xsDisableSelf();	//continue.
	 return;
      }

      count=0.0;
      enemyMilPopTotal=0.0;
      myMilPopTotal=0.0;
   }
}

//==============================================================================
// resignTimer
//==============================================================================
rule resignTimer
   minInterval 60
   inactive
{
   //This rule turns the resign rule back on after a bit of time.
   //Used when the human player refuses to allow quarter

   static bool bFirstUpdate=false;
   if (bFirstUpdate == false)
   {
      bFirstUpdate=true;
      return;
   }
   xsEnableRule("ShouldIResign");
}

//==============================================================================
// lateFindMainland
//==============================================================================
rule lateFindMainland
   inactive
   minInterval 50
{
   if (kbUnitCount(cMyID, cUnitTypeTransport, cUnitStateAlive) >= 1)
   {
      //Enable the rule that looks for the mainland.
      xsEnableRule("findVinlandsagaBase");
      // Move the transport toward map center to find continent quickly.
      int transportID = findUnit(cMyID, cUnitStateAlive, cUnitTypeTransport);
      vector nearCenter = kbGetMapCenter();
      nearCenter = (nearCenter + kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) / 2.0;    // Halfway between start and center
      nearCenter = (nearCenter + kbGetMapCenter()) / 2.0;   // 3/4 of the way to map center
      aiTaskUnitMove(transportID, nearCenter);
      printEcho("Sending transport "+transportID+" to near map center at "+nearCenter);
      xsEnableRule("vinlandsagaFailsafe");  // In case something prevents transport from reaching, turn on the explore plan.
      xsDisableSelf();	//Finally
   }
}

//==============================================================================
// findVinlandsagaBase
//==============================================================================
rule findVinlandsagaBase
   minInterval 2
   inactive
{
   //Save our initial base ID.
   gVinlandsagaInitialBaseID=kbBaseGetMainID(cMyID);

   //Get our initial location.
   vector location=kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));

   //Find the mainland area group.
   int mainlandGroupID=kbAreaGroupGetIDByPosition(kbUnitGetPosition(findIsolatedSettlement()));
   if (mainlandGroupID < 0)
   {
	if (cvRandomMapName == "vinlandsaga")
	    mainlandGroupID=kbFindAreaGroup(cAreaGroupTypeLand, 3.0, kbAreaGetIDByPosition(location));
	else
	    mainlandGroupID=kbFindAreaGroupByLocation(cAreaGroupTypeLand, 0.5, 0.5);  // Can fail if mountains at map center
	//  mainlandGroupID=kbFindAreaGroup(cAreaGroupTypeLand, 1.2, kbAreaGetIDByPosition(location));   // Instead, look for one 20% larger than start area group.
   }
   if (mainlandGroupID < 0) {return;}
   printEcho("findVinlandsagaBase: Found the mainland, AGID="+mainlandGroupID+".");

   // stop the transport right away
   int transportID = findUnit(cMyID, cUnitStateAlive, cUnitTypeTransport);
   printEcho("Stopping transport "+transportID);
   aiTaskUnitMove(transportID, kbUnitGetPosition(transportID));

   //Create the mainland base.
   int mainlandBaseGID=createBaseGoal("Mainland Base", cGoalPlanGoalTypeMainBase,
      -1, 1, 0, -1, kbBaseGetMainID(cMyID));
   if (mainlandBaseGID >= 0)
   {
      //Set the area ID.
      aiPlanSetVariableInt(mainlandBaseGID, cGoalPlanAreaGroupID, 0, mainlandGroupID);
      //Create the callback goal.
      int callbackGID=createCallbackGoal("Vinlandsaga Base Callback", "vinlandsagaBaseCallback",
	 1, 0, -1, false);
      if (callbackGID >= 0)
	 aiPlanSetVariableInt(mainlandBaseGID, cGoalPlanDoneGoal, 0, callbackGID);
   }

   //Done.
   xsDisableSelf();
}

//==============================================================================
// vinlandsagaFailsafe
//==============================================================================
rule vinlandsagaFailsafe
   minInterval 60
   inactive
{
   //Make a plan to explore with the initial transport.
	gVinlandsagaTransportExplorePlanID=aiPlanCreate("Vinlandsaga Transport Explore", cPlanExplore);
   printEcho("Transport explore plan: "+gVinlandsagaTransportExplorePlanID);
	if (gVinlandsagaTransportExplorePlanID >= 0)
	{
      aiPlanAddUnitType(gVinlandsagaTransportExplorePlanID, cUnitTypeTransport, 1, 1, 1);
		aiPlanSetDesiredPriority(gVinlandsagaTransportExplorePlanID, 1);
      aiPlanSetVariableBool(gVinlandsagaTransportExplorePlanID, cExplorePlanDoLoops, 0, false);
      aiPlanSetActive(gVinlandsagaTransportExplorePlanID);
      aiPlanSetEscrowID(gVinlandsagaTransportExplorePlanID);
	}
   xsDisableSelf();
}

//==============================================================================
// vinlandsagaEnableFishing
//==============================================================================
rule vinlandsagaEnableFishing
   minInterval 10
   inactive
{
   //See how many wood dropsites we have.
   static int wdQueryID=-1;
   //If we don't have a query ID, create it.
   if (wdQueryID < 0)
   {
      wdQueryID=kbUnitQueryCreate("Wood Dropsite Query");
      //If we still don't have one, bail.
      if (wdQueryID < 0)
	 return;
      //Else, setup the query data.
      kbUnitQuerySetPlayerID(wdQueryID, cMyID);
      if (cMyCulture == cCultureGreek)
	 kbUnitQuerySetUnitType(wdQueryID, cUnitTypeStorehouse);
      else if (cMyCulture == cCultureEgyptian)
	 kbUnitQuerySetUnitType(wdQueryID, cUnitTypeLumberCamp);
      else if (cMyCulture == cCultureNorse)
	 kbUnitQuerySetUnitType(wdQueryID, cUnitTypeLogicalTypeLandMilitary);
	  else if (cMyCulture == cCultureChinese)
	  {
		 kbUnitQuerySetUnitType(wdQueryID, cUnitTypeStoragePit);
	  }
      kbUnitQuerySetAreaGroupID(wdQueryID, kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) );
      kbUnitQuerySetState(wdQueryID, cUnitStateAlive);
   }
   //Reset the results.
   kbUnitQueryResetResults(wdQueryID);
   //Run the query.  If we don't have anything, skip.
   if ( (kbUnitQueryExecute(wdQueryID)<= 0) && (cMyCulture == cCultureGreek))
      return;

   //Enable the rule.
   xsEnableRule("fishing");
   //Unpause the age upgrades.
   aiSetPauseAllAgeUpgrades(false);
   //Unpause the pause kicker.
   xsEnableRule("unPauseAge2");
   xsSetRuleMinInterval("unPauseAge2", 15);

   //Create a simple plan to maintain X Ulfsarks (since we didn't do this as part of initNorse).
   createSimpleMaintainPlan(cUnitTypeUlfsark, gMaintainNumberLandScouts+1, true, kbBaseGetMainID(cMyID));

   //Disable us.
   xsDisableSelf();
}  

//==============================================================================
// hasWaterNeighbor
//==============================================================================
bool hasWaterNeighbor(int areaID = -1)    // True if the test area has a water area neighbor
{
   int areaCount = -1;
   int areaIndex = -1;
   int testArea = -1;
   bool hasWater = false;

   areaCount = kbAreaGetNumberBorderAreas(areaID);
   if (areaCount > 0)
   {
      for (areaIndex=0; < areaCount)
      {
	 testArea = kbAreaGetBorderAreaID(areaID, areaIndex);
	 if ( kbAreaGetType(testArea) == cAreaTypeWater )
	    hasWater = true;
      }
   }
   if (hasWater == true)
      printEcho("    "+areaID+" has a water neighbor.");
//   else
//      printEcho("    "+areaID);

   return(hasWater);
}

//==============================================================================
// verifyVinlandsagaBase - verify that this area borders water, find another if it doesn't.
//==============================================================================
int verifyVinlandsagaBase(int goalAreaID = -1, int recurseCount = 3 )
{
   int newAreaID = goalAreaID;      // New area will be the one we use.  By default,
				    // we'll start with the one passed to us.
   bool done = false;	       // Set true when we find an acceptable one
   int index = -1;		  // Which number are we checking
   int areaCount = -1;	      // How many areas to search
   int testArea = -1;

   if (recurseCount == 3)     // 3 more levels allowed
      printEcho("***** Beginning verifyVinlandsagaBase "+goalAreaID);
   else if (recurseCount == 2)
      printEcho("    "+goalAreaID);
   else if (recurseCount == 1)
      printEcho("	"+goalAreaID);
   else if (recurseCount == 0)
      printEcho("	   "+goalAreaID);

   if (hasWaterNeighbor(goalAreaID) == true)    // Simple case
   {
      printEcho("Target area "+goalAreaID+" has a water neighbor...using it.");
      return(goalAreaID);
   }

   int recurseLevel = 0;
   if (recurseCount > 0)
   {
      for( recurseLevel=0; < recurseCount)
      {
	 printEcho("Area "+goalAreaID+" has "+kbAreaGetNumberBorderAreas(goalAreaID)+" neighbors.");
	 printEcho("Testing "+(recurseLevel+1)+" layers around area "+goalAreaID);
	 // Test each area that borders each border area.  
	 for (index=0; < kbAreaGetNumberBorderAreas(goalAreaID))  // Get each border area
	 {
	    testArea = kbAreaGetBorderAreaID(goalAreaID, index);
	    if ( verifyVinlandsagaBase(testArea, recurseLevel) > 0)
	    {
	       return(testArea);
	    }
	 }
//	 if (recurseLevel == 2)
//	    breakpoint;
      }
   }


   if (recurseCount == 3)     // Sigh, just fail and return -1.
      printEcho("Couldn't find a water-bordered area.");
   return(-1);
}

//==============================================================================
// vinlandsagaBaseCallback
//==============================================================================
void vinlandsagaBaseCallback(int parm1=-1)
{
   printEcho("VinlandsagaBaseCallback:");

   //Get our water transport type.
   int transportPUID=cUnitTypeTransport;
   if (transportPUID < 0)
      return;
   //Get our main base.  This needs to be different than our initial base.
   if (kbBaseGetMainID(cMyID) == gVinlandsagaInitialBaseID)
      return;

   //Kill the transport explore plan.
   aiPlanDestroy(gVinlandsagaTransportExplorePlanID);
   xsDisableRule("vinlandsagaFailsafe");
   //Kill the land scout explore.
   aiPlanDestroy(gLandExplorePlanID);
   //Create a new land based explore plan for the mainland.
	gLandExplorePlanID=aiPlanCreate("Explore_Land_VS", cPlanExplore);
   if (gLandExplorePlanID >= 0)
   {
      aiPlanAddUnitType(gLandExplorePlanID, gLandScout, 1, 1, 1);
      aiPlanSetActive(gLandExplorePlanID);
      aiPlanSetEscrowID(gLandExplorePlanID, cEconomyEscrowID);
      aiPlanSetBaseID(gLandExplorePlanID, kbBaseGetMainID(cMyID));
      //Don't loop as egyptian.
      if (cMyCulture == cCultureEgyptian)
	 aiPlanSetVariableBool(gLandExplorePlanID, cExplorePlanDoLoops, 0, false);
   }

   //Get our start area ID.
   int startAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, gVinlandsagaInitialBaseID));
   //Get our goal area ID.
   int goalAreaID=kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));

   goalAreaID = verifyVinlandsagaBase( goalAreaID );  // Make sure it borders water,or find one that does.

   //Create the scout/villager xport plan.  If it works, add the unit type(s).
   int planID=createTransportPlan("Villager Transport", startAreaID, goalAreaID,
      true, transportPUID, 100, gVinlandsagaInitialBaseID);
   if (planID >= 0)
   {
      aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, 1, 5, 5);
      aiPlanAddUnitType(planID, cUnitTypeLogicalTypeLandMilitary, 0, 2, 2);	//ulfsark, pharaoh...
      aiPlanAddUnitType(planID, gLandScout, 0, 1, 1);
      if (cMyCulture == cCultureNorse)
	 aiPlanAddUnitType(planID, cUnitTypeOxCart, 0, 1, 1);
   }
   printEcho("Transport plan ID is "+planID);

   //change the farming baseID
   gFarmBaseID=kbBaseGetMainID(cMyID);

   //Allow auto dropsites again.
   aiSetAllowAutoDropsites(true);
   aiSetAllowBuildings(true);

   xsDisableRule("setEarlyEcon");
   xsEnableRule("econForecastAge1Mid");

   //Enable the rule that will eventually enable fishing and other stuff.
   xsEnableRule("vinlandsagaEnableFishing");
}

//==============================================================================
// handle Migration
//==============================================================================
rule handleMigration	//Settlers
   minInterval 2
   inactive
{
    //Get our start area ID.
    int villagerID = findUnit(cMyID, cUnitStateAlive, getBuilderType());
    if(villagerID < 1)
    {
	villagerID = findUnit(cMyID, cUnitStateAlive, cUnitTypeAbstractVillager);
    }
    vector villagerLoc = kbUnitGetPosition(villagerID);
    int startAreaID = kbAreaGetIDByPosition(villagerLoc);

    //Get our goal area ID.
    int settlementID = findUnitRM(0, cUnitStateAlive, cUnitTypeSettlement, true);
    vector settlementLoc = kbUnitGetPosition(settlementID);
    int goalAreaID = kbAreaGetIDByPosition(settlementLoc);

    goalAreaID = verifyVinlandsagaBase( goalAreaID );  // Make sure it borders water,or find one that does.
    gSettlersTargetAreaGroupID = kbAreaGroupGetIDByPosition(settlementLoc);

    int fakeBaseID=kbBaseCreate(cMyID, "Base"+kbBaseGetNextID(), villagerLoc, 75.0);
	kbBaseSetMilitary(cMyID, fakeBaseID, false);
	kbBaseSetEconomy(cMyID, fakeBaseID, false);
    kbBaseSetMain(cMyID, fakeBaseID, true);
    gVinlandsagaInitialBaseID = kbBaseGetMainID(cMyID);

    //Only transport if needed!
    if ( kbAreaGroupGetIDByPosition(villagerLoc) != gSettlersTargetAreaGroupID )
    {
	//Create the scout/villager xport plan.  If it works, add the unit type(s).
	int planID=createTransportPlan("Villager Transport", startAreaID, goalAreaID, true, cUnitTypeTransport, 98, gVinlandsagaInitialBaseID);

	if (planID >= 0)
	{
	    aiPlanAddUnitType(planID, getBuilderType(), 1, 10, 10);
	    aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, 0, 1, 5);
	    aiPlanAddUnitType(planID, cUnitTypeLogicalTypeLandMilitary, 0, 1, 1);
	    aiPlanAddUnitType(planID, gLandScout, 0, 1, 1);
	    if (cMyCulture == cCultureNorse)
		aiPlanAddUnitType(planID, cUnitTypeOxCart, 0, 1, 1);
	}
	printEcho("Transport plan ID is "+planID);
    }

	xsEnableRule("nomadSearchMode");

    //Done.
    xsDisableSelf();
}

//==============================================================================
// resign handler
//==============================================================================
void resignHandler(int result =-1)
{
   if (result == 0)
   {
      //xsEnableRule("resignTimer");
      return;
   }

   if (
	gResignType == cResignGatherers
	||
	gResignType == cResignSettlements
	||
	gResignType == cResignTeammates
	||
	gResignType == cResignMilitaryPop
      )
   {
      aiResign();	//GG
      return;
   }
}

//==============================================================================
// RULE destroyOtherBases (Enemy)
//==============================================================================
rule destroyOtherBases		//plan for more map control.
   minInterval 45
   group AttackRules
   inactive
{
   if(kbGetAge() < cAge2)		//No military to act with in Age1. Go away!
   {
	return;
   }
   int mhpID = aiGetMostHatedPlayerID();
   int mySettleCount = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
   int mhpSettleCount = kbUnitCount(mhpID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
   int mySettleID = gMainBaseID;

   if (mySettleCount >= 1 && mySettleCount < mhpSettleCount)	// We need to do something!
   {
	 if (gOtherBaseAttackPlan >= 0)	//destroy old plans...
	 {
		aiPlanDestroy(gOtherBaseAttackPlan);
		gOtherBaseAttackPlan = -1;
	 }
	 // Create highest-priority attack plan to go kill it
	 int mhpSettleID = findClosestRelTo(mySettleID, mhpID, cUnitStateAliveOrBuilding, cUnitTypeAbstractSettlement);
	 vector mhpSettleLoc = kbUnitGetPosition(mhpSettleID);

	    // Making an attack plan
	    gOtherBaseAttackPlan=aiPlanCreate("Enemy forward tc attack plan", cPlanAttack);
	    if (gOtherBaseAttackPlan < 0)
	       return;

	    aiPlanSetVariableInt(gOtherBaseAttackPlan, cAttackPlanPlayerID, 0, mhpID);
	    // Specify other continent so that armies will transport
	    aiPlanSetNumberVariableValues( gOtherBaseAttackPlan, cAttackPlanTargetAreaGroups,  1, true);
	    aiPlanSetVariableInt(gOtherBaseAttackPlan, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(mhpSettleLoc));
	    aiPlanSetVariableVector(gOtherBaseAttackPlan, cAttackPlanGatherPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	    aiPlanSetVariableFloat(gOtherBaseAttackPlan, cAttackPlanGatherDistance, 0, 50.0);   // Insta-gather, just GO!

	    aiPlanAddUnitType(gOtherBaseAttackPlan, cUnitTypeLogicalTypeLandMilitary, 20, 40, 40);

	    aiPlanSetInitialPosition(gOtherBaseAttackPlan, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
	    aiPlanSetRequiresAllNeedUnits(gOtherBaseAttackPlan, false);
	    if (kbGetAge() > cAge3)
	    {
		aiPlanSetDesiredPriority(gOtherBaseAttackPlan, 74);
	    }else{
		aiPlanSetDesiredPriority(gOtherBaseAttackPlan, 68);
	    }
	    aiPlanSetVariableBool(gOtherBaseAttackPlan, cAttackPlanMoveAttack, 0, true);
	    aiPlanSetVariableInt(gOtherBaseAttackPlan, cAttackPlanSpecificTargetID, 0, mhpSettleID);

	    // We want some siege!
	    if (aiPlanGetNumberUnits(gOtherBaseAttackPlan, cUnitTypeAbstractSiegeWeapon) <= 0)
	    {
		aiPlanAddUnitType(gOtherBaseAttackPlan, cUnitTypeAbstractSiegeWeapon, 1, 2, 2);
	    }

	    aiPlanSetActive(gOtherBaseAttackPlan);	//Go.
   }else{
	aiPlanDestroy(gOtherBaseAttackPlan);
	gOtherBaseAttackPlan = -1;
	xsDisableSelf();
	return;	// kill attack plan when it's even out again.
   }
}

//==============================================================================
// attackMonitor	[todo]
//==============================================================================
rule attackMonitor
minInterval 6
group AttackRules
active
{
   if( cvOkToAttack )		//We are allowed to attack?
   {
	aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, false);
   }else{
	aiPlanSetVariableBool(gLandAttackGoalID, cGoalPlanIdleAttack, 0, true);
   }

   // Find the attack plans
   int numPlans = aiPlanGetNumber(cPlanAttack, -1, true);  // Attack plans, any state, active only
   if(numPlans > 0)
   {
      for(i=0; < numPlans)
      {
	int currentPlanID = aiPlanGetIDByIndex(cPlanAttack, -1, true, i);    // Assuming most recent at end

   if (aiPlanGetVariableInt(currentPlanID, cAttackPlanFromGoalID, 0) == gLandAttackGoalID)	//Ignore naval plans
   {
      gMostRecentAttackPlanID = currentPlanID;	//save

	microArmyVSArmy(gMostRecentAttackPlanID);	//fight or retreat?

      int siegeCount = kbUnitCount(cMyID, cUnitTypeAbstractSiegeWeapon, cUnitStateAlive);
      int titanCount = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
      //Order of attack: Always try to hit the economy!
      if(siegeCount < 3 && titanCount < 1) {
	aiPlanSetNumberVariableValues(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 13, true);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeAbstractVillager);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeOxCart);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 2, cUnitTypeAbstractTradeUnit);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 3, cUnitTypeAbstractPharaoh);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 4, cUnitTypeUnit);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 5, cUnitTypeHouse);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 6, cUnitTypeManor);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 7, cUnitTypeAbstractSettlement);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 8, cUnitTypeBuildingsThatShoot);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 9, cUnitTypeMilitaryBuilding);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 10, cUnitTypeAbstractMonument);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 11, cUnitTypeGate);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 12, cUnitTypeBuilding);
      }else{
	aiPlanSetNumberVariableValues(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 16, true);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 0, cUnitTypeHouse);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 1, cUnitTypeManor);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 2, cUnitTypeAbstractSettlement);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 3, cUnitTypeWonder);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 4, cUnitTypeAbstractPharaoh);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 5, cUnitTypeAbstractVillager);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 6, cUnitTypeMilitary);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 7, cUnitTypeOxCart);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 8, cUnitTypeBuildingsThatShoot);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 9, cUnitTypeMarket);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 10, cUnitTypeGate);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 11, cUnitTypeMilitaryBuilding);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 12, cUnitTypeAbstractTradeUnit);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 13, cUnitTypeUnit);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 14, cUnitTypeAbstractMonument);
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetTypeID, 15, cUnitTypeBuilding);
      }
      aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanRefreshFrequency, 0, 10);

      // Adjust the "retreat factor" for the next attack
      if ( cvOffenseDefenseSlider < 0 )
      {
	 int goalID = gLandAttackGoalID;

	 int oddsOfRetreat = -50 * cvOffenseDefenseSlider; // 50 for totally defensive, 0 for neutral or aggressive
	 if ((kbGetAge() < cAge3 || aiRandInt(101) < oddsOfRetreat) && gTransportMap == false)
	 {
	    printEcho("Next attack is allowed to retreat.");
	    aiPlanSetVariableBool(goalID, cGoalPlanAllowRetreat, 0, true);

	    if (kbGetAge() > cAge2)
	    {
		aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeWillLose);
	    }else{
		aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeOutnumbered);
	    }
	 }
	 else
	 {
	    printEcho("Next attack is not allowed to retreat.");
	    aiPlanSetVariableBool(goalID, cGoalPlanAllowRetreat, 0, false);

	    aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
	 }
      }
   }

   int mhpID = aiGetMostHatedPlayerID();

   if (gMostRecentAttackPlanID >= 0)
   {
      if ( gTransportMap == true )	// Specify other continent so that armies will transport
      {
	   aiPlanSetNumberVariableValues(gMostRecentAttackPlanID, cAttackPlanTargetAreaGroups, 1, true);
	   aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanTargetAreaGroups, 0, kbAreaGroupGetIDByPosition(kbBaseGetLocation(mhpID, kbBaseGetMainID(mhpID))));
	   aiPlanSetVariableVector(gMostRecentAttackPlanID, cAttackPlanGatherPoint, 0, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
      }
      if ( aiPlanGetNumberVariableValues(gMostRecentAttackPlanID, cAttackPlanTargetAreaGroups) > 1 )  // Plan could attack other continent
      {
	 if (aiPlanGetVariableInt(gMostRecentAttackPlanID, cAttackPlanRetreatMode, 0) != cAttackPlanRetreatModeNone )   // It's allowed to retreat
	 {
	    printEcho("***** Turning off retreat for possible remote attack plan "+gMostRecentAttackPlanID);
	    aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanRetreatMode, 0, cAttackPlanRetreatModeNone);
	 }
      }
      
      // Check to see if the gather phase is taking too long and just launch the attack if so.
      if (aiPlanGetState(gMostRecentAttackPlanID) == cPlanStateGather)
	 if ( aiPlanGetVariableInt(gMostRecentAttackPlanID, cAttackPlanGatherStartTime, 0) < (xsGetTime()-20000) )
	 {
	    aiPlanSetVariableFloat(gMostRecentAttackPlanID, cAttackPlanGatherDistance, 0, 300.0);
	    //printEcho("*****  Gather timed out, attacking anyway.");
	 }
   }

   //Condition A - Military
   int myMilCount = getMilPop();
   int mHpMilCount = getEstimatedMilPop(mhpID);

   bool milAttack = false;
   if(myMilCount > mHpMilCount || (kbGetAge() >= cAge4 && kbGetPop() >= kbGetPopCap()*0.8))
   {
	milAttack = true;	//Let's flood in!
   }

   //Condition B - Economy
   int myFood = kbResourceGet(cResourceFood);
   int myWood = kbResourceGet(cResourceWood);
   int myGold = kbResourceGet(cResourceGold);

   bool econAttack = false;
   if(
	(myFood > 2500 && myWood > 2500 && myGold > 2500)
	||
	(
		(kbCanAffordUnit(cUnitTypeSettlementLevel1, cEconomyEscrowID))
		&&
		(kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive) > 2)
		&&
		(kbGetAgeForPlayer(mhpID) <= kbGetAge())
	)
     )
   {
	econAttack = true;	//Let's burn some shit!
   }

   //Condition C - Defense
   if(milAttack || econAttack)
   {
	int enemyMilInBase = kbUnitQueryExecute(getUnitsAtLocQID(mhpID,cUnitStateAlive,cUnitTypeMilitary,kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)),gMainBaseAreaWallRadius));
	int enemyTitanInBase = kbUnitQueryExecute(getUnitsAtLocQID(mhpID,cUnitStateAlive,cUnitTypeAbstractTitan,kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)),gMainBaseAreaWallRadius));

	if(enemyMilInBase >= 15 || enemyTitanInBase > 0)
	{
		milAttack = false;
		econAttack = false;
	}
   }

   bool activeAssault = false;		//Are we still going?

   vector baseFront = xsVectorNormalize(kbGetMapCenter()-kbGetTownLocation());
   int mhpTitans = kbUnitCount(mhpID, cUnitTypeAbstractTitan, cUnitStateAlive);
   int myTitans = kbUnitCount(cMyID, cUnitTypeAbstractTitan, cUnitStateAlive);
   if(
	(milAttack || econAttack)
	&&
	(
		(myTitans > 0 && myTitans > mhpTitans)
		||
		(aiGetAvailableMilitaryPop() < 8)	//We nearly filled our mil pop room?
		||
		(aiGetPersonality() == "Apocalypse Bot")
		||
		(milAttack && econAttack && kbGetAge() > cAge3)
	)
	&&
	(xsGetTime() - gAssaultStartTime < 5*60*1000)	//No single attack should be eternal!
     )
   {
      xsDisableRule("defendPlanRule");	// Pause the defend plan.
      vector planPosition = aiPlanGetLocation(gMostRecentAttackPlanID)+baseFront*(-12);
      aiPlanSetVariableVector(gMostRecentAttackPlanID, cAttackPlanGatherPoint, 0, planPosition);
      gMilitaryGatherPoint=setMilitaryGatherPointAllBases(planPosition);
      aiPlanSetVariableFloat(gMostRecentAttackPlanID, cAttackPlanGatherDistance, 0, 200.0);
      if (gAssaultStartTime < 0) {gAssaultStartTime = xsGetTime();}
      activeAssault = true;
   }else{
      xsEnableRule("defendPlanRule");	// Reactivate the defend plan.
      vector basePosition = kbBaseGetLastKnownDamageLocation(cMyID, kbBaseGetMainID(cMyID));
      if(calcDistanceToPos(cInvalidVector,basePosition) < 4)
      {
	basePosition = kbGetTownLocation()+(baseFront*gMainBaseAreaWallRadius);
      }
      aiPlanSetVariableVector(gMostRecentAttackPlanID, cAttackPlanGatherPoint, 0, basePosition);
      gMilitaryGatherPoint=setMilitaryGatherPointAllBases(basePosition);
      aiPlanSetVariableFloat(gMostRecentAttackPlanID, cAttackPlanGatherDistance, 0, 0.0);
      gAssaultStartTime = -1;	//Reset.
      activeAssault = false;
   }
   int tcInProgress = findUnit(cMyID, cUnitStateBuilding, cUnitTypeSettlementLevel1);
   if(tcInProgress > 0)
   {
	vector nextTcLoc = kbUnitGetPosition(tcInProgress) + vector(3,3,3);
	gMilitaryGatherPoint=setMilitaryGatherPointAllBases(nextTcLoc);	//Go there instead.
   }
   //Update defend plan location too
   aiPlanSetVariableVector(gDefendPlanID, cDefendPlanDefendPoint, 0, gMilitaryGatherPoint);

   int maxAttackSize = gTargetMilitarySize;

   //Attack once we have enough units to break the defense.
   if(gLandUPID >= 0 && kbGetAge() > cAge1)
   {
	if(mHpMilCount < 4)	//Always assume some mil.
	{
		mHpMilCount = 4;
	}
	int minAttackSize = mHpMilCount * 0.5;		//Convert Pop to unit needs.
	if(aiGetAvailableMilitaryPop() < 8)		//We can't have more!
	{
		//Make sure the plan is able to fire an attack with everything we have.
		minAttackSize = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
	}
	if(milAttack && econAttack == false)
	{
		minAttackSize = minAttackSize * 1.25;	//25% more
	}
	if(econAttack && milAttack == false)
	{
		minAttackSize = minAttackSize * 0.75;	//25% less
	}
	if(minAttackSize < 6)	//Anything else isn't worth sending.
	{
		minAttackSize = 6;
	}
	if(maxAttackSize < minAttackSize && maxAttackSize > 0)
	{
		minAttackSize = maxAttackSize * 0.9;
	}
	if(cvAiAutoBalance && mHpMilCount < gTargetMilitarySize)
	{
		minAttackSize = mHpMilCount * 0.80;
		maxAttackSize = mHpMilCount + 1;
	}
	kbUnitPickSetMinimumNumberUnits(gLandUPID, minAttackSize);
	kbUnitPickSetMaximumNumberUnits(gLandUPID, gTargetMilitarySize);

	int attackFrequency = aiPlanGetVariableInt(gLandAttackGoalID, cGoalPlanAttackStartFrequency, 0);

	//Update Attack Goal
	if(activeAssault)	//Just go?
	{
            if(attackFrequency > 4)
	    {
		attackFrequency--;
	    }
	    aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanMinUnitNumber, 0, 3);
	}else{
            if(attackFrequency < 70)
	    {
		attackFrequency++;
	    }
	    aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanMinUnitNumber, 0, minAttackSize);
	}
	aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanMaxUnitNumber, 0, maxAttackSize);

	aiPlanSetVariableInt(gLandAttackGoalID, cGoalPlanAttackStartFrequency, 0, attackFrequency);

	int mediumAttackSize = (minAttackSize+maxAttackSize)*0.5;
	if(maxAttackSize < 0)	//No Limit?
	{
		mediumAttackSize = minAttackSize * 1.25;
	}
	//Update Attack Plan
	aiPlanAddUnitType(gMostRecentAttackPlanID, cUnitTypeLogicalTypeLandMilitary, minAttackSize, mediumAttackSize, maxAttackSize);
   }

   if((cMyCulture != cCultureNorse && milAttack) || (milAttack && econAttack))
   {
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeClosest);
   }else{
	aiPlanSetVariableInt(gMostRecentAttackPlanID, cAttackPlanBaseAttackMode, 0, cAttackPlanBaseAttackModeWeakest);
   }

   if(cvMasterDifficulty >= cDifficultyNightmare)
   {
	if(kbGetAge() < cAge2)
	{
		aiSetAttackResponseDistance(20);
	}else
	if(kbGetAge() < cAge3)
	{
		aiSetAttackResponseDistance(30);
	}else
	if(kbGetAge() < cAge4)
	{
		aiSetAttackResponseDistance(50);
	}else{
		aiSetAttackResponseDistance(70);
	}
   }

      }
   }
}

//==============================================================================
// RULE earlySettlementTracker
//==============================================================================
rule earlySettlementTracker
   minInterval 15
   active
{
   //If this is 3rd age, go away.
   if (kbGetAge() >= 2)
   {
      xsDisableSelf();
      return;
   }

   int tcCount = kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAliveOrBuilding);
   //If we are in Age1 and have alive or building settlements, return.
   if ((tcCount > 0) && (kbGetAge() <= cAge1))
      return;
   if (tcCount >= gEarlySettlementTarget)	//get more in Age2?
      return;
   //If we have a plan to build a settlement, return.
   if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSettlementLevel1) >= 0)
      return;

   xsEnableRule("buildSettlements");
   xsDisableSelf();
}

//==============================================================================
// RULE repairBuildings
//==============================================================================
rule repairBuildings
   minInterval 12
   inactive
{
   float distance = gMainBaseAreaWallRadius;
   if(distance < 30)
   {
	distance = 30;
   }
   if(kbGetAge() < cAge3 && distance > 60)
   {
	distance = 60;
   }else
   if(kbGetAge() < cAge4 && distance > gMaximumBaseResourceDistance)
   {
	distance = gMaximumBaseResourceDistance;
   }

   int buildingID=kbFindBestBuildingToRepair(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), distance, 0.9, cUnitTypeBuildingsThatShoot);
   if (buildingID >= 0)
   {
      //Don't create another plan for the same building.
      if (aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true) >= 0)
	 return;
      
      //Create the plan.
      static int num=0;
      num=num+1;
      string planName="Repair_"+num;
      int planID=aiPlanCreate(planName, cPlanRepair);
      if (planID < 0)
	 return;

      aiPlanSetDesiredPriority(planID, 100);
      aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
      aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
      aiPlanSetInitialPosition(planID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
      aiPlanAddUnitType(planID, getBuilderType(), 1, 1, 5);
      if (cMyCulture == cCultureAtlantean)
	 aiPlanAddUnitType(planID, getBuilderType(), 1, 1, 1);
      aiPlanSetActive(planID);
   }
}

//==============================================================================
// RULE townDefense
//==============================================================================
rule townDefense
   minInterval 11
   inactive
{
   //Get our main base ID.
   int mainBaseID=kbBaseGetMainID(cMyID);
   if (mainBaseID < 0)
      return;
   //Get the time under attack.
   int secondsUnderAttack=kbBaseGetTimeUnderAttack(cMyID, mainBaseID);

   //Factor in a dulled Moderate response for the rest of this.
   if (cvMasterDifficulty == cDifficultyModerate)
   {
      if (secondsUnderAttack < 30)
	 return;
   }
   else
   {
      if (secondsUnderAttack < 10)
	 return;
   }

   //If the enemy has > 4 military units that we've seen and we've been attacked in our town,
   //tower up.
   if (gBuildTowers == false)
   {
      int numHatedUnits=kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeMilitary, cUnitStateAlive);
      if (numHatedUnits > 4)
      {
	 printEcho("townDefense:  Player "+aiGetMostHatedPlayerID()+" has "+numHatedUnits+" units, upgrading towers.");
	 //gBuildTowers=true;
	 //towerInBase("Defensive Towers", false, 2, cMilitaryEscrowID);   // Removed tower decision here, just get upgrades
	 xsEnableRule("towerUpgrade");
      }
   }

   //If we've been under siege for long enough, see if we have enough stuff to
   //be worried.
   int numberEnemyUnits=kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationEnemy, cUnitTypeUnit);
   int numberEnemyMilitaryBuildings=kbBaseGetNumberUnits(cMyID, mainBaseID, cPlayerRelationEnemy, cUnitTypeMilitaryBuilding);
   if ((numberEnemyUnits < 2) && (numberEnemyMilitaryBuildings <= 0))
      return;

   //We're worried.  If we're in the first age, ensure that we go up fast.  If 
   //we're not in the first age, ensure that we have an attack goal setup for
   //the current age. If not, create one.
}

//==============================================================================
// RULE startupWalls
//==============================================================================
rule startupWalls
   minInterval 28
   active
{
   if(cvOkToBuildWalls == false)
   {
	xsDisableSelf();
	return;
   }
   if(kbUnitCount(cMyID, cUnitTypeAbstractSettlement, cUnitStateAlive) < 1)
   {
	return;
   }
   if(gBuildWalls == false)
   {
	switch(kbGetAge())
	{
	   case cAge1:
	   {
		return;		//No walls in Age1.
	   }
	   case cAge2:
	   {
		if(
		    (cMyCulture != cCultureAtlantean && cvOffenseDefenseSlider < 0.0)
		    ||
		    (cvOffenseDefenseSlider < -0.5)
		  )
		{
			gBuildWalls = true;
		}
	   }
	   case cAge3:
	   {
		if(cvOffenseDefenseSlider < 0.4)
		{
			gBuildWalls = true;
		}
	   }
	   case cAge4:
	   {
		gBuildWalls = true;
	   }
	   case cAge5:
	   {
		gBuildWalls = true;
	   }
	}
   }
   if(gBuildWalls == true)
   {
	if(aiGetGameMode() != cGameModeDeathmatch || kbGetAge() >= cAge4)
	{
		xsEnableRule("fillInWallGaps");
		xsEnableRule("wallUpgrade");
		printEcho("We try to build up walls.");
		xsDisableSelf();
	}
   }
}

//==============================================================================
// RULE fillInWallGaps
//==============================================================================
rule fillInWallGaps
   minInterval 31
   inactive
{
   //If we're not building walls, go away.
   if (gBuildWalls == false || cvOkToBuildWalls == false)
   {
      xsDisableSelf();
      return;
   }

   //If we already have a build wall plan, don't make another one.
   if(aiPlanGetIDByTypeAndVariableType(cPlanBuildWall, cBuildWallPlanWallType, cBuildWallPlanWallTypeArea, true) < 0)
   {
      gWallPlanID = aiPlanCreate("FillInWallGaps", cPlanBuildWall);	// Empty wall plan, will store area list there.
   }else{
      aiPlanSetActive(gWallPlanID, false);	//Disable while we update.
   }

      float baseRadius = 32.0 - (11.0*cvOffenseDefenseSlider);	// Not really a 'radius', will be edge of square
      if(gMainBaseAreaWallRadius > 5)
      {
	baseRadius = gMainBaseAreaWallRadius;  //Use the global stuff!
      }

      aiPlanSetNumberVariableValues(gWallPlanID, cBuildWallPlanAreaIDs, 20, true);
      int numAreasAdded = 0;

      int mainArea = -1;
      vector mainCenter = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
      if(gWallBaseID >= 0)
      {
	mainCenter = kbUnitGetPosition(gWallBaseID);
      }
      float mainX = xsVectorGetX(mainCenter);
      float mainZ = xsVectorGetZ(mainCenter);
      mainArea = kbAreaGetIDByPosition(mainCenter);
      aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
      numAreasAdded = numAreasAdded + 1;
      
      int firstRingCount = -1;      // How many areas are in first ring around main?
      int firstRingIndex = -1;      // Which one are we on?
      int secondRingCount = -1;     // How many border areas does the current first ring area have?
      int secondRingIndex = -1;
      int firstRingID = -1;	 // Actual ID of current 1st ring area
      int secondRingID = -1;
      vector areaCenter = cInvalidVector;    // Center point of this area
      float areaX = 0.0;
      float dx = 0.0;
      float areaZ = 0.0;
      float dz = 0.0;
      int areaType = -1;
      bool  needToSave = false;

      firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
      for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
      {
	 needToSave = true;	    // We'll save this unless we have a problem
	 firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
	 areaCenter = kbAreaGetCenter(firstRingID);
	 // Now, do the checks.
	    areaX = xsVectorGetX(areaCenter);
	    areaZ = xsVectorGetZ(areaCenter);
	    dx = mainX - areaX;
	    dz = mainZ - areaZ;
	    if ( (dx > baseRadius) || (dx < (-1.0*baseRadius)) )
	    {
	       needToSave = false;
	    }
	    if ( (dz > baseRadius) || (dz < (-1.0*baseRadius)) )
	    {
	       needToSave = false;
	    }
	    // Override if it's a special type
	    areaType = kbAreaGetType(firstRingID);
	    if ( areaType == cAreaTypeGold)
	    {
	       needToSave = true;
	    }
	    if ( areaType == cAreaTypeSettlement )
	    {
	       needToSave = true;
	    }
	 // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
	 if (needToSave == true)
	 {
	    int i = -1;
	    bool found =false;
	    for (i=0; < numAreasAdded)
	    {
	       if (aiPlanGetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, i) == firstRingID)
	       {
		  found = true;     // It's in there, don't add it
	       }
	    }
	    if ((found == false) && (numAreasAdded < 20))  // add it
	    {
	       aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
	       numAreasAdded = numAreasAdded + 1;
	       // If we had to add it, check all its surrounding areas, too...if it turns out we need to.
		 secondRingCount = kbAreaGetNumberBorderAreas(firstRingID);     // How many does it touch?
		  for (secondRingIndex=0; < secondRingCount)
		  {     // Check each border area.  If it's gold or settlement and not already in list, add it.
		     secondRingID = kbAreaGetBorderAreaID(firstRingID, secondRingIndex);
		     if ( (kbAreaGetType(secondRingID) == cAreaTypeSettlement) || (kbAreaGetType(secondRingID) == cAreaTypeGold) )
		     {
			bool skipme = false;       // Skip it if center is more than 10m outside normal radius
			areaX = xsVectorGetX(kbAreaGetCenter(secondRingID));
			areaZ = xsVectorGetZ(kbAreaGetCenter(secondRingID));
			dx = mainX - areaX;
			dz = mainZ - areaZ;
			if ( (dx > (baseRadius+10.0)) || (dx < (-1.0*(baseRadius+10.0))) )
			{
			   skipme = true;
			}
			if ( (dz > (baseRadius+10.0)) || (dz < (-1.0*(baseRadius+10.0))) )
			{
			   skipme = true;
			}
			bool alreadyIn = false;
			int m=0;
			for (m=0; < numAreasAdded)
			{
			   if (aiPlanGetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, m) == secondRingID)
			   {
			      alreadyIn = true;     // It's in there, don't add it
			   }
			}
			if ((alreadyIn == false) && (skipme == false) && (numAreasAdded < 20))  // add it
			{
			   aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, secondRingID);
			   numAreasAdded = numAreasAdded + 1;
			}
		     }
		  }
	     }
	 }
      }
      // Set the true number of area variables, preserving existing values, then turn on the plan
      aiPlanSetNumberVariableValues(gWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

      aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
      if (cMyCulture == cCultureAtlantean)
      {
	 aiPlanAddUnitType(gWallPlanID, getBuilderType(), 1, 1, 1);
      }else{
	 aiPlanAddUnitType(gWallPlanID, getBuilderType(), 1, 2, 2);
      }
      aiPlanSetVariableInt(gWallPlanID, cBuildWallPlanNumberOfGates, 0, 14);
      aiPlanSetVariableFloat(gWallPlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 16.0);
      aiPlanSetBaseID(gWallPlanID, kbBaseGetMainID(cMyID));
      aiPlanSetEscrowID(gWallPlanID, cMilitaryEscrowID);
      aiPlanSetDesiredPriority(gWallPlanID, 38);
      aiPlanSetActive(gWallPlanID, true);
}

//==============================================================================
// RULE isolationWalls	a.k.a. wall in opponent xD
//==============================================================================
rule isolationWalls
   minInterval 94
   inactive
{
   //If we're not allowed to build walls, go away.
   if (cvOkToBuildWalls == false || cvMasterDifficulty < cDifficultyHard || gFishMap)
   {
      xsDisableSelf();
      return;
   }

   //This is a lategame strategy!
   if(kbGetAge() < cAge3 || kbResourceGet(cResourceGold) < 2000 || kbResourceGet(cResourceFood) < 500)
      return;

   //If we already have a plan, don't make another one.
   if(aiPlanGetActive(gFrontWallPlanID))
   {
      return;
   }

      // Empty wall plan, will store area list there.
      gFrontWallPlanID = aiPlanCreate("isolationWalls", cPlanBuildWall);

      // Calculate the current required radius.
      int mhpMainID = gEnemyMainBaseID;
      int mhpLimes = findFurthestRelTo(mhpMainID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeGate);
      if(mhpLimes < 0 || mhpMainID < 0)
      {
		return;		//Nothing detected.
      }

      // Not really a 'radius', will be edge of square
      float baseRadius = calcDistanceToUnit(mhpMainID,mhpLimes) + 30;

      aiPlanSetNumberVariableValues(gFrontWallPlanID, cBuildWallPlanAreaIDs, 50, true);
      int numAreasAdded = 0;

      int mainArea = -1;
      vector mainCenter = kbBaseGetLocation(aiGetMostHatedPlayerID(), mhpMainID);
      if(gFrontWallPlanID >= 0)
      {
	mainCenter = kbBaseGetLocation(aiGetMostHatedPlayerID(), gFrontWallPlanID);
      }
      float mainX = xsVectorGetX(mainCenter);
      float mainZ = xsVectorGetZ(mainCenter);
      mainArea = kbAreaGetIDByPosition(mainCenter);
      aiPlanSetVariableInt(gFrontWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, mainArea);
      numAreasAdded = numAreasAdded + 1;
      
      int firstRingCount = -1;      // How many areas are in first ring around main?
      int firstRingIndex = -1;      // Which one are we on?
      int secondRingCount = -1;     // How many border areas does the current first ring area have?
      int secondRingIndex = -1;
      int firstRingID = -1;	 // Actual ID of current 1st ring area
      int secondRingID = -1;
      vector areaCenter = cInvalidVector;    // Center point of this area
      float areaX = 0.0;
      float dx = 0.0;
      float areaZ = 0.0;
      float dz = 0.0;
      int areaType = -1;
      bool  needToSave = false;

      firstRingCount = kbAreaGetNumberBorderAreas(mainArea);
 
      for (firstRingIndex = 0; < firstRingCount)      // Check each border area of the main area
      {
	 needToSave = true;	    // We'll save this unless we have a problem
	 firstRingID = kbAreaGetBorderAreaID(mainArea, firstRingIndex);
	 areaCenter = kbAreaGetCenter(firstRingID);
	 // Now, do the checks.
	    areaX = xsVectorGetX(areaCenter);
	    areaZ = xsVectorGetZ(areaCenter);
	    dx = mainX - areaX;
	    dz = mainZ - areaZ;
	    if ( (dx > baseRadius) || (dx < (-1.0*baseRadius)) )
	    {
	       needToSave = false;
	    }
	    if ( (dz > baseRadius) || (dz < (-1.0*baseRadius)) )
	    {
	       needToSave = false;
	    }
	    // Override if it's a special type
	    areaType = kbAreaGetType(firstRingID);
	    if ( areaType == cAreaTypeGold)
	    {
	       needToSave = true;
	    }
	    if ( areaType == cAreaTypeSettlement )
	    {
	       needToSave = true;
	    }
	 // Now, if we need to save it, zip through the list of saved areas and make sure it isn't there, then add it.
	 if (needToSave == true)
	 {
	    int i = -1;
	    bool found =false;
	    for (i=0; < numAreasAdded)
	    {
	       if (aiPlanGetVariableInt(gFrontWallPlanID, cBuildWallPlanAreaIDs, i) == firstRingID)
	       {
		  found = true;     // It's in there, don't add it
	       }
	    }
	    if ((found == false) && (numAreasAdded < 50))  // add it
	    {
	       aiPlanSetVariableInt(gFrontWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, firstRingID);
	       numAreasAdded = numAreasAdded + 1;
	       // If we had to add it, check all its surrounding areas, too...if it turns out we need to.
		 secondRingCount = kbAreaGetNumberBorderAreas(firstRingID);     // How many does it touch?
		  for (secondRingIndex=0; < secondRingCount)
		  {     // Check each border area.  If it's gold or settlement and not already in list, add it.
		     secondRingID = kbAreaGetBorderAreaID(firstRingID, secondRingIndex);
		     if ( (kbAreaGetType(secondRingID) == cAreaTypeSettlement) || (kbAreaGetType(secondRingID) == cAreaTypeGold) )
		     {
			bool skipme = false;       // Skip it if center is more than 10m outside normal radius
			areaX = xsVectorGetX(kbAreaGetCenter(secondRingID));
			areaZ = xsVectorGetZ(kbAreaGetCenter(secondRingID));
			dx = mainX - areaX;
			dz = mainZ - areaZ;
			if ( (dx > (baseRadius+10.0)) || (dx < (-1.0*(baseRadius+10.0))) )
			{
			   skipme = true;
			}
			if ( (dz > (baseRadius+10.0)) || (dz < (-1.0*(baseRadius+10.0))) )
			{
			   skipme = true;
			}
			bool alreadyIn = false;
			int m=0;
			for (m=0; < numAreasAdded)
			{
			   if (aiPlanGetVariableInt(gFrontWallPlanID, cBuildWallPlanAreaIDs, m) == secondRingID)
			   {
			      alreadyIn = true;     // It's in there, don't add it
			   }
			}
			if ((alreadyIn == false) && (skipme == false) && (numAreasAdded < 20))  // add it
			{
			   aiPlanSetVariableInt(gFrontWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, secondRingID);
			   numAreasAdded = numAreasAdded + 1;
			}
		     }
		  }
	     }
	 }
      }
      // Set the true number of area variables, preserving existing values, then turn on the plan
      aiPlanSetNumberVariableValues(gFrontWallPlanID, cBuildWallPlanAreaIDs, numAreasAdded, false);

      aiPlanSetVariableInt(gFrontWallPlanID, cBuildWallPlanWallType, 0, cBuildWallPlanWallTypeArea);
      aiPlanAddUnitType(gFrontWallPlanID, getBuilderType(), 1, 1, 1);
      aiPlanSetVariableInt(gFrontWallPlanID, cBuildWallPlanNumberOfGates, 0, 20);
      aiPlanSetVariableFloat(gFrontWallPlanID, cBuildWallPlanEdgeOfMapBuffer, 0, 40.0);
      aiPlanSetBaseID(gFrontWallPlanID, kbBaseGetMainID(aiGetMostHatedPlayerID()));
      aiPlanSetEscrowID(gFrontWallPlanID, cMilitaryEscrowID);
      aiPlanSetDesiredPriority(gFrontWallPlanID, 175);
      aiPlanSetActive(gFrontWallPlanID, true);
}

//==============================================================================
// RULE findFish:  We don't know if this is a water map...if you see fish, it is.
//==============================================================================
rule findFish
   minInterval 11
   inactive
{
   //Create the fish query.
   int fishCount = kbUnitCount(0, cUnitTypeFish, cUnitStateAlive);

   if (fishCount > 0)
   {
      gFishMap=true;	//gTransportMap?
      
      //Tell the AI what kind of map we are on.
      aiSetWaterMap(gFishMap);

      xsEnableRule("fishing");

      if (cMyCiv != cCivPoseidon && cvMasterDifficulty < cDifficultyHard)
	 createSimpleMaintainPlan(gWaterScout, gMaintainNumberWaterScouts, true, -1);

      //Enable our naval attack goal starter.
      if (cvMasterDifficulty != cDifficultyEasy)
	 xsEnableRule("NavalGoalMonitor");

      //Fire up.
      if (gMaintainWaterXPortPlanID < 0 && gTransportMap)
	 gMaintainWaterXPortPlanID=createSimpleMaintainPlan(kbTechTreeGetUnitIDTypeByFunctionIndex(cUnitFunctionWaterTransport, 0), 1, false, -1);
   }
      xsDisableSelf();
}

//==============================================================================
// RULE getKingOfTheHillVault
//==============================================================================
rule getKingOfTheHillVault
   minInterval 17
   runImmediately
   active
{
   //If we're not on KOTH, go away.
   if ((cvRandomMapName != "king of the hill") || (gKOTHPlentyUnitID == -1))
   {
      xsDisableSelf();
      return;
   }

   //If we already have a attack goals, then quit.
   if (aiPlanGetIDByTypeAndVariableType(cPlanGoal, cGoalPlanGoalType, cGoalPlanGoalTypeAttack, true) >= 0)
      return;
   //If we already have a scout plan for this, bail.
   if (aiPlanGetIDByTypeAndVariableType(cPlanExplore, cExplorePlanNumberOfLoops, -1, true) >= 0)
      return;
   
   //Create an explore plan to go there.
   vector unitLocation=kbUnitGetPosition(gKOTHPlentyUnitID);
   int exploreID=aiPlanCreate("getPlenty", cPlanExplore);
	if (exploreID >= 0)
	{
      aiPlanAddUnitType(exploreID, cUnitTypeLogicalTypeLandMilitary, 5, 5, 5);
      aiPlanAddWaypoint(exploreID, unitLocation);
      aiPlanSetVariableBool(exploreID, cExplorePlanDoLoops, 0, false);
      aiPlanSetVariableBool(exploreID, cExplorePlanQuitWhenPointIsVisible, 0, true);
      aiPlanSetVariableBool(exploreID, cExplorePlanAvoidingAttackedAreas, 0, false);
      aiPlanSetVariableInt(exploreID, cExplorePlanNumberOfLoops, 0, -1);
      aiPlanSetRequiresAllNeedUnits(exploreID, true);
      aiPlanSetVariableVector(exploreID, cExplorePlanQuitWhenPointIsVisiblePt, 0, unitLocation);
		aiPlanSetDesiredPriority(exploreID, 100);
      aiPlanSetActive(exploreID);
	}
}

//==============================================================================
// RULE trainMythUnit
//==============================================================================
rule trainMythUnit
   minInterval 17
   inactive
{
   // Treaty prevents us from doing stuff
   if(TreatyPrevents())
   {
	return;
   }

   if (kbResourceGet(cResourceFavor) < 75)
      return;

   static int planID = -1;


   //Get the PUID of a myth unit that we can train right now.
   int puid=kbGetRandomEnabledPUID(cUnitTypeMythUnit, cMilitaryEscrowID);
   printEcho("TrainMythUnit gets "+puid);

   if (puid < 0)
      return;

   if (puid == cUnitTypeRoc)
      return;

   if (puid == cUnitTypeFlyingMedic)
      return;

   if (puid == cUnitTypePegasus)
      return;

   if (puid == cUnitTypeDryad)
      return;

   if (puid == cUnitTypeServant)
      return;

   if (puid == cUnitTypeOracleScout)
      return;


   if (planID != -1)
      aiPlanDestroy(planID);     // Kill old one to keep from stacking up.

   //Create the plan.
   string planName="Myth Train "+kbGetProtoUnitName(puid);
   printEcho("Training a myth unit: "+kbGetProtoUnitName(puid));
   planID=aiPlanCreate(planName, cPlanTrain);
   if (planID < 0)
      return;
   //Military.
   aiPlanSetMilitary(planID, true);
   //Unit type.
   aiPlanSetVariableInt(planID, cTrainPlanUnitType, 0, puid);
   //Number.
   aiPlanSetVariableInt(planID, cTrainPlanNumberToTrain, 0, 1);
   //Train at main base.
   int mainBaseID=kbBaseGetMainID(cMyID);
   if (mainBaseID >= 0)
   {
      aiPlanSetBaseID(planID, mainBaseID);
      aiPlanSetVariableVector(planID, cTrainPlanGatherPoint, 0, kbBaseGetMilitaryGatherPoint(cMyID, mainBaseID));
   }
   aiPlanSetVariableBool(planID, cTrainPlanUseMultipleBuildings, 0, true);

   aiPlanSetActive(planID);
}

//==============================================================================
// RULE NavalGoalMonitor
//==============================================================================
rule NavalGoalMonitor
   minInterval 13
   inactive
{
   //Don't do anything in the first age.
   if ((kbGetAge() < 1) || (aiGetMostHatedPlayerID() < 0))
      return;

	// Treaty prevents us from doing stuff
	if(TreatyPrevents())
	{
		return;
	}

   //See if we have any enemy warships running around.
   int numberEnemyWarships=0;
   //Find the largest warship count for any of our enemies.
   for (i=1; < cNumberPlayers)
   {
      if ((kbIsPlayerEnemy(i) == true) &&
	 (kbIsPlayerResigned(i) == false) &&
	 (kbHasPlayerLost(i) == false))
      {
	 int tempNumberEnemyWarships=kbUnitCount(i, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
	 if ( cvMasterDifficulty > cDifficultyModerate )
	 {
	    tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipGreek, cUnitStateAlive)/2;
	    tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipNorse, cUnitStateAlive)/2;
	    tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipAtlantean, cUnitStateAlive)/2;
	    tempNumberEnemyWarships = tempNumberEnemyWarships + kbUnitCount(i, cUnitTypeFishingShipEgyptian, cUnitStateAlive)/2;
	 }
	 //int tempNumberEnemyDocks=kbUnitCount(i, cUnitTypeDock, cUnitStateAlive);
	 if (tempNumberEnemyWarships > numberEnemyWarships)
	    numberEnemyWarships=tempNumberEnemyWarships;
	 if (gFakeDeathmatch && numberEnemyWarships < 1)
	    numberEnemyWarships=4;
      }
   }
   //Figure out the min/max number of warships we want.
   int minShips=0;
   int maxShips=0;
   if (numberEnemyWarships > 0)
   {
      //Build at most 2 ships on easy.
      if (cvMasterDifficulty == cDifficultyEasy)
      {
	 minShips=1;
	 maxShips=2;
      }
      //Build at most "6" ships on moderate.
      else if (cvMasterDifficulty == cDifficultyModerate)
      {
	 minShips=numberEnemyWarships/2;
	 maxShips=numberEnemyWarships*3/4;
	 if (minShips < 1)
	    minShips=1;
	 if (maxShips < 1)
	    maxShips=1;
	 if (minShips > 3)
	    minShips=3;
	 if (maxShips > 6)
	    maxShips=6;
      }
      //Build the "same" number (within reason) on Hard/Titan.
      else if (cvMasterDifficulty == cDifficultyHard)
      {
	 minShips=numberEnemyWarships*3/4;
	 maxShips=numberEnemyWarships;
	 if (minShips < 1)
	    minShips=1;
	 if (maxShips < 1)
	    maxShips=1;
	 if (minShips > 5)
	    minShips=5;
	 if (maxShips > 8)
	    maxShips=8;
      }else{
	 minShips=numberEnemyWarships*3/4;
	 maxShips=numberEnemyWarships;
	 if (minShips < 1)
	    minShips=1;
	 if (maxShips < 1)
	    maxShips=1;
	 if (minShips > 5)
	    minShips=5;
	 if (maxShips > 12)
	    maxShips=12;
      }
   }

   //If this is enabled on KOTH, that means we have the water version.  Pretend the enemy
   //has lots of boats so that we will have lots, too.
   if (cvRandomMapName == "king of the hill" || gFakeDeathmatch == true)
   {
      minShips=6;
      maxShips=12;
   }

   //  At 2-3 pop each, don't let this take up most of our military space.
   if ( maxShips > aiGetMilitaryPop()/5 )
   {
      maxShips = aiGetMilitaryPop()/5;
   }

   if(kbGetAge() >= cAge4)	//This is new. Let's see if it works!
   {
	int mhpMilCount = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
	int myMilCount = kbUnitCount(cMyID, cUnitTypeLogicalTypeLandMilitary, cUnitStateAlive);
	int mhpShipCount = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
	int myShipCount = kbUnitCount(cMyID, cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);

	if (mhpMilCount > myMilCount && mhpShipCount < myShipCount && myShipCount > 5)
	{
		minShips = minShips -1;
		maxShips = minShips;
		aiTaskUnitDelete(findWeakestUnit(cMyID, cUnitStateAlive, cUnitTypeLogicalTypeNavalMilitary)); //Kill a NavalUnit
		//That's the price we pay! But we need more pop space anyway.
	}
   }

   if ( minShips > maxShips)
      minShips = maxShips;

   gTargetNavySize = maxShips;   // Set the global var for forecasting

   //If we already have a Naval UP, just set the numbers and be done.  If we don't
   //want anything, just set 1 since we've already done it before.
   if (gNavalUPID >= 0)
   {
      if (maxShips <= 0)
      {
	 kbUnitPickSetMinimumNumberUnits(gNavalUPID, 1);
	 kbUnitPickSetMaximumNumberUnits(gNavalUPID, 1);
      }
      else
      {
	 kbUnitPickSetMinimumNumberUnits(gNavalUPID, minShips);
	 kbUnitPickSetMaximumNumberUnits(gNavalUPID, maxShips);
      }
      return;
   }

   //Else, we don't have a Naval attack goal yet.  If we don't want any ships,
   //just return.
   if (maxShips <= 0)
      return;
    
   //Else, create the Naval attack goal.
   printEcho("Creating NavalAttackGoal for "+maxShips+" ships since I've seen "+numberEnemyWarships+" for Player "+aiGetMostHatedPlayerID()+".");
   gNavalUPID=kbUnitPickCreate("Naval");
   if (gNavalUPID < 0)
   {
      xsDisableSelf();
      return;
   }
   //Fill in the UP.
   kbUnitPickResetAll(gNavalUPID);
   kbUnitPickSetPreferenceWeight(gNavalUPID, 2.0);
   kbUnitPickSetCombatEfficiencyWeight(gNavalUPID, 4.0);
   kbUnitPickSetCostWeight(gNavalUPID, 7.0);
   kbUnitPickSetDesiredNumberUnitTypes(gNavalUPID, 3, 2, true);
   kbUnitPickSetMinimumNumberUnits(gNavalUPID, minShips);
   kbUnitPickSetMaximumNumberUnits(gNavalUPID, maxShips);
   kbUnitPickSetAttackUnitType(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary);
   kbUnitPickSetGoalCombatEfficiencyType(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary);
   kbUnitPickSetPreferenceFactor(gNavalUPID, cUnitTypeArcherShip, 1.0);
   kbUnitPickSetPreferenceFactor(gNavalUPID, cUnitTypeSiegeShip, 1.0);
   kbUnitPickSetPreferenceFactor(gNavalUPID, cUnitTypeLogicalTypeNavalMilitary, 0.8);
   kbUnitPickSetMovementType(gNavalUPID, cMovementTypeWater);
   //Create the attack goal.
   gNavalAttackGoalID=createSimpleAttackGoal("Naval Attack", -1, gNavalUPID, -1, kbGetAge(), -1, -1, false);
   if (gNavalAttackGoalID < 0)
   {
      xsDisableSelf();
      return;
   }
   aiPlanSetVariableBool(gNavalAttackGoalID, cGoalPlanAutoUpdateBase, 0, false);
   aiPlanSetVariableBool(gNavalAttackGoalID, cGoalPlanSetAreaGroups, 0, false);
}

//==============================================================================
// RULE: dockMonitorDM		(FakeDeathmatch)
//==============================================================================
rule dockMonitorDM
   inactive
   minInterval 8
{
   if (gFakeDeathmatch == true)		//Most likely tiny (or something else)
   {
	printEcho("Activating fake deathmatch water build!");
	xsDisableRule("buildSecondDock");

	int myDocks = kbUnitCount(cMyID, cUnitTypeDock, cUnitStateAliveOrBuilding);
	int mhpDocks = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeDock, cUnitStateAliveOrBuilding);

	if (mhpDocks < 0 && kbUnitCount(0, cUnitTypeWave, cUnitStateAlive) < 0)
	{
				return;		//Not the water version...
	}else{
		if(gTransportMap == false)
		{
			gTransportMap = true;			//Just assume we need a transport.
		}
			xsEnableRule("NavalGoalMonitor");	//Let's go!
			gTargetMilitarySize = 40;
	}

	//Don't allow me to have more than one dock less
	if (myDocks < mhpDocks-1)
	{
		int areaID = kbAreaGetClosetArea(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)), cAreaTypeWater);
		int buildDock = aiPlanCreate("BuildDockDM", cPlanBuild);
		if (buildDock >= 0)
		{
		   //Build one.
		   vector mainBaseLocation = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
		   vector dockPosition = kbAreaGetCenter(kbAreaGetClosetArea(mainBaseLocation, cAreaTypeWater));
		   aiPlanSetVariableInt(buildDock, cBuildPlanBuildingTypeID, 0, cUnitTypeDock);
		   aiPlanSetDesiredPriority(buildDock, 100);
		   aiPlanSetNumberVariableValues(buildDock, cBuildPlanDockPlacementPoint, 2);
		   aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 0, mainBaseLocation);
		   aiPlanSetVariableVector(buildDock, cBuildPlanDockPlacementPoint, 1, dockPosition);
		   aiPlanAddUnitType(buildDock, getBuilderType(), 1, 1, 1);
		   aiPlanSetEscrowID(buildDock, cMilitaryEscrowID);
		   aiPlanSetActive(buildDock);
		}
		//Add a dock to forecast
		addUnitForecast(cUnitTypeDock, 1);
	}
		if (myDocks > 0 && kbGetAge() >= cAge2 && gTransportMap)
		{
			if(gTargetNavySize < 0)
			{
				gTargetNavySize = 10;			//We need ships, now!
			}else{
				int mhpShips = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeLogicalTypeNavalMilitary, cUnitStateAlive);
				if(mhpShips > gTargetNavySize +1)
				{
					gTargetNavySize++;			//More!
				}
			}
		}
   }
	else
	{
		xsDisableSelf();		//Go away, we don't need this.
	}
}

//==============================================================================
// RULE getOmniscience
//==============================================================================
rule getOmniscience
   minInterval 24
   inactive
{
   //If we can afford it twice over, then get it.
   float goldCost=kbTechCostPerResource(cTechOmniscience, cResourceGold) * 2.0;
   float currentGold=kbResourceGet(cResourceGold);
   if(goldCost>currentGold)
      return;

   //Get Omniscience
   int voePID=aiPlanCreate("GetOmniscience", cPlanProgression);
	if (voePID != 0)
   {
      aiPlanSetVariableInt(voePID, cProgressionPlanGoalTechID, 0, cTechOmniscience);
	   aiPlanSetDesiredPriority(voePID, 25);
	   aiPlanSetEscrowID(voePID, cMilitaryEscrowID);
	   aiPlanSetActive(voePID);
   }
   xsDisableSelf();
}

//==============================================================================
// RULE getOlympicParentage
//==============================================================================
rule getOlympicParentage
   minInterval 16
   active
{
   //If we're not Zeus, go away.
   if (cMyCiv != cCivZeus)
   {
      xsDisableSelf();
      return;
   }
   //Skip if in 1st or 2nd age.
   if (kbGetAge() < 2)
      return;
   //If in 3rd, make sure we have enough food.
   if (kbGetAge() == 2)
   {
      if(kbResourceGet(cResourceFood) < 600)
	 return;
   }

   //Get Olympic Parentage.
   int opPID=aiPlanCreate("GetOlympicParentage", cPlanProgression);
   if (opPID != 0)
   {
      aiPlanSetVariableInt(opPID, cProgressionPlanGoalTechID, 0, cTechOlympicParentage);
	   aiPlanSetDesiredPriority(opPID, 25);
	   aiPlanSetEscrowID(opPID, cMilitaryEscrowID);
	   aiPlanSetActive(opPID);
   }

   xsDisableSelf();
}

//==============================================================================
// RULE repairTitanGate
//==============================================================================
rule repairTitanGate
   minInterval 10
   inactive
{
   if(gModName == "HoM")	//Go away.
   {
		return;
		xsDisableSelf();
   }

   int buildingID = -1;

   // Find the Titan Gate..
   static int tgQueryID=-1;
   //If we don't have a query ID, create it.
   if (tgQueryID < 0)
   {
     printEcho("       ======< Creating Titan Gate Query>=======");
     tgQueryID=kbUnitQueryCreate("TitanGateQuery");
     //If we still don't have one, bail.
     if (tgQueryID < 0)
     {
       printEcho("       ======< Unable to create query.  Returning.>=======");
    	 xsDisableSelf();
  	    return;
     }
     //Else, setup the query data.
     kbUnitQuerySetPlayerID(tgQueryID, cMyID);
     kbUnitQuerySetUnitType(tgQueryID, cUnitTypeTitanGate);
     kbUnitQuerySetState(tgQueryID, cUnitStateBuilding);
   }

   int numBuilders = kbUnitCount(cMyID, cUnitTypeAbstractVillager, cUnitStateAlive);      // Used to set fractions we use for the titan gate
   if (cMyCulture == cCultureNorse)
      numBuilders = kbUnitCount(cMyID, cUnitTypeAbstractInfantry, cUnitStateAlive);       // Get all inf, not just ulfsarks
   printEcho("Found "+numBuilders+" total builders available.");

   //Reset the results.
   kbUnitQueryResetResults(tgQueryID);
   //Run the query.  
   if (kbUnitQueryExecute(tgQueryID) > 0)
     buildingID = kbUnitQueryGetResult(tgQueryID, 0);

   if (buildingID >= 0)
   {
     printEcho("       ======< Executed query.  Found at least 1 gate.>=======");
     //Don't create another plan for the same building.
     if (aiPlanGetIDByTypeAndVariableType(cPlanRepair, cRepairPlanTargetID, buildingID, true) >= 0)
     {
    	 xsDisableSelf();
	    return;
     }

     //Create the plan.
     int planID=aiPlanCreate("BuildTitanGate", cPlanRepair);
     if (planID < 0)
     {
       printEcho("       ======< Failed to create Plan. >=======");
    	 xsDisableSelf();
	    return;
     }

     aiPlanSetDesiredPriority(planID, 100);
     aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
     aiPlanSetVariableInt(planID, cRepairPlanTargetID, 0, buildingID);
     aiPlanSetInitialPosition(planID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
     if (cMyCulture != cCultureNorse)
	aiPlanAddUnitType(planID, cUnitTypeAbstractVillager, numBuilders/3, numBuilders/2, (numBuilders*2)/3);
     else
	    aiPlanAddUnitType(planID, cUnitTypeAbstractInfantry, numBuilders/3, numBuilders/2, (numBuilders*2)/3);
     aiPlanSetVariableBool(planID, cRepairPlanIsTitanGate, 0, true);
     aiPlanSetActive(planID);
     xsDisableSelf();
   }
   else
     printEcho("       ======< No Gates found.  No AI plan launched.>=======");

   return;

}

//==============================================================================
// RULE guardBestSettlement
//==============================================================================
rule guardBestSettlement
active
minInterval 15
group AttackRules
{
	if (kbGetAge() < cAge2  ||  cvMasterDifficulty == cDifficultyEasy)
	   return;

	if (kbUnitCount(cMyID, cUnitTypeMilitary, cUnitStateAlive) <= 10)
	   return;

	int tcID = gMainBaseID;
	int mhpSettleCount = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeAbstractSettlement, cUnitStateAlive);
	int mySettleCount = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeAbstractSettlement, cUnitStateAlive);
	if (((mhpSettleCount < 2) || (mhpSettleCount < mySettleCount)) && (gTransportMap == false))
	{
		tcID = findClosestRelTo(tcID, aiGetMostHatedPlayerID(), cUnitStateAlive, cUnitTypeAbstractSettlement);
	}
	int settleID = findClosestRelTo(tcID, 0, cUnitStateAlive, cUnitTypeSettlement);
	vector settleLoc = kbUnitGetPosition(settleID);

	if (settleID < 0  &&  aiPlanGetActive(gSettlementGuardPlan))
	{
	   //All settlements claimed. Destroy the plan and go away!
	   aiPlanSetNoMoreUnits(gSettlementGuardPlan, true);
	   aiPlanSetDesiredPriority(gSettlementGuardPlan, 0);
	   aiPlanDestroy(gSettlementGuardPlan);
	   	return;
	}

	if (gGuardSettlementID != settleID  &&  aiPlanGetActive(gSettlementGuardPlan))
	{
	   aiPlanDestroyByName("Guard Settlement "+cMyID);	//Destroy any old plan!
	   aiPlanSetDesiredPriority(gSettlementGuardPlan, 0);
	   aiPlanSetNoMoreUnits(gSettlementGuardPlan, true);
		gSettlementGuardPlan = -1;			//Now continue and create a new one.
	}else{
		if (aiPlanGetActive(gSettlementGuardPlan))
		{
			return;					//Only one plan, no more.
		}
		//This is the first time we got here. Go ahead and create a plan!
	}

	gGuardSettlementID = settleID;		//assign the new ID to check at the next iteration.

	if( kbAreaGroupGetIDByPosition(settleLoc) == kbAreaGroupGetIDByPosition(kbBaseGetLocation(cMyID, tcID)) )
	{
		gSettlementGuardPlan=aiPlanCreate("Guard Settlement "+cMyID, cPlanDefend);
		if(gSettlementGuardPlan >= 0)
		{
		  aiPlanAddUnitType(gSettlementGuardPlan, cUnitTypeHumanSoldier, 2, 2, 4);	//Should do...
		  if(aiGetGameMode() == cGameModeDeathmatch) {
		  	aiPlanSetDesiredPriority(gSettlementGuardPlan, 80);
		  }else{
		  	aiPlanSetDesiredPriority(gSettlementGuardPlan, 15);
		  }
		  aiPlanSetVariableVector(gSettlementGuardPlan, cDefendPlanDefendPoint, 0, settleLoc);
		  aiPlanSetVariableFloat(gSettlementGuardPlan, cDefendPlanEngageRange, 0, 20.0);
		  aiPlanSetVariableBool(gSettlementGuardPlan, cDefendPlanPatrol, 0, false);

		  aiPlanSetVariableFloat(gSettlementGuardPlan, cDefendPlanGatherDistance, 0, 8.0);
		  aiPlanSetInitialPosition(gSettlementGuardPlan, settleLoc);
		  aiPlanSetUnitStance(gSettlementGuardPlan, cUnitStanceDefensive);

		  aiPlanSetVariableInt(gSettlementGuardPlan, cDefendPlanRefreshFrequency, 0, 9);
		  aiPlanSetNumberVariableValues(gSettlementGuardPlan, cDefendPlanAttackTypeID, 3, true);
		  aiPlanSetVariableInt(gSettlementGuardPlan, cDefendPlanAttackTypeID, 0, getBuilderType());
		  aiPlanSetVariableInt(gSettlementGuardPlan, cDefendPlanAttackTypeID, 1, cUnitTypeUnit);
		  aiPlanSetVariableInt(gSettlementGuardPlan, cDefendPlanAttackTypeID, 2, cUnitTypeBuilding);

		  aiPlanAddUserVariableInt(gSettlementGuardPlan, 0, "SelfDestruct Timer", 2);
		  aiPlanSetUserVariableInt(gSettlementGuardPlan, 0, 0, 150);
		  aiPlanSetUserVariableInt(gSettlementGuardPlan, 0, 1, xsGetTime()+3*60*1000);

		  aiPlanSetActive(gSettlementGuardPlan);
		  printEcho("Creating unclaimed settlement defend plan");
		}
	}
}

//==============================================================================
// RULE towerSettlements	[todo]
//==============================================================================
rule towerSettlements
   minInterval 35
   inactive
{/*
   // Starting at hard difficulty.
   if ((cvOkToBuildTowers == false) || (cvMasterDifficulty < cDifficultyHard) || (gTransportMap))
   {
      xsDisableSelf();
      return;
   }

   // Make sure we already have the techs for it.
   if ( ((kbGetTechStatus(cTechWatchTower) == cTechStatusActive) || cMyCiv == cCivGaia)
      && (kbResourceGet(cResourceWood) > 200) && (kbResourceGet(cResourceGold) > 200) )
  {

	//Choose a Unit to build
	int buildingID = cUnitTypeTower;
	int buildDistance = 8;
	if(cMyCiv == cCivGaia)			//Lush has a similar effect.
	{
		buildingID = cUnitTypeBarracksAtlantean;
		buildDistance = 12;
	}
	if(kbCanAffordUnit(buildingID, cMilitaryEscrowID) == false)
	{
		aiPlanDestroyByName("SettleProtection"+cMyID);
		return;
	}
	//Find an unclaimed(!) settlement and check if we should build there
	int settleID = findUnitRM(0, cUnitStateAlive, cUnitTypeSettlement, true);
	int towerID = findClosestRelTo(settleID, cMyID, cUnitStateAliveOrBuilding, cUnitTypeBuildingsThatShoot);
	if(calcDistanceToUnit(settleID,towerID) < 20)
	{
		aiPlanDestroyByName("SettleProtection"+cMyID);
		return;
	}
	if(settleID < 0)	//Nothing found.
	{
		aiPlanDestroyByName("SettleProtection"+cMyID);
		return;
	}
	//Build it in attack range
	vector unitLoc = kbUnitGetPosition(settleID);
	int ax = xsVectorGetX(unitLoc);
	int ay = xsVectorGetY(unitLoc);
	int az = xsVectorGetZ(unitLoc);
	vector baseLoc = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID));
	int bx = xsVectorGetX(baseLoc);
	int by = xsVectorGetY(baseLoc);
	int bz = xsVectorGetZ(baseLoc);
	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*buildDistance;
	int py = xsVectorGetY(path)*buildDistance;
	int pz = xsVectorGetZ(path)*buildDistance;
	vector buildPoint = xsVectorSet(ax-px,ay-py,az-pz);

	//Build at buildPoint
	int towerSettlementPlan = aiPlanCreate("SettleProtection"+cMyID, cPlanBuild);
	if (towerSettlementPlan >= 0)
	{
		aiPlanSetInitialPosition(towerSettlementPlan, buildPoint);
		aiPlanSetVariableInt(towerSettlementPlan, cBuildPlanBuildingTypeID, 0, buildingID);

	   if(cMyCiv == cCivGaia) {
		aiPlanSetVariableInt(towerSettlementPlan, cBuildPlanMaxRetries, 0, 4);
	   }else{
		aiPlanSetVariableInt(towerSettlementPlan, cBuildPlanMaxRetries, 0, 2);
	   }
		aiPlanSetDesiredPriority(towerSettlementPlan, 100);

		aiPlanSetVariableVector(towerSettlementPlan, cBuildPlanInfluencePosition, 0, buildPoint);
		aiPlanSetVariableFloat(towerSettlementPlan, cBuildPlanInfluencePositionDistance, 0, 10);
		aiPlanSetVariableFloat(towerSettlementPlan, cBuildPlanInfluencePositionValue, 0, 98.0);

	   if(cMyCulture == cCultureAtlantean) {
		aiPlanAddUnitType(towerSettlementPlan, getBuilderType(), 1, 1, 1);
	   }else{
		aiPlanAddUnitType(towerSettlementPlan, getBuilderType(), 1, 2, 2);
	   }
		aiPlanSetEscrowID(towerSettlementPlan, cEconomyEscrowID);
		aiPlanAddUserVariableInt(towerSettlementPlan, 0, "Ignore Me", 1);
		aiPlanSetUserVariableInt(towerSettlementPlan, 0, 0, 250);
		aiPlanSetActive(towerSettlementPlan);
	}
  }*/
}

//==============================================================================
// RULE buildSkyPassages
//==============================================================================
rule buildSkyPassages
   minInterval 28
   inactive
{
   printEcho("Sky Passages check running...");
   // Make sure we have a sky passage at home, and one near the nearest TC of 
   // our Most Hated Player.  
   if (aiPlanGetIDByTypeAndVariableType(cPlanBuild, cBuildPlanBuildingTypeID, cUnitTypeSkyPassage) >= 0)
      return;  // Quit if we're already building one

   if (kbBaseGetNumberUnits(cMyID, kbBaseGetMainID(cMyID), cPlayerRelationSelf, cUnitTypeSkyPassage) < 1)
   {  // We don't have one...make sure we have a plan in the works
      printEcho("    Creating a local sky passage.");
	   int planID=aiPlanCreate("BuildLocalSkyPassage", cPlanBuild);
      if (planID < 0)
	 return;
      aiPlanSetVariableInt(planID, cBuildPlanBuildingTypeID, 0, cUnitTypeSkyPassage);
 	   aiPlanSetVariableInt(planID, cBuildPlanNumAreaBorderLayers, 0, 
	 kbAreaGetIDByPosition(kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID))) );
      aiPlanSetDesiredPriority(planID, 70);
      aiPlanSetMilitary(planID, true);
      aiPlanSetEconomy(planID, false);
      aiPlanSetEscrowID(planID, cMilitaryEscrowID);
	   aiPlanAddUnitType(planID, getBuilderType(),
	 1, 1, 1);
      aiPlanSetBaseID(planID, kbBaseGetMainID(cMyID));
      aiPlanSetActive(planID);

      return;  // Don't start second until first is done
   }


   // Local base is covered, now let's check near our Most Hated Player's TC
   static int nearestMhpTCQueryID = -1;
   if (nearestMhpTCQueryID < 0)
   {
      nearestMhpTCQueryID = kbUnitQueryCreate("MostHatedPlayerTC");
   }
   kbUnitQuerySetPlayerID(nearestMhpTCQueryID, aiGetMostHatedPlayerID());
   kbUnitQuerySetUnitType(nearestMhpTCQueryID, cUnitTypeAbstractSettlement);
   kbUnitQuerySetState(nearestMhpTCQueryID, cUnitStateAliveOrBuilding);
   kbUnitQuerySetPosition(nearestMhpTCQueryID, kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)));
   kbUnitQuerySetAscendingSort(nearestMhpTCQueryID, true);

   kbUnitQueryResetResults(nearestMhpTCQueryID);
   printEcho("*****    Checking for most hated player ("+aiGetMostHatedPlayerID()+") TC.");
   int numTCs = kbUnitQueryExecute(nearestMhpTCQueryID);
   if (numTCs < 1)
      return;  // No enemy TCs
   int enemyTC = kbUnitQueryGetResult(nearestMhpTCQueryID, aiRandInt(numTCs));   // ID of enemy TC we want to search, random selection
   vector enemyTCvec = kbUnitGetPosition(enemyTC);
   printEcho("    TC is at "+enemyTCvec);

   // We now know the nearest enemyTC, let's look for a sky passage near there
   static int skyPassageQueryID = -1;
   if (skyPassageQueryID < 0)
   {
      skyPassageQueryID = kbUnitQueryCreate("RemoteSkyPassage");
      kbUnitQuerySetPlayerID(skyPassageQueryID, cMyID);
      kbUnitQuerySetUnitType(skyPassageQueryID, cUnitTypeSkyPassage);
      kbUnitQuerySetState(skyPassageQueryID, cUnitStateAliveOrBuilding);
      kbUnitQuerySetMaximumDistance(skyPassageQueryID, 80.0);
   }
   kbUnitQuerySetPosition(skyPassageQueryID, enemyTCvec);
   kbUnitQueryResetResults(skyPassageQueryID);
   printEcho("    Looking for sky passage near "+enemyTCvec);
   if (kbUnitQueryExecute(skyPassageQueryID) < 1)
   {  // None found, we need one...and we don't have an active plan.
      // First, pick a center location on our side of the enemy TC
      vector offset = kbBaseGetLocation(cMyID, kbBaseGetMainID(cMyID)) - enemyTCvec;
      offset = xsVectorNormalize(offset);
      vector target = enemyTCvec + (offset * 60.0);
      
      printEcho("    Considering target location "+target);
	  
      // Figure out if it's on our enemy's areaGroup.  If not, step 5% closer until it is.
      int enemyAreaGroup = -1;
      int testAreaGroup = -1;
      testAreaGroup = kbAreaGroupGetIDByPosition(target);
      enemyAreaGroup = kbAreaGroupGetIDByPosition(enemyTCvec);
      printEcho("    Target location "+target+" is in areaGroup "+testAreaGroup);
      printEcho("    Enemy TC is in areaGroup "+enemyAreaGroup);

      int i = -1;

      vector towardEnemy = offset * -5.0;    // 5m away from me, toward enemy TC
      bool success = false;

      for (i=0; <18)    // Keep testing until areaGroups match
      {
	 testAreaGroup = kbAreaGroupGetIDByPosition(target);
	 if (testAreaGroup == enemyAreaGroup)
	 {
	    success = true;
	    printEcho("    Test location "+target+" is in areaGroup "+testAreaGroup);
	    break;
	 }
	 else
	 {
	    printEcho("    Test location "+target+" is in areaGroup "+testAreaGroup);
	    target = target + towardEnemy;   // Try a bit closer
	 }
      }
  

      // We have a target and it's on land...
      printEcho("    Creating a remote sky passage at "+target);
	   int remotePlanID=aiPlanCreate("BuildRemoteSkyPassage", cPlanBuild);
      if (remotePlanID < 0)
	 return;
      aiPlanSetVariableInt(remotePlanID, cBuildPlanBuildingTypeID, 0, cUnitTypeSkyPassage);
      aiPlanSetVariableInt(remotePlanID, cBuildPlanAreaID, 0, kbAreaGetIDByPosition(target));
 	   aiPlanSetVariableInt(remotePlanID, cBuildPlanNumAreaBorderLayers, 0, 1);
      aiPlanSetDesiredPriority(remotePlanID, 70);
      aiPlanSetMilitary(remotePlanID, true);
      aiPlanSetEconomy(remotePlanID, false);
      aiPlanSetEscrowID(remotePlanID, cMilitaryEscrowID);
	   aiPlanAddUnitType(remotePlanID, getBuilderType(), 1, 1, 1);
      aiPlanSetActive(remotePlanID);
   }
}

//==============================================================================
// RULE hesperides
//==============================================================================
rule hesperides      // Watch for ownership of a hesperides tree, make driads if you own it.
   minInterval 34
   active
{
   static bool iHaveOne = false;
   static int driadPlan = -1;

   if (iHaveOne == true)   // I think I have one...verify, kill maintain plan if not.
   {
      if (kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive) < 1)   // It's gone!
      {
	 printEcho("Lost the hesperides tree.");
	 aiPlanDestroy(driadPlan);
	 iHaveOne = false;
      }
   }
   else     // I don't think I have one...see if one has appeared, and set up maintain plan if it has
   {
      if (kbUnitCount(cMyID, cUnitTypeHesperidesTree, cUnitStateAlive) > 0)   // I have one!
      {
	 printEcho("I have a hesperides tree.");
	 iHaveOne = true;
	 driadPlan = createSimpleMaintainPlan(cUnitTypeDryad, 5, false, kbBaseGetMainID(cMyID)) ;
      }
   }
}

//==============================================================================
// RULE buildForwardBuildings
//==============================================================================
rule buildForwardBuildings
   minInterval 35
   inactive
{
   if ((cvMasterDifficulty <= cDifficultyHard) || (gTransportMap))
   {
      xsDisableSelf();
      return;
   }
   int currentPopCap = kbGetPopCap();
   int currentPop = kbGetPop();
   if (currentPop <= currentPopCap*0.5)
   {
	return;
   }
	gFowardBuildings = true;	//Only build where we need it!

   // Make sure we already have the resources for it.
   if (
	(kbResourceGet(cResourceWood) > 300 && cMyCulture != cCultureEgyptian && cMyCulture != cCultureAtlantean)
	||
	(kbResourceGet(cResourceGold) > 200 && cMyCulture == cCultureEgyptian && cMyCulture != cCultureAtlantean)
	||
	(kbResourceGet(cResourceGold) > 200 && kbResourceGet(cResourceWood) > 300)
      )
   {

	//Choose a Unit to build
	int buildingID1 = kbTechTreeGetUnitIDByTrain(kbUnitPickGetResult(gLandUPID, 0), cMyCiv);
	int buildingID2 = kbTechTreeGetUnitIDByTrain(kbUnitPickGetResult(gLandUPID, 1), cMyCiv);
	if(cMyCulture == cCultureNorse)
	{
	    if(buildingID1 == cUnitTypeSettlementLevel1)
	    {
		buildingID1 = cUnitTypeLonghouse;
	    }
	    if(buildingID2 == cUnitTypeSettlementLevel1)
	    {
		buildingID2 = cUnitTypeLonghouse;
	    }
	}
	if(kbCanAffordUnit(buildingID1, cMilitaryEscrowID) == false || kbCanAffordUnit(buildingID2, cMilitaryEscrowID) == false)
	{
		return;
	}
	int bigBuildingID = getBigBuildingID();
	if(buildingID1 == getBigBuildingID() || buildingID2 == getBigBuildingID())
	{
	    //We already reached the build limit?
	    if (kbUnitCount(cMyID, bigBuildingID, cUnitStateAlive) >= kbGetBuildLimit(cMyID, bigBuildingID))
	    {
		int oldID = findUnitRM(cMyID, cUnitStateAlive, bigBuildingID, false);
		aiTaskUnitDelete(oldID);	//Make room for a new one!
	    }
	}
	int unitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeMilitary, false, cActionRangedAttack);
	int pegasusID = findClosestRelTo(unitID, -1, cUnitStateAlive, cUnitTypePegasus, cPlayerRelationEnemy);
	int baseID = findClosestRelTo(unitID, cMyID, cUnitStateAlive, cUnitTypeBuildingsThatShoot);
	if(unitID < 0 || baseID < 0)	//Nothing found.
	{
		return;
	}
	if(pegasusID>=0 && calcDistanceToUnit(unitID,pegasusID)<=18)
	{
		return;
	}
	//Try to keep a safe distance
	vector unitLoc = kbUnitGetPosition(unitID);
	int ax = xsVectorGetX(unitLoc);
	int ay = xsVectorGetY(unitLoc);
	int az = xsVectorGetZ(unitLoc);
	vector baseLoc = kbUnitGetPosition(baseID);
	int bx = xsVectorGetX(baseLoc);
	int by = xsVectorGetY(baseLoc);
	int bz = xsVectorGetZ(baseLoc);
	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*8;
	int py = xsVectorGetY(path)*8;
	int pz = xsVectorGetZ(path)*8;
	vector buildPoint = xsVectorSet(ax-px,ay-py,az-pz);

	// Now, check if that's on ground, and just give up if it isn't
	int buildArea = kbAreaGetIDByPosition(buildPoint);
	if ( (kbAreaGetType(buildArea) == cAreaTypeWater) || (kbAreaGetType(buildArea) == cAreaTypeImpassableLand) )
	{
		return;
	}
	kbBaseSetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID), buildPoint);

	//Build at buildPoint
	int OffensiveBuildPlan = aiPlanCreate("PassiveSupportBuildings", cPlanBuild);
	if (OffensiveBuildPlan >= 0)
	{
		aiPlanSetInitialPosition(OffensiveBuildPlan, buildPoint);
		aiPlanSetVariableInt(OffensiveBuildPlan, cBuildPlanBuildingTypeID, 0, buildingID1);
		aiPlanSetVariableInt(OffensiveBuildPlan, cBuildPlanBuildingTypeID, 1, buildingID2);
		aiPlanSetVariableInt(OffensiveBuildPlan, cBuildPlanMaxRetries, 0, 5);
		aiPlanSetDesiredPriority(OffensiveBuildPlan, 70);

		aiPlanSetVariableInt(OffensiveBuildPlan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeTree);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanInfluenceUnitDistance, 0, 10);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanInfluenceUnitValue, 0, 12.0);

		aiPlanSetVariableVector(OffensiveBuildPlan, cBuildPlanInfluencePosition, 0, buildPoint);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanInfluencePositionDistance, 0, 40);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanInfluencePositionValue, 0, 15.0);

		aiPlanSetVariableBool(OffensiveBuildPlan, cBuildPlanInfluenceAtBuilderPosition, 0, true);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanRandomBPValue, 0, 0.99);
		aiPlanSetVariableVector(OffensiveBuildPlan, cBuildPlanCenterPosition, 0, buildPoint);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanCenterPositionDistance, 0, 36.00);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanBuildingBufferSpace, 0, 14.0);

	   if(cMyCulture == cCultureAtlantean) {
		aiPlanAddUnitType(OffensiveBuildPlan, getBuilderType(), 1, 1, 2);
	   }else{
		aiPlanAddUnitType(OffensiveBuildPlan, getBuilderType(), 2, 2, 3);
	   }
		aiPlanSetEscrowID(OffensiveBuildPlan, cEconomyEscrowID);
		aiPlanAddUserVariableInt(OffensiveBuildPlan, 0, "Ignore Me", 1);
		aiPlanSetUserVariableInt(OffensiveBuildPlan, 0, 0, 250);
		aiPlanSetActive(OffensiveBuildPlan);
	}
   }
}

//==============================================================================
// RULE buildForwardTowers
//==============================================================================
rule buildForwardTowers
   minInterval 25
   inactive
{
   if ((cvOkToBuildTowers == false) || (cvMasterDifficulty <= cDifficultyHard) || (gTransportMap))
   {
      xsDisableSelf();
      return;
   }
	gFowardBuildings = true;	//Only build where we need it!

   // Make sure we already have the techs for it.
   if(kbGetTechStatus(cTechWatchTower) != cTechStatusActive)
   {
	// We need to start rolling!
	if(kbUnitCount(cMyID, cUnitTypeTower, cUnitStateAlive) > 3)
	{
		return;
	}else{
		xsEnableRule("towerUpgrade");
	}
   }
   if (getEconPop(cMyID) < getEconPop(aiGetMostHatedPlayerID())*0.6)
   {
	return;		// Don't abuse too many villagers!
   }
   if ( (kbResourceGet(cResourceWood) > 200) && (kbResourceGet(cResourceGold) > 200) )
   {

	//Choose a Unit to build
	int buildingID = cUnitTypeTower;

	switch(aiRandInt(3))
	{
	   case 0:
	   {
		buildingID = cUnitTypeTower;
		if(kbGetTechStatus(cTechAge4Helios) == cTechStatusActive)
		{
			buildingID = cUnitTypeTowerMirror;
		}
		break;
	   }
	   case 2:
	   {
		buildingID = getBigBuildingID();
		break;
	   }
	   	case 3:
	   	{
			buildingID = cUnitTypeTower;	//default
			break;
	   	}
	}
	if(kbCanAffordUnit(buildingID, cMilitaryEscrowID) == false)
	{
		return;
	}
	int unitID = findUnitRM(cMyID, cUnitStateAlive, cUnitTypeMilitary, false, cActionRangedAttack);
	int pegasusID = findClosestRelTo(unitID, -1, cUnitStateAlive, cUnitTypePegasus, cPlayerRelationEnemy);
	int baseID = findClosestRelTo(unitID, cMyID, cUnitStateAlive, cUnitTypeBuildingsThatShoot);
	if(unitID < 0 || baseID < 0)	//Nothing found.
	{
		return;
	}
	if(pegasusID>=0 && calcDistanceToUnit(unitID,pegasusID)<=18)
	{
		return;
	}
	//Try to keep a safe distance
	vector unitLoc = kbUnitGetPosition(unitID);
	int ax = xsVectorGetX(unitLoc);
	int ay = xsVectorGetY(unitLoc);
	int az = xsVectorGetZ(unitLoc);
	vector baseLoc = kbUnitGetPosition(baseID);
	int bx = xsVectorGetX(baseLoc);
	int by = xsVectorGetY(baseLoc);
	int bz = xsVectorGetZ(baseLoc);
	vector path = xsVectorSet(ax-bx,ay-by,az-bz);
	path = xsVectorNormalize(path);
	int px = xsVectorGetX(path)*15;
	int py = xsVectorGetY(path)*15;
	int pz = xsVectorGetZ(path)*15;
	vector buildPoint = xsVectorSet(ax-px,ay-py,az-pz);

	// Now, check if that's on ground, and just give up if it isn't
	int buildArea = kbAreaGetIDByPosition(buildPoint);
	if ( (kbAreaGetType(buildArea) == cAreaTypeWater) || (kbAreaGetType(buildArea) == cAreaTypeImpassableLand) )
	{
		return;
	}
	kbBaseSetMilitaryGatherPoint(cMyID, kbBaseGetMainID(cMyID), buildPoint);

	//We already reached the build limit?
	if (kbUnitCount(cMyID, buildingID, cUnitStateAlive) >= kbGetBuildLimit(cMyID, buildingID))
	{
		int oldID = findUnitRM(cMyID, cUnitStateAlive, buildingID, false);
		aiTaskUnitDelete(oldID);	//Make room for a new one!
	}

	//Build at buildPoint
	int OffensiveBuildPlan = aiPlanCreate("ActiveSupportBuildings", cPlanBuild);
	if (OffensiveBuildPlan >= 0)
	{
		aiPlanSetInitialPosition(OffensiveBuildPlan, buildPoint);
		aiPlanSetVariableInt(OffensiveBuildPlan, cBuildPlanBuildingTypeID, 0, buildingID);
		aiPlanSetVariableInt(OffensiveBuildPlan, cBuildPlanMaxRetries, 0, 10);
		aiPlanSetDesiredPriority(OffensiveBuildPlan, 100);
			
		//Try to favor the placement around the BuildPoint first.
		aiPlanSetVariableVector(OffensiveBuildPlan, cBuildPlanInfluencePosition, 0, buildPoint);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanInfluencePositionDistance, 0, 30);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanInfluencePositionValue, 0, 60.0);
		aiPlanSetVariableInt(OffensiveBuildPlan, cBuildPlanInfluenceUnitTypeID, 0, cUnitTypeMilitary);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanInfluenceUnitDistance, 0, 20);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanInfluenceUnitValue, 0, 50.0);
			
		aiPlanSetVariableBool(OffensiveBuildPlan, cBuildPlanInfluenceAtBuilderPosition, 0, true);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanRandomBPValue, 0, 0.99);
		aiPlanSetVariableVector(OffensiveBuildPlan, cBuildPlanCenterPosition, 0, buildPoint);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanCenterPositionDistance, 0, 14.00);
		aiPlanSetVariableFloat(OffensiveBuildPlan, cBuildPlanBuildingBufferSpace, 0, 4.0);

	   if(cMyCulture == cCultureAtlantean) {
		aiPlanAddUnitType(OffensiveBuildPlan, getBuilderType(), 1, 2, 2);
	   }else{
		aiPlanAddUnitType(OffensiveBuildPlan, getBuilderType(), 3, 5, 5);
	   }
		aiPlanSetEscrowID(OffensiveBuildPlan, cEconomyEscrowID);
		aiPlanAddUserVariableInt(OffensiveBuildPlan, 0, "Ignore Me", 1);
		aiPlanSetUserVariableInt(OffensiveBuildPlan, 0, 0, 250);
		aiPlanSetActive(OffensiveBuildPlan);
	}
   }
}

//==============================================================================
// build Mirrortowers
//==============================================================================
rule buildMirrorTowers
   minInterval 20
   inactive
{
   int pID = cUnitTypeTowerMirror;

   if(
	(kbGetTechStatus(cTechAge4Helios) < cTechStatusResearching)
	&&
	(kbCanAffordUnit(pID, cMilitaryEscrowID)==false)
	&&
	(kbUnitCount(cMyID, pID, cUnitStateAliveOrBuilding) < 3)
     )
   {
		return;		//Go away!
   }
   // Build our unit.
   createSimpleBuildPlan(pID, 1, 80, true, false, cMilitaryEscrowID, kbBaseGetMainID(cMyID), 1);
}

//==============================================================================
// RULE milPopMonitor...monitor mil pop, fix UP targets if jammed
//==============================================================================
rule milPopMonitor
   minInterval 13
   active
{
   static int mode = 0;	     // 0 is monitor; 1 is reducing pop target
   static int originalGoal = -1;    // What was the UP's minimum pop target before reduction?
   static int lastKnownPlan = -1;		// The last attack plan this rule knows about...
   int attackGoalID = gLandAttackGoalID;	// Currently active attack goal
   int UPID = gLandUPID;			// Currently active unit picker
   static int lastKnownAge = -1;		// The age we were last working in


	// The treaty prevents us from doing stuff so no army
	if(TreatyPrevents())
	{
		kbUnitPickSetMinimumPop(gLandUPID, 0);
		kbUnitPickSetMaximumPop(gLandUPID, 0);
		return;
	}

   if (kbGetAge() < cAge2) 
      return;		 // Don't mess with age 1

   if (kbGetAge() != lastKnownAge)
   {
      if (lastKnownAge == cAge2)
      {
	 mode = 0;      // In case we were reducing an age 2 UP when the age advanced
      }
      lastKnownAge = kbGetAge();
   }

   if (mode == 1)    // We're in reduction mode
   {
      if ( aiPlanGetIDByTypeAndVariableType(cPlanAttack, cAttackPlanFromGoalID, attackGoalID) >= 0  )  // There's a new plan!
      {
	 mode = 0;      // Back to monitoring
	 kbUnitPickSetMinimumPop(UPID, originalGoal);  // restore UP target
	 lastKnownPlan = aiPlanGetIDByTypeAndVariableType(cPlanAttack, cAttackPlanFromGoalID, attackGoalID);
	 printEcho("Returning to military monitor mode at pop "+originalGoal+", attack plan "+lastKnownPlan+" has been created.");
      }
      else  // no plan
      {
	 if (aiGetAvailableMilitaryPop() > 10)
	 {  // Our army has been killed, go to monitor
	    mode = 0;
	    kbUnitPickSetMinimumPop(UPID, originalGoal);  // restore UP target
	    printEcho("Returning to military monitor mode at pop "+originalGoal+", no longer at mil pop limit.");
	    return;
	 }
	 if ( kbUnitPickGetMinimumPop(UPID) > 3)
	 {
	    kbUnitPickSetMinimumPop(UPID, kbUnitPickGetMinimumPop(UPID) - 3);      // Lower by 3
	    printEcho("Pop goal is now "+kbUnitPickGetMinimumPop(UPID));
	 }
	 else
	    printEcho("Error, military pop goal is <= 3.");
      }
   }
   else     // We're in monitor mode...see if we're pop capped without an attack plan
   {
      if (attackGoalID == -1)    // No rush goal, just the idle goal, don't worry about it.
	 return;

      if (aiPlanGetVariableBool(attackGoalID, cGoalPlanIdleAttack, 0) == true)
	 return;		 // No real attacks, probably easy difficulty

      if (aiPlanGetState(attackGoalID) == cPlanStateDone)      // No more attacks, waiting to age up.
	 return;

      if (aiGetAvailableMilitaryPop() > 10)
	 return;		 // No sense worrying about it if we still have pop room.

      // look for a land attack plan
      if ( aiPlanGetIDByTypeAndVariableType(cPlanAttack, cAttackPlanFromGoalID, attackGoalID) >= 0 )
	 return;     // We have one

      // If we're here, we're near our mil pop cap and we don't have an attack plan.
      printEcho("Going to military goal reduction mode.");
      mode = 1;
      originalGoal = kbUnitPickGetMinimumPop(UPID);
   }
}

//==============================================================================
// RULE spotAgeUpgrades...detect age upgrades given as starting conditions or via triggers
//==============================================================================
rule spotAgeUpgrades
   minInterval 21
   active
{
   // If my current age is higher than the last upgrade I remember...do the handler

   if ( gLastAgeHandled < kbGetAge() )
   {
      if (gLastAgeHandled == cAge1)
	 age2Handler();
      if (gLastAgeHandled == cAge2)
	 age3Handler();
      if (gLastAgeHandled == cAge3)
	 age4Handler();
      if (gLastAgeHandled == cAge4)
	 age5Handler();

   }
}

//==============================================================================
// MAIN.
//==============================================================================
void runScript(void)
{
   //Set our random seed.  "-1" is a random init.
   aiRandSetSeed(-1);

   //Calculate some areas.
   kbLookAtAllUnitsOnMap();	//Don't worry, it's a fair use here!
   kbAreaCalculate();

   setParameters();     // Set the control variables before anything else

	setTargetEnemy(aiCalculateMostHatedPlayerID());

    detectMods();	//Mod Support.

    gBuilderType = getBuilderType();

   //Go.
   if (cvDelayStart == false)
   {
		init();
   }
}
