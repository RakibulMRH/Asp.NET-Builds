﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Class2Assignment.Models
{
    public class personInfo
    {
        //<h2>Personal</h2>
        //<p>Highly skilled and motivated Sr.Software Engineer with a strong background in developing VAT Processing Software, ERP Software, and HRM & Payroll Software.Proficient in .NET Framework, C#, ASP.NET MVC, and ASP.NET Core. Committed to delivering technical solutions and achieving business outcomes through collaborative teamwork.</p>
        //<h2> Personal Details</h2>
        //<p><strong>First Name:</strong>  </p>
        //<p><strong>Last Name:</strong>  </p>
        //<p><strong>Father's Name:</strong>  </p>
        //<p><strong>Mother's Name:</strong>  </p>
        //<p><strong>Date of Birth:</strong> March 16, 2002</p>
        //<p><strong>Blood Group:</strong> B+</p>
        //<p><strong>Mobile Number:</strong> +1234567890</p>
        //<p><strong>Email:</strong> rakibulmrh4bd @gmail.com</p>
        //<p><strong>Address:</strong> 123 Main Street, City, Country</p>
        //<p><strong>Website:</strong> <a href = "https://www.example.com" > www.rakibulmrh.com </ a ></ p >

        public string FirstName { get; set; }
        public string LastName { get; set; }
        public string FatherName { get; set; }
        public string MotherName { get; set; }
        public DateTime DateOfBirth { get; set; }
        public string BloodGroup { get; set; }
        public string MobileNumber { get; set; }
        public string Email { get; set; }
        public string Address { get; set; }
        public Uri Website { get; set; }
    }
}