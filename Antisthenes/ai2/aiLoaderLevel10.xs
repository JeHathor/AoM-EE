//==============================================================================
// aiLoaderApocalypse.xs
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Apocalypse Bot");

	cvMasterDifficulty = cDifficultyNightmare;
	cvMasterHandicap = 3.00;

	xsEnableRule("aiCheatRule");
	aiResourceCheat(cMyID, cResourceFood, 50.0);

	runScript();
}
//------------------------------------------------------------------------------
rule aiCheatRule
      highFrequency
   inactive
{
	if(kbResourceGet(cResourceFood) < 2000 && kbGetAge() > cAge1)
	{
		aiResourceCheat( cMyID, cResourceFood, 1.0 );
	}
	if(kbResourceGet(cResourceWood) < 2000 && kbGetAge() > cAge1)
	{
		aiResourceCheat( cMyID, cResourceWood, 1.0 );
	}
	if(kbResourceGet(cResourceGold) < 2000 && kbGetAge() > cAge1)
	{
		aiResourceCheat( cMyID, cResourceGold, 1.0 );
	}
	if(
		(kbResourceGet(cResourceFavor) < 2 && kbGetAge() > cAge1)
		||
		(
		    (gSettlementHighScoreID < gNumberMySettlements)
		    &&
		    (kbResourceGet(cResourceFavor) < 50 && kbGetAge() > cAge3)
		)
		||
		(kbResourceGet(cResourceFavor) < 10 && kbGetAge() >= cAge4)
	  )
	{
		aiResourceCheat( cMyID, cResourceFavor, 1.0 );
	}
}