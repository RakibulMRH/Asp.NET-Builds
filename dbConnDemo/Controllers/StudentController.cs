using dbConnDemo.EF;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dbConnDemo.Controllers
{
    public class StudentController : Controller
    {
        // GET: Student

        [HttpGet]
        public ActionResult Student()
        {
            return View();
        }

        [HttpPost]
        public ActionResult Student(Student s)
        {
            if (ModelState.IsValid)
            {
                var db = new EF.ASPEntities();
                db.Students.Add(s);
                db.SaveChanges();
                return RedirectToAction("List", "List");
            }
            return View();
        }
    }
}