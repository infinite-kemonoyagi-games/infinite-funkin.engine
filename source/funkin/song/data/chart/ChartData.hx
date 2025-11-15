package funkin.song.data.chart;

typedef ChartData = 
{
    var characters:Array<ChartCharacter>;
    var skins:Array<ChartNoteSkins>;
    var stages:Array<String>;

    var allowedVocals:Map<String, Bool>;
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
    public inline final strum = "strum";
    public inline final note = "note";
}

typedef ChartCharacter =
{
    var type:ChartCharacterType;
    var name:String;
}

enum abstract ChartCharacterType(String) from String
{
    var player = "player";
    var opponent = "opponent";
    var girlfriend = "girlfriend";
}
