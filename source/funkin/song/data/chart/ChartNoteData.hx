package funkin.song.data.chart;

typedef ChartNoteData = 
{
    var position:Float;

    var name:String;
    var character:String;
    var length:Float;

    var ?sustainAnimation:Null<SustainAnimation>;

    var alt:Bool;
    var data:String;
    var skin:String;

    var ?speed:Null<Float>;
    var ?speedMode:Null<NoteSpeedMode>;
}

enum abstract SustainAnimation(String) from String to String
{
    public inline final none = "none";
    public inline final loop = "loop";
    public inline final steps = "steps";
    public inline final beats = "beats";
}

enum abstract NoteSpeedMode(String) from String to String
{
    public inline var constant = 'constant';
    public inline var mult = 'mult';
}
