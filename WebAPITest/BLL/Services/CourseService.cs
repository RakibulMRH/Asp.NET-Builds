using BLL.DTOs;
using DAL.EF.Entities;
using DAL.Repos;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BLL.Services
{
    public class CourseService
    {
        public static void Create(CourseDTO c)
        {
            //convert CourseDTO to Course
            Course cd = new Course();//converted CourseDTO to Course
            new CourseRepo().Create(cd);
        }

        public static List<CourseDTO> Get()
        {
            var data = new CourseRepo().Get(); //list of Course
            //convert list of Course to list of CourseDTO
            var list = new List<CourseDTO>();
            return list;    
        }
    }
}
