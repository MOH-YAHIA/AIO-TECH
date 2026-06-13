

using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GraduationProject.Models
{
    public class ProductSource
    {
        [Key]
        public int SourceId { get; set; }

        [ForeignKey("Product")]
        public int ProductId { get; set; }

        [MaxLength(100)]
        public string? SourceName { get; set; }   // e.g. "Noon", "Amazon.eg"

        public string? ProductUrl { get; set; }

        [Column(TypeName = "decimal(10,2)")]
        public decimal CurrentPrice { get; set; }

        [MaxLength(10)]
        public string Currency { get; set; } = "EGP";

        public string? ImageUrl { get; set; }

        public DateTime LastUpdated { get; set; } = DateTime.UtcNow;

        // Navigation
        public Product Product { get; set; } = null!;
    }
}

