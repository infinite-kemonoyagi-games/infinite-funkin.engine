package funkin.play.notes.data;

import funkin.utils.AnimationFile;

typedef NoteFile = 
{
    var name:String;
    var notes:Array<NoteData>;
}

typedef NoteData =
{
    var note:String;
    var animations:Array<AnimationFile>;
}
