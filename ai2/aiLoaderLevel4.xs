//==============================================================================
// aiLoaderTitan.xs
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Titan Bot");

	cvMasterDifficulty = cDifficultyNightmare;
	cvMasterHandicap = 1.25;

	runScript();
}