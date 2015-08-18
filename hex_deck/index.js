// MARK: Imports
var WebSocketServer = require("ws").Server
var http = require("http")
var express = require("express")
var game = require("./models/game.js")

// MARK: Properties
var app = express()
var port = process.env.PORT || 5000
var currentGame = new game.Game()

// MARK: Initialization
app.use(express.static(__dirname + "/"))

var server = http.createServer(app)
server.listen(port)
console.log("http server listening on %d", port)

var socketServer = new WebSocketServer({server: server})
console.log("websocket server created")

// MARK: Message Handlers
socketServer.sockets = []
socketServer.broadcast = function(msg) {
    socketServer.sockets.forEach(function(_socket) {
        _socket.send(msg)
    })
}

// MARK: Connection Handler
socketServer.on("connection", function(socket) {
    // MARK: Connection Response
    console.log("connection open")
    socketServer.sockets.push(socket)
    socket.send(JSON.stringify({
        event: "connection",
        game_id: currentGame.id,
        current_card: currentGame.currentCard
    }))
    
    // MARK: Event Responders
    socket.on("message", function(data) {
        console.log("message")
    
        eventInfo = JSON.parse(data)
        if (eventInfo.event == "drag_started") {
            console.log("drag started")
            socketServer.broadcast(JSON.stringify({
                event: "drag_started",
                player_id: eventInfo.player_id,
                location: eventInfo.location
            }))
        }
        
        else if (eventInfo.event == "drag_canceled") {
            console.log("drag canceled")
            socketServer.broadcast(JSON.stringify({
                event: "drag_canceled",
                player_id: eventInfo.player_id
            }))
        }
        
        else if (eventInfo.event == "drag_completed") {
            console.log("drag completed")
            currentGame.currentCard = currentGame.nextCard()
            
            socketServer.broadcast(JSON.stringify({
                event: "card_taken",
                player_id: eventInfo.player_id,
                current_card: currentGame.currentCard
            }))
        }
    })
    
    socket.on("close", function() {
        socketServer.sockets = socketServer.sockets.filter(function (_socket) {
            return _socket != socket
        })
        
        console.log("closed")
    })
})
