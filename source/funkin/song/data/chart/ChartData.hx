package funkin.song.data.chart;

import funkin.song.data.chart.ChartEventData;
import funkin.song.data.chart.ChartNoteData;

typedef ChartData = 
{
    var characters:Array<ChartCharacter>;
    var skins:Array<ChartNoteSkins>;
    var stages:Array<String>;

    var ?allowedVocals:Map<String, Bool>;
    var _allowedVocals:Dynamic;
    var allowedScore:Bool;

    var current:ChartCurrentData;

    var speed:Float;
    var notes:Array<ChartNoteData>;
    var events:Array<ChartEventData>;
}

typedef ChartCurrentData = 
{
    var player:String;
    var opponent:String;
    var girlfriend:String;

    var strumline:String;
    var notes:String;

    var stage:String;
}

typedef ChartNoteSkins =
{
    var type:ChartNoteType;
    var name:String;
}

enum abstract ChartNoteType(String) from String to String 
{
    public inline final STRUM = "strum";
    public inline final NOTE = "note";
}

typedef ChartCharacter =
{
    var type:ChartCharacterType;
    var name:String;
}

enum abstract ChartCharacterType(String) from String
{
    var PLAYER = "player";
    var OPPONENT = "opponent";
    var GIRLFRIEND = "girlfriend";
}
