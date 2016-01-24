// index.js
// the heart of the backend
// vhost router for api, website & static files
// =============================================================================
var connect = require('connect')
var http = require('http')
var app = connect()

app.use(require("./ink.js").app)

http.createServer(app).listen(80);
