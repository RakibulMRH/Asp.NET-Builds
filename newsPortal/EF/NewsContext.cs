using newsPortal.EF.Tables;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace newsPortal.EF
{
    public class NewsContext : DbContext
    {
        public DbSet<News> News { get; set; }
    }
}