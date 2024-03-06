using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace projectManagement.DTOs
{
    public class LoginDTO
    {
        public int id { get; set; }
        public string uname { get; set; }
        public string pass { get; set; }
        public string type { get; set; }
    }
}