using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using LAB2demo.Models;

namespace LAB2demo.Controllers
{
    public class DashboardController : Controller
    {
        // GET: Dashboard
        public ActionResult Profile()
        {
            var s1 = new Student();
            s1.name = "Tanvir";
            s1.id = 1;
            s1.cgpa = 2.34f;

            var s2 = new Student();
            s2.name = "Sabbir";
            s2.id = 2;
            s2.cgpa = 3.45f;

            var students = new Student[] { s1, s2 };
            string name = "Rakib";
            string id = "ID";
            float cgpa = 99.99f;

            ViewBag.name = name;
            ViewBag.cgpa = cgpa;
            ViewBag.id = id;
            return View();
        }
    }
}