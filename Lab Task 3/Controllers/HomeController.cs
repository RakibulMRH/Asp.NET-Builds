using Lab_Task_3.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Lab_Task_3.Controllers
{
    public class HomeController : Controller
    {
        [HttpGet]
        public ActionResult Registration()
        {
            return View(new Student());
        }

        [HttpPost]
        public ActionResult Registration(Student student)
        {
            if (ModelState.IsValid)
            {
                return View("Success");
            }
            else
            {
                return View(student);
            }
        }

        public ActionResult Success()
        {
            return View();
        }
    }
}