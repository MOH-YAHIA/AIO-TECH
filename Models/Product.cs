
using System.ComponentModel.DataAnnotations;

namespace GraduationProject.Models
{
    public class Product
    {
        [Key]
        public int ProductId { get; set; }

        [Required, MaxLength(255)]
        public string Title { get; set; } = string.Empty;

        [MaxLength(100)]
        public string? Category { get; set; }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

        // Navigation
        public ICollection<ProductSource> Sources { get; set; } = new List<ProductSource>();
        public ICollection<PriceHistory> PriceHistories { get; set; } = new List<PriceHistory>();
        public ProductInsight? Insight { get; set; }
        public ICollection<Watchlist> Watchlists { get; set; } = new List<Watchlist>();
    }
}