using FluentValidation;
using MediatR;
using Microsoft.EntityFrameworkCore;
using ZSafeBack.Application;
using ZSafeBack.Domain;
using ZSafeBack.Infrastructure;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString("DefaultConnection") 
    ?? "Server=(local);Database=ZSafeDb;Integrated Security=true;TrustServerCertificate=True;";
builder.Services.AddDbContext<DefenseBDContext>(options =>
    options.UseSqlServer(connectionString));

builder.Services.AddMediatR(cfg => cfg.RegisterServicesFromAssembly(typeof(GetOptimalStrategyQueryHandler).Assembly));
builder.Services.AddValidatorsFromAssemblyContaining<GetOptimalStrategyQueryValidator>();
builder.Services.AddScoped<IZombieRepository, ZombieRepository>();
builder.Services.AddControllers();


var app = builder.Build();

try 
{
    using (var scope = app.Services.CreateScope())
    {
        var dbContext = scope.ServiceProvider.GetRequiredService<DefenseBDContext>();
        dbContext.Database.Migrate();
    }
}
catch (Exception ex)
{
    app.Logger.LogError($"Error al migrar la base de datos: {ex.Message}");
}
// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.MapControllers();

app.Run();
