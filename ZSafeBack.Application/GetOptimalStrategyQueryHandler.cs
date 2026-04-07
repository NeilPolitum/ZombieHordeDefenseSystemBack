using System.Threading;
using System.Threading.Tasks;
using MediatR;

namespace ZSafeBack.Application;

public class GetOptimalStrategyQueryHandler : IRequestHandler<GetOptimalStrategyQuery, StrategyResponse>
{
    public Task<StrategyResponse> Handle(GetOptimalStrategyQuery request, CancellationToken cancellationToken)
    {
        // implementar después la logica de calculo
        throw new NotImplementedException();
    }
}