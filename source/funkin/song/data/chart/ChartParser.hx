package funkin.song.data.chart;

import haxe.Json;
import openfl.utils.Assets;

final class ChartParser
{
    public static function loadChart(URL:String, difficulty:String):ChartData
    {
        final file:ChartData = cast Json.parse(Assets.getText(URL + difficulty + '.fnc'));
        file.allowedVocals = [];
        for (index => x in Reflect.fields(file._allowedVocals))
        {
            file.allowedVocals.set(x, Reflect.field(file._allowedVocals, x));
        }
        return file;
    }
}