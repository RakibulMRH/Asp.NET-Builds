using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Net.Mail;
using System.Web;

namespace Lab_Task_3.Models
{
    public class Student
    {
        [Required(ErrorMessage = "Name is required.")]
        [RegularExpression(@"^[a-zA-Z]+[a-zA-Z\s\.\-]*$", ErrorMessage = "Name must be alphabetic.")]
        public string Name { get; set; }

        [Required(ErrorMessage = "ID is required.")]
        [RegularExpression(@"^[0-9]{2}-[0-9]{5}-[1-3]{1}$", ErrorMessage = "AIUB ID format xx-xxxxx-x")]
        public string Id { get; set; }

        [Required(ErrorMessage = "Username is required.")]
        [StringLength(10, MinimumLength = 3, ErrorMessage = "Username must be 3-10 characters long.")]
        [RegularExpression(@"^[a-zA-Z0-9.-]*$", ErrorMessage = "Username must contain only alphanumeric characters, periods, and hyphens.")]
        public string Username { get; set; }

        [Required(ErrorMessage = "Email is required.")]
        [CustomAnnonationEmail]
        public string Email { get; set; }

    }
}