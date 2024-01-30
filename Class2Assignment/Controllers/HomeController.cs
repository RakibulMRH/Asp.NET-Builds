using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Class2Assignment.Controllers
{
    public class HomeController : Controller
    {

        public ActionResult Index()
        {
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
        public ActionResult Education()
        {
            ViewBag.Message = "Your Education page.";

            return View();
        }
        public ActionResult Personal()
        {
            ViewBag.Message = "Your Personal info page.";

            return View();
        }
        public ActionResult Projects()
        {
            ViewBag.Message = "Your Projects page.";

            return View();
        }
        public ActionResult Reference()
        {
            ViewBag.Message = "Your Reference page.";

            return View();
        }
    }
}