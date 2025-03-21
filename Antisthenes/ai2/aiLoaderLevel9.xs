//==============================================================================
// aiLoaderTitan.xs
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Expert Bot");

	cvMasterDifficulty = cDifficultyNightmare;
	cvMasterHandicap = 2.10;

	runScript();
}