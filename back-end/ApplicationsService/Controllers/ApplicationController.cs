using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using ApplicationsService.Models;
using Microsoft.AspNetCore.Authorization;
using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;
using System.Net.Http;

namespace ApplicationsService.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class ApplicationController : ControllerBase
    {
        private readonly ApplicationContext _context;

        public ApplicationController(ApplicationContext context)
        {
            _context = context;
        }

        // GET: api/Application/applications
        [HttpGet("applications")]
        [Authorize]
        public async Task<ActionResult<IEnumerable<ApplicationModel>>> GetApplications()
        {

            try
            {
                var token = Request.Headers.Authorization.ToString()?.Replace("Bearer ", "");

                if (token == null)
                {
                    return Unauthorized("Token is missing");
                }

                var handler  = new JwtSecurityTokenHandler();
                var jwtToken = handler.ReadJwtToken(token);
                var userId   = jwtToken.Claims.FirstOrDefault(c => c.Type == "user_id")?.Value;

                var httpClient = new HttpClient();
                httpClient.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", token);
                var user_response = await httpClient.GetAsync($"http://localhost:5151/api/user/{userId}");

                if (!user_response.IsSuccessStatusCode)
                {
                    return StatusCode(401, new { error = "Unable to find user." });
                }

                var jsonString = user_response.Content.ReadAsStringAsync().Result;
                var gidKey = "\"gid\":";
                var gidIndex = jsonString.IndexOf(gidKey);
                var startIndex = gidIndex + gidKey.Length;
                var endIndex = jsonString.IndexOfAny(new[] { ',', '}' }, startIndex);
                var rawGid = jsonString.Substring(startIndex, endIndex - startIndex).Trim();
                var gid = rawGid.Trim('"');

                if (rawGid == "null")
                {
                    return StatusCode(401, new { error = "User has no gid." });
                }

                var applications = await _context.Application.Where(a => a.Gid == gid).ToListAsync();

                return StatusCode(200, new { response = applications });
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error retrieving applications: " + ex.Message);
                return StatusCode(500, new { error = "Failed to retrieve applications." });
            }
        }

        // POST: api/Application/data
        [HttpPost("data")]
        public async Task<ActionResult<ApplicationModel>> PostApplication(ApplicationDto applicationDto)
        {
            try
            {
                var statuses = new Dictionary<int, string>
                {
                    { 2, "Just Applied" },
                    { 1, "Action Needed" },
                    { 0, "Rejected" }
                };

                foreach (var application in applicationDto.Data)
                {
                    if (application.Count < 4)
                        return BadRequest("Invalid application data format.");

                    // Convert and extract values
                    if (!int.TryParse(application[0], out var statusKey) || !statuses.ContainsKey(statusKey))
                        return BadRequest("Invalid status code.");

                    var status = statuses[statusKey];
                    var gid = application[1];
                    var company = application[3];

                    // Check for existing entry
                    var existing = await _context.Application.FirstOrDefaultAsync(app => app.Company == company);

                    if (existing != null)
                    {
                        existing.Status = status;
                        existing.Gid = gid;
                    }
                    else
                    {
                        var newApplication = new ApplicationModel
                        {
                            Status = status,
                            Gid = gid,
                            Company = company
                        };

                        _context.Application.Add(newApplication);
                    }

                    await _context.SaveChangesAsync();
                }

                return Ok(new { message = "Data processed successfully." });
            }
            catch (Exception ex)
            {
                Console.WriteLine("Error processing applications: " + ex.Message);
                return StatusCode(500, new { error = "Failed to process applications." });
            }
        }

    }
}
