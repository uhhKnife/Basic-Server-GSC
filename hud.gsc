#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\zombies\_zm_utility;
#include maps\mp\gametypes_zm\_hud_util;
#include maps\mp\gametypes_zm\_hud_message;

init()

{
    level thread enemy_counter_hud();
    level thread onPlayerConnect();
	level thread timer_hud();
	level thread round_timer_hud();
}

onPlayerConnect()
{
    for (;;)
    {
        level waittill("connecting", player);
        player thread onPlayerSpawned();
    }
}

onPlayerSpawned()
{
    level endon("game_ended");
    self endon("disconnect");

    for(;;)
    {
        self waittill("spawned_player");
        self thread health_bar_hud();
		self thread bleedout_bar_hud();
    }
}

health_bar_hud()
{
    self endon("disconnect");

	flag_wait( "initial_blackscreen_passed" );

	x = 5;
	y = -134;
	if (level.script == "zm_buried")
	{
		y -= 22;
	}
	else if (level.script == "zm_tomb")
	{
		y -= 20;
	}

	health_bar = self createbar((1, 1, 1), level.primaryprogressbarwidth - 10, level.primaryprogressbarheight);
	health_bar.alignx = "left";
	health_bar.bar.alignx = "left";
	health_bar.barframe.alignx = "left";
	health_bar.aligny = "middle";
	health_bar.bar.aligny = "middle";
	health_bar.barframe.aligny = "middle";
	health_bar.horzalign = "user_left";
	health_bar.bar.horzalign = "user_left";
	health_bar.barframe.horzalign = "user_left";
	health_bar.vertalign = "user_bottom";
	health_bar.bar.vertalign = "user_bottom";
	health_bar.barframe.vertalign = "user_bottom";
	health_bar.x += x;
	health_bar.bar.x += x + ((health_bar.width + 4) / 2);
	health_bar.barframe.x += x;
	health_bar.y += y;
	health_bar.bar.y += y;
	health_bar.barframe.y += y;
	health_bar.hidewheninmenu = 1;
	health_bar.bar.hidewheninmenu = 1;
	health_bar.barframe.hidewheninmenu = 1;
	health_bar.foreground = 1;
	health_bar.bar.foreground = 1;
	health_bar.barframe.foreground = 1;

	health_bar_text = createfontstring("objective", 1.2);
	health_bar_text.alignx = "left";
	health_bar_text.aligny = "middle";
	health_bar_text.horzalign = "user_left";
	health_bar_text.vertalign = "user_bottom";
	health_bar_text.x += x + health_bar.width + 7;
	health_bar_text.y += y;
	health_bar_text.hidewheninmenu = 1;
	health_bar_text.foreground = 1;

	health_bar endon("death");

	health_bar thread destroy_on_intermission();
	health_bar_text thread destroy_on_intermission();

	while (1)
	{
		if(isDefined(self.e_afterlife_corpse))
		{
			health_bar hideelem();
			health_bar_text hideelem();

			while(isDefined(self.e_afterlife_corpse))
			{
				wait 0.05;
			}

			health_bar showelem();
			health_bar_text showelem();
		}

		health_bar updatebar(self.health / self.maxhealth);
		health_bar_text setvalue(self.health);

		wait 0.05;
	}
}

enemy_counter_hud()
{
    enemy_counter_hud = newHudElem();
    enemy_counter_hud.alignx = "left";
    enemy_counter_hud.aligny = "top";
    enemy_counter_hud.horzalign = "user_left";
    enemy_counter_hud.vertalign = "user_top";
	enemy_counter_hud.x += 5;

    if (level.script == "zm_tomb")
    {
        enemy_counter_hud.y += 49;

    }
    else
    {
        enemy_counter_hud.y += 2;
    }
    enemy_counter_hud.fontscale = 1.4;
	enemy_counter_hud.alpha = 0;
	enemy_counter_hud.color = ( 1, 1, 1 );
	enemy_counter_hud.hidewheninmenu = 1;
	enemy_counter_hud.foreground = 1;
	enemy_counter_hud.label = &"Zombies Remaining:^1 ";

	enemy_counter_hud endon("death");

	enemy_counter_hud thread destroy_on_intermission();

	flag_wait( "initial_blackscreen_passed" );

	enemy_counter_hud.alpha = 1;
	while (1)
	{
		enemies = get_round_enemy_array().size + level.zombie_total;

		if (enemies == 0)
		{
			enemy_counter_hud setText("");
		}
		else
		{
			enemy_counter_hud setValue(enemies);
		}

		wait 0.05;
	}
}

