
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GraduationProject.Models
{
    public class ProductInsight
    {
        [Key]
        public int InsightId { get; set; }

        [ForeignKey("Product")]
        public int ProductId { get; set; }

        [Column(TypeName = "decimal(3,1)")]
        public decimal? AiScore { get; set; }

        public string? SummaryText { get; set; }

        // Store as JSON strings: e.g. ["Fast processor","Great camera"]
        public string? ProsList { get; set; }
        public string? ConsList { get; set; }

        [MaxLength(50)]
        public string? GeminiVersion { get; set; }

        public DateTime LastAnalyzed { get; set; } = DateTime.UtcNow;

        // Navigation
        public Product Product { get; set; } = null!;
    }
}
