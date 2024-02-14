using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using dbConnDemo.EF;

namespace dbConnDemo.Controllers
{
    public class CourseController : Controller
    {
        // GET: Course
        public ActionResult Course()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Course(Cours c)
        {
            if (ModelState.IsValid)
            {
                var db = new EF.ASPEntities();
                db.Courses.Add(c);
                db.SaveChanges();
                return RedirectToAction("List", "List");
            }
            return View();
        }
    }
}