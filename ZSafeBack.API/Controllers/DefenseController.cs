using MediatR;
using Microsoft.AspNetCore.Mvc;
using ZSafeBack.Application;

namespace ZSafeBack.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DefenseController : ControllerBase
{
    private readonly IMediator _mediator;

    public DefenseController(IMediator mediator)
    {
        _mediator = mediator;
    }

    [HttpGet("optimal-strategy")]
    public async Task<ActionResult<StrategyResponse>> GetOptimalStrategy([FromQuery] GetOptimalStrategyQuery query)
    {
        var response = await _mediator.Send(query);
        return Ok(response);
    }
}