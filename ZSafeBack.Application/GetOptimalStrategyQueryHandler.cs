using System.Collections.Generic;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using MediatR;
using ZSafeBack.Domain;

namespace ZSafeBack.Application;

public class GetOptimalStrategyQueryHandler : IRequestHandler<GetOptimalStrategyQuery, StrategyResponse>
{
    private readonly IZombieRepository _zombieRepository;

    public GetOptimalStrategyQueryHandler(IZombieRepository zombieRepository)
    {
        _zombieRepository = zombieRepository;
    }

    public async Task<StrategyResponse> Handle(GetOptimalStrategyQuery request, CancellationToken cancellationToken)
    {
        var zombies = (await _zombieRepository.GetAllAsync()).ToList();
        var cache = new Dictionary<string, Result>();

        var optimal = Solve(0, request.Bullets, request.SecondsAvailable, zombies, cache);
        var orderedZombies = optimal.SelectedZombies.OrderByDescending(z => z.ThreatLevel).ToList();

        return new StrategyResponse
        {
            TotalScore = optimal.TotalScore,
            BulletsUsed = orderedZombies.Sum(z => z.BulletsRequired),
            SecondsUsed = orderedZombies.Sum(z => z.TimeToShoot),
            ZombiesEliminated = orderedZombies.Select(z => new ZombieDto
            {
                Id = z.Id,
                Name = z.Name,
                ThreatLevel = z.ThreatLevel,
                BulletsRequired = z.BulletsRequired,
                TimeToShoot = z.TimeToShoot,
                Score = z.Score
            }).ToList()
        };
    }

    private static Result Solve (int index, int bulletsLeft, int secondsLeft, List<ZombieType> zombies, Dictionary<string, Result> cache)
    {
        if (index >= zombies.Count || bulletsLeft <= 0 || secondsLeft <= 0)
        {
            return Result.Empty;
        }

        var key = $"{index}-{bulletsLeft}-{secondsLeft}";
        if (cache.TryGetValue(key, out var cached))
        {
            return cached;
        }

        var current = zombies[index];
        var skipResult = Solve(index + 1, bulletsLeft, secondsLeft, zombies, cache);
        Result best = skipResult;

        if (current.BulletsRequired <= bulletsLeft && current.TimeToShoot <= secondsLeft)
        {
            var takeResult = Solve(index + 1, bulletsLeft - current.BulletsRequired, secondsLeft - current.TimeToShoot, zombies, cache);
            takeResult = takeResult.WithAddedZombie(current);

            if (takeResult.TotalScore > best.TotalScore)
            {
                best = takeResult;
            }
            else if (takeResult.TotalScore == best.TotalScore)
            {
                if (takeResult.SelectedZombies.Count > best.SelectedZombies.Count)
                {
                    best = takeResult;
                }
            }
        }
        cache[key] = best;
        return best;
    }

    private sealed class Result
    {
        public int TotalScore { get; init; }
        public List<ZombieType> SelectedZombies { get; init; } = new();

        public static Result Empty => new() { TotalScore = 0, SelectedZombies = new List<ZombieType>() };

        public Result WithAddedZombie(ZombieType zombie)
        {
            var selectedZombies = new List<ZombieType>(SelectedZombies) { zombie };
            return new Result
            {
                TotalScore = TotalScore + zombie.Score,
                SelectedZombies = selectedZombies
            };
        }
    }
}