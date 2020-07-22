import numpy as np
import rasterio as rio

classnames = {
    0: "None",
    1: "Woodland",
    2: "Arable",
    3: "Grassland",
    4: "Freshwater",
    5: "Built-up areas",
    6: "Other"
}

path = "data/FILECOPY_1/temp/07b6e5e9-b766-48e5-a28c-5b3e35abecc0/LCC_GB_1990_to_2015.tif"
with rio.open(path) as landcover:
    # print(landcover.bounds)
    # print(landcover.meta)
    # print(landcover.count)

    # Band 1 is for 1990, band 2 for 2015
    band1 = landcover.read(1)
    band2 = landcover.read(2)

    # Pack into a single uint8 field, so we can count all transitions
    bands = (band1 << 4) + band2
    vals, counts = np.unique(bands, return_counts=True)

    # Write as CSV
    print("class_1990,class_2015,sqkm")
    for val, count in zip(vals, counts):
        class_1990 = classnames[val >> 4]
        class_2015 = classnames[val & 0xF]
        if class_1990 == "None" or class_2015 == "None":
            continue
        sqkm = count // 1600 # each pixel is 25m by 25m
        print(f"{class_1990},{class_2015},{sqkm}")
