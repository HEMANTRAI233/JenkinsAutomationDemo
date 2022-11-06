using System;
using System.Collections.Generic;
using System.Data.SqlClient;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Configuration;
using System.Data;
using System.IO;
namespace TestApp1
{
    class Program
    {

        static void Main(string[] args)
        {
            string _DBConnection = ConfigurationManager.ConnectionStrings["BoxOffice3Conn"].ConnectionString;
            string sessionId = "";
            string requestBody = "";
            SqlTransaction transaction;
            List<string> availableSeats;
            using (SqlConnection connection = new SqlConnection(_DBConnection))
            {
                connection.Open();
                transaction = connection.BeginTransaction();
                SqlDataReader dataReader = null;
                SqlCommand comm = connection.CreateCommand();
                comm.CommandType = CommandType.StoredProcedure;
                comm.CommandText = "GetSalesInfoByShow";
                comm.Transaction = transaction;
                try
                {
                    dataReader = comm.ExecuteReader();
                    if (dataReader.HasRows)
                    {
                        if (dataReader.Read())
                        {
                            if (!dataReader.IsDBNull(0))
                            {
                                if (dataReader.GetString(0) == "Fail")
                                    requestBody = "500";
                                else
                                {
                                    string[] availableSeatsArray = dataReader.GetString(0).Split(',');
                                    availableSeats = new List<string>(availableSeatsArray);
                                }
                            }
                            sessionId = dataReader.GetString(0);
                            requestBody = dataReader.GetString(1);
                        }
                    }

                    dataReader.Close();
                    connection.Close();
                    if (!String.IsNullOrEmpty(requestBody))
                    {
                        try
                        {
                            string filename = @"D:\"+sessionId+".json";
                            if (File.Exists(filename)) File.Delete(filename);
                            using (FileStream fs = File.Create(filename))
                            {
                                Byte[] title = new UTF8Encoding(true).GetBytes("");
                                fs.Write(title, 0, title.Length);
                                byte[] author = new UTF8Encoding(true).GetBytes(requestBody);
                                fs.Write(author, 0, author.Length);
                            }
                        }
                        catch (Exception Ex)
                        {
                            Console.WriteLine(Ex.ToString());
                        }
                    }
                }
                catch (Exception ex)
                {
                    Console.WriteLine(ex.ToString());
                }
            }
        }
    }
}
