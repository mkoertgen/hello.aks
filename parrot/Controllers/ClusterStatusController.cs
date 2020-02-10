using System;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Logging;
using parrot.Hubs;
using parrot.Models;

namespace parrot.Controllers
{
    [Route("api/[controller]")]
    public class ClusterStatusController : Controller
    {   

        public ClusterStatusController(ILogger<ClusterStatusController> logger, DaemonHub hub)
        {
            _hub = hub;
            _logger = logger;
        }

        private readonly DaemonHub _hub;
        private readonly ILogger _logger;

        [HttpGet]
        public ActionResult Get()
        {
            return new OkResult();
        }

        [HttpDelete]
        public ActionResult Delete()
        {
            _logger.LogDebug("Incoming Cluster Clear");
            try {
                _hub.ClearClusterView();
            }
            catch(Exception ex) {
                HttpContext.Response.StatusCode = (int)System.Net.HttpStatusCode.InternalServerError; 
                _logger.LogWarning(ex, "Error clearing cluster view");
                return Json(new { status="error",message=$"error updating cluster view {ex.Message}"});
            }
            return new OkResult();
        }

        [HttpPost]
        public ActionResult Post([FromBody]Pod pod)
        {
            _logger.LogDebug("Incoming Cluster Update");
            _logger.LogDebug(pod.ToString());
            try {
                _hub.UpdateClusterView(pod);
            }
            catch(Exception ex) {
                HttpContext.Response.StatusCode = (int)System.Net.HttpStatusCode.InternalServerError; 
                _logger.LogWarning(ex, "Error updating cluster view");
                return Json(new { status="error",message=$"error updating cluster view {ex.Message}"});
            }

            return new OkResult();
        }
    }
}
