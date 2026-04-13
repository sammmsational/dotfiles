from onboardapis.train.de.db import ICEPortal
from onboardapis.units import kilometers, kilometers_per_hour

with ICEPortal() as train:
    print(
        f"{int(kilometers_per_hour(train.speed))} km/h"
        f" ╏ "
        f"{train.current_station.name} in "
        f"{kilometers(meters=int(train.calculate_distance(train.current_station))):.1f} km",
    )
