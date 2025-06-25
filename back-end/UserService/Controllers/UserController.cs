using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using UserService.Models;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.IdentityModel.Tokens;
using Microsoft.AspNetCore.Authorization;

namespace UserService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UserController : ControllerBase
    {
        private readonly UserContext _context;

        public UserController(UserContext context)
        {
            _context = context;
        }

        // GET: api/User/{id}
        [Authorize]
        [HttpGet("{id}")]
        public async Task<ActionResult<UserModel>> Login(int id)
        {
            try
            {
                var user_by_id = await _context.Users.FindAsync(id);

                if (user_by_id == null)
                {
                    return StatusCode(401, new { error = "Unable to find user." });
                }

                return StatusCode(200, new
                {
                    user = user_by_id
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error finding user: " + ex.Message);
                return StatusCode(500, new { error = "Failed to find user." });
            }
        }

        // POST: api/User/login
        [HttpPost("login")]
        public async Task<ActionResult<UserModel>> Login(LoginDto loginDto)
        {

            try
            {
                var user = await _context.Users.FirstOrDefaultAsync(u => u.Email == loginDto.Email && u.Password == loginDto.Password);

                if (user == null)
                {
                    return StatusCode(401, new { error = "Invalid email or password." });
                }

                var user_token = GenerateToken(user.User_id);
                return StatusCode(200, new
                {
                    message = "User Logged in",
                    token = user_token
                });
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error finding user: " + ex.Message);
                return StatusCode(500, new { error = "Login Failed." });
            }
        }

        // POST: api/User/signup
        [HttpPost("signup")]
        public async Task<ActionResult<UserModel>> CreateAccount(SignupDto signupDto)
        {

            var userModel = new UserModel
            {
                First_name = signupDto.First_name,
                Last_name = signupDto.Last_name,
                Email = signupDto.Email,
                Password = signupDto.Password,
                Username = null,
                Gid = null,
                Registration_date = DateTime.UtcNow
            };

            try
            {
                _context.Users.Add(userModel);
                await _context.SaveChangesAsync();

                return StatusCode(StatusCodes.Status201Created, new
                {
                    message = "User created successfully",
                    user = userModel
                });
            }
            catch (DbUpdateException ex)
            {
                Console.WriteLine("Error inserting user: " + ex.Message);
                return StatusCode(500, new { error = "Database error." });
            }
        }

        private string GenerateToken(int user_id)
        {
            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes("e3a62530935093323d905de5ee7d5bb7171cd57669bb68582838ae9e7241787e"); // Replace with your secret key

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(new[]
                {
                    new Claim("user_id", user_id.ToString())
                }),

                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature)
            };

            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}
