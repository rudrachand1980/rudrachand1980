/* eslint-disable  func-names */
/* eslint quote-props: ["error", "consistent"]*/

'use strict';
const Alexa = require('alexa-sdk');
const AWS = require('aws-sdk');
const req = require('request-promise');
const parser = require('xml2json-light');
const docClient = new AWS.DynamoDB.DocumentClient();
const tableauServ = 'https://10ay.online.tableau.com/api/3.1';
const APP_ID = "amzn1.ask.skill.50931c03-31cd-4690-9282-27e6344ec057";
const table = 'tableauData';

const SKILL_NAME = 'Talking Tableau';
const WELCOME_MESSAGE = 'Welcome to Talking Tableau! What may I help you with';
const HELP_MESSAGE = 'Something went wrong. Please try again.';
const HELP_REPROMPT = 'What can I help you with';
const STOP_MESSAGE = 'Goodbye!';

var myRequest = "";
var say = "";
var repromptSpeech = "";
var speechOutput = "";


const handlers = {
    'LaunchRequest': function () {
        return login()
        .then(()=>{
            this.emit('Welcome');
            console.log('Login Successful!');
        })
        .catch(err =>{
            console.log('Error' + err);
        });

        // let params =  {
        //     TableName: table,
        //     Item: {
        //         id: '1',
        //         datetime: '1',
        //         siteId: '1',
        //         tokenId: '1',
        //     }
        // };
        // // console.log(params);
        // return docClient.put(params, function(err, data) {
        //     if (err) {
        //       console.log("Error", err);
        //     } else {
        //         this.emit('Welcome');
        //       console.log("Success", data);
        //     }
        //   });
        
    },
    'Welcome': function() {
        say = WELCOME_MESSAGE;
        
        this.response.speak(say).listen(say);
        this.emit(':responseReady');
    },
    'CustomerProfitCount': function () {
        
        var type = this.event.request.intent.slots.Type.value;
        var viewURL = '/9b307d58-f92b-4edf-bdc6-7a465137a918/data';
            
        // console.log(this.event.request.intent.slots.Type.value.resolutions.resolutionsPerAuthority[0].values);
        // say = 'Working on it!';
        // this.response.speak(say).listen();
        // this.emit(':responseReady'); 
        reports(viewURL)
        .then( result => {
            // console.log('Inside Funtion');
            // console.log(result);
            var myResult = 0, countLow = 0, countHigh = 0;
            var arr1 = result.split("\n");
            for(var value in arr1)
            {
                var arr = arr1[value].split(",");
                // console.log(arr);
                
                if(arr[1] && value >= 1)
                {
                    myResult = arr[1].replace(/(")+/g, '');
                    myResult = myResult.replace(/(\$)+/g, '');
                    console.log(myResult);
                    if(myResult > 0)
                        countHigh++;
                    else
                        countLow++;
                }
            }
            console.log(countHigh + ' ' + countLow);
            if(type === "profit" || type === "profiting"){
                say = "Total number of profiting customer are " + countHigh +".";
            }
            else{
                say = "Total number of customer under loss are " + countLow +".";
            }
            this.response.speak(say).listen();
            this.emit(':responseReady'); 
            return (result);
        })
        .catch(err =>{
            console.log('Error' + err);
        });
    },
    'RegionWiseReport': function () {
        var regionName = this.event.request.intent.slots.regionName.value;
        var measure = this.event.request.intent.slots.measure.value;
        var requestData = [{
            region: regionName,
            measure: measure.toLowerCase()
        }];
        // console.log(requestData);
        var viewURL = '/840f8db8-5314-4408-ab89-9f0839b7ff31/data?vf_Region=' + requestData[0].region;
            
        console.log(viewURL);
        // say = 'Working on it: ' + regionName + ' ' + measure;
        // this.response.speak(say).listen();
        // this.emit(':responseReady'); 
        reports(viewURL)
        .then( result => {
            // console.log('Inside Funtion');
            // console.log(result);
            var myResult = [];
            var arr1 = result.split("\n");
            for(var value in arr1)
            {
                var arr = arr1[value].split(",");
                // console.log(arr);
                if(arr[0].toLowerCase() == requestData[0].measure)
                {
                    console.log('Inside the if');
                    console.log(arr);
                    myResult[0] = arr[2] + '' + arr[3] + '' + arr[4];
                }

            }
            if(myResult.length > 0 || myResult !== 'undefined' || myResult !== NULL)
            {
                console.log(myResult);
                var data = [];
                for (var value in myResult)
                {
                    data[value] = myResult[value].replace(/(")+/g, '');
                    data[value] = data[value].replace(/['\r']+/g, '');
                    data[value] = data[value].replace("undefined", '');
                    data[value] = Math.round(data[value]);
                }
                console.log(data);
                if(requestData[0].measure === 'profit')
                    say = 'Total profit achieved in ' + requestData[0].region + ' region is $' + data[0] + '.';
                else if(requestData[0].measure === 'sales')
                    say = 'Total sales achieved in '  + requestData[0].region + ' region is $' +
                    data[0] + '.';
                else
                    say = 'Total quantity sold in ' + requestData[0].region + ' is ' + data[0] + '.';
            }
            else
            {
                say = 'No line item found! Please try again with valid inputs.';
            }
            // agent.add(`Coming Soon`);
            
            this.response.speak(say).listen();
            this.emit(':responseReady'); 
            return (result);
        })
        .catch(err =>{
            console.log('Error' + err);
        });
    },
    'SegmentSubcategoryReport': function () {
        var segment = this.event.request.intent.slots.segment.value;
        var subcategory = this.event.request.intent.slots.subcategory.value;
        var measure = this.event.request.intent.slots.measure.value;
        var requestData = [{
            segment: segment,
            subcategory: subcategory,
            measure: measure
        }];
        // console.log(requestData);
        var viewURL = '/43f29d49-2686-4cc1-9887-03a38b068dac/data?vf_Segment=' + requestData[0].segment + '&vf_Sub-Category=' + requestData[0].subcategory;
        console.log(viewURL);

        reports(viewURL)
        .then( result => {
            // console.log('Inside Funtion');
            // console.log(result);
            var myResult = [];
            var arr1 = result.split("\n");
            for(var value in arr1)
            {
                var arr = arr1[value].split(",");
                // console.log(arr);
                if(arr[0].toLowerCase() == requestData[0].measure.toLowerCase())
                {
                    // console.log('Inside the if');
                    console.log(arr);
                    myResult[0] = arr[3] + '' + arr[4];
                }
            }
            if(myResult.length > 0 || myResult !== 'undefined' || myResult !== NULL)
            {
                console.log(myResult);
                var data = [];
                for (var value in myResult)
                {
                    data[value] = myResult[value].replace(/(")+/g, '');
                    data[value] = data[value].replace(/['\r']+/g, '');
                    data[value] = data[value].replace("undefined", '');
                    data[value] = Math.round(data[value]);
                }
                console.log(data);
                // if(requestData[0].measure == 'quantity')
                //     say = data[0] + ' units of ' + requestData[0].subcategory + ' was sold in the ' + requestData[0].segment + ' segment.';
                if(requestData[0].measure == 'profit') {
                    if(data[0] > 0) {
                        say = 'A profit of $' + data[0] + ' has been achieved.';
                    } else {
                        say = 'There has been a loss of $' + data[0] + '.';
                    }
                } else if (requestData[0].measure == 'sales'){
                    say = 'Total sales of ' + requestData[0].subcategory + ' achieved in ' + requestData[0].segment + ' segment is $' + data[0] + '.';                    
                }
                else
                    say = data[0] + ' units of ' + requestData[0].subcategory + ' was sold in the ' + requestData[0].segment + ' segment.';
            }
            else
            {
                say = 'No line item found! Please try again with valid inputs.';
            }
            // agent.add(`Coming Soon`);
            
            this.response.speak(say).listen();
            this.emit(':responseReady'); 
            return (result);
        })
        .catch(err =>{
            console.log('Error' + err);
        });
    },
    'AMAZON.HelpIntent': function () {
        // const speechOutput = this.t('HELP_MESSAGE');
        // say = HELP_MESSAGE;
        const reprompt = HELP_MESSAGE;
        this.emit(':ask', reprompt);
    },
    'AMAZON.CancelIntent': function () {
        say = STOP_MESSAGE;
        this.emit(':tell', say);
    },
    'AMAZON.StopIntent': function () {
        say = STOP_MESSAGE;
        this.emit(':tell', say);
    },
    'Unhandled': function() {
        say = HELP_MESSAGE;
	this.emit(':ask', say, say);
    },
};

exports.handler = function (event, context) {
    const alexa = Alexa.handler(event, context);
    alexa.APP_ID = APP_ID;
    alexa.registerHandlers(handlers);
    alexa.execute();
};

function login() {
    var url = tableauServ + '/auth/signin';
    // console.log(url);
    var options = { 
        method: 'POST',
        url: url,
        headers: 
        { 
            'content-type': 'application/x-www-form-urlencoded'
        },
        body: '<tsRequest><credentials name="rudrachand.isb@gmail.com" password="rudra1980!!" ><site contentUrl="rudranarayanchand" /></credentials></tsRequest>'
    };

    // console.log(options);
    return req(options).promise()
    .then(body => {
        // if (error) throw new Error(error);
        // console.log("XML: " + body);
        var jsonData = parser.xml2json(body);
        // console.log("JSON");
        // console.log(JSON.stringify(jsonData));
        let data = JSON.stringify(jsonData);
        // console.log(data);
        var res = JSON.parse(data);

        const params = {
            TableName: table,
            Key:{
                id: "4",
            },
            UpdateExpression: "set tokenId=:t, siteId=:s",
            ExpressionAttributeValues:{
                ":t":res.tsResponse.credentials.token,
                ":s":res.tsResponse.credentials.site.id
            },
            ReturnValues:"UPDATED_NEW"
        };
    
        // console.log('Attempting to add expense', params);  
          
        return docClient.update(params).promise()
        .then(data => {
            // console.log('Token saved: ', params);
            return params;
        })
        .catch(err => {
            console.error(err);
        });
    });
}

function reports(viewURL) {
    // var myData = [];
    var params = {
        TableName: table,
        Key:{
            id: "4",
        }
    };
    return docClient.get(params).promise()
    .then(data =>{
        var token = data.Item.tokenId;
        var siteId = data.Item.siteId;
        var url = tableauServ + '/sites/' + siteId + '/views' + viewURL;
        // console.log(url);
        var options = { 
            method: 'GET',
            url: url,
            headers: 
            { 
                'x-tableau-auth': token
            }
        };
        console.log(options);
        return req(options, function (error, response, body) {
            var result = [];
            if (error) //throw new Error(error);
            {
                console.log(error);
            }
            result = body;
            // console.log('Inside request');
            // console.log(result);
            return (result);
        }); 
    })
    .catch(err=> {
        console.log('Error in report fetch!');
    });
    // .catch(errorObject => {
    //     console.log("The read failed in reports: ");
    //     // console.log(errorObject);
    //     var errorCode = JSON.stringify(errorObject.statusCode);
    //     console.log(errorCode);
    //     if(errorCode == '401' || errorCode == '403')
    //     {
    //         console.log('Login initialted!');
    //         // login();
    //     }
    // });
}