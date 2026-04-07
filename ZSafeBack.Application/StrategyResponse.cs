using System.Collections.Generic;

namespace ZSafeBack.Application
{
    public class StrategyResponse
    {
        public int TotalScore { get; set; }
        public int BulletsUsed { get; set; }
        public int SecondsUsed { get; set; }
        public List<ZombieDto> ZombiesEliminated { get; set; } = new();
    }
}