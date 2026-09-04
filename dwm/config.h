/* See LICENSE file for copyright and license details. */

#include <X11/XF86keysym.h>

/* appearance */
static const unsigned int borderpx  = 1;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray follows selected monitor, >0: pin systray to monitor X */
static const unsigned int systrayonleft = 0;    /* 0: systray in the right corner, >0: systray on left of status text */
static const unsigned int systrayspacing = 20;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: if pinning fails, display systray on the first monitor, False: display systray on the last monitor*/
static const int showsystray        = 1;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const double activeopacity   = 0.85f;     /* Window opacity when it's focused (0 <= opacity <= 1) */
static const double inactiveopacity = 0.85f;     /* Window opacity when it's inactive (0 <= opacity <= 1) */
static const char *fonts[]          = { "CaskaydiaCove Nerd Font Propo:style=regular:size=13" };
static const char dmenufont[]       = "CaskaydiaCove Nerd Font Propo:style=medium:size=14";
static const char col_gray1[]       = "#282a36";
static const char col_gray2[]       = "#ffb86c";
static const char col_gray3[]       = "#fff";
static const char col_gray4[]       = "#000000";
static const char col_cyan[]        = "#9476c4";
static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_gray3, col_gray1, col_gray2 },
	[SchemeSel]  = { col_gray4, col_cyan,  col_cyan  },
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title   tags mask  switch  isfloat   opac 		opacun 			monitor */
	{ "firefox",  	NULL,     NULL,   1 << 0,    1,      1,      activeopacity,   inactiveopacity,	-1 },
	{ "Nemo",  		NULL,     NULL,   1 << 1,    1,      0,      activeopacity,   inactiveopacity, 	-1 },
	{ "Nautilus",  	NULL,     NULL,   1 << 1,    1,      0,      activeopacity,   inactiveopacity, 	-1 },
	{ "Files",  	NULL,     NULL,   1 << 1,    1,      0,      activeopacity,   inactiveopacity, 	-1 },
	{ "Terminal",  	NULL,     NULL,   1 << 2,    1,      0,      activeopacity,   inactiveopacity, 	-1 },
	{ "Neovim",  	NULL,     NULL,   1 << 3,    1,      0,      activeopacity,   inactiveopacity, 	-1 },
	{ "Evince",  	NULL,     NULL,   1 << 4,    1,      1,      activeopacity,   inactiveopacity, 	-1 },
	{ "Inkscape",  	NULL,     NULL,   1 << 5,    1,      0,      activeopacity,   inactiveopacity, 	-1 },
	{ "Wilson",  	NULL,     NULL,   1 << 6,    1,      0,      activeopacity,   inactiveopacity, 	-1 },
	{ "Gpick",  	NULL,     NULL,   0,         0,      1,      activeopacity,   inactiveopacity, 	-1 },
	{ "Viewnior",  	NULL,     NULL,   0,         0,      1,      activeopacity,   inactiveopacity, 	-1 },
	{ "st-256color",NULL,     NULL,   0,         0,      1,      1.0f,   		  1.0f, 	-1 },
	{ "Matplotlib", NULL,     NULL,   0,         0,      1,      1.0f,   		  1.0f, 	-1 },
	{ "Nm-connection-editor", NULL,   NULL,   0, 0,      1,      1.0f,   		  1.0f, 	-1 },
	{ "gksqt", 		NULL,     NULL,     0, 		 0,      1,      1.0f,   		  1.0f, 	-1 },
	{ "Lxappearance", NULL,   NULL,     0, 		 0,      1,      1.0f,   		  1.0f, 	-1 },
	{ "Dconf-editor", NULL,   NULL,     0, 		 0,      1,      1.0f,   		  1.0f, 	-1 },
	{ "Audacious", 	  NULL,   NULL,     0, 		 0,      1,      1.0f,   		  1.0f, 	-1 },
	{ "mpv", 	  NULL,   NULL,     0, 		 0,      1,      1.0f,   		  1.0f, 	-1 },
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */
static const int refreshrate = 120;  /* refresh rate (per second) for client move/resize */

static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* first entry is default */
	{ "><>",      NULL },    /* no layout function means floating behavior */
	{ "[M]",      monocle },
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static char dmenumon[2] = "0"; /* component of dmenucmd, manipulated in spawn() */
static const char *dmenucmd[] = { "dmenu_run", NULL };
// static const char *dmenucmd[] = { "dmenu_run", "-m", dmenumon, "-fn", dmenufont, "-nb", col_gray1, "-nf", col_gray3, "-sb", col_cyan, "-sf", col_gray4, "-l", "10", NULL };

