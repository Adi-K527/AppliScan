using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace ApplicationsService.Models;

public class ApplicationModel
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int Application_id { get; set; }
    public DateTime? Application_date { get; set; }
    public string? Status { get; set; }
    public string? Company { get; set; }
    public string? Gid { get; set; }
}