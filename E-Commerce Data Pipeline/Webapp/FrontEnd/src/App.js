import './App.css';
import AppBar from '@material-ui/core/AppBar';
import Toolbar from '@material-ui/core/Toolbar';
import Typography from '@material-ui/core/Typography';
import Button from '@material-ui/core/Button';
import TextField from '@material-ui/core/TextField';
import Table from '@material-ui/core/Table';
import TableBody from '@material-ui/core/TableBody';
import TableCell from '@material-ui/core/TableCell';
import TableContainer from '@material-ui/core/TableContainer';
import TableHead from '@material-ui/core/TableHead';
import TableRow from '@material-ui/core/TableRow';
import Paper from '@material-ui/core/Paper';
import { useState } from 'react';
import { baseUrl } from './constants.js';
import { PowerBIEmbed } from 'powerbi-client-react';
import { models } from 'powerbi-client';

function App() {

  const [userId, setUserId] = useState();
  const [predictionData, setPredictionData] = useState([]);
  const [currentComponent, setCurrentComponent] = useState(0);

  const predictionItem = () => {
    async function getPredictionOp() {
      await fetch(baseUrl + "/getPrediction/" + userId)
        .then((response) => response.json())
        .then((data) => {
          setPredictionData(data.prediction_data);
          console.log("predictionData = " + predictionData)
        });
    }
    getPredictionOp();

  };

  return (
    <div className="App">
      <div className="header">
        <AppBar position="static" height="100px">
          <Toolbar variant="dense">
            <div style={{ width: '100%', display: "flex", justifyContent: "space-between", padding: "30px 0px" }}>
              <Typography variant="h6" color="inherit">
                Advance DBMS Final
              </Typography>
              <div>
                <Button style={{ color: "white" }} onClick={() => { setCurrentComponent(0) }}>Home</Button>
                <Button style={{ color: "white" }} onClick={() => { setCurrentComponent(1) }}>Default</Button>
              </div>
            </div>
          </Toolbar>
        </AppBar>
      </div>
      <div className="app_body">

        {
          currentComponent == 0 ? (
            <>
              <div className="app_input">
                <Typography variant="h6" gutterBottom style={{ color: "white" }}>Enter User Id : </Typography>
                {/* <TextField
                  type="number"
                  id="user_id"
                  label="User Id"
                  variant="outlined" min={0} value={userId}
                  onChange={(event) => { setUserId(event.target.value) }} /> */}
                <input type="number" id="user_id" label="User Id" min={0} value={userId} onChange={(event) => { setUserId(event.target.value) }}
                  placeholder="Enter User ID"
                  style={{ padding: "10px", borderRadius: "5px", marginLeft: "10px" }} />
                <Button variant="contained" color="primary" style={{ marginLeft: "10px" }} onClick={predictionItem}>
                  Get Prediction
                </Button>
              </div>
              <div className="app__predictionTable">
                <TableContainer component={Paper}>
                  <Table aria-label="simple table">
                    <TableHead>
                      <TableRow bac>
                        <TableCell>Item Id</TableCell>
                        <TableCell align="right">Prediction</TableCell>
                      </TableRow>
                    </TableHead>
                    <TableBody>
                      {predictionData && predictionData.length > 0 ? predictionData.map((row) => (
                        <TableRow key={row.itemID}>
                          <TableCell component="th" scope="row">
                            {row.itemID}
                          </TableCell>
                          <TableCell align="right">{row.prediction}</TableCell>
                        </TableRow>
                      )) : ""}
                    </TableBody>
                  </Table>
                </TableContainer>
              </div>

            </>
          ) : (
            <>
              <h1 style={{ color: "white" }}>Power BI dashboard</h1>
              <PowerBIEmbed
                style={{ height: '80vh' }}
                embedConfig={{
                  type: 'report',   // Supported types: report, dashboard, tile, visual and qna
                  id: "8bdc885a-9d40-4e7e-af01-3584b5f28d4e",
                  embedUrl: "https://app.powerbi.com/reportEmbed?reportId=8bdc885a-9d40-4e7e-af01-3584b5f28d4e&groupId=6821f197-6045-4045-a8e8-ebbd233185e6&config=eyJjbHVzdGVyVXJsIjoiaHR0cHM6Ly9XQUJJLVVTLU5PUlRILUNFTlRSQUwtRi1QUklNQVJZLXJlZGlyZWN0LmFuYWx5c2lzLndpbmRvd3MubmV0IiwiZW1iZWRGZWF0dXJlcyI6eyJtb2Rlcm5FbWJlZCI6dHJ1ZX19%22",
                  accessToken: "eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsIng1dCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyIsImtpZCI6Im5PbzNaRHJPRFhFSzFqS1doWHNsSFJfS1hFZyJ9.eyJhdWQiOiJodHRwczovL2FuYWx5c2lzLndpbmRvd3MubmV0L3Bvd2VyYmkvYXBpIiwiaXNzIjoiaHR0cHM6Ly9zdHMud2luZG93cy5uZXQvYThlZWMyODEtYWFhMy00ZGFlLWFjOWItOWEzOThiOTIxNWU3LyIsImlhdCI6MTYxNzMyNzU0MSwibmJmIjoxNjE3MzI3NTQxLCJleHAiOjE2MTczMzE0NDEsImFjY3QiOjAsImFjciI6IjEiLCJhaW8iOiJBVFFBeS84VEFBQUFjTjBMSE9NZnhMd1V3TGduTFRrMG9HNUtCSzVoZ3g0QjhoOFFjbTJ1dVZ6YXdiZVkvMVM4dkY3cjZPSnRPUjFrIiwiYW1yIjpbInB3ZCJdLCJhcHBpZCI6Ijg3MWMwMTBmLTVlNjEtNGZiMS04M2FjLTk4NjEwYTdlOTExMCIsImFwcGlkYWNyIjoiMiIsImZhbWlseV9uYW1lIjoiUmFjaGNoYSIsImdpdmVuX25hbWUiOiJBbnVyYWciLCJpcGFkZHIiOiI3Ni4xMTguMjM3LjEzNCIsIm5hbWUiOiJBbnVyYWcgUmFjaGNoYSIsIm9pZCI6IjlmZWNlY2I1LTEzNTUtNGI3OC05M2U4LWVhNzU2ZmU4MWZhMSIsIm9ucHJlbV9zaWQiOiJTLTEtNS0yMS0xOTQzNjI2MjMyLTczNDA4NDM1LTEyMjY0NDI4OC0xMDU3MDUxIiwicHVpZCI6IjEwMDMyMDAwMzk0RTAzNjQiLCJyaCI6IjAuQVZrQWdjTHVxS09xcmsyc201bzVpNUlWNXc4QkhJZGhYckZQZzZ5WVlRcC1rUkJaQUFJLiIsInNjcCI6InVzZXJfaW1wZXJzb25hdGlvbiIsInN1YiI6IjhGaGtOWXJYOGRoTXJCZEpTRUJPVWNYTUpZVlVhYllBX3lHZjdtcmM3U0EiLCJ0aWQiOiJhOGVlYzI4MS1hYWEzLTRkYWUtYWM5Yi05YTM5OGI5MjE1ZTciLCJ1bmlxdWVfbmFtZSI6InJhY2hjaGEuYUBub3J0aGVhc3Rlcm4uZWR1IiwidXBuIjoicmFjaGNoYS5hQG5vcnRoZWFzdGVybi5lZHUiLCJ1dGkiOiJOcTg2MmZPSWRFdXNsa0NyT0o1b0FBIiwidmVyIjoiMS4wIiwid2lkcyI6WyJiNzlmYmY0ZC0zZWY5LTQ2ODktODE0My03NmIxOTRlODU1MDkiXX0.kZ5lfEZeoJTNvzIIBah-qsT3nzZMGgme2hKH7uYrByhWEFwtB-XvVJ0ooFNAg_6rXE2233biCj0_Dq4YJa-25wyHMyKbT_Eu1GHWr1UoqbUpXJFPaKEBoZYLIjh7uK93-dTOnALp0nNvWZO6HnG5of0sgIE20G5nJjULw_yYZe9exhzJUxwTOKosNTfm8_TMrtNPRFQQmBxZLOJyCEMqKt9ElNPeITc_cid5XcJwAhllkD8f9Qm_05qGq_S1XuvcCiVupF30MiaWOUHJa99TJ7HqWinLikT6iHmy3IaDU5FePV8AmTG2jOKQi1e50D2364kSUNIE5-dR4ptyW45CbQ",
                  tokenType: models.TokenType.Aad,
                  settings: {
                    panes: {
                      filters: {
                        expanded: false,
                        visible: false
                      }
                    },
                    background: models.BackgroundType.Transparent,
                  }
                }}

                eventHandlers={
                  new Map([
                    ['loaded', function () { console.log('Report loaded'); }],
                    ['rendered', function () { console.log('Report rendered'); }],
                    ['error', function (event) { console.log(event.detail); }]
                  ])
                }

                cssClassName={"EMbed-container"}

                getEmbeddedComponent={(embeddedReport) => {
                  window.report = embeddedReport;
                }}
              />
            </>
          )
        }

      </div>

    </div>
  );
}

export default App;
