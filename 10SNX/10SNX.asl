state("10SNX")
{
    double starCount : 0x003CA734, 0x34, 0x10, 0x718, 0x6C0;
		
	// BACKUP MARATHON POINTERS
	// 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x0;
	// 0x003CB79C, 0x2DC, 0x8, 0x4, 0x50, 0x18, 0x14, 0x0;
	// 0x003CB79C, 0x2D8, 0x8, 0x50, 0x14, 0xC, 0x0;
	// 0x003CB79C, 0x2DC, 0x8, 0x4, 0x50, 0x14, 0xC, 0x0;
	
	double marathonL1 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x0;
	double marathonL2 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x10;
	double marathonL3 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x20;
	double marathonL4 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x30;
	double marathonL5 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x40;
	
	double marathonX1 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x50;
	double marathonX2 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x60;
	double marathonX3 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x70;
	double marathonX4 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x80;
	double marathonX5 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0x90;
	double marathonX6 : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0xA0;
	
	double marathonB  : 0x003CB79C, 0x2D8, 0x8, 0x50, 0x18, 0x14, 0xB0;
	
	int screenNumber : 0x005CC868;
	int movementLocked : 0x003CA43C, 0x0, 0x3F4, 0xC, 0xB4;  
}
startup 
{
	//USED FOR ADDING SETTINGS AND SETTING VARIABLES
	settings.Add("auto_restart", true, "Forcibly restart game when save file is deleted");
	settings.SetToolTip("auto_restart", "Only needed for splitting on marathon mode. Will only be done if the script has split at least once because of a marathon.");
	
	settings.Add("auto_start", true, "Automatically start timer");
	settings.SetToolTip("auto_start", "Automatically starts the timer either when you hit start on the title screen, or when you enter the first level of any world.");
	
	settings.Add("NNS", false, "Split when entering the first level of any world");
	settings.SetToolTip("NNS", "Mainly meant for No New Save categories");
	
	settings.Add("split_benji", true, "Split when talking to Benji at the end of the game story");
	settings.SetToolTip("split_benji", "Mainly meant for any%");
	
	settings.Add("split_stars", true, "Split based on the total number of stars");
	
	settings.CurrentDefaultParent = "split_stars";

	settings.Add("S16", true, "16 - World 2 unlock (any%)");
	settings.Add("S36", true, "36 - World 3 unlock (any%)");
	settings.Add("S56", true, "56 - World 4 unlock (any%)");
	settings.Add("S76", true, "76 - World 5 unlock (any%)");
	settings.Add("S96", true, "96 - World 6 unlock (any%)");
	
	settings.Add("S116", true, "116 - Legacy Worlds unlock (all stars)");
	settings.Add("S180", true, "180 - Finished all Normal Worlds (all stars)");
	settings.Add("S204", true, "204 - Legacy World 1 (all stars)");
	settings.Add("S228", true, "228 - Legacy World 2 (all stars)");
	settings.Add("S252", true, "252 - Legacy World 3 (all stars)");
	settings.Add("S276", true, "276 - Legacy World 4 (all stars)");
	settings.Add("S300", true, "300 - Legacy World 5 (all stars)");
	
	settings.CurrentDefaultParent = null;
	
	settings.Add("split_marathon", true, "Split when getting rank S or higher on certain marathons");
	settings.CurrentDefaultParent = "split_marathon";
	
	settings.Add("ML1", true, "Legacy World 1");
	settings.Add("ML2", true, "Legacy World 2");
	settings.Add("ML3", true, "Legacy World 3");
	settings.Add("ML4", true, "Legacy World 4");
	settings.Add("ML5", true, "Legacy World 5");
	
	settings.Add("MX1", true, "Normal World 1");
	settings.Add("MX2", true, "Normal World 2");
	settings.Add("MX3", true, "Normal World 3");
	settings.Add("MX4", true, "Normal World 4");
	settings.Add("MX5", true, "Normal World 5");
	settings.Add("MX6", true, "Normal World 6");
	
	settings.Add("MB", false, "Bonus World");

}

init {
	vars.lastStarSplit = 0;
	vars.hasSplitMarathon = new bool[12];
	vars.splitOnBenjiEnd = false;
}

