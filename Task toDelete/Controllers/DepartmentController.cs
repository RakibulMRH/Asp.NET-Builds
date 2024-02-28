using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Task_toDelete.EF;

namespace Task_toDelete.Controllers
{
    public class DepartmentController : Controller
    {
        // GET: Department
        public ActionResult Index()
        {
            var db = new ASPEntities();
            var data = db.Departments.ToList();
            return View(data);
        }
        [HttpGet]
        public ActionResult Create()
        {
            return View();
        }
        [HttpPost]
        public ActionResult Create(Department d)
        {
            var db = new ASPEntities();
            db.Departments.Add(d);
            db.SaveChanges();
            return RedirectToAction("Index");
        }
        [HttpGet]
        public ActionResult Edit(int id)
        {
            var db = new ASPEntities();
            var data = db.Departments.Find(id);
            #region delete
            //db.Departments.Remove(data);
            //db.SaveChanges();
            #endregion
            //(from d in db.Departments where d.Id == id select d).SingleOrDefault();
            return View(data);
        }
        [HttpPost]
        public ActionResult Edit(Department upObj)
        {
            var db = new ASPEntities();
            var exobj = db.Departments.Find(upObj.Id);
            exobj.Name = upObj.Name;
            db.SaveChanges();
            return RedirectToAction("Index");
        }
        public ActionResult Details(int id)
        {
            var db = new ASPEntities();
            var exobj = db.Departments.Find(id);
            //var courses = (from c in db.Courses
            //              where c.DeptId == id
            //              select c).ToList();
            //ViewBag.Courses = courses;  
            return View(exobj);
        }

        [HttpGet]
        public ActionResult Delete()
        {
            //get all data of department
            var db = new ASPEntities();
            var data = db.Departments.ToList();
            return View(data);
        }
        [HttpPost]
        //delete department
        public ActionResult Delete(int id)
        {
            var db = new ASPEntities();
            var exobj = db.Departments.Find(id);
            db.Departments.Remove(exobj);
            db.SaveChanges();
            return RedirectToAction("Index");
        }
        
    }
}