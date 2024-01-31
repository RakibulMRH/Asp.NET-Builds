using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace LAB2demo.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Login()     //ActionResult is like a superclass
        {
            return View();
        }
        public ActionResult SignUp()  
        {
            return View();
        }

        public ActionResult Submit()  
        {
            //validation-authentication
            //if ok do return like below
            //return RedirectToAction("Profile", "Dashboard");
            //if external application needs to be redirected do this
            return Redirect("https://portal.aiub.edu");
        }

    }
}