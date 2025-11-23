import haxe.Json;
import sys.io.File;

using StringTools;

class Color
{
    public static inline var RESET = "\x1b[0m";
    public static inline var BOLD = "\x1b[1m";
    public static inline var RED = "\x1b[31m";
    public static inline var GREEN = "\x1b[32m";
    public static inline var YELLOW = "\x1b[33m";
    public static inline var BLUE = "\x1b[34m";
    public static inline var CYAN = "\x1b[36m";
    public static inline var WHITE = "\x1b[37m";
}

class SongConverter
{
    private static final letters:EReg = ~/[A-Za-z]/g;
    private static final spaces:EReg = ~/\s+/g;

    private static var path:String;

    private static var original:SwagSong;

    private static var resultChart:ChartData;
    private static var resultSong:SongMetaData;

    private static final characters:Array<ChartCharacterType> = [PLAYER, OPPONENT, GIRLFRIEND];

    private static var outputURL:String = "";
    private static var outputChart:String = "";
    private static var outputSong:String = "";

    public static function main():Void
    {
        final splitter:EReg = ~/[\/]/g;

        path = Sys.args()[0];
        if (Sys.args()[1] != null && Sys.args()[1] != "")
            outputURL = Sys.args()[1];
        else 
        {
            final directoryParts:Array<String> = splitter.split(Sys.programPath());
            final directory = Sys.programPath().replace('/${directoryParts[directoryParts.length - 1]}', '');
            outputURL = directory + "/";
        }

        final parts:Array<String> = splitter.split(path);
        final name:String = parts[parts.length - 1].split(".")[0];
        outputChart = name + "-chart.fnc";
        outputSong = name + "-meta.json";

        Sys.println(Color.BOLD + Color.CYAN + "\n=== Friday Night Funkin' Infinite Engine | Chart Convertor ===" + Color.RESET);
        initialize();
    }

