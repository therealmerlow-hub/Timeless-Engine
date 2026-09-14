package mikolka.vslice.ui;

import mikolka.vslice.ui.mainmenu.DesktopMenuState;
import mikolka.compatibility.ui.MainMenuHooks;
import mikolka.compatibility.VsliceOptions;
import mikolka.vslice.ui.title.TitleState;
import mikolka.compatibility.ModsHelper;
import options.OptionsState;

class MainMenuState extends MusicBeatState
{
	public var cheatBuffer:String = "";

	#if !LEGACY_PSYCH
	public static var psychEngineVersion:String = '0.0.4'; // This is also used for Discord RPC
	#else
	public static var psychEngineVersion:String = '0.0.4'; // This is also used for Discord RPC
	#end
	public static var pSliceVersion:String = '0.0.4';
	public static var funkinVersion:String = '0.7.6'; // Version of funkin' we are emulationg

	var bg:FlxSprite;
	var magenta:FlxSprite;

	var stickerSubState:Bool;

	public function new(?stickers:Bool = false)
	{
		super();
		stickerSubState = stickers;
		
	}

	override function create()
	{
		cheatBuffer = "";
		if (!backend.ClientPrefs.data.corruptionCheat) {
				backend.ClientPrefs.data.corruptionCheat = false;
		}

		if(stickerSubState) ModsHelper.clearStoredWithoutStickers();
		else CacheSystem.clearStoredMemory();
		CacheSystem.clearUnusedMemory();
		#if (debug && !LEGACY_PSYCH)
		FlxG.console.registerFunction("dumpCache",CacheSystem.cacheStatus); 
		FlxG.console.registerFunction("dumpSystem",backend.Native.buildSystemInfo);
		#end
		
		ModsHelper.resetActiveMods();

		#if DISCORD_ALLOWED
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Main Menu", null);
		#end

		persistentUpdate = persistentDraw = true;

		bg = new FlxSprite(-80);
		if (backend.ClientPrefs.data.timelessMenuBG) {
				bg.loadGraphic(Paths.image('TimelessBG'));
		} else {
				bg.loadGraphic(Paths.image('menuBG'));
		}
		bg.antialiasing = VsliceOptions.ANTIALIASING;
		bg.setGraphicSize(Std.int(bg.width * 1.175));
		bg.updateHitbox();
		bg.screenCenter();
		add(bg);

		magenta = new FlxSprite(-80);
		if (backend.ClientPrefs.data.timelessMenuBG) {
				magenta.loadGraphic(Paths.image('TimelessBG'));
		} else {
				magenta.loadGraphic(Paths.image('menuDesat'));
		}
		magenta.antialiasing = VsliceOptions.ANTIALIASING;
		magenta.setGraphicSize(Std.int(magenta.width * 1.175));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.color = 0xFFFD719B;
		add(magenta);

		var psychVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, "Timeless Engine " + psychEngineVersion, 12);
		var fnfVer:FlxText = new FlxText(0, FlxG.height - 18, FlxG.width, 'v${funkinVersion} (V-slice ${pSliceVersion})', 12);

		psychVer.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		psychVer.scrollFactor.set();
		fnfVer.scrollFactor.set();
		add(psychVer);
		add(fnfVer);

		#if ACHIEVEMENTS_ALLOWED
		// Unlocks "Freaky on a Friday Night" achievement if it's a Friday and between 18:00 PM and 23:59 PM
		var leDate = Date.now();
		if (leDate.getDay() == 5 && leDate.getHours() >= 18)
			MainMenuHooks.unlockFriday();

		#if MODS_ALLOWED
		MainMenuHooks.reloadAchievements();
		#end
		#end

		super.create();
		#if TOUCH_CONTROLS_ALLOWED
		if (controls.mobileC)
			new mobile.states.MobileMenuState(this);
		else
		#end
		new DesktopMenuState(this);
		
	}

	function goToOptions()
	{
		MusicBeatState.switchState(new OptionsState());
		#if !LEGACY_PSYCH OptionsState.onPlayState = false; #end
		if (PlayState.SONG != null)
		{
			PlayState.SONG.arrowSkin = null;
			PlayState.SONG.splashSkin = null;
			#if !LEGACY_PSYCH PlayState.stageUI = 'normal'; #end
		}
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ANY) {
				for (key in flixel.input.keyboard.FlxKey.fromStringMap.keys()) {
						if (FlxG.keys.checkStatus(flixel.input.keyboard.FlxKey.fromStringMap.get(key), JUST_PRESSED)) {
								var lastKey:String = key.toLowerCase();
								if (lastKey.length == 1) {
										cheatBuffer += lastKey;
						
										if (cheatBuffer.length > 20) 
												cheatBuffer = cheatBuffer.substring(cheatBuffer.length - 20);
						
										if (cheatBuffer.indexOf("corruption") != -1) {
												cheatBuffer = "";
												if (!backend.ClientPrefs.data.corruptionCheat) {
														backend.ClientPrefs.data.corruptionCheat = true;
														FlxG.camera.flash(0xFF9900FF, 0.5);
														FlxG.sound.play(Paths.sound('glitchhit'), 1.0);
														if (bg != null) bg.loadGraphic(Paths.image('corruptedBG'));
														if (magenta != null) magenta.loadGraphic(Paths.image('corruptedBG'));
														if (FlxG.sound.music != null) FlxG.sound.music.stop();
														FlxG.sound.playMusic(Paths.music('CorruptedMenu'), 0.8, true);
												}
										}
					
										if (cheatBuffer.indexOf("uncorrupt") != -1) {
												cheatBuffer = "";
												if (backend.ClientPrefs.data.corruptionCheat) {
														backend.ClientPrefs.data.corruptionCheat = false;
														FlxG.camera.flash(0xFFFFFFFF, 0.5);
														FlxG.sound.play(Paths.sound('glitchhit'), 2.0);
														if (backend.ClientPrefs.data.timelessMenuBG) {
																if (bg != null) bg.loadGraphic(Paths.image('TimelessBG'));
																if (magenta != null) magenta.loadGraphic(Paths.image('TimelessBG'));
														} else {
																if (bg != null) bg.loadGraphic(Paths.image('menuBG'));
																if (magenta != null) magenta.loadGraphic(Paths.image('menuDesat'));
														}
														if (FlxG.sound.music != null) FlxG.sound.music.stop();
														FlxG.sound.playMusic(Paths.music('FreakyMenu'), 0.8, true);
												}
										}
								}
						}
				}
		}



		if (FlxG.sound.music.volume < 0.8)
			FlxG.sound.music.volume += 0.5 * elapsed;
		super.update(elapsed);
	}
}
