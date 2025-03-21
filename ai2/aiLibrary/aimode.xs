//=================================================================================================================================
// Game Mode.xs
// Creator: WarriorMario
//
// Created with ADE v0.09
//=================================================================================================================================
const bool cvGameModeDebug = true;

extern int gGameModeData = -1;
const int cGameModeType = 0;
const int cGameModeTreatyTransitionTime = 1;

bool aiPlanIncrementUserVariableInt(int planID = -1, int variableIndex = -1, int valueIndex = -1, int value = 1)
{
	return(aiPlanSetUserVariableInt(planID,variableIndex,valueIndex,aiPlanGetUserVariableInt(planID,variableIndex,valueIndex)+value));
}

void echoGameMode(string msg = "")
{
	if(cvGameModeDebug)
	{
		printEcho("Player Echo: "+ msg);
	}
}

void initGameMode()
{
	gGameModeData = aiPlanCreate("Game Mode Data", cPlanData);
	aiPlanAddUserVariableInt(gGameModeData, cGameModeType, "Game mode", 1);
	int gameMode = aiGetGameMode();
	aiPlanSetUserVariableInt(gGameModeData, cGameModeType, 0 , gameMode);
	if(gameMode == cGameModeTreaty)
	{
		echoGameMode("Treaty time: "+ kbGetTreatyTime());
		aiPlanAddUserVariableInt(gGameModeData, cGameModeTreatyTransitionTime, "Treaty transition time",1);
	}
}

//=================================================================================================================================
// SetTreatyTransitionTime(int timeInSec)
//=================================================================================================================================
void SetTreatyTransitionTime(int timeInSec = -1)
{
	if(aiPlanSetUserVariableInt(gGameModeData, cGameModeTreatyTransitionTime, 0 , timeInSec))
	{
		echoGameMode("Setting treaty transition time to:"+timeInSec);
	}
	else
	{
		echoGameMode("Failed to set transition time. Game mode probably not initialised.");
	}
}

//=================================================================================================================================
// AddTreatyTransitionTime(int timeInSec)
//=================================================================================================================================
void AddTreatyTransitionTime(int timeInSec = -1)
{
	if(aiPlanIncrementUserVariableInt(gGameModeData, cGameModeTreatyTransitionTime, 0 ,timeInSec))
	{
		echoGameMode("Setting treaty transition time to:"+timeInSec);
	}
	else
	{
		echoGameMode("Failed to set transition time. Game mode probably not initialised.");
	}
}

//=================================================================================================================================
// GetTreatyTransitionTime()
// Returns the treaty time in seconds
//=================================================================================================================================
bool TreatyPrevents()
{
	if(aiGetGameMode() != cGameModeTreaty)// Temporary fix as kbGetTreatyTime returns the last selected treaty value even in supremacy
	{
		return(false);
	}
	return(kbGetTreatyTime() - aiPlanGetUserVariableInt(gGameModeData,cGameModeTreatyTransitionTime,0) > 0);
}

void SetScenarioMode(int parm = -1)
{
	printEcho("AI deaded.");
	aiSet("NoAI.xs",cMyID);
}
