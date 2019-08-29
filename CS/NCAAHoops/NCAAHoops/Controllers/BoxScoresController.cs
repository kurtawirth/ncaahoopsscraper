﻿using System;
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
            AmazonDynamoDBClient client = new AmazonDynamoDBClient("AKIATE3XJ4OF7CAOTTUN", "JBCFrJkt/eAqXcNNyyCCnt3EOr2oaZ+CA9qfoiAV", Amazon.RegionEndpoint.USEast1);

            Dictionary<string, AttributeValue> attributes = new Dictionary<string, AttributeValue>();
            attributes["Date"] = new AttributeValue { S = boxScores.date };
            attributes["TeamName"] = new AttributeValue { S = boxScores.teamName };
            attributes["Role"] = new AttributeValue { S = boxScores.role };
            attributes["Opponent"] = new AttributeValue { S = boxScores.opponent };
            attributes["PTS"] = new AttributeValue { N = boxScores.pts.ToString() };
            attributes["FGM"] = new AttributeValue { N = boxScores.fgm.ToString() };
            attributes["FGA"] = new AttributeValue { N = boxScores.fga.ToString() };
            attributes["3PTM"] = new AttributeValue { N = boxScores.tptm.ToString() };
            attributes["3PTA"] = new AttributeValue { N = boxScores.tpta.ToString() };
            attributes["FTM"] = new AttributeValue { N = boxScores.ftm.ToString() };
            attributes["FTA"] = new AttributeValue { N = boxScores.fta.ToString() };
            attributes["ORB"] = new AttributeValue { N = boxScores.orb.ToString() };
            attributes["DRB"] = new AttributeValue { N = boxScores.drb.ToString() };
            attributes["REB"] = new AttributeValue { N = boxScores.reb.ToString() };
            attributes["AST"] = new AttributeValue { N = boxScores.ast.ToString() };
            attributes["TO"] = new AttributeValue { N = boxScores.to.ToString() };
            attributes["STL"] = new AttributeValue { N = boxScores.stl.ToString() };
            attributes["BLK"] = new AttributeValue { N = boxScores.blk.ToString() };
            attributes["PF"] = new AttributeValue { N = boxScores.pf.ToString() };

            PutItemRequest request = new PutItemRequest
            {
                TableName = "NCAAHoops_BoxScores",
                Item = attributes
            };

            client.PutItemAsync(request);

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
