using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace AzureKeyVault.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index()
        {
            var service = new Services.MainService();
            var db = new Services.Configuration(service).DB;

            ViewBag.DB = db;

            return View();
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}