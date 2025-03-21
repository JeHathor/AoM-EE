//==============================================================================
// AoMXaiProg.xs
//
// Handles progression.
//==============================================================================

//==============================================================================
// initProgress
//==============================================================================
void initProgress()
{
   xsEnableRule("age1Progress");	//progressAge1
   printEcho("Progress Init.");
}

//==============================================================================
// chooseMinorGod
//==============================================================================
int chooseMinorGod(int age = -1, int mythUnitPref = -1, int godPowerPref = -1)
{
   //So, I know there are only 2 choices in minor god selection.
   int minorGodA=kbTechTreeGetMinorGodChoices(0, age);
   int minorGodB=kbTechTreeGetMinorGodChoices(1, age);
   int finalChoice=-1;

   //Look at the myth units.
   if (mythUnitPref != -1)
   {
	  int currentChoice=minorGodA;
	  for (a=0; < 2)
	  {
		 if (a == 1)
			currentChoice=minorGodB;

		 //Get the list of myth units that minorGodA gives us.
		 int totalMythUnits=kbTechTreeGetMinorGodMythUnitTotal( currentChoice );
		 for (i=0; < totalMythUnits)
		 {
			//Get the myth protounit ID.
			int mythUnitProtoID=kbTechTreeGetMinorGodMythUnitByIndex( currentChoice, i );
		 
			if (mythUnitPref == mythUnitProtoID)
			{
			   finalChoice=currentChoice;
			   break;
			}
		 }

		 //Kick out because we have made our choice.
		 if (finalChoice != -1)
			break;
	  }
   }

   //Look at the god power if we haven't made our finalChoice yet.
   if ((godPowerPref != -1) && (finalChoice == -1))
   {
	  //Get the god power tech ids from the minor god tech.
	  int godPowerTechIDA=kbTechTreeGetGPTechID(minorGodA);
	  int godPowerTechIDB=kbTechTreeGetGPTechID(minorGodB);
	  
	  //Choose minor god.
	  if (godPowerTechIDA == godPowerPref)
		 finalChoice=minorGodA;
	  else if (godPowerTechIDB == godPowerPref)
		 finalChoice=minorGodB;
   }

   //So, no prefs were set, just pick one.
   if (finalChoice == -1)
   {
	  //Choose minor god.
	  if (minorGodA != -1)
		 finalChoice=minorGodA;
	  else if (minorGodB != -1)
		 finalChoice=minorGodB;
   }

   //Return the final minor god choice. Note final Choice can still be invalid.
   return(finalChoice);
}

//==============================================================================
// progressAge2Handler
//==============================================================================
void progressAge2Handler(int age=1)
{
   printEcho("Progress Age "+age+".");
   xsEnableRule("age2Progress");
   xsEnableRule("buildMonuments");
}

//==============================================================================
// progressAge3Handler
//==============================================================================
void progressAge3Handler(int age=2)
{
   printEcho("Progress Age "+age+".");
   xsEnableRule("age3Progress");
   xsEnableRule("buildMonuments");
}

//==============================================================================
// progressAge4Handler
//==============================================================================
void progressAge4Handler(int age=3)
{
   printEcho("Progress Age "+age+".");
   xsEnableRule("buildMonuments");
}

// Age 4 freeze not below
//==============================================================================
// RULE: unPauseAge2
//==============================================================================
rule unPauseAge2
   minInterval 91
   inactive
{
   if (gAge2ProgressionPlanID == -1)
   {
	  printEcho("Age 2 Progression Plan id("+gAge2ProgressionPlanID+") is invalid.");
	  xsDisableSelf();
	  return;
   }

   aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanPaused, false);
   aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanPaused, 0, false);
   aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, false);
   xsDisableSelf();
}

//==============================================================================
// RULE: unPauseAge3
//==============================================================================
rule unPauseAge3
   minInterval 51
   inactive
{
   if (gAge3ProgressionPlanID == -1)
   {
	  printEcho("Age 3 Progression Plan id("+gAge3ProgressionPlanID+") is invalid.");
	  xsDisableSelf();
	  return;
   }

   aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanPaused, false);
   aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanPaused, 0, false);
   aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, false);
   xsDisableSelf();
}

