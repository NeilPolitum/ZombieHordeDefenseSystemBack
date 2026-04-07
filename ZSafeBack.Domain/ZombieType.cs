namespace ZSafeBack.Domain;

public class ZombieType
{
    public ZombieType() { }
	public ZombieType(int id, string name, int timeToShoot, int bulletsRequired, int score, int threatLevel)
	{
		Id = id;
		Name = name;
		TimeToShoot = timeToShoot;
		BulletsRequired = bulletsRequired;
		Score = score;
		ThreatLevel = threatLevel;
	}

	public int Id { get; set; }

	public string Name { get; set; }

	public int TimeToShoot { get; set; }

	public int BulletsRequired { get; set; }

	public int Score { get; set; }

	public int ThreatLevel { get; set; }
}