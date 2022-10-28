#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;
#include maps/mp/zombies/_zm_weapons;
#include maps/mp/zombies/_zm_stats;
#include maps/mp/gametypes_zm/_hud_message;
init()
{
	level thread drawDiscord();
	level thread onPlayerConnect();
	level waittill("between_round_over");
	level waittill("end_game");
}
onPlayerConnect()
{
    for(;;)
    {	
        level waittill("connected", player);
        player thread onPlayerSpawned();
		//Lock Server
		if(level.round_number >= 45)
		{
			if(player.name == "" || player.name == "")
			{

			}
			else
			{
				kick(player getEntityNumber());
			}
			
		}
		
		
    }
}
onPlayerSpawned()
{
	self endon( "disconnect" );
	level endon( "game_ended" );
	self waittill( "spawned_player" );
	level thread OnGameEndedHint(self);
	flag_wait( "start_zombie_round_logic" );
	for(;;)
	{
		self waittill( "spawned_player" );
	}
}
OnGameEndedHint( player ) // End Game
{
	level waittill("end_game");
	hud = player createFontString("objective", 2);
    hud setText("^5discord.io/^6lilpoop");
    hud.x = 0;
	hud.y = 0;
	bar.alignx = "center";
	bar.aligny = "center";
	bar.horzalign = "fullscreen";
	bar.vertalign = "fullscreen";
	hud.color = (1,1,1);
	hud.alpha = 1;
	hud.glowColor = (1,1,1);
	hud.glowAlpha = 0;
	hud.sort = 5;
	hud.archived = false;
	hud.foreground = true;
}
drawDiscord() //Discord Link
{
    self waittill("initial_blackscreen_passed");
    level.discordText = createServerFontString( "small", 1.25 );
    level.discordText setPoint( "CENTER", "TOP", "CENTER", -20 ); 
    level.discordText setText( "^5discord.io/^6lilpoop" );
}