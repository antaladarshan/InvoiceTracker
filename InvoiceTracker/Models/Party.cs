using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace InvoiceTracker.Models
{
    public class Party
    {
        public int Id { get; set; }
        public string Name { get; set; }
        public string ContactNo { get; set; }
        public string GSTNo { get; set; }
    }
}