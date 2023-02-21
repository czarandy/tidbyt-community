"""
Applet: Indy Car
Summary: Indy Car Race & Standings
Description: Show Indy Car next race info and current driver standings. - F1 Next Race from AMillionAir was the original inspiration for my race apps
Author: jvivona
"""

load("cache.star", "cache")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")
load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")

VERSION = 23045

IMAGES = {
    "oval": "iVBORw0KGgoAAAANSUhEUgAAABgAAAAeCAYAAAA2Lt7lAAAACXBIWXMAAC4jAAAuIwF4pT92AAABuElEQVRIibWWu06CQRCFD4rxgoWYqC/gpTA2lFRUhpZCSh8AKnwHQ2PD6ygmhgegQRJRn0CNgmIMiXAsOL+QZfn/XQKTTIbsnJlvgb3FSGKRtuSoOwVwDeBLXtVYtJEM8xjJCkc2kAdWkWZqjyjApRp1SV6Q3CCZ1OeucuVZARmSfZLfJNOWfFq5vrRegCWSTc2wGDKJojRN1TgDciq8n1Y4NpGGtDkfQFVF5xH/EaQhyRtbPsbJfbAF4AVAD8AugJ+Ihbgu/ar07fGkbR9kAaxorUc1hzRV1WTNpA2QUrxzaB5YoE2ZCRvgRLHhAWgataGAfcVHD0BL8cAFsKP44QF4N2r/zbaKCKAPIO4BAIBfAMsAYuODrqepq/XMARugo5kkPBonVNNxAbwpJj0A24qfLoAnxUMPwJHiswsgWP8TazrEjo3aUEBdMeMBCLR1MzGPw24NwCuGh90ejP1j+wZtADUAmwDOIpoDQF7amtkcwNT7ID/DhZP3uXDiJB9UWAgBFKRpqWYhl/6AZHZan6jrsKwZdkmWOHq2lDh6tlyF9YgCLPzhFXiWw0u9K78N+1nG3bYP5mp/F5vVkadWLcYAAAAASUVORK5CYII=",
    "road": "iVBORw0KGgoAAAANSUhEUgAAAB4AAAAYCAYAAADtaU2/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABnUlEQVRIieXWv2sUQRjG8c/pqWlSWBoEg42kCFrYWNmI2GmhsTIgtgEjaqU2CoIW/qqsAhYWkliksPAvsFMrEQSFU2yNkBAtdCzuVpa9d25vL8IVPrA7y/O+M999d2Z2t5VSMg5tGwsV7V57B0fwHRNION5wrJuYwi6s4wPuZbNTSlJKz1O/bvdidcdS0LfQu5TS1ahfUfHv4J5+DlHlWxwcEJ/BXcxivhzYyhy/qYGWdQ5P/gV4CYca9pnHwlbB5zP+Y9zAi0z8ZHHRziQM0q3A62BfxbuPxYp3rLgYpeLpwHuG3RXvEl4HuVdGBe8MvA6+Bf7nwJssg1tBQu5d+ivwJjK5UWEpFyi0mfF/BF5urWyvA0cvkD365w32B17uJrMqwF+D2Fn983YZR4Pch03BxSNaxMVKbAqf8BRfcBgXgjFeNYWWwbCC05X4NK7VjLEyCri8uM7oVthEqwZ9+oYEEy+cnF7i1CjQCEx3Ty/X9HuEE0OMH22n9t9ToLle+wB7sQMb+IjrQwALdXrte92CDmANWv/dz97YwH8ARhmjTPwdskgAAAAASUVORK5CYII=",
    "street": "iVBORw0KGgoAAAANSUhEUgAAAB4AAAAYCAYAAADtaU2/AAAACXBIWXMAAC4jAAAuIwF4pT92AAABY0lEQVRIie3WsUtWURjH8Y+lmYomWJYNQoqCQ9Qg0haE/4yOgkO7k9GQk0GTBQ4uDU4ObkFD0CLUECIvRTQ0aCmI0ONwz4Xr2/WVq+Tb8P7gcJ/zPOfcL+e595zztEWEZuhKU6ingJ8gsNRg3h3cxhSO0vi3VcDtJb6r6Xm9JHYPXVhP9iFqGEH3ecHdGMeD1B/CfXxPsEEsY1K2wo/4gBfYqgIFEZG3iSjXYkS8LvQ3I2IlIgbq5m0U3nVmK0v1V7zENB5jPvk38AXPsFN5hXUqA3/CAn4kcK5XWKsb24nZZI9iDn24iVW8qwKuoluYSfYInhditUbg/2oft8Dn1VNsy771LzwsBi/6czVSf2q5rhWDl5nqsWaB32CiGeATaoFb4H+mtlRlvpdVHMPYx2fcTb5c3/ATHakfyT6xP89QTVbRPMrBu7J7dFd2wnTJirgDWVb+oMffJ13gdwVwL/Zw4xji9Z/+bRF76AAAAABJRU5ErkJggg==",
}

