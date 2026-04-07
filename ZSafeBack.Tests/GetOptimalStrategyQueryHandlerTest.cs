using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;
using FluentAssertions;
using Moq;
using ZSafeBack.Application;
using ZSafeBack.Domain;
using Xunit;

namespace ZSafeBack.Tests;

public class GetOptimalStrategyQueryHandlerTest
{
	[Fact]
	public async Task Handler_Should_Return_Max_Score_Given_Constraints()
	{
		// Arrange
		var zombies = new List<ZombieType>
		{
			new(1, "Bone Runner", 3, 4, 40, 2),
			new(2, "Necro Tank", 5, 6, 70, 5),
			new(3, "Acid Howler", 2, 3, 30, 3)
		};

		var zombieRepositoryMock = new Mock<IZombieRepository>();
		zombieRepositoryMock
			.Setup(x => x.GetAllAsync())
			.ReturnsAsync(zombies);

		var handler = new GetOptimalStrategyQueryHandler(zombieRepositoryMock.Object);
		var query = new GetOptimalStrategyQuery(10, 8);

		// Act
		var result = await handler.Handle(query, CancellationToken.None);

		// Assert
		result.TotalScore.Should().Be(110);
		result.BulletsUsed.Should().Be(10);
		result.SecondsUsed.Should().Be(8);
		result.ZombiesEliminated.Should().HaveCount(2);
		result.ZombiesEliminated.Should().BeInDescendingOrder(z => z.ThreatLevel);
	}
}
