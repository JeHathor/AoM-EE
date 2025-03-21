//==============================================================================
// aiLoaderEasy.xs
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Easy Bot");

	cvMasterDifficulty = cDifficultyEasy;
	cvMasterHandicap = 1.00;

	runScript();
}