    private static function initialize():Void
    {
        try 
        {
            var parsed = Json.parse(File.getContent(path));
            if (!Reflect.hasField(parsed, "song")) throw "file doesn't have `song` field.";
            original = cast parsed.song;
        } 
        catch(e) 
        {
            Sys.println(Color.RED + "[ERROR] Failed to load file:" + Color.RESET);
            Sys.println(Color.RED + Std.string(e) + Color.RESET);
            Sys.exit(1);
        }

        Sys.println(Color.BOLD + "\n--- CONVERTING SONG ---" + Color.RESET);
        Sys.println("Song name: " + Color.YELLOW + original.song + Color.RESET);

        Sys.println("\nLet's set up your new chart file\n");

        original.current = 
        {
            player: "",
            opponent: "",
            girlfriend: "",
            stage: "",
            notes: "",
            strumline: ""
        };
        original.loadedCharacters = [original.player1, original.player2];
        original.characters = [];
        original.skins = [];
        
        Sys.println(Color.BOLD + "Step 1: Set characters" + Color.RESET);

        Sys.println('Current: [${original.player1}, ${original.player2}]');
        Sys.println('');

        Sys.println("You can set characters like: bf, dad, gf, etc.");
        Sys.println("You can use %[loadedCharacters] to import original characters.");
        Sys.println("For example: %[loadedCharacters], bambi, expunged...");
        Sys.println("or you can put this in blank to import only the original characters");

        Sys.print(Color.YELLOW + "Characters > " + Color.RESET);

        // ---------------------- CHARACTERS ---------------------- //

        var input:String = Sys.stdin().readLine();
        if (input == "") input = "%[loadedCharacters]";

        var characters:Array<String> = input.split(",");
        var resultCharacters:Array<String> = [];
        for (s in characters) 
        {
            var eReg = ~/%\[(.*?)\]/g;
            s = spaces.replace(s, "");
            if (!eReg.match(s)) 
            {
                resultCharacters.push(s);
                continue;
            }
            for (a in (getVariable(original, s) : Array<String>)) resultCharacters.push(a);
        }

        // ---------------------- SETTING UP CHARACTERS ---------------------- //

        Sys.print(Color.YELLOW + "Setting up your characters > " + Color.RESET);

        var existsPlayer:Bool = false;
        var existsOpponent:Bool = false;
        var existsGirlfriend:Bool = false;

        for (character in resultCharacters)
        {
            final result:ChartCharacter = {name: "", type: ""};
            Sys.println("\nCharacter: " + Color.CYAN + character + Color.RESET);
            result.name = character;

            Sys.println("Set the type of character (player, opponent, girlfriend): ");
            var input:String = Sys.stdin().readLine();

            while (!SongConverter.characters.contains(input))
            {
                Sys.println(Color.RED + input + " is not valid." + Color.RESET);
                input = Sys.stdin().readLine();
            }
            result.type = input;

            switch result.type
            {
                case PLAYER:
                    if (!existsPlayer)
                    {
                        Sys.println(Color.YELLOW + "You want to set this character as the current player? (Y/n) " + Color.RESET);
                        var input:String = Sys.stdin().readLine().toLowerCase();
                        if (input == "y" || input == "yes" || input == "")
                        {
                            original.current.player = result.name;
                            existsPlayer = true;
                        }
                    }
                case OPPONENT:
                    if (!existsOpponent)
                    {
                        Sys.println(Color.YELLOW + "You want to set this character as the current opponent? (Y/n) " + Color.RESET);
                        var input:String = Sys.stdin().readLine().toLowerCase();
                        if (input == "y" || input == "yes" || input == "")
                        {
                            original.current.opponent = result.name;
                            existsOpponent = true;
                        }
                    }
                case GIRLFRIEND:
                    if (!existsGirlfriend)
                    {
                        Sys.println(Color.YELLOW + "You want to set this character as the current girlfriend? (Y/n) " + Color.RESET);
                        var input:String = Sys.stdin().readLine().toLowerCase();
                        if (input == "y" || input == "yes" || input == "")
                        {
                            original.current.girlfriend = result.name;
                            existsGirlfriend = true;
                        }
                    }
            }
            original.characters.push(result);
        }

        // ---------------------- END CHARACTERS ---------------------- //

        Sys.println(Color.BOLD + "Step 2: Set stage" + Color.RESET);

        Sys.println("You can set a stage like: stage, limo, mall, etc.");
        Sys.println("or you can put this in blank...");
        Sys.println("default value: stage");

        Sys.print(Color.YELLOW + "Stage > " + Color.RESET);

        // ---------------------- STAGE ---------------------- //

        var input:String = Sys.stdin().readLine();
        if (input == "") input = "stage";
        original.stage = input;
        original.current.stage = input;

        // ---------------------- END STAGE ---------------------- //

        Sys.println(Color.BOLD + "Step 3: Set note skins" + Color.RESET);

        Sys.println("You can set the notes and strumnotes skins like: funkin, pixel, etc.");
        Sys.println("this configuration is global, but each can get an individual skin");

        // ---------------------- NOTES SKINS ---------------------- //

        Sys.print(Color.YELLOW + "Note's skins (default: funkin) > " + Color.RESET);

        var input:String = Sys.stdin().readLine();
        if (input == "") input = "funkin";

        var skins:Array<String> = input.split(",");
        for (index => s in skins) 
        {
            s = spaces.replace(s, "");
            original.skins.push({name: s, type: "note"});
            if (index == 0) original.current.notes = s;
        }

        // ---------------------- STRUMLINE SKINS ---------------------- //

        Sys.print(Color.YELLOW + "Strumline's skins (default: funkin) > " + Color.RESET);

        var input:String = Sys.stdin().readLine();
        if (input == "") input = "funkin";

        var skins:Array<String> = input.split(",");
        for (index => s in skins) 
        {
            s = spaces.replace(s, "");
            original.skins.push({name: s, type: "strum"});
            if (index == 0) original.current.strumline = s;
        }

        // ---------------------- TIME SIGNATURE ---------------------- //

        Sys.println(Color.BOLD + "Step 4: Set Time signature (optional)" + Color.RESET);

        Sys.println("examples: [4, 4], [2, 4], etc.");
        Sys.println("default: 4, 4");

        Sys.print(Color.YELLOW + "Time signature > " + Color.RESET);

        var input = Sys.stdin().readLine();
        if (input == "") input = "4, 4";

        var signature:Array<Int> = [];
        var inputSplitted = input.split(",");
        for (s in inputSplitted) 
        {
            s = spaces.replace(s, "");
            signature.push(Std.parseInt(s));
        }
        original.signature = signature;

        convert();
    }

    private static function convert():Void
    {
        resultSong = 
        {
            title: original.song,
            tempo: [{data: original.bpm}],
            signature: [{data: original.signature}],
            authors: [],
        };

        resultChart =
        {
            characters: original.characters,
            speed: original.speed,
            current: original.current,
            allowedScore: original.validScore,
            _allowedVocals: [original.current.player => original.needsVoices, original.current.opponent => original.needsVoices],
            stages: [original.stage],
            skins: original.skins,
            events: [],
            notes: []
        };

        Sys.println("\n");
        Sys.print(Color.YELLOW + "Do you want to export now? (Y = yes, r = reset, c = cancel) > " + Color.RESET);
        var input = Sys.stdin().readLine().toLowerCase();
        switch input 
        {
            case "y": startCharting();
            case "r": main();
            case "c": Sys.exit(0);
            default: convert();
        }
    }

