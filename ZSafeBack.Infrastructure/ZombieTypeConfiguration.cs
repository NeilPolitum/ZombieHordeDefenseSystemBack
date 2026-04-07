using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using ZSafeBack.Domain;

namespace ZSafeBack.Infrastructure;

public class ZombieTypeConfiguration : IEntityTypeConfiguration<ZombieType>
{
    public void Configure(EntityTypeBuilder<ZombieType> builder)
    {
        builder.HasKey(z => z.Id);
        builder.Property(z => z.Id).ValueGeneratedOnAdd();
        builder.Property(z => z.Name).HasMaxLength(100).IsRequired();
        builder.Property(z => z.TimeToShoot).IsRequired();
        builder.Property(z => z.BulletsRequired).IsRequired();
        builder.Property(z => z.Score).IsRequired();
        builder.Property(z => z.ThreatLevel).IsRequired();
    }
}