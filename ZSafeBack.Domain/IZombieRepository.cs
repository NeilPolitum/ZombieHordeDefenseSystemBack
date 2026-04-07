using System.Collections.Generic;
using System.Threading.Tasks;

namespace ZSafeBack.Domain;

public interface IZombieRepository
{
    Task<IEnumerable<ZombieType>> GetAllAsync();
}