using Microsoft.EntityFrameworkCore;
using ZSafeBack.Domain;

namespace ZSafeBack.Infrastructure;

public class DefenseBDContext : DbContext
{
    public DefenseBDContext(DbContextOptions<DefenseBDContext> options) : base(options)
    {
    }

    public DbSet<ZombieType> ZombieTypes { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfiguration(new ZombieTypeConfiguration());

        modelBuilder.Entity<ZombieType>().HasData(
            new ZombieType(1, "Walker", 2, 1, 10, 1),
            new ZombieType(2, "Runner", 3, 2, 25, 2),
            new ZombieType(3, "Tank", 8, 5, 50, 4),
            new ZombieType(4, "Spitter", 4, 2, 30, 3),
            new ZombieType(5, "Crawler", 1, 3, 15, 1),
            new ZombieType(6, "Bloater", 6, 3, 60, 4),
            new ZombieType(7, "Screamer", 5, 2, 35, 3),
            new ZombieType(8, "Lurker", 7, 4, 70, 5),
            new ZombieType(9, "Mutant", 9, 4, 80, 5),
            new ZombieType(10, "Horde", 10, 5, 100, 5)
        );
    }
}