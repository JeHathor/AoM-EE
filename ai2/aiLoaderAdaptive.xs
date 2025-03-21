//==============================================================================
// aiLoaderAdaptive.xs
//==============================================================================
include "aiLibrary/MainScript.xs";
void main()
{
	aiSetPersonality("Adaptive Bot");

	cvAiAutoBalance = true;
	cvMasterDifficulty = cDifficultyNightmare;
	cvMasterHandicap = 1.80;

	aiResourceCheat(cMyID, cResourceFood, 50.0);

	runScript();
}