DEFAULTS = {
    "series": "car",
    "display": "nri",
    "timezone": "America/New_York",
    "time_24": False,
    "date_us": True,
    "api": "https://tidbyt.apis.ajcomputers.com/indy/api/{}/{}.json",
    "ttl": 1800,
    "positions": 16,
}

SIZES = {
    "regular_font": "tom-thumb",
    "datetime_font": "tb-8",
    "animation_frames": 30,
    "animation_hold_frames": 75,
    "data_box_bkg": "#000",
    "slide_duration": 99,
    "nri_data_box_width": 48,
    "drv_data_box_width": 64,
    "data_box_height": 26,
    "title_box_width": 64,
    "title_box_height": 7,
}

SERIES = {
    "car": ["NTT Indycar", "#0086bf80"],
    "nxt": ["Indy NXT Series", "#da291c80"],
}

def main(config):
    series = config.get("series", DEFAULTS["series"])
    displaytype = config.get("datadisplay", DEFAULTS["display"])
    data = json.decode(get_cachable_data(DEFAULTS["api"].format(series, displaytype)))
    if displaytype == "nri":
        displayrow = nextrace(config, data)
    else:
        displayrow = standings(config, data)

    return render.Root(
        show_full_animation = True,
        child = render.Column(
            children = [
                render.Box(
                    width = 64,
                    height = 6,
                    child = render.Text(SERIES[series][0], font = "tom-thumb"),
                    color = SERIES[series][1],
                ),
                displayrow,
            ],
        ),
    )

# ##############################################
#            Next Race  Functions
# ##############################################
def nextrace(config, data):
    timezone = config.get("$tz", DEFAULTS["timezone"])  # Utilize special timezone variable to get TZ - otherwise assume US Eastern w/DST
    date_and_time = data["start"]
    date_and_time3 = time.parse_time(date_and_time, "2006-01-02T15:04:05-0700").in_location(timezone)
    date_str = date_and_time3.format("Jan 02" if config.bool("is_us_date_format", DEFAULTS["date_us"]) else "02 Jan").title()  #current format of your current date str
    time_str = "TBD" if date_and_time.endswith("T00:00:00-0500") else date_and_time3.format("15:04 " if config.bool("is_24_hour_format", DEFAULTS["time_24"]) else "3:04pm")[:-1]
    text_color = config.get("text_color", coloropt[0].value)

    return render.Row(expanded = True, children = [
        render.Box(width = 16, height = 26, child = render.Image(src = base64.decode(IMAGES[data["type"]]), height = 24, width = 14)),
        fade_child(data["name"], data["track"], "{}\n{}\nTV: {}".format(date_str, time_str, data["tv"].upper()), text_color),
    ])

def fade_child(race, track, date_time_tv, text_color):
    # IndyNXT doesn't name their races, so we're just going to flip back & forth between track & date/time/tv
    if race == track:
        return render.Animation(
            children =
                createfadelist(track, SIZES["animation_hold_frames"], SIZES["regular_font"], text_color, SIZES["nri_data_box_width"], "center") +
                createfadelist(date_time_tv, SIZES["animation_hold_frames"], SIZES["datetime_font"], text_color, SIZES["nri_data_box_width"], "center"),
        )
    else:
        return render.Animation(
            children =
                createfadelist(race, SIZES["animation_hold_frames"], SIZES["regular_font"], text_color, SIZES["nri_data_box_width"], "center") +
                createfadelist(track, SIZES["animation_hold_frames"], SIZES["regular_font"], text_color, SIZES["nri_data_box_width"], "center") +
                createfadelist(date_time_tv, SIZES["animation_hold_frames"], SIZES["datetime_font"], text_color, SIZES["nri_data_box_width"], "center"),
        )

# ##############################################
#            Standings  Functions
# ##############################################
# we're going to display 3 marquees, 9 total data elements, 3 on each line
def standings(config, data):
    standingformat = "{}\n{}\n{}\n{}"

    text_color = config.get("text_color", coloropt[0].value)
    text = drvrtext(data)

    return render.Animation(
        children =
            createfadelist(standingformat.format(text[0], text[1], text[2], text[3]), SIZES["animation_hold_frames"], SIZES["regular_font"], text_color, SIZES["drv_data_box_width"], "right") +
            createfadelist(standingformat.format(text[4], text[5], text[6], text[7]), SIZES["animation_hold_frames"], SIZES["regular_font"], text_color, SIZES["drv_data_box_width"], "right") +
            createfadelist(standingformat.format(text[8], text[9], text[10], text[11]), SIZES["animation_hold_frames"], SIZES["regular_font"], text_color, SIZES["drv_data_box_width"], "right"),
    )

