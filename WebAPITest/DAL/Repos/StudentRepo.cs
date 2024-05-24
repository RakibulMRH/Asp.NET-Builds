using DAL.EF.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace DAL
{
    public class StudentRepo
    {
        public void Create(Student s)
        {
            Console.WriteLine("Student created");
        }
        
        public Student Get(int id)
        {
            return new Student();
        } 
        
        public List<Student> Get()
        {
            return new List<Student>();
        }

        public void Update(Student s)
        {
            Console.WriteLine("Student updated");
        }

        public void Delete(int id)
        {
            Console.WriteLine("Student deleted");
        }
    }
}
