package funkin.utils;

final class FunkinStringUtils
{
    /**
     * 0 -> 0.00
     */
    public static function formatDecimals(num:Float, precision:Int):String
    {
        num = MathUtils.floorDecimal(num, precision);
        var result:String = '$num';
        for (i in 0...precision)
        {
            final value:Float = num * Math.pow(10, i + 1);
            if (i == 0) result += ".";
            if (value - Math.floor(value) == 0) result += "0";
        }
        return result;
    }
}