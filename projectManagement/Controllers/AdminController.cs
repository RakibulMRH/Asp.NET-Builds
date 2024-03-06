using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using projectManagement.Auth;
using projectManagement.EF;

namespace projectManagement.Controllers
{
    public class AdminController : Controller
    {
        // GET: Admin
        [AdminAccess]
        //admin can see all the projects
        [HttpGet]
        public ActionResult Projects()
        {
            using (labtaskEntities db = new labtaskEntities())
            {
                var projects = db.projects.ToList();
                return View(projects);
            }

        }

        [HttpPost]
        public ActionResult Projects(int pId)
        {
            using (labtaskEntities db = new labtaskEntities())
            {
                var project = db.projects.Where(p => p.pId == pId).FirstOrDefault();
                project.pstatus = "approved";
                db.SaveChanges();
                return RedirectToAction("Projects");
            }
        }

    }
}