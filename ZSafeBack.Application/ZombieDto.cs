namespace ZSafeBack.Application;

public class ZombieDto
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public int TimeToShoot { get; set; }
    public int BulletsRequired { get; set; }
    public int Score { get; set; }
    public int ThreatLevel { get; set; }
}