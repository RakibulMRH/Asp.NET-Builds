using APIIntro.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Web.Http;

namespace APIIntro.Controllers
{
    public class PersonController : ApiController
    {
        //custom route
        [HttpGet]
        [Route("api/person/all")] //not allowed / in the beginning
        public HttpResponseMessage GetAllPerson()
        {
            string[] names = { "Tom", "Jerry", "Mickey", "Donald" };
            return Request.CreateResponse(HttpStatusCode.OK, names);
        }

        [HttpPost]
        [Route("api/person/create")]
        public HttpResponseMessage AddPerson(Person p)
        {
            return Request.CreateResponse(HttpStatusCode.OK, "Person added successfully");

        }
    }
}
