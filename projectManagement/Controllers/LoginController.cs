using projectManagement.DTOs;
using projectManagement.EF;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace projectManagement.Controllers
{
    public class LoginController : Controller
    {
        labtaskEntities db = new labtaskEntities();
        // GET: Login
        [HttpGet]
        public ActionResult Index()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Index(LoginDTO l)
        {
            var user = db.logins.Where(u => u.uname == l.uname && u.pass == l.pass).FirstOrDefault();
            if (user != null)
            {
                Session["user"] = user;
                if (user.type.Equals("Admin"))
                {
                    return RedirectToAction("Projects", "Admin");
                }

                return RedirectToAction("Index", "Order");

            }
            TempData["Msg"] = "Invalid username and password";
            return RedirectToAction("Index");

        }
    }
}