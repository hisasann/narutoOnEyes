var express = require('express');
var app = express();
var http = require('http')

app.use(express.static(__dirname + '/public'));

app.get('/detect', function (req, res) {
//  res.send('hello world');
  console.log(req.query.image);

  var url ='http://rekognition.com/func/api/?';
  var params = ['api_key=hogehoge',
              'api_secret=foofoo',
              'jobs=face_part_aggressive&',
              'urls=', req.query.image].join('')
  var data = undefined;

  http.get(url + params, function(data){
    var body = '';
    data.setEncoding('utf8');

    data.on('data', function(chunk){
      body += chunk;
    });

    data.on('end', function(data){
      var ret = JSON.parse(body);
      console.log(ret);

      // response
      res.send(ret);
    });
  }).on('error', function(e){
    console.log(e.message);
  });
});

var PORT = 3000;
console.log('listen: ', PORT);
app.listen(process.env.PORT || PORT);
//app.listen(PORT);
