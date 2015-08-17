var uuid = require("uuid")
var exports = module.exports = {};

exports.Game = function() {
    this.id = uuid.v4()
    this.currentCard = 0x000000
    
    this.previousCard = function() {
        return this.currentCard - 0x000001
    }
    
    this.nextCard = function() {
        return this.currentCard + 0x000001
    }
    
    this.onLastCard = function() {
        return this.currentCard >= 0xFFFFFF
    }
}