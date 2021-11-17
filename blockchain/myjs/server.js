var queryCO = require("./queryCO.js");//queryCO
var queryTime = require("./queryTime.js");
var queryCS = require("./queryCS.js");
var queryList = require("./queryList.js");
var invoke = require("./invokeExport.js");
var express = require("express");
var fs = require("fs");
var app = express();
var bodyParser = require("body-parser")

app.use(bodyParser.urlencoded({
  extended: true
}));

app.get('/queryCO', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/queryCO.html", "utf-8", function (e, data) {
    response.write(data);
    response.end();
  });
});

app.get('/queryTime', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/queryTime.html", "utf-8", function (e, data) {
    response.write(data);
    response.end();
  });
});

app.get('/queryCS', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/queryCS.html", "utf-8", function (e, data) {
    response.write(data);
    response.end();
  });
});

app.get('/queryList', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/queryList.html", "utf-8", function (e, data) {
    response.write(data);
    response.end();
  });
});

app.get('/buyCO', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/buyCO.html", "utf-8", function (e, data) {
    response.write(data);
    response.end();
  });
});

app.get('/confirm', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/confirm.html", "utf-8", function (e, data) {
    response.write(data);
    response.end();
  });
});

app.get('/list', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/list.html", "utf-8", function (e, data) {
    response.write(data);
    response.end();
  });
});

app.get('/delist', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/delist.html", "utf-8", function (e, data) {
    response.write(data);
    response.end();
  });
});

app.post('/queryCO', function (request, response) {
  ID_CO = request.body.ID_CO;
  query.queryCO(ID_CO).then((result) => {
    response.writeHead(200, { 'Content-Type': 'application/json' });
    if (result.length == 0) {
      result = "CO not found!"
    }
    response.write(result);
    response.end();
  });
});

app.post('/queryList', function (request, response) {
  queryList.queryList().then((result) => {
    response.writeHead(200, { 'Content-Type': 'application/json' });
    if (result.length == 0) {
      result = "There is not list"
    }
    response.write(result);
    response.end();
  });
});

app.post('/queryTime', function (request, response) {
  T_charge = request.body.T_charge;
  queryTime.queryTime(T_charge).then((result) => {
    response.writeHead(200, { 'Content-Type': 'application/json' });
    response.write(result);
    response.end();
  });
});

app.post('/queryCS', function (request, response) {
  T_arrive = request.body.T_arrive;
  queryCS.queryCS(T_arrive).then((result) => {
    response.writeHead(200, { 'Content-Type': 'application/json' });
    response.write(result);
    response.end();
  });
});

app.post('/invoke', function (request, response) {
  func = request.body.func
  console.log(func)
  if (func == 'buyCO') { // to create new co
    ID_CO = request.body.ID_CO;
    ID_car = request.body.ID_car;
    CO_T = request.body.CO_T;
    T_charge = request.body.T_charge;
    invoke.invokecc(func, [ID_CO, ID_car, CO_T, T_charge]).then((result) => {
      response.writeHead(200, { 'Content-Type': 'application/json' });
      
      if(result == 200) response.write("Success, CO bought!");
      response.end();
    });
  } else if (func == 'confirm') {
    ID_CO = request.body.ID_CO;
    invoke.invokecc(func, [ID_CO]).then((result) => {
      response.writeHead(200, { 'Content-Type': 'application/json' });
      if(result == 200) response.write("Success, CO confirmed！");
      response.end();
    });
  } else if (func == 'list') {
    ID_CO = request.body.ID_CO;
    CO_price = request.body.CO_price;
    invoke.invokecc(func, [ID_CO,CO_price]).then((result) => {
      response.writeHead(200, { 'Content-Type': 'application/json' });
      if(result == 200) response.write("Success, CO listed！");
      response.end();
    });
  } else if (func == 'delist') {
    ID_CO = request.body.ID_CO;
    ID_car = request.body.ID_car;
    invoke.invokecc(func, [ID_CO,ID_car]).then((result) => {
      response.writeHead(200, { 'Content-Type': 'application/json' });
      if(result == 200) response.write("Success, CO delisted！");
      response.end();
    });
  };

});

app.listen(8080);

