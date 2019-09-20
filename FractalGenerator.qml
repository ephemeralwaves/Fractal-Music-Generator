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

      //note to pitch
      function n2p(note, octave){
            var notenames=['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];
            var pitch=notenames.indexOf(note);
            if(pitch==-1) return -1;
            pitch+=12*(octave+1);
            //console.log('pitch: '+pitch);
            return pitch;
      }

    //adds chord at current position. chord_notes is an array with pitch of notes.
      function addChord(cursor, chord_notes, duration){ 
            if(chord_notes.length==0) return -1;
       
            var cur_time=cursor.tick;
            cursor.setDuration(1, duration);
            cursor.addNote(chord_notes[0]); //add 1st note
            var next_time=cursor.tick;
            setCursorToTime(cursor, cur_time); //rewind to this note
            var chord = cursor.element; //get the chord created when 1st note was inserted
            for(var i=1; i<chord_notes.length; i++){
                  chord.add(createNote(chord_notes[i])); //add notes to the chord
            }
            setCursorToTime(cursor, next_time);
            return 0;
      }

      function setCursorToTime(cursor, time){
            cursor.rewind(0);
            while (cursor.segment) { 
                  var current_time = cursor.tick;
                  if(current_time>=time){
                        return true;
                  }
                  cursor.next();
            }
        cursor.rewind(0);
        return false;
    }

    // create and return a new Note element with given (midi) pitch, tpc1, tpc2 and headtype
      function createNote(pitch, tpc1, tpc2, head){
            var note = newElement(Element.NOTE);
            note.pitch = pitch;
            var pitch_mod12 = pitch%12; 
            var pitch2tpc=[14,21,16,23,18,13,20,15,22,17,24,19]; //get tpc from pitch... yes there is a logic behind these numbers :-p
            if (tpc1){
                  note.tpc1 = tpc1;
                  note.tpc2 = tpc2;
            }else{
                  note.tpc1 = pitch2tpc[pitch_mod12];
                  note.tpc2 = pitch2tpc[pitch_mod12];
            }
            if (head) note.headType = head; 
            else note.headType = NoteHead.HEAD_AUTO;
            // console.log("  created note with tpc: ",note.tpc1," ",note.tpc2," pitch: ",note.pitch);
            return note;
      }

      onRun: {
            var measures    = 38;
            var numerator   = 3;
            var denominator = 4;
            var notes = [55,57,60,62,64,67,69,72,74,76,79,81,84,86,88]//pentatonic C scale
            var currentPitch = 7;//setting where to start in note array
                  
            // Initializing a L-System that produces the Koch-curve
            var thestring = 'F'; // "axiom" or start of the string
            var numloops = 4; // how many iterations to pre-compute
            var therules = []; // array for rules
            therules[0] = ['F', 'F+F-F-F+F']; // first rule, based on Koch Curve
            var whereinstring = 0; // where in the L-system are we?

            //Score Setup
            var score = newScore("Fractal.mscz", "piano", measures);
            score.addText("title", "Fractal Melodies");
            score.addText("subtitle", "Using L-Systems");

            var cursor = score.newCursor();
            cursor.track = 0;

            cursor.rewind(0);

            var ts = newElement(Element.TIMESIG);
            ts.setSig(numerator, denominator);
            cursor.add(ts);

            cursor.rewind(0);
            cursor.setDuration(1, denominator);


            // Compute L-System
            for (var i = 0; i < numloops; i++) {
                  thestring = lindenmayer(thestring, therules);
                  console.log(thestring); //debug F output  
            }

            // Write out the generated melody
            for(var n=0; n < 302; n++) {
                 
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

           // Generate notes for other staff
           var staff = 1
           cursor.track = staff * 4;
           cursor.setDuration(1, 2);
           var nMeasures= (score.nmeasures)/2;

           cursor.rewind(0); //go to the start of the score
            for(var n=0; n < nMeasures; n++) {
                  addChord(cursor, [n2p('C',3), n2p('G',3)], 1);
                  cursor.next();
                  addChord(cursor, [n2p('A',2), n2p('E',3)], 1);
                  cursor.next();
            }

            Qt.quit();
      }
}