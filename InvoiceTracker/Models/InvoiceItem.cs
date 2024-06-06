using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace InvoiceTracker.Models
{
    public class InvoiceItem
    {
        public int SRNo { get; set; }
        public string ItemCode { get; set; }
        public string ItemName { get; set; }
        public int Qty { get; set; }
        public decimal Rate { get; set; }
        public decimal GST { get; set; }
        public decimal Total { get; set; }
    }
}