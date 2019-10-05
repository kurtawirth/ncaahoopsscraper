using System;
using System.IO;
using System.Net;
using System.Text;

namespace UploadBoxScoreData
{
    class Program
    {
        private static string[] dates = new string[] { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" };

        static void Main(string[] args)
        {
            SendBoxScores();
            Console.ReadLine();
        }

        private static void SendBoxScores()
        {
            int numRecords = 0;

            string[] files = Directory.GetFiles("..\\..\\..\\..\\..\\..\\..\\data\\BoxScores");
            Console.WriteLine("Found " + files.Length + " box score files.");

            foreach (string file in files)
            {
                using (FileStream stream = File.OpenRead(file))
                {
                    Console.WriteLine("Successfully opened file: " + file);
                    using (StreamReader reader = new StreamReader(stream))
                    {
                        string[] colHeaders = new string[] { "id", "date", "teamName", "role", "opponent", "pts", "fgm", "fga", "ft%", "tptm", "tpta", "tpt%", "ftm", "fta", "ft%", "orb", "drb", "reb", "ast", "to", "stl", "blk", "pf" };
                        string headers = reader.ReadLine();  // Need to trash the first line which contains only headers

                        while (reader.Peek() != -1)
                        {
                            System.Threading.Thread.Sleep(200);

                            string line = reader.ReadLine();
                            string[] values = line.Split("\",\"");
                            Console.Write("Extracted data row: ");
                            int colNum = 0;
                            string requestBody = "{";

                            foreach(string item in values)
                            {
                                string trimmed = item.Replace("\"", "");

                                // Don't store percantages in the database -- they can be calculated using success/attempts
                                // Also, no need to store an explicit ID as the date and team name result in a unique identifier
                                if (!colHeaders[colNum].Contains("%") && colHeaders[colNum] != "id")
                                {
                                    if (colHeaders[colNum] == "date")
                                        trimmed = ConvertDate(trimmed);

                                    requestBody += "\"" + colHeaders[colNum] + "\":";
                                    if (colNum > 0 && colNum < 5) requestBody += "\"";
                                    requestBody += trimmed;
                                    if (colNum > 0 && colNum < 5) requestBody += "\"";
                                    if (colNum < 22) requestBody += ",";
                                }

                                colNum++;
                            }

                            requestBody += "}";
                            Console.WriteLine(SendPostRequest(requestBody));
                            numRecords++;
                        }
                    }
                }
            }

            Console.WriteLine("Total number of records found: " + numRecords);
        }

        private static string ConvertDate(string _date)
        {
            string dateNoComma = _date.Replace(",", "");
            string[] dateSplit = dateNoComma.Split(' ');
            return dateSplit[2] + "-" + (Array.IndexOf(dates, dateSplit[0]) + 1).ToString() + "-" + dateSplit[1];
        }

        private static string SendPostRequest(string _body)
        {
            WebRequest request = WebRequest.Create("http://ncaahoopsdata-env-1.ju4dv2armd.us-east-1.elasticbeanstalk.com/api/boxScores");
            request.Method = "POST";
            request.ContentType = "application/json";
            byte[] content = Encoding.ASCII.GetBytes(_body);
            request.ContentLength = content.Length;
            Stream stream = request.GetRequestStream();
            stream.Write(content, 0, content.Length);
            stream.Close();

            try
            {
                WebResponse response = request.GetResponse();
                using (StreamReader reader = new StreamReader(response.GetResponseStream()))
                {
                    return reader.ReadToEnd();
                }
            }
            catch
            {
                return "Bad request. Skipping item.";
            }

            //using (StreamWriter writer = new StreamWriter(request.GetRequestStream()))
            //{
            //    writer.Write(_body);
            //    writer.Flush();
            //    writer.Close();

            //    WebResponse response = request.GetResponse();
            //    using (StreamReader reader = new StreamReader(response.GetResponseStream()))
            //    {
            //        return reader.ReadToEnd();
            //    }
            //}
        }
    }
}
