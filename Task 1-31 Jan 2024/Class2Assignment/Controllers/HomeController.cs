using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Class2Assignment.Models;
namespace Class2Assignment.Controllers
{
    public class HomeController : Controller
    {

        public ActionResult Index()
        {
            return View();
        }
        public ActionResult Education()
        {
            var e1 = new Education();
            e1.Degree = "SSC";
            e1.Year = "2017";
            e1.Institute = "Jamalpur Zilla School";

            var e2 = new Education();
            e2.Degree = "HSC";
            e2.Year = "2019";
            e2.Institute = "Govt. Ashek Mahmud College";

            var e3 = new Education();
            e3.Degree = "B.Sc. in CSE";
            e3.Year = "2024";
            e3.Institute = "American International University";

            ViewBag.Educations = new Education[] { e1, e2, e3 };
            return View();
        }
        public ActionResult Personal()
        {
            ViewBag.Message = "Highly skilled and motivated Sr. Software Engineer with a strong background in developing VAT Processing Software, ERP Software, and HRM & Payroll Software. Proficient in .NET Framework, C#, ASP.NET MVC, and ASP.NET Core. Committed to delivering technical solutions and achieving business outcomes through collaborative teamwork.";
            var person = new personInfo();
            person.FirstName = "Rakibul";
            person.LastName = "Hasan";
            person.FatherName = "";
            person.MotherName = "";
            person.DateOfBirth = new DateTime(3000, 03, 16);
            person.BloodGroup = "B+";
            person.MobileNumber = "+1234567890";
            person.Email = "rakibulmrh4bd@gmail.com";
            person.Address = "123 Main Street, City, Country";
            person.Website = new Uri("https://www.example.com");
            ViewBag.personInfo = person;
            return View();
        }
        public ActionResult Projects()
        {
            var p1 = new Projects();
            p1.ProjectName = "E-commerce Platform Development:";
            p1.ProjectDescription = new string[] { "Developed a comprehensive e-commerce platform using ASP.NET MVC, incorporating secure payment gateways and user-friendly interfaces.", "Implemented a robust product catalog and inventory management system.", "Integrated third-party APIs for shipping and order tracking." };
            
            var p2 = new Projects();
            p2.ProjectName = "HRM & Payroll Software:";
            p2.ProjectDescription = new string[] { "Led the development of an HRM & Payroll software solution using .NET Framework and C#.", "Designed and implemented modules for employee management.", "Customized the system to adhere to specific client requirements." };

            var p3 = new Projects();
            p3.ProjectName = "Filling Station Management System:";
            p3.ProjectDescription = new string[] { "Framework: .Net Framework", "Language: C#", "Data Base: Microsoft Azzure" };

            ViewBag.Projects = new Projects[] { p1, p2, p3 };

            return View();
        }
        public ActionResult Reference()
        {
            var r1 = new Reference();
            r1.Name = "Shibaji Mridha";
            r1.Designation = "Assistant Professor,";
            r1.Organization = "Faculty of Arts & Social Science,";
            r1.MobileNumber = "+1234567890";
            r1.Email = "smridha@aiub.edu";

            var r2 = new Reference();
            r2.Name = "Zahiduddin Ahmed";
            r2.Designation = "Assistant Professor";
            r2.Organization = "Faculty Of Science And Technology";
            r2.MobileNumber = "+1234567890";
            r2.Email = "zahid@aiub.edu";
            
            ViewBag.References = new Reference[] { r1, r2 };

            return View();
        }
    }
}