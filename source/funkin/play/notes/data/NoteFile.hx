package funkin.play.notes.data;

import funkin.utils.AnimationFile;
import funkin.utils.AnimationStructure;

typedef NoteFile = AnimationBasic & 
{
    var notes:Array<NoteData>;
}

typedef NoteData =
{
    var note:String;
    var animations:Array<AnimationFile>;
}
