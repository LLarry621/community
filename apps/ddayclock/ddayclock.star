"""
Applet: DDayClock
Summary: Displays the current time of the Doomsday Clock
Description: Gets the current Doomsday Clock data from https://www.doomsdayclock.net/
Author: LLarry
"""

load("cache.star", c = "cache")
load("http.star", h = "http")
load("render.star", r = "render")
load("schema.star", s = "schema")

DDAYCLOCK_URL = "https://www.doomsdayclock.net/"

#One second is 0.1 degrees of a circle
MAX_SECONDS = 3600

#One minute is 6 degrees of a circle
MAX_MINUTES = 60

DEFAULT_CLOCK_COLOR = "#f00"

def main(config):
    degrees = -1
    clockColor = config.get("color") or DEFAULT_CLOCK_COLOR
    number = c.get("number")
    unit = c.get("unit")

    if number == None or unit == None:
        time = get_data(DDAYCLOCK_URL)
        number = time[0]
        unit = time[1]
    else:
        #Converts number into int only if it isn't None.
        number = int(number)

    if (unit.lower() == "seconds"):
        if number <= MAX_SECONDS:
            degrees = number * 0.1
    elif (unit.lower() == "minutes"):
        if number <= MAX_MINUTES:
            degrees = number * 6

    #Returns Degree Error
    #Happens if number isn't within acceptable bounds.
    if degrees == -1:
        return r.Root(
            child = r.Box(
                r.Text(
                    content = "Deg. Error",
                    font = "6x13",
                ),
            ),
        )
    else:
        #Sets the different secition colors and section degrees.
        #Needs at least three sections due to pie charts starting at the right and not the top.
        if degrees < 270:
            d1 = 270 - degrees
            c1 = "#000"
            d2 = degrees
            c2 = clockColor
            d3 = 90
            c3 = c1
        else:
            d1 = 270
            c1 = clockColor
            d2 = 90 - (degrees - 270)
            c2 = "#000"
            d3 = 90 - d2
            c3 = clockColor

        #Beginning graphical return
        return r.Root(
            r.Row(
                children = [
                    r.Column(
                        children = [
                            r.WrappedText(
                                content = "{} {} Until 12:00".format(number, unit[0:1]),
                                width = 31,
                                font = "tb-8",
                            ),
                        ],
                        main_align = "center",
                        expanded = True,
                    ),
                    r.Column(
                        children = [
                            r.Column(
                                children = [
                                    r.Circle(
                                        color = "#fff",
                                        diameter = 24,
                                        child = r.PieChart(colors = [c1, c2, c3], weights = [d1, d2, d3], diameter = 24),
                                    ),
                                ],
                                main_align = "center",
                            ),
                        ],
                        main_align = "center",
                        expanded = True,
                    ),
                ],
                main_align = "center",
                expanded = True,
            ),
        )

#Gets the clock data from the website.
#Note: It uses the non-javascript site.
def get_data(url):
    #I couldn't get the BSoup functions to properly process the html, so I used manual divides.
    #This will need to be checked the next time the DDay clock is updated to ensure it works.
    #However, the non-JS version of the website seems fairly consistent in its updates.
    time = h.get(url).body().split("<h1>")[1].split("</h1>")[0].split(" - ")[1]
    number = int(time.split(" ")[0])
    unit = time.split(" ")[1]
    c.set("number", str(number), 86400)
    c.set("unit", unit, 86400)
    return (number, unit)

#Allows you to determine UI colors
def get_schema():
    return s.Schema(
        version = "1",
        fields = [
            s.Color(
                id = "color",
                name = "Color",
                desc = "Color of the distance to midnight.",
                icon = "brush",
                default = DEFAULT_CLOCK_COLOR,
            ),
        ],
    )
