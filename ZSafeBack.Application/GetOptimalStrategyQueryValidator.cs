using FluentValidation;

namespace ZSafeBack.Application;

public class GetOptimalStrategyQueryValidator : AbstractValidator<GetOptimalStrategyQuery>
{
    public GetOptimalStrategyQueryValidator()
    {
        RuleFor(x => x.Bullets)
            .GreaterThan(0)
            .WithMessage("Bullets must be greater than 0");

        RuleFor(x => x.SecondsAvailable)
            .GreaterThan(0)
            .WithMessage("SecondsAvailable must be greater than 0");
    }
}