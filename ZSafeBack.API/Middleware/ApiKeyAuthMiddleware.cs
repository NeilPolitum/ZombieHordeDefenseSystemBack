using Microsoft.Extensions.Configuration;

namespace ZSafeBack.API.Middleware;

public class ApiKeyAuthMiddleware
{
    private readonly RequestDelegate _next;
    private readonly IConfiguration _configuration;

    public ApiKeyAuthMiddleware(RequestDelegate next, IConfiguration configuration)
    {
        _next = next;
        _configuration = configuration;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        if (!context.Request.Headers.TryGetValue("X-API-KEY", out var extractedApiKey))
        {
            context.Response.StatusCode = 401; 
            await context.Response.WriteAsync("Falta la clave de API.");
            return;
        }

        var apiKey = _configuration.GetValue<string>("ApiKey");
        if (string.IsNullOrEmpty(apiKey) || !apiKey.Equals(extractedApiKey))
        {
            context.Response.StatusCode = 401; 
            await context.Response.WriteAsync("Clave de API no válida.");
            return;
        }

        await _next(context);
    }
}