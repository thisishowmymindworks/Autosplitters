state("KNIGHTS")
{
	int Level 			: 	"mono.dll", 0x00265A68, 0x28, 0xF28, 0x1B0;  
	int LevelPack 		: 	"mono.dll", 0x00265A68, 0x28, 0xF28, 0x1AC;
	int LevelFinished	:	"unityplayer.dll", 0x014802A0,0x0,0xEF0;
}

start {
	if (current.Level != old.Level) {
		switch ((int)current.Level) {
			case 0:
				return current.LevelPack == 3 || current.LevelPack == 4;
			case 1:
				return current.LevelPack == 2 || current.LevelPack == 1;
			case 2:
				return current.LevelPack == 0;
		}
	}
}

split
{
	return (old.LevelFinished == 0 && current.LevelFinished == 1);
}