    private static function startCharting():Void
    {
        var currentTempo:Float = 0.0;
        var currentFocus:Bool = false;

        function changeTempo(section:SwagSection):Float
        {
            if (section.bpm != null && section.changeBPM == true) 
            {
                currentTempo = section.bpm;
                return section.bpm;
            } 
            else if (currentTempo > 0) return currentTempo;

            return resultSong.tempo[0].data;
        }

        function getCrochet(section:SwagSection):Float
        {
            return (60 / changeTempo(section)) * 1000;
        }

        var sectionPosition:Float = 0.0;

        for (index => section in original.notes) 
        {
            if (section.lengthInSteps != null)
                sectionPosition += (getCrochet(section) * 4) / section.lengthInSteps;
            else 
                sectionPosition += (getCrochet(section) * 4) / 4;

            if (index < 1 || currentFocus != section.mustHitSection)
            {
                var focused = section.mustHitSection ? 0 : 1;
                resultChart.events.push({
                    position: sectionPosition,
                    name: "focusCharacter",
                    values: [focused == 1 ? resultChart.current.player : resultChart.current.opponent, 0.35]
                });
                currentFocus = section.mustHitSection;
            }
            if (section.changeBPM && section.bpm != currentTempo)
            {
                resultChart.events.push({
                    position: sectionPosition,
                    name: "changeTempo",
                    values: [section.bpm]
                });
            }

            // notes
            final names:Array<String> = ["left", "down", "up", "right"];
            
            for (note in section.sectionNotes) 
            {
                var character:String = resultChart.current.player;
                var type:ChartCharacterType = PLAYER;
                if (section.mustHitSection && note[1] > 3)
                {
                    character = resultChart.current.opponent;
                    type = OPPONENT;
                }
                else if (!section.mustHitSection && note[1] < 4)
                { 
                    character = resultChart.current.opponent;
                    type = OPPONENT;
                }

                resultChart.notes.push({
                    name: names[Std.int(Math.abs(note[1] % 4))],
                    character: character,
                    type: type,
                    position: note[0],
                    length: note[2],
                    speed: null,
                    speedMode: null,
                    skin: null,
                    data: "",
                    alt: section.altAnim,
                    sustainAnimation: "steps",
                }); 
            }
        }

        resultChart.notes.sort((a:ChartNoteData, b:ChartNoteData) -> return Std.int(a.position - b.position));

        Sys.println("EXPORTED SUCCESFULLY!!");

        File.saveContent(outputURL + outputSong, Json.stringify(resultSong));
        File.saveContent(outputURL + outputChart, Json.stringify(resultChart));
    }

    public static function getVariable(data:Dynamic, s:String, ?id:EReg = null):Dynamic
    {
        var eReg = id != null ? id : ~/%\[(.*?)\]/g;
        var result = null;
        eReg.map(s, function(r)
        {
            var match2 = r.matched(1);
            result = Reflect.getProperty(data, match2);
            return r.matched(0);
        });
        return result;
    }
}

typedef SongMetaData = 
{
    var title:String;
    var authors:Array<String>;
    var tempo:Array<SongMetaEvents<Float>>;
    var signature:Array<SongMetaEvents<Array<Int>>>;
}

typedef SongMetaEvents<T> = 
{
    var ?position:Null<Float>;
    var ?step:Null<Int>;
    var ?beat:Null<Int>;
    var data:T;
}

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

typedef ChartEventData = 
{
    var position:Float;
    var name:String;
    var values:Array<Dynamic>;
}

// ORIGINAL CODE

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Int;
	var needsVoices:Bool;
	var speed:Float;

	var player1:String;
	var player2:String;
    
	var validScore:Bool;

    var ?current:ChartCurrentData; // new
    var ?loadedCharacters:Array<String>; // new
    var ?characters:Array<ChartCharacter>; // new
    var ?skins:Array<ChartNoteSkins>; // new
    var ?stage:String; // new
	var ?signature:Array<Int>; // new
}

typedef SwagSection =
{
	var sectionNotes:Array<Dynamic>;
	var ?lengthInSteps:Int;
	var ?typeOfSection:Int;
	var mustHitSection:Bool;
	var bpm:Int;
	var changeBPM:Bool;
	var altAnim:Bool;
}
