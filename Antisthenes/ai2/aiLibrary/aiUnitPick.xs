//==============================================================================
// aiUnitPick.xs			by JeHathor
//
// Handles unit preference.
//==============================================================================

//==============================================================================
// updateUnitPreference
//==============================================================================
void updateUnitPreference(int upID=-1, int upChoice=-1)
{
    if(upID < 0)	//Not a valid unit picker.
    {
	return;
    }

    if(upChoice < 0)
    {
	int mhpInf = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeAbstractInfantry, cUnitStateAlive);
	int mhpArc = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeAbstractArcher, cUnitStateAlive);
	int mhpCav = kbUnitCount(aiGetMostHatedPlayerID(), cUnitTypeAbstractCavalry, cUnitStateAlive);

	if(mhpCav > mhpInf && mhpCav > mhpArc)
	{
		upChoice = 2;	//train Inf.
	}else
	if(mhpInf > mhpArc && mhpInf > mhpCav)
	{
		upChoice = 0;	//train Arc.
	}else
	if(mhpArc > mhpInf && mhpArc > mhpCav)
	{
		upChoice = 1;	//train Cav.
	}
    }

 //Early Odin and Poseidon play cavalry against cavalry.
 if(cMyCiv == cCivPoseidon || cMyCiv == cCivOdin)
 {
	if(upChoice == 2 && kbGetAge() < cAge3)
	{
		upChoice = 1;	//train Cav.
	}
 }

 if (cvPrimaryMilitaryUnit == -1)    // Skip this whole thing otherwise
 {
   printEcho("Before switch, upChoice is "+upChoice);
   //Do the preference actual work now.
   //Counter units should always stay below their basetype units!
   switch (cMyCiv)
   {
      //Zeus. - Infantry
      case cCivZeus:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 0.9);
	 }
	 break;
      }
      //Poseidon. - Cavalry
      case cCivPoseidon:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 0.9);
	 }
	 break;
      }
      //Hades. - Archers
      case cCivHades:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeProdromos, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHypaspist, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePeltast, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHelepolis, 0.9);
	 }
	 break;
      }
      //Isis. - Migdol Soldiers
      case cCivIsis:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.7);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.3);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 break;
      }
      //Ra. - Migdol Soldiers
      case cCivRa:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 break;
      }
      //Set. - Migdol Soldiers
      case cCivSet:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSpearman, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAxeman, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSlinger, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypePriest, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
		//Adding in some animals...
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeRhinocerosofSet, 0.2);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeHyenaofSet, 0.1);
		kbUnitPickSetPreferenceFactor(upID, cUnitTypeCrocodileofSet, 0.1);
	 break;
      }
      //Loki. - Hero Norse
      case cCivLoki:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.5);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.5);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.1);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 break;
      }
      //Odin. - Hillfort Soldiers
      case cCivOdin:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.4);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.5);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.1);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 break;
      }
      //Thor. - Infantry
      case cCivThor:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.4);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.5);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeUlfsark, 0.9);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeRaidingCavalry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeThrowingAxeman, 0.1);

	    //Reset the rest back to the abstract class
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHuskarl, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroNorse, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJarl, 0.4);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 break;
      }
      //Kronos. - Myth and Siege
      case cCivKronos:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeChieroballista, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.6);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeChieroballista, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeChieroballista, 0.4);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 break;
      }
      //Ouranos. - Humans
      case cCivOuranos:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.6);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.8);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 break;
      }
      //Gaia. - Economy [Balanced]
      case cCivGaia:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.6);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.8);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeJavelinCavalry, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 0.9);
	 }
	 break;
      }
      //Fuxi. - Immortals
      case cCivFuxi:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTiger, 0.4);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.1);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseGeneral, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTiger, 0.4);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTiger, 0.4);
	 }
	 break;
      }
      //Nuwa. - Economy [Balanced]
      case cCivNuwa:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTiger, 0.4);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.1);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseGeneral, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTiger, 0.4);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTiger, 0.4);
	 }
	 break;
      }
      //Shennong. - Monks and Siege
      case cCivShennong:
      {
	 if (upChoice == 0)
	 {
	    printEcho("Executing case 0, upChoice = "+upChoice);	//vs. Inf
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.5);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseMonk, 0.3);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTigerShennong, 0.4);
	 }
	 else if (upChoice == 1)
	 {
	    printEcho("Executing case 1, upChoice = "+upChoice);	//vs. Arc
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.3);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.8);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.7);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.2);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseMonk, 0.1);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTigerShennong, 0.4);
	 }
	 else
	 {
	    printEcho("Executing case 2, upChoice = "+upChoice);	//vs. Cav
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractInfantry, 0.7);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.6);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractCavalry, 0.5);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeAbstractSiegeWeapon, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeMythUnit, 1.0);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseImmortal, 0.1);
	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeHeroChineseMonk, 0.2);

	    kbUnitPickSetPreferenceFactor(upID, cUnitTypeSittingTigerShennong, 0.4);
	 }
	 break;
      }
   }
	// This should *only* be produced through the hesperides rule!
	kbUnitPickSetPreferenceFactor(upID, cUnitTypeDryad, 0.0);

	if(cMyCulture == cCultureGreek)
	{
	   //Up archers against non infantry in early defense.
	   if(kbGetAge() < cAge4 && cvOffenseDefenseSlider < 0.0 && upChoice != 0)
	   {
		kbUnitPickAdjustPreferenceFactor(upID, cUnitTypeAbstractArcher, 0.2);
	   }
	   if(kbGetAge() > cAge3 && upChoice == 1)	//Weaken cavalry against lategame archer.
	   {
		kbUnitPickAdjustPreferenceFactor(upID, cUnitTypeAbstractCavalry, -0.4);
	   }
	}
  }
}

