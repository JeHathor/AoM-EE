//==============================================================================
// aiLoaderRandom.xs			[Elo 1600-2100]
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Random Bot");

	cvMasterDifficulty = cDifficultyNightmare;
	cvMasterHandicap = 1.25 + (aiRandInt(86))/100.0;	//1.25-2.10

	runScript();
}