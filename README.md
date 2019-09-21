# Fractal-Music-Generator
Musescore 2.0 plugin: Fractal Music Generator using L-Systems

 I created this as a compositional tool, and the rule set can be changed to generate different melodies. The rule set I used is one that is usually used in visual art to generate Koch curves, rules : (F ? F+F-F-F+F).

For my program melody generator interprets each “F” as a note and each “+” or “-” as going up or down a pitch. I set my start note to “C4”, confined the melody to only move up and down the C pentatonic scale and created the score below using the Koch curve ruleset as seen above. It can technically go on forever, so I limited the score to 51 measures and the note output to 300 some notes which can also be changed. The rule set can be changed by changing 'therules' array.

To get this working right away just download musescore and open their 'plugin creator' under Plugins in the top menu bar. Then load in the qml file and run!