//==============================================================================
// initUnitPicker
//==============================================================================
int initUnitPicker(string name="BUG", int numberTypes=1, int minUnits=10,
   int maxUnits=20, int minPop=-1, int maxPop=-1, int numberBuildings=1,
   bool guessEnemyUnitType=false)
{
   //Create it.
   int upID=kbUnitPickCreate(name);
   if (upID < 0)
      return(-1);

   //Default init.
   kbUnitPickResetAll(upID);
   //1 Part Preference, 2 Parts CE, 2 Parts Cost.  Testing 1/10/4
   if(cvMasterDifficulty <= cDifficultyHard)
   {
	kbUnitPickSetPreferenceWeight(upID, 2.0);
	kbUnitPickSetCombatEfficiencyWeight(upID, 4.0);
	kbUnitPickSetCostWeight(upID, 7.0);
   }
   else if(aiGetPersonality() == "Apocalypse Bot")
   {
	kbUnitPickSetPreferenceWeight(upID, 5.0);
	kbUnitPickSetCombatEfficiencyWeight(upID, 6.0);
	kbUnitPickSetCostWeight(upID, 2.0);
   }else{
	//Titan & Expert Bot
	kbUnitPickSetPreferenceWeight(upID, 3.0);
	kbUnitPickSetCombatEfficiencyWeight(upID, 4.0);
	kbUnitPickSetCostWeight(upID, 6.0);
   }
   //Desired number units types, buildings.
   kbUnitPickSetDesiredNumberUnitTypes(upID, numberTypes, numberBuildings, true);
   //Min/Max units and Min/Max pop.
   kbUnitPickSetMinimumNumberUnits(upID, minUnits);
   kbUnitPickSetMaximumNumberUnits(upID, maxUnits);
   kbUnitPickSetMinimumPop(upID, minPop);
   kbUnitPickSetMaximumPop(upID, maxPop);
   //Default to land units.
   kbUnitPickSetAttackUnitType(upID, cUnitTypeLogicalTypeLandMilitary);
   kbUnitPickSetGoalCombatEfficiencyType(upID, cUnitTypeLogicalTypeMilitaryUnitsAndBuildings);

   //Setup the military unit preferences.  These are just various strategies of unit
   //combos and what-not that are more or less setup to coincide with the bonuses
   //and mainline units of each civ.  We start with a random choice.  If we have
   //an enemy unit type to preference against, we override that random choice.
   //0:  Counter infantry (i.e. enemyUnitTypeID == cUnitTypeAbstractInfantry).
   //1:  Counter archer (i.e. enemyUnitTypeID == cUnitTypeAbstractArcher).
   //2:  Counter cavalry (i.e. enemyUnitTypeID == cUnitTypeAbstractCavalry).
   int upRand=aiRandInt(3);

   //Figure out what we're going to assume our opponent is building.
   int enemyUnitTypeID=-1;
   int mostHatedPlayerID=aiGetMostHatedPlayerID();
   if ((guessEnemyUnitType == true) && (mostHatedPlayerID > 0))
   {
      //If the enemy is Norse, assume infantry.
      //Zeus is infantry too.
      if ((kbGetCultureForPlayer(mostHatedPlayerID) == cCultureNorse) ||
	 (kbGetCivForPlayer(mostHatedPlayerID) == cCivZeus))
      {
	 enemyUnitTypeID=cUnitTypeAbstractInfantry;
	 upRand=0;
	 printEcho("Setting unit picker "+upID+" to counter infantry.");
      }  
      //Hades is archers.
      else if (kbGetCivForPlayer(mostHatedPlayerID) == cCivHades)
      {
	 enemyUnitTypeID=cUnitTypeAbstractArcher;
	 upRand=1;
	 printEcho("Setting unit picker "+upID+" to counter archers.");
      }
      //Poseidon is cavalry.
      else if (kbGetCivForPlayer(mostHatedPlayerID) == cCivPoseidon)
      {
	 enemyUnitTypeID=cUnitTypeAbstractCavalry;
	 printEcho("Setting unit picker "+upID+" to counter cavalry.");
	 upRand=2;
      }
      else
      {
	 switch(upRand)
	 {
	 case 0:
	    {
	       printEcho("Randomly setting unit picker "+upID+" to counter infantry.");
	       break;
	    }
	 case 1:
	    {
	       printEcho("Randomly setting unit picker "+upID+" to counter archers.");
	       break;
	    }
	 case 2:
	    {
	       printEcho("Randomly setting unit picker "+upID+" to counter cavalry.");
	       break;
	    }
	 }
      }
   }
   updateUnitPreference(upID, upRand);		//initial Preference.

   if (cvNumberMilitaryUnitTypes >= 0)
   {
      kbUnitPickSetDesiredNumberUnitTypes(upID, cvNumberMilitaryUnitTypes, numberBuildings, true);
      setMilitaryUnitPrefs(cvPrimaryMilitaryUnit, cvSecondaryMilitaryUnit, cvTertiaryMilitaryUnit);
   }else if(gNumberMilitaryUnitTypes >= 0 && aiGetPersonality() == "Apocalypse Bot"){
      kbUnitPickSetDesiredNumberUnitTypes(upID, gNumberMilitaryUnitTypes, numberBuildings+1, true);
   }else{
      kbUnitPickSetDesiredNumberUnitTypes(upID, gNumberMilitaryUnitTypes, numberBuildings, true);
   }
   return(upID);				//Done.
}