def drvrtext(data):
    text = []  # preset 4 text strings

    # layout is:   1 digit position, 10 char driver last name, 4 digit points - with spaces between values
    # loop through drivers and parse the data

    positions = len(data) if len(data) <= DEFAULTS["positions"] else DEFAULTS["positions"]

    for i in range(0, positions):
        text.append("{} {} {}".format(text_justify_trunc(2, str(data[i]["RANK"]), "right"), text_justify_trunc(9, data[i]["DRIVER"].replace(" Jr.", "").split(" ")[-1], "left"), text_justify_trunc(3, str(data[i]["TOTAL"]), "right")))

    return text

# ##############################################
#            Text Display Funcitons
# ##############################################

def createfadelist(text, cycles, text_font, text_color, data_box_width, text_align):
    alpha_values = ["00", "33", "66", "99", "CC", "FF"]
    cycle_list = []

    # this is a pure genius technique and is borrowed from @CubsAaron countdown_clock
    # need to ponder if there is a different way to do it if we want something other than grey
    # use alpha channel to fade in and out

    # go from none to full color
    for x in alpha_values:
        cycle_list.append(fadelistchildcolumn(text, text_font, text_color + x, data_box_width, text_align))
    for x in range(cycles):
        cycle_list.append(fadelistchildcolumn(text, text_font, text_color, data_box_width, text_align))

    # go from full color back to none
    for x in alpha_values[5:0]:
        cycle_list.append(fadelistchildcolumn(text, text_font, text_color + x, data_box_width, text_align))
    return cycle_list

def fadelistchildcolumn(text, font, color, data_box_width, text_align):
    return render.Column(main_align = "center", cross_align = "center", expanded = True, children = [render.WrappedText(content = text, font = font, color = color, align = text_align, width = data_box_width)])

# ##############################################
#           Schema Funcitons
# ##############################################
coloropt = [
    schema.Option(
        display = "White",
        value = "#FFFFFF",
    ),
    schema.Option(
        display = "Red",
        value = "#FF0000",
    ),
    schema.Option(
        display = "Orange",
        value = "#FFA500",
    ),
    schema.Option(
        display = "Yellow",
        value = "#FFFF00",
    ),
    schema.Option(
        display = "Green",
        value = "#008000",
    ),
    schema.Option(
        display = "Blue",
        value = "#0000FF",
    ),
    schema.Option(
        display = "Indigo",
        value = "#4B0082",
    ),
    schema.Option(
        display = "Violet",
        value = "#EE82EE",
    ),
    schema.Option(
        display = "Pink",
        value = "#FC46AA",
    ),
]

dispopt = [
    schema.Option(
        display = "Next Race",
        value = "nri",
    ),
    schema.Option(
        display = "Driver Standings",
        value = "drv",
    ),
]

def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Dropdown(
                id = "series",
                name = "Series",
                desc = "Select which series to display",
                icon = "flagCheckered",
                default = DEFAULTS["series"],
                options = [
                    schema.Option(
                        display = "NTT Indycar",
                        value = "car",
                    ),
                    schema.Option(
                        display = "Indycar NXT Series",
                        value = "nxt",
                    ),
                ],
            ),
            schema.Dropdown(
                id = "datadisplay",
                name = "Display Type",
                desc = "What data to display?",
                icon = "eye",
                default = "nri",
                options = dispopt,
            ),
            schema.Dropdown(
                id = "text_color",
                name = "Text Color",
                desc = "The color for Standings / Race / Track / Time text.",
                icon = "palette",
                default = coloropt[0].value,
                options = coloropt,
            ),
            schema.Generated(
                id = "nri_generated",
                source = "datadisplay",
                handler = show_nri_options,
            ),
        ],
    )

def show_nri_options(datadisplay):
    if datadisplay == "nri":
        return [
            schema.Toggle(
                id = "is_24_hour_format",
                name = "24 hour format",
                desc = "Display the time in 24 hour format.",
                icon = "clock",
                default = DEFAULTS["time_24"],
            ),
            schema.Toggle(
                id = "is_us_date_format",
                name = "US Date format",
                desc = "Display the date in US format.",
                icon = "calendarDays",
                default = DEFAULTS["date_us"],
            ),
        ]
    else:
        return []

# ##############################################
#           General Funcitons
# ##############################################
def get_cachable_data(url):
    key = url

    data = cache.get(key)
    if data != None:
        return data

    res = http.get(url = url)
    if res.status_code != 200:
        fail("request to %s failed with status code: %d - %s" % (url, res.status_code, res.body()))

    cache.set(key, res.body(), ttl_seconds = DEFAULTS["ttl"])

    return res.body()

def text_justify_trunc(length, text, direction):
    if len(text) < length:
        for _ in range(0, length - len(text)):
            text = " " + text if direction == "right" else text + " "

    else:
        # text is longer - need to trunc it
        text = text[0:length]
    return text
