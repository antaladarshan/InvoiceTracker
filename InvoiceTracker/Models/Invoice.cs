using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace InvoiceTracker.Models
{
    public class Invoice
    {
        public int PartyID { get; set; }
        public string InvoiceNo { get; set; }
        public string PartyName { get; set; }
        public string ContactNo { get; set; }
        public DateTime InvoiceDate { get; set; }
        public string GSTNo { get; set; }
        public List<InvoiceItem> Items { get; set; }
        public decimal GrandTotal { get; set; }
        public decimal Discount { get; set; }
        public decimal GSTAmount { get; set; }
        public decimal NetAmount { get; set; }
    }
}