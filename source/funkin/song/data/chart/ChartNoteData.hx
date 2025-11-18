package funkin.song.data.chart;

import funkin.song.data.chart.ChartData.ChartCharacterType;

typedef ChartNoteData = 
{
    var position:Float;

    var name:String;
    var character:String;
    var type:ChartCharacterType;
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
    public inline final NONE = "none";
    public inline final LOOP = "loop";
    public inline final STEPS = "steps";
    public inline final BEATS = "beats";
}

enum abstract NoteSpeedMode(String) from String to String
{
    public inline var CONSTANT = 'constant';
    public inline var MULT = 'mult';
}
