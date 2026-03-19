//==============================================================================
// aiLoaderStandard.xs
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Global Settings");

	int worldDifficulty = aiGetWorldDifficulty();
	if(worldDifficulty == cDifficultyEasy){
		cvMasterDifficulty = cDifficultyNightmare;
		cvMasterHandicap = 1.25;	// +25%  [Elo 1600]
	}else
	if(worldDifficulty == cDifficultyModerate){
		cvMasterDifficulty = cDifficultyNightmare;
		cvMasterHandicap = 1.50;	// +50%  [Elo 1700]
	}else
	if(worldDifficulty == cDifficultyHard){
		cvMasterDifficulty = cDifficultyNightmare;
		cvMasterHandicap = 1.75;	// +75%  [Elo 1800]
	}else
	if(worldDifficulty == cDifficultyNightmare){
		cvMasterDifficulty = cDifficultyNightmare;
		cvMasterHandicap = 2.00;	//+100%  [Elo 2000]
	}

	runScript();
}