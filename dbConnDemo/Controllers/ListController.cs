
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
            var data = (from s in db.Students
                        join c in db.Courses on s.Id equals c.Id
                        join d in db.Departments on s.Id equals d.Id
                        select new
                        {
                            s.Id,
                            s.Name,
                            s.Address,
                            s.Cgpa,
                            c.CourseCode,
                          Dname=  c.Name,
                            c.Credit,
                           // d.Name
                        }).ToList();
            return View(data);
        }
    }
}