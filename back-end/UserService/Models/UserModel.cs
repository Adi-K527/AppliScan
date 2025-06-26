using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace UserService.Models;

public class UserModel
{
    [Key]
    [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
    public int User_id { get; set; }
    public string? Username { get; set; }
    public string? Email { get; set; }
    public string? Password { get; set; }
    public string? First_name { get; set; }
    public string? Last_name { get; set; }
    public DateTime? Registration_date { get; set; }
    public string? Gid { get; set; }

    public UserModel()
    {
        Registration_date = DateTime.UtcNow;
    }
}