static const Key keys[] = {
	/* modifier                     key        	function        argument */
	{ MODKEY,                       XK_a,      	spawn,          {.v = dmenucmd } },
	{ MODKEY,             			XK_t, 	   	spawn,          SHCMD("st -c Terminal") },
	{ MODKEY,             			XK_b, 	   	spawn,          SHCMD("firefox") },
	{ MODKEY,             			XK_e, 	   	spawn,          SHCMD("st -c Files yazi") },
	{ MODKEY,             			XK_s, 	   	spawn,          SHCMD("open_in_nvim") },
	{ MODKEY,             			XK_i, 	   	spawn,          SHCMD("inkscape") },
	{ MODKEY,             			XK_l, 	   	spawn,          SHCMD("i3lock -nef") },
	{ MODKEY,             			XK_p, 	   	spawn,          SHCMD("gpick -so | xclip -i -selection clipboard") },
	{ MODKEY|ShiftMask,             XK_s, 	   	spawn,          SHCMD("gnome-screenshot -i") },
	{ MODKEY,             			XK_x, 	   	spawn,          SHCMD("exitting") },
	{ MODKEY|ShiftMask,             XK_w, 	   	spawn,          SHCMD("st -c Wilson -e ssh abhirup@10.20.90.179 -t 'tmux attach'") },
	{ MODKEY|ShiftMask,             XK_p, 	   	spawn,          SHCMD("pgrep picom && killall picom || picom -b") },
	{ MODKEY,             			XK_w, 	   	spawn,          SHCMD("pgrep -af walldaemon | head -n 1 | cut -d ' ' -f1 | xargs kill -SIGCONT") },
	{ MODKEY,                       XK_Tab,    	focusstack,     {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_Tab,    	focusstack,     {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_i,      	incnmaster,     {.i = +1 } },
	{ MODKEY|ShiftMask,				XK_d,      	incnmaster,     {.i = -1 } },
	{ MODKEY,                       XK_Left,   	setmfact,       {.f = -0.05} },
	{ MODKEY,                       XK_Right,  	setmfact,       {.f = +0.05} },
	{ MODKEY,                       XK_Return, 	zoom,           {0} },
	{ MODKEY,             			XK_q,      	killclient,     {0} },
	{ MODKEY,                       XK_t,      	setlayout,      {.v = &layouts[0]} },
	{ MODKEY,                       XK_f,      	setlayout,      {.v = &layouts[1]} },
	{ MODKEY,                       XK_m,      	setlayout,      {.v = &layouts[2]} },
	{ MODKEY,                       XK_space,  	setlayout,      {0} },
	{ MODKEY|ShiftMask,             XK_space,  	togglefloating, {0} },
	{ MODKEY,                       XK_0,      	view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      	tag,            {.ui = ~0 } },
	{ MODKEY,                       XK_comma,  	focusmon,       {.i = -1 } },
	{ MODKEY,                       XK_period, 	focusmon,       {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_comma,  	tagmon,         {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_period, 	tagmon,         {.i = +1 } },
    { 0,                         	XF86XK_AudioRaiseVolume, spawn, SHCMD("pactl set-sink-volume @DEFAULT_SINK@ +5%") },
    { 0,                         	XF86XK_AudioLowerVolume, spawn, SHCMD("pactl set-sink-volume @DEFAULT_SINK@ -5%") },
    { 0,                         	XF86XK_AudioMute, spawn, SHCMD("pactl set-sink-mute @DEFAULT_SINK@ toggle") },
    { 0,                         	XF86XK_MonBrightnessUp, spawn, SHCMD("brightnessctl set +5%") },
    { 0,                         	XF86XK_MonBrightnessDown, spawn, SHCMD("brightnessctl set 5%-") },
    { MODKEY|ShiftMask,             XK_equal,      changefocusopacity,   {.f = +0.025}},
    { MODKEY|ShiftMask,             XK_minus,      changefocusopacity,   {.f = -0.025}},
	{ MODKEY|ControlMask,           XK_equal,      changeunfocusopacity, {.f = +0.025}},
    { MODKEY|ControlMask,           XK_minus,      changeunfocusopacity, {.f = -0.025}},
	TAGKEYS(                        XK_1,      	                0)
	TAGKEYS(                        XK_2,      	                1)
	TAGKEYS(                        XK_3,      	                2)
	TAGKEYS(                        XK_4,      	                3)
	TAGKEYS(                        XK_5,      	                4)
	TAGKEYS(                        XK_6,      	                5)
	TAGKEYS(                        XK_7,      	                6)
	TAGKEYS(                        XK_8,      	                7)
	TAGKEYS(                        XK_9,      	                8)
	{ MODKEY|ShiftMask,             XK_x,      	quit,           {0} },
};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};

