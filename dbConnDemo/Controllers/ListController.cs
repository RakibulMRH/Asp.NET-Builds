using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace dbConnDemo.Controllers
{
    public class ListController : Controller
    {
        // GET: List
        [HttpGet]
        public ActionResult List()
        {
            var db = new EF.ASPEntities();
            var data = db.Students.ToList();
            var dataD = db.Departments.ToList();
            var dataC = db.Courses.ToList();

            //return multiple models
            return View(Tuple.Create(data, dataD, dataC));
        }
    }
}