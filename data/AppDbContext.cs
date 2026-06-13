using GraduationProject.Models;
using Microsoft.EntityFrameworkCore;
using System.Collections.Generic;
using System.Reflection.Emit;

namespace GraduationProject.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options) { }

        public DbSet<User> Users { get; set; }
        public DbSet<Product> Products { get; set; }
        public DbSet<ProductSource> ProductSources { get; set; }
        public DbSet<PriceHistory> PriceHistories { get; set; }
        public DbSet<ProductInsight> ProductInsights { get; set; }
        public DbSet<Watchlist> Watchlists { get; set; }
        public DbSet<Notification> Notifications { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            // Unique email per user
            modelBuilder.Entity<User>()
                .HasIndex(u => u.Email)
                .IsUnique();

            // One-to-one: Product ↔ ProductInsight
            modelBuilder.Entity<ProductInsight>()
                .HasOne(pi => pi.Product)
                .WithOne(p => p.Insight)
                .HasForeignKey<ProductInsight>(pi => pi.ProductId);
        }
    }
}