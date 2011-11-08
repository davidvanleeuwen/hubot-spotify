sh = require('sh')
spotify = require('spotify')

module.exports = (robot) ->
  robot.respond /spotify$/i, (msg) ->
    msg.send "play - Play the current song \npause - Pause the current song \ntoggle - Play/pause the current song \nstop - Stop current song \nnext - Play the next song from the playlist \nprev|previous - Play the previous song from the playlist \ncurrent song - Shows what song I'm currently playing \nvolume <0..9> - Change volume to a specific number between 0 (mute) and 9 \nsearch <track> - Search for a track on Spotify and play it"
  robot.respond /toggle$/i, (msg) ->
    msg.send "Okay, toggling play/pause in Spotify"
    sh('osascript -e \'tell app "Spotify" to playpause\'')
  robot.respond /play$/i, (msg) ->
    msg.send "Playing the current song in Spotify"
    sh('osascript -e \'tell app "Spotify" to playpause\'')
  robot.respond /(pause|stop)$/i, (msg) ->
    msg.send "Pausing the current song in Spotify"
    sh('osascript -e \'tell app "Spotify" to playpause\'')
  robot.respond /next$/i, (msg) ->
    sh('osascript -e \'tell app "Spotify" to next track\'')
    song = sh('osascript src/hubot/scripts/current_song.scpt')
    song.result (obj) ->
      msg.send "And now I'm playing "+ obj
  robot.respond /(previous|prev)$/i, (msg) ->
    sh('osascript -e \'tell app "Spotify" to previous track\'')
    song = sh('osascript src/hubot/scripts/current_song.scpt')
    song.result (obj) ->
      msg.send "Playing this song again: "+ obj
  robot.respond /(current|song|track|current song|current track)$/i, (msg) ->
    song = sh('osascript src/hubot/scripts/current_song.scpt')
    song.result (obj) ->
      msg.send "The current song I'm playing is "+ obj
  robot.respond /volume (\d)$/i, (msg) ->
    volume = msg.match[1]
    msg.send "Setting the volume to "+volume
    sh('osascript -e \'set volume '+volume+'\'')
  robot.respond /search (.*)$/i, (msg) ->
    query = msg.match[1]
    spotify.search
      type: "track"
      query: query
      (err, data) ->
        unless err
          song = data.tracks[0]
          if song
            sh('open '+song.href)
            msg.send "Found it, playing: “"+song.name+"” by "+song.artists[0].name+" from "+song.album.name