//==============================================================================
// aiLoaderModerate.xs
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Moderate Bot");

	cvMasterDifficulty = cDifficultyModerate;
	cvMasterHandicap = 1.00;

	runScript();
}