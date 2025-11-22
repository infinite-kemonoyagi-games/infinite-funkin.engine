package funkin.utils;

using StringTools;

final class FunkinStringUtils
{
    /**
     * 0 -> 0.00
     */
    public static function formatDecimals(num:Float, precision:Int):String
    {
        num = MathUtils.floorDecimal(num, precision);
        var result:String = '$num';
        final hasDot = result.contains(".");
        if (!hasDot) result += ".";
        final resultSplit:Array<String> = result.split(".")[1].split("");
        if (resultSplit.length < precision || !hasDot)
        {
            final length:Int = precision - resultSplit.length + 1;
            for (_ in 0...length) result += "0";
        }
        return result;
    }
}