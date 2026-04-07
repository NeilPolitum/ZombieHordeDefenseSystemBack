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
        return await _context.ZombieTypes.ToListAsync();
    }
}
