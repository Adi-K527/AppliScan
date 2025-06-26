using Microsoft.EntityFrameworkCore;

namespace ApplicationsService.Models
{
    public class ApplicationContext : DbContext
    {
        public ApplicationContext(DbContextOptions<ApplicationContext> options) : base(options)
        {

        }

        public DbSet<ApplicationModel> Application { get; set; }
    }
}