start {
	if (settings["auto_start"] && old.screenNumber != current.screenNumber) {
		int[] splitScreenNumbers = new int[] {35, 43, 51, 59, 67, 75, 85, 95, 105, 115, 125, 135};
		if (Array.IndexOf(splitScreenNumbers, current.screenNumber) >= 0) {
			return true;
		}
		return (old.screenNumber == 1 && current.screenNumber == 34 && current.starCount == 0);
	}
}

update
{	
	// RESTARTING/RESETTING
	// If save is deleted, reset values needed for splitting
	if (current.starCount < old.starCount && current.starCount == 0) {
		vars.lastStarSplit = 0;
		vars.splitOnBenjiEnd = false;
		// If auto_restart is enabled, and the script has split at least once on a marathon, restart the game
		// (this is needed to reset the marathon rank values in memory)
		if (settings["auto_restart"] && Array.IndexOf(vars.hasSplitMarathon, true) != -1) {
			vars.hasSplitMarathon = new bool[12];
			string exePath = game.MainModule.FileName;
			game.Kill();
			game.WaitForExit();
			ProcessStartInfo psi = new ProcessStartInfo(exePath);
			game = Process.Start(psi);
		}
		return false;
	}
	
	return true;
}

split
{
	// SPLITTING ON ENTERING LEVEL 1 OF ANY WORLD
	int[] splitScreenNumbers = new int[] {35, 43, 51, 59, 67, 75, 85, 95, 105, 115, 125, 135};
	if (settings["NNS"] && old.screenNumber != current.screenNumber && Array.IndexOf(splitScreenNumbers, current.screenNumber) >= 0) {
		return true;
	}	
	
	//SPLITTING AT THE END OF ANY%
	if (settings["split_benji"] && old.screenNumber == 182 && current.movementLocked == 1 && vars.splitOnBenjiEnd == false) {
		vars.splitOnBenjiEnd = true;
		return true;
	}
	
	// SPLITTING ON STAR COUNT
	int[] starCounts = new int[] {16, 36, 56, 76, 96, 116, 180, 204, 228, 252, 276, 300};
	
	foreach (int starCount in starCounts) {
		if (settings["S"+starCount.ToString()] && vars.lastStarSplit < starCount && current.starCount >= starCount) {
			vars.lastStarSplit = starCount;
			return true;
		}
	} 
	
	// SPLITTING ON MARATHON
	if (settings["ML1"] && !vars.hasSplitMarathon[0] && current.marathonL1 >= 4) {
		vars.hasSplitMarathon[0] = true;
		return true;
	}

	if (settings["ML2"] && !vars.hasSplitMarathon[1] && current.marathonL2 >= 4) {
		vars.hasSplitMarathon[1] = true;
		return true;
	}
	
	if (settings["ML3"] && !vars.hasSplitMarathon[2] && current.marathonL3 >= 4) {
		vars.hasSplitMarathon[2] = true;
		return true;
	}
	
	if (settings["ML4"] && !vars.hasSplitMarathon[3] && current.marathonL4 >= 4) {
		vars.hasSplitMarathon[3] = true;
		return true;
	}
	
	if (settings["ML5"] && !vars.hasSplitMarathon[4] && current.marathonL5 >= 4) {
		vars.hasSplitMarathon[4] = true;
		return true;
	}
	
	if (settings["MX1"] && !vars.hasSplitMarathon[5] && current.marathonX1 >= 4) {
		vars.hasSplitMarathon[5] = true;
		return true;
	}
	
	if (settings["MX2"] && !vars.hasSplitMarathon[6] && current.marathonX2 >= 4) {
		vars.hasSplitMarathon[6] = true;
		return true;
	}
	
	if (settings["MX3"] && !vars.hasSplitMarathon[7] && current.marathonX3 >= 4) {
		vars.hasSplitMarathon[7] = true;
		return true;
	}
	
	if (settings["MX4"] && !vars.hasSplitMarathon[8] && current.marathonX4 >= 4) {
		vars.hasSplitMarathon[8] = true;
		return true;
	}
	
	if (settings["MX5"] && !vars.hasSplitMarathon[9] && current.marathonX5 >= 4) {
		vars.hasSplitMarathon[9] = true;
		return true;
	}
	
	if (settings["MX6"] && !vars.hasSplitMarathon[10] && current.marathonX6 >= 4) {
		vars.hasSplitMarathon[10] = true;
		return true;
	}
	
	if (settings["MB"] && !vars.hasSplitMarathon[11] && current.marathonB >= 4) {
		vars.hasSplitMarathon[11] = true;
		return true;
	}
	
    return false;
}
