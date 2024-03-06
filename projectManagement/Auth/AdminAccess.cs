using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using projectManagement.EF;

namespace projectManagement.Auth
{
    public class AdminAccess : AuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {

            if (httpContext.Session["user"] != null)
            {
                var user = (login)httpContext.Session["user"];
                if (user.type.Equals("Admin"))
                    return true;
            }
            return false;
        }
    }
}