using System;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;
using System.Collections.Generic;
using System.Threading.Tasks;

namespace RequestTest
{
    class Program
    {
        static void Main(string[] args)
        {
            AmazonDynamoDBClient client = new AmazonDynamoDBClient("AKIATE3XJ4OF7CAOTTUN", "JBCFrJkt/eAqXcNNyyCCnt3EOr2oaZ+CA9qfoiAV", Amazon.RegionEndpoint.USEast1);

            Task<ListTablesResponse> listTablesTask = client.ListTablesAsync();
            listTablesTask.ContinueWith( x => ListTables(x.Result));

            Dictionary<string, AttributeValue> attributes = new Dictionary<string, AttributeValue>();
            attributes["Date"] = new AttributeValue { S = "string1" };
            attributes["TeamName"] = new AttributeValue { S = "string2" };
            attributes["Role"] = new AttributeValue { S = "string3" };
            attributes["Opponent"] = new AttributeValue { S = "string4" };
            attributes["Pts"] = new AttributeValue { N = "0" };
            attributes["FGM"] = new AttributeValue { N = "0" };
            attributes["FGA"] = new AttributeValue { N = "0" };
            attributes["3PTM"] = new AttributeValue { N = "0" };
            attributes["3PTA"] = new AttributeValue { N = "0" };
            attributes["FTM"] = new AttributeValue { N = "0" };
            attributes["FTA"] = new AttributeValue { N = "0" };
            attributes["ORB"] = new AttributeValue { N = "0" };
            attributes["DRB"] = new AttributeValue { N = "0" };
            attributes["REB"] = new AttributeValue { N = "0" };
            attributes["AST"] = new AttributeValue { N = "0" };
            attributes["TO"] = new AttributeValue { N = "0" };
            attributes["STL"] = new AttributeValue { N = "0" };
            attributes["BLK"] = new AttributeValue { N = "0" };
            attributes["PF"] = new AttributeValue { N = "0" };

            PutItemRequest request = new PutItemRequest
            {
                TableName = "NCAAHoops_BoxScores",
                Item = attributes
            };

            Task<PutItemResponse> putItemTask = client.PutItemAsync(request);
            putItemTask.ContinueWith(x => PutItem(x.Result));

            Console.WriteLine("Request sent.");
            Console.ReadLine();
        }

        static void ListTables(ListTablesResponse _response)
        {
            Console.WriteLine(_response.TableNames);
        }

        static void PutItem(PutItemResponse _response)
        {
            Console.WriteLine("Request completed with: " + _response.HttpStatusCode.ToString());
        }
    }
}
