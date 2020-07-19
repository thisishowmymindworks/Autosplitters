state("innoquous")
{
	int Level : "innoquous.exe", 0x1AF2F8;
}

start {
	return old.Level == 8 && current.Level != 8;
}

split
{
	return old.Level != current.Level;
}
