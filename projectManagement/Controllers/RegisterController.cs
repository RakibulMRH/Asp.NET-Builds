using projectManagement.EF;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.NetworkInformation;
using System.Web;
using System.Web.Mvc;

namespace projectManagement.Controllers
{
    public class RegisterController : Controller
    {
        // GET: Register
        public ActionResult Registration()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Registration(string mname, string mstatus, int pId)
        {
            using (labtaskEntities db = new labtaskEntities())
            {
                member m = new member();
                m.mname = mname;
                m.mstatus = mstatus;
                m.pId = pId;
                db.SaveChanges();
                return RedirectToAction("Index", "Login");
            }
        }
    }
}