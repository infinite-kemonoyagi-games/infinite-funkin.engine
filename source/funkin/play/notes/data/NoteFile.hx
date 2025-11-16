package funkin.play.notes.data;

import funkin.utils.AnimationBaseFile;
import funkin.utils.AnimationFile;
import funkin.utils.PointsObject;

typedef NoteFile = 
{
    var name:String;
    var size:PointsObject;
    var spriteType:AnimationBaseFile;
    var notes:Array<NoteData>;
}

typedef NoteData =
{
    var note:String;
    var animations:Array<AnimationFile>;
}
