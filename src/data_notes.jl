"""
EPD data-quality intervals listed at <https://elfin.igpp.ucla.edu/data-notes>
The ELFIN-A sector configuration needs a modified phase delay that the L2 pitch angles do not include.
"""
const EPD_DATA_NOTES = [
    (probe = "ela", head = "e", tstart = DateTime(2020, 9, 26, 9, 22), tend = DateTime(2020, 9, 28, 8, 12),
        issue = "experimental threshold configuration: fluxes inaccurate, nothing below ~100 keV"),
    (probe = "elb", head = "e", tstart = DateTime(2020, 10, 18, 7, 35, 6), tend = DateTime(2020, 10, 19, 8, 31, 25),
        issue = "experimental threshold configuration: fluxes inaccurate, nothing below ~100 keV"),
    (probe = "elb", head = "e", tstart = DateTime(2021, 1, 27, 3, 54, 40), tend = DateTime(2021, 2, 23, 1, 56, 23),
        issue = "experimental threshold configuration: fluxes inaccurate, nothing below ~100 keV"),
    (probe = "ela", head = "e", tstart = DateTime(2021, 10, 28, 15), tend = DateTime(2021, 11, 4, 11),
        issue = "solar energetic particles: penetrating ions mimic > 400 keV electrons"),
    (probe = "elb", head = "e", tstart = DateTime(2021, 10, 28, 15), tend = DateTime(2021, 11, 4, 11),
        issue = "solar energetic particles: penetrating ions mimic > 400 keV electrons"),
    (probe = "elb", head = "e", tstart = DateTime(2021, 11, 19, 20), tend = DateTime(2021, 11, 25, 4),
        issue = "flight computer page fault: instrument in default (incorrect) state"),
    (probe = "ela", head = "e", tstart = DateTime(2022, 1, 3, 1, 10), tend = DateTime(2022, 1, 3, 1, 16),
        issue = "calibration configuration"),
    (probe = "ela", head = "e", tstart = DateTime(2022, 1, 14, 23), tend = DateTime(2022, 1, 16),
        issue = "solar energetic particles: penetrating ions mimic > 400 keV electrons"),
    (probe = "elb", head = "e", tstart = DateTime(2022, 1, 14, 23), tend = DateTime(2022, 1, 16),
        issue = "solar energetic particles: penetrating ions mimic > 400 keV electrons"),
    (probe = "ela", head = "e", tstart = DateTime(2022, 3, 15, 12, 53), tend = DateTime(2022, 5, 3, 22),
        issue = "off-nominal sector configuration: pitch angles need a modified phase delay"),
    (probe = "elb", head = "e", tstart = DateTime(2022, 5, 31), tend = DateTime(2022, 6, 14),
        issue = "flight computer page fault: instrument in default (incorrect) state"),
    (probe = "elb", head = "e", tstart = DateTime(2022, 6, 18), tend = DateTime(2022, 7, 5),
        issue = "flight computer page fault: instrument in default (incorrect) state"),
    (probe = "ela", head = "i", tstart = DateTime(2018, 9, 15), tend = DateTime(2022, 6, 29),
        issue = "ion thresholds not yet working on orbit: uncalibrated"),
    (probe = "elb", head = "i", tstart = DateTime(2018, 9, 15), tend = DateTime(2022, 7, 6),
        issue = "ion thresholds not yet working on orbit: uncalibrated"),
]

"""
    epd_data_notes(probe, t0, t1; head = "e")

Data-quality notes for `probe` and EPD `head` (`"e"` electron, `"i"` ion) that overlap `[t0, t1)`;
empty when the interval is clean.
"""
function epd_data_notes(probe, t0, t1; head = "e")
    t0, t1 = DateTime(t0), DateTime(t1)
    return filter(n -> n.probe == string(probe) && n.head == head && n.tstart < t1 && t0 < n.tend, EPD_DATA_NOTES)
end
