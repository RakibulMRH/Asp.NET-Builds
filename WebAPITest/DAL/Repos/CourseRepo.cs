using DAL.EF.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL.Repos
{
    public class CourseRepo
    {
        public void Create(Course c)
        {
            Console.WriteLine("Course created");
        }
        
        public Course Get(int id)
        {
            return new Course();
        } 
        
        public List<Course> Get()
        {
            return new List<Course>();
        }

        public void Update(Course c)
        {
            Console.WriteLine("Course updated");
        }

        public void Delete(int id)
        {
            Console.WriteLine("Course deleted");
        }
    }
}
