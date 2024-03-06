using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace projectManagement.Auth
{
    public class logged : AuthorizeAttribute
    {
        protected override bool AuthorizeCore(HttpContextBase httpContext)
        {
            if (httpContext.Session["user"] != null)
            {
                return true;
            }
            return false;
        }
    }
}