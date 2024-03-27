using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace APIIntro.Controllers
{
    public class HomeController : ApiController
    {
        public HttpResponseMessage Get()
        {
            string[] names = { "Tom", "Jerry", "Mickey", "Donald" };
            return Request.CreateResponse(HttpStatusCode.OK, names);
        }

        public HttpResponseMessage Post()
        {
            var obj = new { Name = "Tom", Age = 25 };
            return Request.CreateResponse(HttpStatusCode.OK, obj);
        }
        


    }
}
