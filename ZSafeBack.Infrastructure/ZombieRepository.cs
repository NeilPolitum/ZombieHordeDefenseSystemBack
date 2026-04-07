using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using ZSafeBack.Domain;

namespace ZSafeBack.Infrastructure;

public class ZombieRepository : IZombieRepository
{
    private readonly DefenseBDContext _context;

    public ZombieRepository(DefenseBDContext context)
    {
        _context = context;
    }

    public async Task<IEnumerable<ZombieType>> GetAllAsync()
    {
        return await _context.ZombieTypes
            .FromSqlRaw(@"
                SELECT
                    z.Id,
                    z.Tipo AS Name,
                    CAST(ROUND(z.TiempoDisparo, 0) AS INT) AS TimeToShoot,
                    CAST(z.BalasNecesarias AS INT) AS BulletsRequired,
                    CAST(CASE
                        WHEN z.NivelAmenaza * 10 > 100 THEN 100
                        ELSE z.NivelAmenaza * 10
                    END AS INT) AS Score,
                    CAST(z.NivelAmenaza AS INT) AS ThreatLevel
                FROM dbo.Zombies AS z")
            .AsNoTracking()
            .ToListAsync();
    }
}
