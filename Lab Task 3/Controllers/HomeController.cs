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
        public ActionResult Index()
        {
            return View(new Student());
        }

        [HttpPost]
        public ActionResult Index(Student student)
        {
            if (student.Email == null || student.Id == null || !student.Email.StartsWith(student.Id))
            {
                ModelState.AddModelError("Email", "Email ID must match the provided ID.");
                return View(student);
            }
            else
            {
                return View("About");
            }
        }

        public ActionResult About()
        {
            ViewBag.Message = "Your application description page.";

            return View();
        }

        public ActionResult Contact()
        {
            ViewBag.Message = "Your contact page.";

            return View();
        }
    }
}