//==============================================================================
// RULE: BuildMonuments
//==============================================================================
rule buildMonuments
   minInterval 117
   inactive
{
   if (cMyCulture != cCultureEgyptian)
   {
	  xsDisableSelf();
	  return;
   }

   static int lastQty = 0;

   int targetNum = -1;
   float scratch = 0.0;
   scratch = (-1.0 * cvRushBoomSlider) + 1.0;  //  0 for extreme rush, 2 for extreme boom
   scratch = (scratch * 1.5) + 0.5;   // 0.5 to 3.5
   targetNum = kbGetAge() + scratch;			  // 0 for extreme rush, 3 for extreme boom, +1 in cAge2, 2 in cAge3, +3 in cAge4
   if ( kbGetAge() == cAge4 )
	  targetNum = 5;
   if ( targetNum > 5 )
	  targetNum = 5;
   printEcho("Ready to build up to "+targetNum+" monuments.");

   //Create the plan to build the monuments.
   int pid=aiPlanCreate("Monuments "+kbGetAge(), cPlanProgression);
   if (pid >= 0)
   { 
	  aiPlanSetNumberVariableValues(pid, cProgressionPlanGoalUnitID, targetNum, true);
	  if (lastQty <= 0)
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 0, cUnitTypeMonument);
	  if ( (targetNum > 1) && (lastQty <= 4) )
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 1, cUnitTypeMonument2);
	  if ( (targetNum > 2) && (lastQty <= 4) )
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 2, cUnitTypeMonument3);
	  if ( (targetNum > 3) && (lastQty <= 4) )
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 3, cUnitTypeMonument4);
	  if ( (targetNum > 4) && (lastQty <= 4) )
		 aiPlanSetVariableInt(pid, cProgressionPlanGoalUnitID, 4, cUnitTypeMonument5);
	  aiPlanSetVariableBool(pid, cProgressionPlanRunInParallel, 0, false);
		aiPlanSetDesiredPriority(pid, 35);
		aiPlanSetEscrowID(pid, cEconomyEscrowID);
	  aiPlanSetBaseID(pid, kbBaseGetMainID(cMyID));
	  aiPlanSetActive(pid);

	  lastQty = targetNum;
   }
   
   //Go away now.
   xsDisableSelf();
}

//==============================================================================
// RULE: age1Progress  ---> Age2
//==============================================================================
rule age1Progress
   minInterval 15
   inactive
{
   if(gModDelayStart == false && xsGetTime() < (4*1000))	//4 sec.
   {
	return;
   }
   if (gAge2MinorGod == -1)
		gAge2MinorGod=chooseMinorGod(cAge2, -1, -1);

	// And now a progression to get to age 2
   gAge2ProgressionPlanID=aiPlanCreate("Age 2", cPlanProgression);
   if ((gAge2ProgressionPlanID >= 0) && (gAge2MinorGod != -1))
   { 
	  aiPlanSetVariableInt(gAge2ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge2MinorGod);
		aiPlanSetDesiredPriority(gAge2ProgressionPlanID, 100);
		aiPlanSetEscrowID(gAge2ProgressionPlanID, cEconomyEscrowID);
	  aiPlanSetBaseID(gAge2ProgressionPlanID, kbBaseGetMainID(cMyID));
	  //Start paused!!
	  aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanPaused, 0, true);
	  aiPlanSetVariableBool(gAge2ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, true);
	  aiPlanSetActive(gAge2ProgressionPlanID);
	  //Unpause after a brief amount of time.
	  if ((cvMigrationMap == false) && (cvNomadMap == false))
		 xsEnableRule("unPauseAge2");
	  //If we have a lot of resources, assume we want to go up fast.
	  if (kbResourceGet(cResourceWood) >= 1000)
		 xsSetRuleMinInterval("unPauseAge2", 5);
   }
   xsDisableSelf();
}

//==============================================================================
// RULE: age2Progress  ---> Age3
//==============================================================================
rule age2Progress
   minInterval 15
   inactive
{
	if (gAge3MinorGod == -1)
		gAge3MinorGod=chooseMinorGod(cAge3, -1, -1);

	//And now a progression to get to age 3
   gAge3ProgressionPlanID=aiPlanCreate("Age 3", cPlanProgression);
   if ((gAge3ProgressionPlanID >= 0) && (gAge3MinorGod != -1))
   { 
	  aiPlanSetVariableInt(gAge3ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge3MinorGod);
	  if(cMyCulture == cCultureGreek)
	  {
		aiPlanSetDesiredPriority(gAge3ProgressionPlanID, 40);
	  }else{
		aiPlanSetDesiredPriority(gAge3ProgressionPlanID, 99);
	  }
		aiPlanSetEscrowID(gAge3ProgressionPlanID, cEconomyEscrowID);
	  aiPlanSetBaseID(gAge3ProgressionPlanID, kbBaseGetMainID(cMyID));
	  if(cMyCulture != cCultureEgyptian)	//Start paused!!
	  {
		aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanPaused, 0, true);
		aiPlanSetVariableBool(gAge3ProgressionPlanID, cProgressionPlanAdvanceOneStep, 0, true);
		xsEnableRule("unPauseAge3");
	  }
	  aiPlanSetActive(gAge3ProgressionPlanID);
   }
   
   xsDisableSelf();
}

