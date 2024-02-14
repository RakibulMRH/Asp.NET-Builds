using dbConnDemo.EF;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dbConnDemo.Controllers
{
    public class DepartmentController : Controller
    {
        // GET: Department
        [HttpGet]
        public ActionResult Department()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Department(Department d)
        {
            if (ModelState.IsValid)
            {
                var db = new ASPEntities();
                db.Departments.Add(d);
                db.SaveChanges();
                return RedirectToAction("List", "List");
            }
            return View();
        }
    }
}