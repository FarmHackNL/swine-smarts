import React, { Component } from 'react';
import logo from './logo.svg';
import './App.css';
import { TextField, RaisedButton } from 'material-ui'
import oadaIdClient from 'oada-id-client'
var domain = '207.154.219.238'
var token = ''

class App extends Component {
   
  doAuth() {
    var options = {
      metadata: 'eyJqa3UiOiJodHRwczovL2lkZW50aXR5Lm9hZGEtZGV2LmNvbS9jZXJ0cyIsImtpZCI6ImtqY1NjamMzMmR3SlhYTEpEczNyMTI0c2ExIiwidHlwIjoiSldUIiwiYWxnIjoiUlMyNTYifQ.eyJyZWRpcmVjdF91cmlzIjpbImh0dHBzOi8vMjA3LjE1NC4yMTkuMjM4L29hdXRoMi9yZWRpcmVjdC5odG1sIiwiaHR0cDovL2xvY2FsaG9zdDo4MDAwL29hdXRoMi9yZWRpcmVjdC5odG1sIl0sInRva2VuX2VuZHBvaW50X2F1dGhfbWV0aG9kIjoidXJuOmlldGY6cGFyYW1zOm9hdXRoOmNsaWVudC1hc3NlcnRpb24tdHlwZTpqd3QtYmVhcmVyIiwiZ3JhbnRfdHlwZXMiOlsiaW1wbGljaXQiXSwicmVzcG9uc2VfdHlwZXMiOlsidG9rZW4iLCJpZF90b2tlbiIsImlkX3Rva2VuIHRva2VuIl0sImNsaWVudF9uYW1lIjoiVHJpYWxzIFRyYWNrZXIiLCJjbGllbnRfdXJpIjoiaHR0cHM6Ly9naXRodWIuY29tL09wZW5BVEsvVHJpYWxzVHJhY2tlciIsImNvbnRhY3RzIjpbIlNhbSBOb2VsIDxzYW5vZWxAcHVyZHVlLmVkdT4iXSwic29mdHdhcmVfaWQiOiJhMWI4MDJkNS1kZTMzLTQ1ODQtOTVmZi0zMWU3MzVkMGYwZDEiLCJyZWdpc3RyYXRpb25fcHJvdmlkZXIiOiJodHRwczovL2lkZW50aXR5Lm9hZGEtZGV2LmNvbSIsImlhdCI6MTQ5NzUyOTg3NH0.mEmJ5uRpAy2yU2cLsEk5NjWaZArIZwUmrJou3j_uKdGvzPj4ThLuQ_2MG9k6diXxTKdQiT0m3Cx-2U03s10cM2Q_msIbgW0La05ZBjqR3M6OTDOMk0YbhjUa-Mm1OsR0gjzmHGJuoVkK-Fr6jjFUgJqMk688B_T5hx8IzYBTfmU',
      scope: 'feed-intakes slaughter-stats daily-weights',
      "redirect": 'https://farmhacknl.github.io/swine-smarts/oauth2/redirect.html',
    }
    oadaIdClient.getAccessToken(domain, options, function(err, accessToken) {
      if (err) { console.dir(err); return err; } // Something went wrong  
      console.log('DONE')
      window.location = 'https://farmhacknl.github.io/swine-smarts/graph.html';
    })
  }
  
  render() {
    return (
      <div className="App">
        <div className="App-header">
          <img src={logo} className="App-logo" alt="logo" />
          <h2>Swine Smarts</h2>
        </div>
        <div className="App-middle">
          <TextField
            defaultValue="pigdrive.com"
            floatingLabelText="Connect Data Source"
            style={{width:'200px'}}
          />
          <RaisedButton 
            onTouchTap={() => this.doAuth()}
            style={{width:'200px', 'marginTop': '30px'}}
            label="Connect to my Data!" />
          <p className="App-intro">
          {token} 
          </p>
        </div>
        <div className="App-footer">
        </div>
      </div>
    );
  }
}

export default App;