//==============================================================================
// RULE: age3Progress  ---> Age4
//==============================================================================
rule age3Progress
   minInterval 15
   inactive
{
   if (gAge4MinorGod == -1)
		gAge4MinorGod=chooseMinorGod(cAge4, -1, -1);

  if (aiGetGameMode() == cGameModeDeathmatch)   // Non-DM will activate this after market is built
  {
	// And now a progression to get to age 4
	  gAge4ProgressionPlanID=aiPlanCreate("Age 4", cPlanProgression);
	  if ((gAge4ProgressionPlanID >= 0) && (gAge4MinorGod != -1))
	  { 
		 aiPlanSetVariableInt(gAge4ProgressionPlanID, cProgressionPlanGoalTechID, 0, gAge4MinorGod);
		 aiPlanSetDesiredPriority(gAge4ProgressionPlanID, 99);
		   aiPlanSetEscrowID(gAge4ProgressionPlanID, cEconomyEscrowID);
		 aiPlanSetBaseID(gAge4ProgressionPlanID, kbBaseGetMainID(cMyID));
		 aiPlanSetActive(gAge4ProgressionPlanID);
	  }
  }
   
   xsDisableSelf();
}

//==============================================================================
// updateAge4Options
//==============================================================================
void updateAge4Options(int age=4)
{
      //It's a mod, stick to our initial choice!
	if(gNewCivMod)
	{
		return;
	}

      //Check our situation!
	if(cMyCulture == cCultureGreek)
	{
	    if(cvMilitaryEconSlider < 0.2)	//Eco.
	    {
		gAge4MinorGod=cTechAge4Hephaestus;
	    }
	    if(cvMilitaryEconSlider > 0.6)	//Mil.
	    {
		if(cMyCiv != cCivZeus)
		{
			gAge4MinorGod=cTechAge4Hera;
		}else{
			gAge4MinorGod=cTechAge4Artemis;
		}
	    }
	}
	if(cMyCulture == cCultureAtlantean)
	{
	    if((cvMilitaryEconSlider + cvOffenseDefenseSlider) < -0.4)	//Def.
	    {
		if(cMyCiv != cCivGaia)
		{
			gAge4MinorGod=cTechAge4Helios;
		}else{
			gAge4MinorGod=cTechAge4Atlas;
		}
	    }
	}
	if(gAge4MinorGod < 0)	//No progression set yet?
	{
	    gAge4MinorGod = kbTechTreeGetMinorGodChoices(aiRandInt(2), cAge4);
	}

      //Update the progression to follow this minor god.
	kbTechTreeAddMinorGodPref(gAge4MinorGod);
}

//==============================================================================
// RULE: LateAdvanceHandler
//==============================================================================
rule LateAdvanceHandler
   minInterval 30
   active
{
   if(kbGetAge() >= cvMaxAge)
   {
	xsDisableSelf();
	return;
   }

   int ageUpgradeTech = -1;	//All ages.
   switch (kbGetAge())
   {
      case cAge1:
      {
	 ageUpgradeTech = gAge2MinorGod;
	 break;
      }
      case cAge2:
      {
	 ageUpgradeTech = gAge3MinorGod;
	 break;
      }
      case cAge3:
      {
	 updateAge4Options();
	 ageUpgradeTech = gAge4MinorGod;
	 break;
      }
      case cAge4:
      {
	 ageUpgradeTech = cTechSecretsoftheTitans;
	 xsDisableSelf();
	 break;
      }
   }
   if(ageUpgradeTech < 0)	//No progression set yet?
   {
	ageUpgradeTech = kbTechTreeGetMinorGodChoices(aiRandInt(2), kbGetAge()+1);
   }
   //If we can afford it twice go get it now!
   if(
	(kbTechCostPerResource(ageUpgradeTech,cResourceFood)*2) <= kbResourceGet(cResourceFood)
	&&
	(kbTechCostPerResource(ageUpgradeTech,cResourceWood)*2) <= kbResourceGet(cResourceWood)
	&&
	(kbTechCostPerResource(ageUpgradeTech,cResourceGold)*2) <= kbResourceGet(cResourceGold)
	&&
	(kbTechCostPerResource(ageUpgradeTech,cResourceFavor)*2) <= kbResourceGet(cResourceFavor)
     )
   {
	aiSetPauseAllAgeUpgrades(false);	//Unpause
	int myTC = findUnit(cMyID, cUnitStateAlive, cUnitTypeAbstractSettlement);
	aiTaskUnitResearch(myTC, ageUpgradeTech);
   }
}
