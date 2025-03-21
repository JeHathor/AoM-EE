//==============================================================================
// aiLoaderHard.xs
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Hard Bot");

	cvMasterDifficulty = cDifficultyHard;
	cvMasterHandicap = 1.00;

	runScript();
}