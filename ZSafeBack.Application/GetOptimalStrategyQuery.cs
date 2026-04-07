using MediatR;

namespace ZSafeBack.Application;

public record GetOptimalStrategyQuery(int Bullets, int SecondsAvailable) : IRequest<StrategyResponse>;