using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.ComponentModel.DataAnnotations;

namespace Lab_Task_3.Models
{
    public class CustomAnnonationEmail : ValidationAttribute
    {
        protected override ValidationResult IsValid(object value, ValidationContext validationContext)
        {
            var data = validationContext.ObjectInstance as Student;
            if (data.Email != null && data.Id != null)
            {
                var test = data.Id + "@student.aiub.edu";
                
                if ( test == data.Email)
                {
                    return ValidationResult.Success;
                }
                
                else
                {
                    return new ValidationResult("Email must be of AIUB");
                }
            }
            else
            {
                return new ValidationResult("Model is empty!");
            }

        }

    }
}