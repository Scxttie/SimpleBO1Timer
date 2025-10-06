#include maps\_utility;
#include common_scripts\utility;

mt_format_time(totalSec)
{
    mins = int(totalSec / 60);
    secs = totalSec - (mins * 60);

    mins_s = string(mins);
    secs_s = string(secs);

    if (mins < 10)
        mins_s = "0" + mins_s;
    if (secs < 10)
        secs_s = "0" + secs_s;

    return mins_s + ":" + secs_s;
}

mt_timer_hud()
{
    self endon("disconnect");
    self endon("death");

    wait 0.05;

    while (!isDefined(self.sessionstate) || self.sessionstate != "playing" || is_true(self.intermission))
        wait 0.05;

    wait 3.2;

    if (!isDefined(level.mt_started))
    {
        level.mt_started  = true;
        level.mt_start_ms = getTime();
    }

    if (isDefined(self.mt_value)) { self.mt_value destroy(); self.mt_value = undefined; }

    value = NewHudElem();
    value.horzAlign = "right";
    value.alignX    = "right";
    value.vertAlign = "top";
    value.alignY    = "top";
    value.x = -40;
    value.y = 20;
    value.foreground = 1;
    value.fontscale  = 8;
    value.alpha      = 1;
    value.color      = (1, 1, 1);
    self.mt_value = value;

    lastShown = -1;
    for (;;)
    {
        if (!isDefined(level.mt_start_ms))
        {
            wait 0.05;
            continue;
        }

        el_ms = getTime() - level.mt_start_ms;
        if (el_ms < 0) el_ms = 0;

        el_s = int(el_ms / 1000);
        if (el_s != lastShown)
        {
            lastShown = el_s;
            value SetText(mt_format_time(el_s));
        }

        wait 0.05;
    }
}

mt_onplayerspawned()
{
    self endon("disconnect");
    for (;;)
    {
        self waittill("spawned_player");
        self thread mt_timer_hud();
    }
}

mt_onplayerconnect()
{
    for (;;)
    {
        level waittill("connected", p);
        if (isDefined(p))
            p thread mt_onplayerspawned();
    }
}

init()
{
    if (GetDvar(#"zombiemode") != "1")
        return;

    level.mt_started  = undefined;
    level.mt_start_ms = undefined;

    level thread mt_onplayerconnect();
}
