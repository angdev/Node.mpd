net = require 'net'
express = require 'express'

app = express()
connection = net.createConnection {port: 6600}
connection.setEncoding 'utf-8'

mpd_state = ''
data_reached = false

connection.on 'connect', ->
        console.log 'Connected'

connection.on 'data', (data)->
        console.log data
        mpd_state = data
        data_reached = true

app.get '/', (req, res) ->
        connection.write 'currentsong\n'
        0 while data_reached is false
        res.setHeader 'Content-Type', 'text/plain'
        res.setHeader 'Content-Length', mpd_state.length
        res.end mpd_state
        data_reached = false

app.listen 3000
