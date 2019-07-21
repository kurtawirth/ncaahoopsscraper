using System;
using System.IO;

namespace UploadBoxScoreData
{
    class Program
    {
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
                        //string headers = reader.ReadLine();  // Need to trash the first line which contains only headers

                        while (reader.Peek() != -1)
                        {
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
                                    requestBody += "\"" + colHeaders[colNum] + "\":";
                                    if (colNum > 0 && colNum < 5) requestBody += "\"";
                                    requestBody += trimmed;
                                    if (colNum > 0 && colNum < 5) requestBody += "\"";
                                    if (colNum < 22) requestBody += ",";
                                }

                                colNum++;
                            }

                            requestBody += "}";
                            Console.WriteLine(requestBody);
                            numRecords++;
                        }
                    }
                }
            }

            Console.WriteLine("Total number of records found: " + numRecords);
        }
    }
}
