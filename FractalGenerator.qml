import QtQuick 2.1
import MuseScore 1.0

MuseScore {

      version:  "2.0"
      description: "Create L-System score."
      menuPath: "Plugins.random"

      // Interpret an L-system
      function lindenmayer(s, therules) {
            var outputstring = ''; // start a blank output string

            // iterate through 'therules' looking for symbol matches:
            for (var i = 0; i < s.length; i++) {
                  var ismatch = 0; // by default, no match
                  for (var j = 0; j < therules.length; j++) {
                        if (s[i] == therules[j][0])  {
                        outputstring += therules[j][1]; // write substitution
                        ismatch = 1; // we have a match, so don't copy over symbol
                        break; // get out if the for() loop
                  }
            }
            // if nothing matches, just copy the symbol over.
            if (ismatch == 0) outputstring+= s[i];
            }

            return outputstring; // send out the modified string
      }

      function setCurrentPitch(currentPitch) {
             var newPitch = currentPitch;
             getCurrentPitch(newPitch);
      }
      function getCurrentPitch(currentPitch) {
            if (currentPitch == null){ // add note
                  currentPitch = 72;
                  return currentPitch;

            } else {  
             return currentPitch;
            }
      }


      onRun: {
            var measures    = 38;
            var numerator   = 3;
            var denominator = 4;
            //var currentPitch  = 72; // start with C5
            var notes = [60,62,64,67,69,72,74,76,79,81]//pentatonic C scale
            var currentPitch = 5;//setting where to start in note array
                  
            // Initializing a L-System that produces the Koch-curve
            var thestring = 'F'; // "axiom" or start of the string
            var numloops = 3; // how many iterations to pre-compute
            var therules = []; // array for rules
            therules[0] = ['F', 'F+F-F-F+F']; // first rule, based on Koch Curve
            var whereinstring = 0; // where in the L-system are we?

            //Score Setup
            var score = newScore("Fractal.mscz", "piano", measures);
            score.addText("title", "Fractal Melodies");
            score.addText("subtitle", "L-System");

            var cursor = score.newCursor();
            cursor.track = 0;

            cursor.rewind(0);

            var ts = newElement(Element.TIMESIG);
            ts.setSig(numerator, denominator);
            cursor.add(ts);

            cursor.rewind(0);
            cursor.setDuration(1, denominator);

            //var realMeasures = Math.floor((measures + numerator - 1) / numerator);
            //console.log(realMeasures);
            //var notes = realMeasures * numerator;

            // COMPUTE THE L-SYSTEM
            for (var i = 0; i < numloops; i++) {
                  thestring = lindenmayer(thestring, therules);
                  console.log(thestring); //debug F output  
            }

            //Write out the generated melody
            for(var n=0; n < 88; n++) {
                 
                  var k = thestring[whereinstring];
                  cursor.setDuration(1, 4); //make all quarter notes
            
                  if (k=='F') { // add note
                        cursor.addNote(notes[currentPitch]);
                        console.log("F: " + currentPitch);
                  } else if (k == '+') {
                        currentPitch++; // up a note
                        console.log("F+1: " + currentPitch);
                  } else if (k == '-') {
                        currentPitch--; // down a note
                        console.log("F-1: " + currentPitch);
                  }

                  //cursor.next(); // goes to next measure
                  setCurrentPitch(currentPitch);

                  // increment the point for where we're reading the string.
                  // wrap around at the end.
                  whereinstring++;

                  if (whereinstring > thestring.length-1){
                        whereinstring = 0;
                  }
            }

            Qt.quit();
      }
}