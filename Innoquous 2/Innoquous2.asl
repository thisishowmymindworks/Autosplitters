state("Innoquous 2")
{
	int Level : "Innoquous 2.exe", 0x1AF2F8;
}

start {
	return old.Level == 21 && current.Level != 21;
}

split
{
	return old.Level != current.Level;
}
