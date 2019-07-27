using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Amazon.DynamoDBv2;
using Amazon.DynamoDBv2.Model;

namespace NCAAHoops.Controllers
{
    public class BoxScores
    {
        public string date { get; set; }
        public string teamName { get; set; }
        public string role { get; set; }
        public string opponent { get; set; }
        public int pts { get; set; }
        public int fgm { get; set; }
        public int fga { get; set; }
        public int tptm { get; set; }
        public int tpta { get; set; }
        public int ftm { get; set; }
        public int fta { get; set; }
        public int orb { get; set; }
        public int drb { get; set; }
        public int reb { get; set; }
        public int ast { get; set; }
        public int to { get; set; }
        public int stl { get; set; }
        public int blk { get; set; }
        public int pf { get; set; }
    }

    [Route("api/[controller]")]
    [ApiController]
    public class BoxScoresController : ControllerBase
    {
        // GET api/boxscores
        [HttpGet]
        public ActionResult<IEnumerable<string>> Get()
        {
            return new string[] { "value1", "value2" };
        }

        // GET api/boxscores/5
        [HttpGet("{id}")]
        public ActionResult<string> Get(int id)
        {
            return "value";
        }

        // POST api/boxscores
        [HttpPost]
        public ActionResult<string> Post([FromBody] BoxScores boxScores)
        {
            AmazonDynamoDBClient client = new AmazonDynamoDBClient();

            Dictionary<string, AttributeValue> attributes = new Dictionary<string, AttributeValue>();
            attributes["date"] = new AttributeValue { S = boxScores.date };
            attributes["teamName"] = new AttributeValue { S = boxScores.teamName };
            attributes["role"] = new AttributeValue { S = boxScores.role };
            attributes["opponent"] = new AttributeValue { S = boxScores.opponent };
            attributes["pts"] = new AttributeValue { N = boxScores.pts.ToString() };
            attributes["fgm"] = new AttributeValue { N = boxScores.fgm.ToString() };
            attributes["fga"] = new AttributeValue { N = boxScores.fga.ToString() };
            attributes["tptm"] = new AttributeValue { N = boxScores.tptm.ToString() };
            attributes["tpta"] = new AttributeValue { N = boxScores.tpta.ToString() };
            attributes["ftm"] = new AttributeValue { N = boxScores.ftm.ToString() };
            attributes["fta"] = new AttributeValue { N = boxScores.fta.ToString() };
            attributes["orb"] = new AttributeValue { N = boxScores.orb.ToString() };
            attributes["drb"] = new AttributeValue { N = boxScores.drb.ToString() };
            attributes["reb"] = new AttributeValue { N = boxScores.reb.ToString() };
            attributes["ast"] = new AttributeValue { N = boxScores.ast.ToString() };
            attributes["to"] = new AttributeValue { N = boxScores.to.ToString() };
            attributes["stl"] = new AttributeValue { N = boxScores.stl.ToString() };
            attributes["blk"] = new AttributeValue { N = boxScores.blk.ToString() };
            attributes["pf"] = new AttributeValue { N = boxScores.pf.ToString() };

            PutItemRequest request = new PutItemRequest
            {
                TableName = "NCAAHoops_BoxScores",
                Item = attributes
            };

            client.PutItemAsync(request);

            //return "Date: " + boxScores.date + "\n"
            //    + "TeamName: " + boxScores.teamName + "\n"
            //    + "Role: " + boxScores.role + "\n"
            //    + "Opponent: " + boxScores.opponent + "\n"
            //    + "Pts: " + boxScores.pts + "\n"
            //    + "FGM: " + boxScores.fgm + "\n"
            //    + "FGA: " + boxScores.fga + "\n"
            //    + "3PTM: " + boxScores.tptm + "\n"
            //    + "3PTA: " + boxScores.tpta + "\n"
            //    + "FTM: " + boxScores.ftm + "\n"
            //    + "FTA: " + boxScores.fta + "\n"
            //    + "ORB: " + boxScores.orb + "\n"
            //    + "DRB: " + boxScores.drb + "\n"
            //    + "REB: " + boxScores.reb + "\n"
            //    + "AST: " + boxScores.ast + "\n"
            //    + "TO: " + boxScores.to + "\n"
            //    + "STL: " + boxScores.stl + "\n"
            //    + "BLK: " + boxScores.blk + "\n"
            //    + "PF: " + boxScores.pf;

            return "Successfully placed item for game: " + boxScores.date + ", " + boxScores.teamName;
        }

        // PUT api/boxscores/5
        [HttpPut("{id}")]
        public void Put(int id, [FromBody] string value)
        {
        }

        // DELETE api/boxscores/5
        [HttpDelete("{id}")]
        public void Delete(int id)
        {
        }
    }
}
