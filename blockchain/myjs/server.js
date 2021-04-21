var query = require("./queryExport.js");
var queryPrice = require("./queryPrice.js");
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

app.get('/queryPrice', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/queryPrice.html", "utf-8", function (e, data) {
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

app.get('/buy', function (request, response) {
  response.writeHead(200, { "Content-Type": "text/html" });
  fs.readFile("html/buy.html", "utf-8", function (e, data) {
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

app.post('/queryPrice', function (request, response) {
  T_arrive = request.body.T_arrive;
  T_leave = request.body.T_leave;
  queryPrice.queryPrice(T_arrive, T_leave).then((result) => {
    response.writeHead(200, { 'Content-Type': 'application/json' });
    response.write(result);
    response.end();
  });
});

app.post('/invoke', function (request, response) {
  func = request.body.func
  console.log(func)
  if (func == 'buy') { // to create new co
    ID_CO = request.body.ID_CO;
    ID_car = request.body.ID_car;
    ID_cs = request.body.ID_cs;
    T_arrive = request.body.T_arrive;
    T_leave = request.body.T_leave;
    invoke.invokecc(func, [ID_CO, ID_car, ID_cs, T_arrive, T_leave]).then((result) => {
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
  } else if (func == 'confirm') {
    ID_CO = request.body.ID_CO;
    invoke.invokecc(func, [ID_CO]).then((result) => {
      response.writeHead(200, { 'Content-Type': 'application/json' });
      if(result == 200) response.write("Success, CO confirmed！");
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

