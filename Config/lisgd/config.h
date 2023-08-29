/*
  distancethreshold: Minimum cutoff for a gestures to take effect
  degreesleniency: Offset degrees within which gesture is recognized (max=45)
  timeoutms: Maximum duration for a gesture to take place in miliseconds
  orientation: Number of 90 degree turns to shift gestures by
  verbose: 1=enabled, 0=disabled; helpful for debugging
  device: Path to the /dev/ filesystem device events should be read from
  gestures: Array of gestures; binds num of fingers / gesturetypes to commands
            Supported gestures: SwipeLR, SwipeRL, SwipeDU, SwipeUD,
                                SwipeDLUR, SwipeURDL, SwipeDRUL, SwipeULDR
*/

unsigned int distancethreshold = 125;
unsigned int distancethreshold_pressed = 60;
unsigned int degreesleniency = 15;
unsigned int timeoutms = 800;
unsigned int orientation = 0;
unsigned int verbose = 0;
double edgesizeleft = 50.0;
double edgesizetop = 50.0;
double edgesizeright = 50.0;
double edgesizebottom = 50.0;
char *device = "/dev/input/event19";
// char *device = "/dev/input/event17";
// char *device = "/dev/input/event16";

//Gestures can also be specified interactively from the command line using -g
Gesture gestures[] = {
	/* nfingers  gesturetype  command */
	// { 1,         SwipeLR,     EdgeAny, DistanceAny, ActModeReleased, "xdotool key --clearmodifiers Alt+Shift+e" },
	//{ 1,         SwipeRL,     EdgeAny, DistanceAny, ActModeReleased, "xdotool key --clearmodifiers Alt+Shift+r" },
	{ 1,         SwipeLR,     EdgeAny, DistanceAny, ActModeReleased, "hyprctl dispatch workspace -1 && notify-send prve workspace" },
	{ 1,         SwipeRL,     EdgeAny, DistanceAny, ActModeReleased, "hyprctl dispatch workspace +1 && notify-send next workspace" },
	{ 1,         SwipeDLUR,   EdgeAny, DistanceAny, ActModeReleased, "sxmo_vol.sh up" },
	{ 1,         SwipeURDL,   EdgeAny, DistanceAny, ActModeReleased, "sxmo_vol.sh down" },
	{ 1,         SwipeDRUL,   EdgeAny, DistanceAny, ActModeReleased, "sxmo_brightness.sh up" },
	{ 1,         SwipeULDR,   EdgeAny, DistanceAny, ActModeReleased, "sxmo_brightness.sh down" },
	{ 2,         SwipeLR,     EdgeAny, DistanceAny, ActModeReleased, "xdotool key --clearmodifiers Alt+e" },
	{ 2,         SwipeRL,     EdgeAny, DistanceAny, ActModeReleased, "xdotool key --clearmodifiers Alt+r" },
	{ 2,         SwipeDU,     EdgeAny, DistanceAny, ActModeReleased, "pidof $KEYBOARD || $KEYBOARD &" },
	{ 2,         SwipeUD,     EdgeAny, DistanceAny, ActModeReleased, "pkill -9 -f $KEYBOARD" },
};

