//==============================================================================
// aiMapSupport.xs			by JeHathor
//
// Use this file to add support for any custom made maps
// by simply inserting them into the list below...
//==============================================================================
void initMap(void)
{
   //Decide if we have a water map - is it good for fishing?
   if (
	(cvFishMap == true)
	||
	(cvRandomMapName == "Alps")
	||
	(cvRandomMapName == "Anatolia")
	||
	(cvRandomMapName == "Anaximander's World")
	||
	(cvRandomMapName == "Archipelago")
	||
	(cvRandomMapName == "Basin")
	||
	(cvRandomMapName == "Beach")
	||
	(cvRandomMapName == "Black Sea")
	||
	(cvRandomMapName == "Calm Shores")
	||
	(cvRandomMapName == "Consequences")
	||
	(cvRandomMapName == "Cyclades")
	||
	(cvRandomMapName == "Danubius")
	||
	(cvRandomMapName == "Dia")
	||
	(cvRandomMapName == "Dog Bone")
	||
	(cvRandomMapName == "Foul Lakeside")
	||
	(cvRandomMapName == "Galapagos")
	||
	(cvRandomMapName == "Helvetia")
	||
	(cvRandomMapName == "Highland")
	||
	(cvRandomMapName == "Islands")
	||
	(cvRandomMapName == "Isthmus")
	||
	(cvRandomMapName == "Jungle Journey")
	||
	(cvRandomMapName == "Kithira")
	||
	(cvRandomMapName == "Mediterranean")
	||
	(cvRandomMapName == "MediterraneanSplit")
	||
	(cvRandomMapName == "Midgard")
	||
	(cvRandomMapName == "Mirage")
	||
	(cvRandomMapName == "Moat")
	||
	(cvRandomMapName == "Mountain Pass")
	||
	(cvRandomMapName == "Nordic")
	||
	(cvRandomMapName == "Old Atlantis")
	||
	(cvRandomMapName == "Riverland")
	||
	(cvRandomMapName == "River Nile")
	||
	(cvRandomMapName == "Sacred Lake")
	||
	(cvRandomMapName == "Sea of Worms")
	||
	(cvRandomMapName == "Settlers")
	||
	(cvRandomMapName == "Settlers Random")
	||
	(cvRandomMapName == "Southern Isles")
	||
	(cvRandomMapName == "Sudden Death")
	||
	(cvRandomMapName == "Surrounded Sea")
	||
	(cvRandomMapName == "Team Migration")
	||
	(cvRandomMapName == "Vinlandsaga")
	||
	(cvRandomMapName == "Vinlandsaga II")
	||
	(cvRandomMapName == "Volcanic Island")
	||
	(cvRandomMapName == "Volcano")
	||
	(cvRandomMapName == "Wild Lake")
	||
	(cvRandomMapName == "Yellow River")
       )
   {
      //Tell the AI that this map is valid for fishing:
      gFishMap=true;
      aiEcho("This is a water map.");
      xsEnableRule("fishing");
      aiSetWaterMap(gFishMap);
   }
//------------------------------------------------------------------------------
   //Decide if we have a transport-needed map.
   if (
	(cvTransportMap == true)
	||
	(cvRandomMapName == "Archipelago")
	||
	(cvRandomMapName == "Anaximander's World")
	||
	(cvRandomMapName == "Black Sea")
	||
	(cvRandomMapName == "Cyclades")
	||
	(cvRandomMapName == "Danubius")
	||
	(cvRandomMapName == "Helvetia")
	||
	(cvRandomMapName == "Islands")
	||
	(cvRandomMapName == "Jungle Journey")
	||
	(cvRandomMapName == "King of the Hill")
	||
	(cvRandomMapName == "River Nile")
	||
	(cvRandomMapName == "River Styx")	// No fish
	||
	(cvRandomMapName == "Southern Isles")
	||
	(cvRandomMapName == "Settlers Random")
	||
	(cvRandomMapName == "Team Migration")
	||
	(cvRandomMapName == "Vinlandsaga")
	||
	(cvRandomMapName == "Vinlandsaga II")
	||
	(cvRandomMapName == "Volcano")
	||
	(cvRandomMapName == "Yellow River")
       )
   {
      //Tell the AI that this map is valid for transporting:
      gTransportMap=true;
      aiEcho("This is a transport map.");
      aiSetWaterMap(gTransportMap);
   }
//------------------------------------------------------------------------------
   //Decide if we have a hunt map - is it good for hunting?
   if (
	(cvHuntMap == true)
	||
	(cvRandomMapName == "Arabian Plateau")
	||
	(cvRandomMapName == "Arctic Craters")
	||
	(cvRandomMapName == "Black Forest II")
	||
	(cvRandomMapName == "Erebus")
	||
	(cvRandomMapName == "Exile")
	||
	(cvRandomMapName == "Exile Pro")
	||
	(cvRandomMapName == "Jotunheim")
	||
	(cvRandomMapName == "Lost City")
	||
	(cvRandomMapName == "Marsh")
	||
	(cvRandomMapName == "Muspelheim")
	||
	(cvRandomMapName == "Niflheim")
	||
	(cvRandomMapName == "Nordic")
	||
	(cvRandomMapName == "OP Settlement")
	||
	(cvRandomMapName == "Primary Start")
	||
	(cvRandomMapName == "River Styx")
	||
	(cvRandomMapName == "Savannah")
	||
	(cvRandomMapName == "Tropical Mirage")
	||
	(cvRandomMapName == "Tundra")
	||
	(cvRandomMapName == "Watering Hole")
       )
   {
      //Tell the AI that this map is valid for hunting:
      gHuntMap=true;
      aiEcho("This is a high hunt map.");
   }
//------------------------------------------------------------------------------
   //Decide if we have a rush map - is it bad for rushing?
   if (
	(cvNoRushMap == true)
	||
	(cvRandomMapName == "Archipelago")
	||
	(cvRandomMapName == "Black Sea")
	||
	(cvRandomMapName == "Cyclades")
	||
	(cvRandomMapName == "Danubius")
	||
	(cvRandomMapName == "Deep Jungle")
	||
	(cvRandomMapName == "Green Savannah")
	||
	(cvRandomMapName == "Helvetia")
	||
	(cvRandomMapName == "Islands")
	||
	(cvRandomMapName == "Jungle Journey")
	||
	(cvRandomMapName == "Megaopolis")
	||
	(cvRandomMapName == "Non-rush Forest")
	||
	(cvRandomMapName == "River Nile")
	||
	(cvRandomMapName == "River Styx")
	||
	(cvRandomMapName == "Southern Isles")
	||
	(cvRandomMapName == "Team Migration")
       )
   {
      //Tell the AI that this map is invalid for rushing:
      gNoRushMap=true;
      aiEcho("This is not a rush map.");
   }
//------------------------------------------------------------------------------
   //Decide if we need a mainland explore plan. (Early)
   if (
	(cvMigrationMap == true)
	||
	(cvRandomMapName == "Danubius")
	||
	(cvRandomMapName == "Team Migration")
	||
	(cvRandomMapName == "Vinlandsaga")
	||
	(cvRandomMapName == "Vinlandsaga II")
       )
   {
      //Tell the AI that this map has a migration start:
      gMigrationMap = true;
      aiEcho("This is a migration map.");
   }
//------------------------------------------------------------------------------
   //Decide if we need a mainland explore plan. (Late)
   if (
	(cvExpansionMap == true)
	||
	(cvRandomMapName == "Jungle Journey")
	||
	(cvRandomMapName == "New World")
	||
	(cvRandomMapName == "River Styx")
	||
	(cvRandomMapName == "Yellow River")
       )
   {
      //Tell the AI that this map has a late migration:
      gExpansionMap = true;
      aiEcho("This is an expansion map.");
   }
//------------------------------------------------------------------------------
   //Do we need to find and claim a tc first?
   if (
	(cvNomadMap == true)
	||
	(cvRandomMapName == "Nomad")
	||
	(cvRandomMapName == "Settlers")
	||
	(cvRandomMapName == "Settlers Random")
       )
   {
      //Tell the AI that this map has a nomad start:
      gNomadMap = true;
      aiEcho("This is a nomad map.");
   }
}