bleedout_bar_hud()
{
	self endon("disconnect");

	flag_wait( "initial_blackscreen_passed" );

	if(flag("solo_game"))
	{
		return;
	}
	bleedout_bar = self createbar((1, 0, 0), level.secondaryprogressbarwidth * 2, level.secondaryprogressbarheight);
	bleedout_bar setpoint("CENTER", undefined, level.secondaryprogressbarx, -1 * level.secondaryprogressbary);
	bleedout_bar.hidewheninmenu = 1;
	bleedout_bar.bar.hidewheninmenu = 1;
	bleedout_bar.barframe.hidewheninmenu = 1;
	bleedout_bar hideelem();

	while (1)
	{
		self waittill("entering_last_stand");

		if(!self maps\mp\zombies\_zm_laststand::player_is_in_laststand())
		{
			continue;
		}

		self thread bleedout_bar_hud_updatebar(bleedout_bar);

		bleedout_bar showelem();

		self waittill_any("player_revived", "bled_out", "player_suicide");

		bleedout_bar hideelem();
	}
}

bleedout_bar_hud_updatebar(bleedout_bar)
{
	self endon("player_revived");
	self endon("bled_out");
	self endon("player_suicide");

	bleedout_time = getDvarInt("player_lastStandBleedoutTime");
	interval_time = 30;
	interval_frac = interval_time / bleedout_time;
	num_intervals = int(bleedout_time / interval_time) + 1;

	bleedout_bar updatebar(1);

	for(i = 0; i < num_intervals; i++)
	{
		time = bleedout_time;
		if(time > interval_time)
		{
			time = interval_time;
		}

		frac = 0.99 - ((i + 1) * interval_frac);

		barwidth = int((bleedout_bar.width * frac) + 0.5);
		if(barwidth < 1)
		{
			barwidth = 1;
		}

		bleedout_bar.bar scaleovertime(time, barwidth, bleedout_bar.height);

		wait time;

		bleedout_time -= time;
	}
}


destroy_on_intermission()
{
	self endon("death");

	level waittill("intermission");

	if(isDefined(self.elemtype) && self.elemtype == "bar")
	{
		self.bar destroy();
		self.barframe destroy();
	}

	self destroy();
}

timer_hud()
{
    
    flag_wait("initial_blackscreen_passed");
    timer_hud = Create_simple_hud();
    timer_hud.alignx = "right";
    timer_hud.aligny = "top";
    timer_hud.horzalign = "user_right";
    timer_hud.vertalign = "user_top";
    timer_hud.x = -5;
    timer_hud.y = 20;
    timer_hud.fontscale = 1.4;
    timer_hud.alpha = 0;
    timer_hud.color = (1, 1, 1);
    timer_hud.hidewheninmenu = 1;
    timer_hud.alpha = 1;
    timer_hud settimerup(0);
}

round_timer_hud()
{
    if(isDefined(level.scr_zm_ui_gametype_obj) && level.scr_zm_ui_gametype_obj != "zsnr")
	{
		return;
	}
	flag_wait( "initial_blackscreen_passed" );
	round_timer_hud = Create_simple_hud();
	round_timer_hud.alignx = "right";
	round_timer_hud.aligny = "top";
	round_timer_hud.horzalign = "user_right";
	round_timer_hud.vertalign = "user_top";
	round_timer_hud.x -= 5;
	round_timer_hud.y += 32;
	round_timer_hud.fontscale = 1.4;
	round_timer_hud.alpha = 0;
	round_timer_hud.color = ( 1, 1, 1 );
	round_timer_hud.hidewheninmenu = 1;
	round_timer_hud.foreground = 1;
	round_timer_hud.label = &"^3Round: ";

	round_timer_hud endon("death");

	round_timer_hud thread destroy_on_intermission();

	level thread set_time_frozen_on_end_game(round_timer_hud);

	

	round_timer_hud.alpha = 1;
	while (1)
	{
		round_timer_hud setTimerUp(0);
		round_timer_hud.start_time = int(getTime() / 1000);
		round_timer_hud.end_time = undefined;
		level waittill( "end_of_round" );
		round_timer_hud.end_time = int(getTime() / 1000);
		time = round_timer_hud.end_time - round_timer_hud.start_time;

		set_time_frozen(round_timer_hud, time);
	}
}

set_time_frozen_on_end_game(hud)
{
	level endon("intermission");

	level waittill("end_game");

	if(!isDefined(hud.end_time))
	{
		hud.end_time = int(getTime() / 1000);
	}

	time = hud.end_time - hud.start_time;

	set_time_frozen(hud, time);
}

set_time_frozen(hud, time)
{

	level endon( "start_of_round" );

	if(time != 0)
	{
		time -= .1; 
	}

	while (1)
	{
		if(time == 0)
		{
			hud setTimerUp(time);
		}
		else
		{
			hud setTimer(time);
		}

		wait 0.5;
	}
}