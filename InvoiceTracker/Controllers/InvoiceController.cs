using InvoiceTracker.Models;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data.SqlClient;
using System.Data;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace InvoiceTracker.Controllers
{
    public class InvoiceController : Controller
    {
        private readonly string connectionString = ConfigurationManager.ConnectionStrings["BillingSystemDB"].ConnectionString;

        private string GetLastInvoiceNoFromDatabase()
        {
            string lastInvoiceNo = string.Empty;

            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlCommand cmd = new SqlCommand("GetLastInvoiceNo", con);
                cmd.CommandType = CommandType.StoredProcedure;

                con.Open();
                lastInvoiceNo = cmd.ExecuteScalar()?.ToString() ?? "";
            }

            return lastInvoiceNo;
        }

        private string GenerateNextInvoiceNo(string lastInvoiceNo)
        {
            if (string.IsNullOrEmpty(lastInvoiceNo))
                return "INV001";

            int lastNumber = int.Parse(lastInvoiceNo.Substring(3));
            int nextNumber = lastNumber + 1;

            string nextInvoiceNo = "INV" + nextNumber.ToString("000");

            return nextInvoiceNo;
        }

        public ActionResult Create()
        {
            try
            {
                string lastInvoiceNo = GetLastInvoiceNoFromDatabase();
                string nextInvoiceNo = GenerateNextInvoiceNo(lastInvoiceNo);
                ViewBag.InvoiceNo = nextInvoiceNo;
            }
            catch (Exception ex)
            {
                ViewBag.InvoiceNo = "INV001"; 
                TempData["ErrorMessage"] = "Something went wrong. Please try again."; 
            }

            List<SelectListItem> partyList = new List<SelectListItem>();
            try
            {
                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    SqlCommand cmd = new SqlCommand("GetPartyNames", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    while (reader.Read())
                    {
                        partyList.Add(new SelectListItem
                        {
                            Value = reader["PartyID"].ToString(),
                            Text = reader["PartyName"].ToString()
                        });
                    }
                }
            }
            catch (Exception ex)
            {
                TempData["ErrorMessage"] = "Failed to retrieve party names from the database.";
            }

            ViewBag.Parties = new SelectList(partyList, "Value", "Text");
            return View();
        }

        [HttpPost]
        public JsonResult GetPartyDetails(int partyID)
        {
            try
            {
                string gstNo = "";
                string contactNo = "";

                using (SqlConnection con = new SqlConnection(connectionString))
                {
                    SqlCommand cmd = new SqlCommand("GetPartyDetails", con);
                    cmd.CommandType = CommandType.StoredProcedure;
                    cmd.Parameters.AddWithValue("@PartyID", partyID);

                    con.Open();
                    SqlDataReader reader = cmd.ExecuteReader();
                    if (reader.Read())
                    {
                        gstNo = reader["GSTNo"].ToString();
                        contactNo = reader["ContactNo"].ToString();
                    }
                }

                return Json(new { GSTNo = gstNo, ContactNo = contactNo });
            }
            catch (Exception ex)
            {
                return Json(new { error = "Failed to retrieve party details from the database." });
            }
        }

        [HttpPost]
        public ActionResult SaveInvoice(Invoice invoice)
        {
            using (SqlConnection con = new SqlConnection(connectionString))
            {
                SqlTransaction transaction = null;
                try
                {
                    con.Open();
                    transaction = con.BeginTransaction();

                    SqlCommand cmdInvoice = new SqlCommand("INSERT INTO Invoice (InvoiceNo, PartyID, InvoiceDate, GrandTotal, Discount, GSTAmount, NetAmount) OUTPUT INSERTED.InvoiceID VALUES (@InvoiceNo, @PartyID, @InvoiceDate, @GrandTotal, @Discount, @GSTAmount, @NetAmount)", con, transaction);
                    cmdInvoice.Parameters.AddWithValue("@InvoiceNo", invoice.InvoiceNo);
                    cmdInvoice.Parameters.AddWithValue("@PartyID", invoice.PartyID);
                    cmdInvoice.Parameters.AddWithValue("@InvoiceDate", invoice.InvoiceDate);
                    cmdInvoice.Parameters.AddWithValue("@GrandTotal", invoice.GrandTotal);
                    cmdInvoice.Parameters.AddWithValue("@Discount", invoice.Discount);
                    cmdInvoice.Parameters.AddWithValue("@GSTAmount", invoice.GSTAmount);
                    cmdInvoice.Parameters.AddWithValue("@NetAmount", invoice.NetAmount);

                    int invoiceId = (int)cmdInvoice.ExecuteScalar();

                    foreach (var item in invoice.Items)
                    {
                        SqlCommand cmdItem = new SqlCommand("INSERT INTO InvoiceItem (InvoiceID, SRNo, ItemCode, ItemName, Qty, Rate, GST, Total) VALUES (@InvoiceID, @SRNo, @ItemCode, @ItemName, @Qty, @Rate, @GST, @Total)", con, transaction);
                        cmdItem.Parameters.AddWithValue("@InvoiceID", invoiceId);
                        cmdItem.Parameters.AddWithValue("@SRNo", item.SRNo);
                        cmdItem.Parameters.AddWithValue("@ItemCode", item.ItemCode);
                        cmdItem.Parameters.AddWithValue("@ItemName", item.ItemName);
                        cmdItem.Parameters.AddWithValue("@Qty", item.Qty);
                        cmdItem.Parameters.AddWithValue("@Rate", item.Rate);
                        cmdItem.Parameters.AddWithValue("@GST", item.GST);
                        cmdItem.Parameters.AddWithValue("@Total", item.Total);

                        cmdItem.ExecuteNonQuery();
                    }

                    transaction.Commit();
                    return Json(new { success = true, message = "Invoice saved successfully!" });
                }
                catch (Exception ex)
                {
                    if (transaction != null)
                    {
                        transaction.Rollback();
                    }
                    return Json(new { success = false, message = "Failed to save invoice." });
                }
            }
        }
    }
}