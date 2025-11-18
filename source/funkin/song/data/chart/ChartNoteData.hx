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
    public inline final NONE = "NONE";
    public inline final LOOP = "LOOP";
    public inline final STEPS = "STEPS";
    public inline final BEATS = "BEATS";
}

enum abstract NoteSpeedMode(String) from String to String
{
    public inline var CONSTANT = 'constant';
    public inline var MULT = 'mult';
}
